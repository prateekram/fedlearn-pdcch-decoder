function grads = decompress_metadata(compressed)
    fields = fieldnames(compressed);
    grads = struct();
    for i = 1:numel(fields)
        c = compressed.(fields{i});
        grads.(fields{i}) = double(c.data)/255 * (c.maxVal - c.minVal) + c.minVal;
    end
end
