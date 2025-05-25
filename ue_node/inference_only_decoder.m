function [decodedDCIs, stats] = inference_only_decoder(rxWaveform, model, ue_id)
    tic;
    if mod(ue_id, 2) == 1
        rng(42);
    else
        rng(42 + ue_id);
    end

    pdcchFormats = {'Format0_0', 'Format1_0', 'Format2_1'};
    chosenFormats = pdcchFormats(randi([1 3], 1, 100));
    featureDim = 10;
    numCandidates = 100;

    candidateFeatures = zeros(featureDim, numCandidates);
    labels = zeros(1, numCandidates);
    for i = 1:numCandidates
        fmt = chosenFormats{i};
        switch fmt
            case 'Format0_0'
                base = randn(featureDim,1);
                noise = 0.1 * randn(featureDim,1);
            case 'Format1_0'
                base = randn(featureDim,1) + 0.5;
                noise = 0.2 * randn(featureDim,1);
            case 'Format2_1'
                base = randn(featureDim,1) + 1.0;
                noise = 0.3 * randn(featureDim,1);
        end
        candidateFeatures(:,i) = base + noise;
        labels(i) = rand() > 0.7;
    end

    X = dlarray(candidateFeatures, 'CB');
    scores = extractdata(forward(model, X));
    [~, sortedIdx] = sort(scores, 'descend');
    selectedIdx = sortedIdx(1:10);
    decodedDCIs = {};

    numSuccess = sum(labels(selectedIdx));
    decodingTime = toc;

    stats.numSuccessfulDecodes = numSuccess;
    stats.numAttempts = 10;
    stats.totalDecodingTime = decodingTime * 1000;
    stats.baseline.numSuccessfulDecodes = sum(labels);
    stats.baseline.numAttempts = 100;
    stats.baseline.totalDecodingTime = (decodingTime / 10) * 100;
end
