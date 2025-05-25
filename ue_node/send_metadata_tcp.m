function send_metadata_tcp(grads, stats, ue_id)
    client = tcpclient('localhost', 30000);

    packet.ue_id = ue_id;
    packet.stats = stats;

    if ~isempty(grads)
        compressed = compress_metadata(grads);
        packet.grads = compressed;
    else
        packet.grads = struct(); % Send empty if not training
    end

    data = jsonencode(packet);
    write(client, uint8(data));
end
