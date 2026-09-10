% Script to obtain firing probability vs. stimulus amplitude
% NOTE: requires redefining boulet_model_main as a function!

%% obtaining num of spikes vs. pulse amplitude data
run boulet_parameters
A = [0:10:45 45:0.2:55 55:10:100];
%A = 50;

for i = 1:length(A)
    spiketimes = boulet_model_main(A(i));
    numspikes(i) = length(cell2mat(spiketimes));
end

%% plot and smooth
numspikes = numspikes(1:length(A));
plot(A,numspikes/nneurons);
hold on;
plot(50,0.45,'O');
%plot(50*linspace(1,1,100),linspace(0,0.5,100));
plot(A,smoothdata(numspikes,'gaussian',5)/nneurons)
title({['Firing probability vs. noise level'],['nneurons: ',num2str(nneurons), ', tmax: ', num2str(tmax), ', vth0: ', num2str(vth0)]});
xlabel('Stimulus amplitude (pA)');
ylabel('Firing probability');
filename = strcat('firingprob',num2str(RS_mem),'.mat');
save(filename,'nneurons','vth0','RS_mem','dt','numspikes','A');

%% testing various levels of smoothing
sm = [4 6 8 2];
for i=1:4
    %plot(a(i,:),ns(i,:)/nneurons)
    plot(a(i,:),smoothdata(ns(i,:),'gaussian',sm(i))/nneurons)
    hold on;
    title({['Firing probability vs. noise level'],['nneurons: ',num2str(nneurons), ', vth0: ', num2str(vth0)]});
    xlabel('Stimulus amplitude (pA)');
    ylabel('Firing probability (%)');
end