function start_all_ues()
    load('results/txWaveform.mat', 'txWaveform');
    numUEs = 5;
    numRounds = 5;

    % Preload waveform
    for ue_id = 1:numUEs
        fprintf("Simulating UE %d\n", ue_id);
        rxWaveform = dynamic_channel_model(txWaveform);
        globalModel = local_mlp_model();

        for round = 1:numRounds
            globalModel = receive_global_model_tcp(globalModel);
            isTrainer = (ue_id == 1); % Only UE 1 trains

            if isTrainer
                [decodedDCIs, trainingData, stats] = blind_decoder(rxWaveform, globalModel, ue_id);
                grads = local_train_update(globalModel, trainingData);
                send_metadata_tcp(grads, stats, ue_id);
            else
                [~, stats] = inference_only_decoder(rxWaveform, globalModel, ue_id);
                send_metadata_tcp(struct(), stats, ue_id);
            end

            pause(1);
        end
    end
end
