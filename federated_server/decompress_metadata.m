function grads = decompress_metadata(compressed)
    fields = fieldnames(compressed);
    grads = struct();

    for i = 1:numel(fields)
        entry = compressed.(fields{i});
        g = double(entry.data) / 255;
        grads.(fields{i}) = g * (entry.maxVal - entry.minVal + eps) + entry.minVal;
    end
end
