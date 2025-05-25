function ssbStruct = myNRSSBurst()
% Lightweight custom SSB generator

    % Initialize empty SSB grid
    ssbGrid = complex(zeros(240,4)); % 240 subcarriers, 4 OFDM symbols

    % Random Cell ID
    NID = randi([0 1007]);

    % Generate PSS and SSS
    NID2 = mod(NID,3);
    pssSeq = nrPSS(NID2); % 127 symbols
    sssSeq = nrSSS(NID);  % 127 symbols

    % Map PSS (centered)
    ssbGrid(57:183,1) = pssSeq; % Symbol 1

    % Map SSS
    ssbGrid(1:127,2) = sssSeq; % Symbol 2

    % Dummy PBCH (payload)
    pbchPayload = randi([0 1], 864, 1);
    pbchMapped = (pbchPayload(1:113)*2-1) + 1j*(pbchPayload(114:226)*2-1);
    ssbGrid(184:end,3:4) = repmat(pbchMapped(1:(240-183)), 1, 2);

    % Output structure
    ssbStruct.PRBSet = 0:19; % 20 PRBs (0..19)
    ssbStruct.Grid = ssbGrid;
end
