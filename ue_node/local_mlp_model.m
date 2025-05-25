function net = local_mlp_model()
    layers = [
        featureInputLayer(10, 'Name', 'input')
        fullyConnectedLayer(32, 'Name', 'fc1')
        reluLayer
        fullyConnectedLayer(16, 'Name', 'fc2')
        reluLayer
        fullyConnectedLayer(1, 'Name', 'fc3')
        sigmoidLayer
    ];

    net = dlnetwork(layerGraph(layers));
end
