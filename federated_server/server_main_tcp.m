function server_main_tcp(roundId)
    server = tcpserver('0.0.0.0', 30000);
    gradsCell = {};
    numUEs = 5;
    received = 0;
    receivedUEs = [];

    global decodingLog;
    if isempty(decodingLog)
        decodingLog = struct('round', [], 'ue_id', [], ...
                             'success_rate', [], 'latency_ms', [], ...
                             'baseline_success', [], 'baseline_latency', []);
    end

    disp('Server is running and waiting for UEs...');

    while received < numUEs
        if server.NumBytesAvailable > 0
            try
                raw = char(read(server, server.NumBytesAvailable, 'uint8'));
                cleanJson = raw(find(raw == '{', 1):find(raw == '}', 1, 'last'));
                packet = jsondecode(cleanJson);

                if ismember(packet.ue_id, receivedUEs)
                    warning("Duplicate packet from UE %d", packet.ue_id);
                    continue;
                end

                if ~isempty(fieldnames(packet.grads))
                    grads = decompress_metadata(packet.grads);
                    gradsCell{end+1} = grads;
                end

                decodingLog.round(end+1) = roundId;
                decodingLog.ue_id(end+1) = packet.ue_id;
                decodingLog.success_rate(end+1) = ...
                    (packet.stats.numSuccessfulDecodes / packet.stats.numAttempts) * 100;
                decodingLog.latency_ms(end+1) = packet.stats.totalDecodingTime;
                decodingLog.baseline_success(end+1) = ...
                    (packet.stats.baseline.numSuccessfulDecodes / packet.stats.baseline.numAttempts) * 100;
                decodingLog.baseline_latency(end+1) = packet.stats.baseline.totalDecodingTime;

                receivedUEs(end+1) = packet.ue_id;
                received = received + 1;
                disp("✅ Received from UE " + packet.ue_id);
            catch ME
                warning("⚠️ Skipped malformed packet: %s", ME.message);
            end
        else
            pause(0.5);
        end
    end

    save('results/decodingLog.mat', 'decodingLog');

    if ~isempty(gradsCell)
        avgGrads = FedAvg(gradsCell);
        globalModel = local_mlp_model();
        learnables = globalModel.Learnables;

        for i = 1:size(learnables,1)
            key = [learnables.Layer{i} '_' learnables.Parameter{i}];
            if isfield(avgGrads, key)
                learnables.Value{i} = {dlarray(avgGrads.(key))};
            end
        end

        globalModel.Learnables = learnables;
        save('results/global_models/globalModel.mat', 'globalModel');
        disp("✅ Global model updated and saved.");
    else
        disp("⚠️ No model updates received this round.");
    end

    % === Plotting ===
    try
        rounds = unique(decodingLog.round);
        ue_ids = unique(decodingLog.ue_id);

        avgSuccess = arrayfun(@(r) mean(decodingLog.success_rate(decodingLog.round==r)), rounds);
        avgBaseSuccess = arrayfun(@(r) mean(decodingLog.baseline_success(decodingLog.round==r)), rounds);
        avgBaseLatency = arrayfun(@(r) mean(decodingLog.baseline_latency(decodingLog.round==r)), rounds);

        figure;
        subplot(1,2,1); hold on;
        colors = lines(length(ue_ids));
        for u = 1:length(ue_ids)
            mask = decodingLog.ue_id == ue_ids(u);
            scatter(decodingLog.round(mask), decodingLog.success_rate(mask), 60, 'filled', ...
                'MarkerEdgeColor', 'k', 'MarkerFaceColor', colors(u,:), ...
                'DisplayName', ['UE ' num2str(ue_ids(u))]);
        end
        plot(rounds, avgSuccess, 'k--o', 'LineWidth', 1.8, 'DisplayName', 'FedAvg');
        plot(rounds, avgBaseSuccess, 'r--d', 'LineWidth', 1.5, 'DisplayName', 'Baseline');
        xlabel('Federated Round'); ylabel('Success Rate (%)');
        title('Per-UE Success Rate vs Baseline'); legend; grid on; ylim([0 100]);

        subplot(1,2,2); hold on;
        for u = 1:length(ue_ids)
            mask = decodingLog.ue_id == ue_ids(u);
            scatter(decodingLog.round(mask), decodingLog.latency_ms(mask), 60, 'filled', ...
                'MarkerEdgeColor', 'k', 'MarkerFaceColor', colors(u,:), ...
                'DisplayName', ['UE ' num2str(ue_ids(u))]);
        end
        plot(rounds, avgBaseLatency, 'r--d', 'LineWidth', 1.5, 'DisplayName', 'Baseline');
        xlabel('Federated Round'); ylabel('Decoding Latency (ms)');
        title('Per-UE Decoding Latency vs Baseline'); legend; grid on;

        sgtitle('PDCCH/DCI Blind Decoding – FedAvg vs Static Baseline');

        % === Save and open plot ===
        plotDir = 'results/plots';
        if ~isfolder(plotDir)
            mkdir(plotDir);
        end
        plotFile = fullfile(plotDir, sprintf('performance_round%d.pdf', roundId));
        exportgraphics(gcf, plotFile);
        open(plotFile);  % <-- Automatically opens it

    catch ME
        warning("⚠️ Plotting failed: %s", ME.message);
    end
end
