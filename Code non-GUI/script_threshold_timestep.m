%% Script: strength-duration for Boulet model
% NOTE: requires redefining boulet_model_main as a function!

% pseudocode:
    % choose simulation timestep (dt)
    % find firing threshold for given timestep
    % change timestep, repeat

clear all;
dt = [0.05 0.025 0.01 0.005 0.0025 0.001 0.0005 0.00025 0.0001 0.00001]; % ms
A = 0; % pA, initial pulse amplitude
dA = 0.1; % pA, pulse amplitude increment
Ath = zeros(size(dt));

tic
for j=1:length(dt)
    
    % fix dt, loop until spike
    while (Ath(j)==0)
        spiketimes = boulet_model_main(A,dt(j));
        if (length(cell2mat(spiketimes))>0)
            Ath(j) = A; % save current threshold if spike
            break;
        end
        A = A + dA; % else increase pulse amplitude
    end % A loop
    
end % dt loop
toc

%% plot results
plot(log10(dt),Ath);
xlabel('Timestep (ms)')
ylabel('Stimulation threshold (pA)')
title('Stimulation threshold vs. simulation timestep')