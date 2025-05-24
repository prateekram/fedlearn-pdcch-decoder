% === start_ue.m (Updated for Hybrid Learning) ===
function start_ue(ue_id)
    load('results/txWaveform.mat', 'txWaveform');
    rxWaveform = dynamic_channel_model(txWaveform);

    globalModel = local_mlp_model();

    for round = 1:5
        % Load latest global model
        globalModel = receive_global_model_tcp(globalModel);

        isTrainer = (ue_id == 1); % Only UE 1 performs blind + learning

        if isTrainer
            [decodedDCIs, trainingData, stats] = blind_decoder(rxWaveform, globalModel, ue_id);
            grads = local_train_update(globalModel, trainingData);
            send_metadata_tcp(grads, stats, ue_id);
        else
            [~, stats] = inference_only_decoder(rxWaveform, globalModel, ue_id);
            send_metadata_tcp(struct(), stats, ue_id); % Send only stats, no grads
        end

        pause(3); % simulate wait
    end
end
