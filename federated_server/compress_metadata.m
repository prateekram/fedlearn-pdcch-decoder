function compressed = compress_metadata(grads)
    fields = fieldnames(grads);
    compressed = struct();
    for i = 1:numel(fields)
        try
            g = grads.(fields{i});

            % If g is a table or timetable, skip it immediately
            if istable(g)
                warning(['Skipping table field: ', fields{i}]);
                continue;
            end

            % If g is a cell, check if non-empty
            if iscell(g)
                if isempty(g)
                    warning(['Skipping empty cell field: ', fields{i}]);
                    continue;
                else
                    g = g{1}; % unwrap first element
                end
            end

            % If g is a struct with "Value" field
            if isstruct(g) && isfield(g, 'Value')
                g = g.Value;
            end

            % If still a dlarray, extract numeric data
            if isa(g, 'dlarray')
                g = extractdata(g);
            end

            % Now, only if numeric
            if isnumeric(g)
                minVal = min(g(:));
                maxVal = max(g(:));

                if maxVal - minVal < eps
                    scaledData = zeros(size(g), 'uint8');
                else
                    scaledData = uint8(255 * (g - minVal) / (maxVal - minVal));
                end

                compressed.(fields{i}) = struct( ...
                    'data', scaledData, ...
                    'minVal', minVal, ...
                    'maxVal', maxVal ...
                );
            else
                warning(['Skipping non-numeric field: ', fields{i}]);
            end
        catch ME
            warning(['Skipping problematic field: ', fields{i}, ' -> ', ME.message]);
            continue;
        end
    end
end
