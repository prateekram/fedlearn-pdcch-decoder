function globalModel = receive_global_model_tcp(currentModel)
    try
        client = tcpclient('localhost', 31000);
        data = read(client, client.NumBytesAvailable, 'uint8');
        newParams = jsondecode(char(data));
        globalModel = local_mlp_model();
        globalModel.Learnables = decompress_metadata(newParams);
    catch
        globalModel = currentModel;
    end
end
