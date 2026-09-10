%% Calculate ECAP Amplitudes:
IPI = tIPI;
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
   %plot(t,Istim(:,1)/max(Istim(:,1)));
   %plot(t,mod/max(mod),'--b');
   hold on;
   plot(tamp(1:length(Amp)),Amp/max(Amp),'-r.');
   %plot(t_1000,amp_1000/max(amp_1000),'-green.');