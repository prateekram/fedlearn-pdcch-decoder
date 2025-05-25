function grads = local_train_update(model, data)
    X = dlarray(data.features, 'CB');
    Y = dlarray(data.labels, 'CB');

    % Compute gradients via dlfeval
    [lossVal, gradsRaw] = dlfeval(@modelLossAndGradients, model, X, Y);

    % Extract gradients into flat struct
    grads = struct();
    for i = 1:size(gradsRaw, 1)
        key = [gradsRaw.Layer{i}, '_', gradsRaw.Parameter{i}];
        val = gradsRaw.Value(i);
        if iscell(val)
            grads.(key) = extractdata(val{1});
        else
            grads.(key) = extractdata(val);
        end
    end
end

function [loss, grads] = modelLossAndGradients(model, X, Y)
    YPred = forward(model, X);
    loss = crossentropy(YPred, Y);
    grads = dlgradient(loss, model.Learnables);
end
