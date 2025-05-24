function start_all_ues()
    numUEs = 50;
    numRounds = 5;

    % Load once for efficiency
    load('results/txWaveform.mat', 'txWaveform');

    % Run simulation for each UE across rounds
    for round = 1:numRounds
        fprintf('\n=== Round %d ===\n', round);

        % Load latest model once per round
        globalModel = receive_global_model_tcp(local_mlp_model());

        for ue_id = 1:numUEs
            fprintf('>> Simulating UE %d\n', ue_id);

            % Apply channel (simulate different conditions per UE)
            rxWaveform = dynamic_channel_model(txWaveform);

            isTrainer = (ue_id == 1); % Only UE 1 sends gradients

            if isTrainer
                [decodedDCIs, trainingData, stats] = blind_decoder(rxWaveform, globalModel, ue_id);
                grads = local_train_update(globalModel, trainingData);
                send_metadata_tcp(grads, stats, ue_id);
            else
                [~, stats] = inference_only_decoder(rxWaveform, globalModel, ue_id);
                send_metadata_tcp(struct(), stats, ue_id);
            end

            pause(0.2); % staggered sending (helps avoid socket collisions)
        end

        fprintf('✅ Round %d complete. Waiting for server update...\n', round);
        pause(5); % allow server to process and update model
    end
end
