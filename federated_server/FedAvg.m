function avgGrads = FedAvg(gradsCell)
    avgGrads = gradsCell{1};
    for i = 2:numel(gradsCell)
        fields = fieldnames(avgGrads);
        for f = 1:numel(fields)
            avgGrads.(fields{f}) = avgGrads.(fields{f}) + gradsCell{i}.(fields{f});
        end
    end
    fields = fieldnames(avgGrads);
    for f = 1:numel(fields)
        avgGrads.(fields{f}) = avgGrads.(fields{f}) / numel(gradsCell);
    end
end
