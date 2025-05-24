addpath(genpath('gnb_node'));
addpath(genpath('federated_server'));
addpath(genpath('ue_node'));
addpath(genpath('utils'));

start_gnb;

roundId = 1;
while true
    server_main_tcp(roundId);   % ✅ Pass roundId!
    roundId = roundId + 1;
end
