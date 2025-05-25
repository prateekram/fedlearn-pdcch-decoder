function [decodedDCIs, trainingData, stats] = blind_decoder(rxWaveform, model, ue_id)

    tic;

    % === Adaptive Seed for Each UE ===
    if mod(ue_id, 2) == 1
        rng(42);
    else
        rng(42 + ue_id);
    end

    % === Format-aware simulation ===
    pdcchFormats = {'Format0_0', 'Format1_0', 'Format2_1'};
    formatProb = [0.4, 0.4, 0.2];
    cumulative = cumsum(formatProb);
    chosenFormats = cell(1, 100);
    for i = 1:100
        r = rand();
        idx = find(r <= cumulative, 1, 'first');
        chosenFormats{i} = pdcchFormats{idx};
    end

    % Parameters
    numCandidates = 100;
    topK = 10;
    featureDim = 10;

    candidateFeatures = zeros(featureDim, numCandidates);
    labels = zeros(1, numCandidates);
    for i = 1:numCandidates
        fmt = chosenFormats{i};
        switch fmt
            case 'Format0_0'
                base = randn(featureDim, 1);
                noise = 0.1 * randn(featureDim, 1);
            case 'Format1_0'
                base = randn(featureDim, 1) + 0.5;
                noise = 0.2 * randn(featureDim, 1);
            case 'Format2_1'
                base = randn(featureDim, 1) + 1.0;
                noise = 0.3 * randn(featureDim, 1);
        end
        candidateFeatures(:, i) = base + noise;
        labels(i) = rand() > 0.7;
    end

    % Inference
    X = dlarray(candidateFeatures, 'CB');
    YScore = forward(model, X);
    scores = extractdata(YScore);
    [~, sortedIdx] = sort(scores, 'descend');
    selectedIdx = sortedIdx(1:topK);

    decodedDCIs = {};
    trainingData.features = candidateFeatures(:, selectedIdx);
    trainingData.labels = labels(selectedIdx);

    % Stats
    numSuccess = sum(trainingData.labels);
    decodingTime = toc;
    stats.numSuccessfulDecodes = numSuccess;
    stats.numAttempts = topK;
    stats.totalDecodingTime = decodingTime * 1000;

    % Baseline
    baseline.numSuccessfulDecodes = sum(labels);
    baseline.numAttempts = numCandidates;
    baseline.totalDecodingTime = (decodingTime / topK) * numCandidates;
    stats.baseline = baseline;

end
