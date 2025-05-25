function rxWaveform = dynamic_channel_model(txWaveform)
    cdl = nrCDLChannel;
    cdl.DelayProfile = 'CDL-D';
    cdl.MaximumDopplerShift = 300;
    cdl.DelaySpread = 300e-9;
    cdl.CarrierFrequency = 3.5e9;
    cdl.SampleRate = 30.72e6;
    
    % Fix number of antennas to 1
    cdl.TransmitAntennaArray.Size = [1 1 1 1 1]; % <-- Force 1 antenna
    cdl.ReceiveAntennaArray.Size = [1 1 1 1 1];  % <-- Also 1 receive antenna (optional)

    % Pass through channel
    [rxWaveform, ~] = cdl(txWaveform);
end
