% Script to calculate and plot ECAP response
% Based on code from Hess 2017 semester project paper
% pseudocode:
    % for each stimulus pulse
        % replace each spiketime with a uniform action potential (convolution)
        % sum all action potentials
        % calculate the amplitude as max-min ECAP
    % go to the next stimulus pulse 

%% Calculate ECAP Amplitudes:
IPI = tIPI; % "dummy" variable due to differences in notation
APnegVoltage = 0.12; % N1-peak of the unit AP
APposVoltage = 0.09; % P1-peak of the unit AP
APnegStd = 0.12; % width of the N1-peak of the unit AP
APposStd = 0.16; % width of the P1-peak of the unit AP
    
for i=1:npulses % for all pulses...
    % prepare spike times:
    spiketimes_pulse = [];
    for j=1:nneurons
        spiketimes_pulse = [spiketimes_pulse, spiketimes{j}(logical((spiketimes{j}>=(i-1)*IPI) .* ...
                                                        (spiketimes{j}<(i-1)*IPI+IPI)))]; 
    end
    nSpikes(i) = numel(spiketimes_pulse);
    
    % calculate ECAP:
    [Amp(i),N1(i,:),P1(i,:),ECAP{i}] = ECAP_Amplitude2(spiketimes_pulse, [APnegVoltage APposVoltage], [APnegStd APposStd]);
end

%% plot results
tamp = 0:round(tmax/npulses):tmax-round(tmax/npulses);
figure(1)
    plot(t,Istim(:,1));
figure(2)
   plot(tamp,Amp,'-b*');