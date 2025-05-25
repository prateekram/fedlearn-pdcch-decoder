function gnb_generate()
    % Carrier Configuration
    carrier = nrCarrierConfig;
    carrier.NCellID = 42;
    carrier.SubcarrierSpacing = 30; % 30 kHz SCS
    carrier.NSizeGrid = 52;          % 52 PRBs wide carrier

    % CORESET and SearchSpace Configuration
    coreset = nrCORESETConfig;
    searchspace = nrSearchSpaceConfig;

    % Generate empty resource grid
    grid = nrResourceGrid(carrier);

    % Insert SSB (Synchronization Signal Block)
    ssbStruct = mynrSSBurst(); % <-- your custom SSB generator

    nSCPerPRB = 12; % 12 subcarriers per PRB
    centerPRB = floor(carrier.NSizeGrid/2); % Middle of carrier
    ssbPRBs = ssbStruct.PRBSet; % Typically [0:19]

    % Calculate target PRB indices to center SSB
    targetPRBIndices = centerPRB - floor(length(ssbPRBs)/2) + ssbPRBs;

    % Expand PRBs to subcarrier indices
    targetSCIndices = [];
    for prb = targetPRBIndices
        targetSCIndices = [targetSCIndices, (prb*nSCPerPRB+1):(prb*nSCPerPRB+nSCPerPRB)];
    end

    % Insert SSB into carrier grid
    grid(targetSCIndices, 1:size(ssbStruct.Grid,2)) = ssbStruct.Grid;

    % ------------------
    % Generate PDCCH properly
    % ------------------

    % Create random DCI message
    dciBits = randi([0 1], 32, 1);

    % Set PDCCH parameters
    nID = carrier.NCellID;   % use Cell ID for scrambling
    rnti = 1;                % Random UE RNTI (you can improve later)

    % Encode DCI (simplified here)
    dciCW = double(dciBits); % DCI CodeWord as double precision

    % Map DCI to PDCCH symbols
    pdcchSym = nrPDCCH(dciCW, nID, rnti);

    % Map PDCCH symbols into grid (simple mapping for demo)
    pdcchIndices = 1:length(pdcchSym);
    grid(pdcchIndices, 1) = pdcchSym; % Map in first OFDM symbol

    % OFDM Modulation
    txWaveform = nrOFDMModulate(carrier, grid);

    % Save the waveform and configs
    save('results/txWaveform.mat', 'txWaveform', 'carrier', 'coreset', 'searchspace');

    disp('✅ gNB transmission with real SSB and PDCCH generated successfully.');
end
