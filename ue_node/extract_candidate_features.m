function features = extract_candidate_features(candidates)
    % Candidates: assumed extracted from real CORESET mapping
    % For now, randomly simulate
    numCandidates = size(candidates, 1);
    features = rand(numCandidates, 6);
end
