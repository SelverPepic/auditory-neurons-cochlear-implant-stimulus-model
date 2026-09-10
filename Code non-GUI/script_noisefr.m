% Script to obtain firing rate vs. voltage noise (relative spread)
% NOTE: requires redefining boulet_model_main as a function!

%% obtaining the data
run boulet_parameters
RS_mem2 = [0:0:05:0.15 0.15:0.01:0.5];

for i = 1:length(A)
    %disp(RS_mem2(i));
    spiketimes = boulet_model_main(RS_mem2(i));
    numspikes(i) = length(cell2mat(spiketimes));
    
    for k=1:nneurons
        nspikes = length(spiketimes{k});
        fr(k) = nspikes/nneurons;%tmax*1000;
    end
    fr_mean(i) = mean(fr)
    fr_std(i) = std(fr)
end

%% plot
plot(RS_mem2,fr_meanA);
hold on;
plot(RS_mem2,fr_std);
plot(RS_mem2,fr_mean+fr_std,'--');
plot(RS_mem2,fr_mean-fr_std,'--');
title({['Firing rate vs. noise level'],['nneurons: ',num2str(nneurons), ', tmax: ', num2str(tmax), ', vth0: ', num2str(vth0)]});
xlabel('RS_mem');
ylabel('Firing rate (1/s)');
filename = strcat('fr_vs_noise_',num2str(nneurons),'neurons','.mat');
save(filename,'nneurons','vth0','tmax','dt','RS_mem','fr_mean','fr_std');