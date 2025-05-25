function avgGrads = FedAvg(gradsCell)
    avgGrads = gradsCell{1};
    fields = fieldnames(avgGrads);

    for f = 1:length(fields)
        avgGrads.(fields{f}) = double(avgGrads.(fields{f}));
    end

    for i = 2:length(gradsCell)
        for f = 1:length(fields)
            avgGrads.(fields{f}) = avgGrads.(fields{f}) + double(gradsCell{i}.(fields{f}));
        end
    end

    for f = 1:length(fields)
        avgGrads.(fields{f}) = avgGrads.(fields{f}) / length(gradsCell);
    end
end
