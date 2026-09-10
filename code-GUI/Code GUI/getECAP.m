function [ECAP_amp, ECAP_time] = getECAP(spiketimes, APamp, APstd, npulses, tIPI, to, nneurons, tmax)
%%% Calculate ECAP Amplitudes for the whole signal
% Adapted from Hess 2017 semester project paper

% Pseudocode:
    % for each stimulus pulse
        % replace each spiketime with a uniform action potential (UP function)
        % sum all action potentials
        % calculate the amplitude as maxECAP - minECAP
    % go to the next stimulus pulse
    
% INPUTS:
    % spiketimes
    % APamp - unit action potential positive and negative peak heights
    % APstd - unit action potential positive and negative peak widths
    % npulses, tIPI, to, nneurons, tmax - stimulus parameters needed to
        % properly align calculated ECAP signal with the stimulus waveform
        % Respectively: num of pulses, inter-pulse interval, time of the
        % initial stimulus pulse, number of neurons, duration of stimulus
        
% OUTPUTS:
    % ECAP_time - ECAP time points
    % ECAP_amp - ECAP amplitudes at ECAP time points
    

%%
APnegVoltage = APamp(1); % N1-peak of the unit AP
APposVoltage = APamp(2); % P1-peak of the unit AP
APnegStd = APstd(1); % width of the N1-peak of the unit AP
APposStd = APstd(2); % width of the P1-peak of the unit AP

for i=1:npulses % for each pulse
    % prepare spike times:
    spiketimes_pulse = [];
    
    for j=1:nneurons % for each neuron which fired during i-th pulse
        spiketimes_pulse = [spiketimes_pulse, spiketimes{j}(logical((spiketimes{j}>=(i-1)*tIPI+to) .* (spiketimes{j}<(i-1)*tIPI+tIPI+to)))];
    end
    nSpikes(i) = numel(spiketimes_pulse);
    
    % calculate ECAP:
    [ECAP_amp(i),N1(i,:),P1(i,:),ECAP{i}] = ECAP_Amplitude2(spiketimes_pulse, [APnegVoltage APposVoltage], [APnegStd APposStd]);
end

% Aligning ECAP waveform and stimulus waveform / time vectors

% add zeropad from front and back
pad_front = flip( to-tIPI:(-tIPI):0 );
% NOT using (0:tIPI:to-tIPI) since array will not reach t=to-tIPI if to is
% not divisible with tIPI!
ECAP_time = to : tIPI : to+(npulses-1)*tIPI;
pad_back =  to+npulses*tIPI : tIPI : tmax;

ECAP_time = [pad_front ECAP_time pad_back];
ECAP_amp = [ zeros(size(pad_front)) ECAP_amp zeros(size(pad_back))];
%save('test.mat','pad_front','pad_back','ECAP_time','ECAP_amp');