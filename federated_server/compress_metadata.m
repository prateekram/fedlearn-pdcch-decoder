function compressed = compress_metadata(grads)
    fields = fieldnames(grads);
    compressed = struct();

    for i = 1:numel(fields)
        g = grads.(fields{i});
        minVal = min(g(:));
        maxVal = max(g(:));
        normData = (g - minVal) / (maxVal - minVal + eps);
        compressed.(fields{i}) = struct( ...
            'data', uint8(normData * 255), ...
            'minVal', minVal, ...
            'maxVal', maxVal ...
        );
    end
end
