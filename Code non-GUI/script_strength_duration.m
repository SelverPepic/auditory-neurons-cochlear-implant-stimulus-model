%% script: strength-duration function for HH model
% pseudocode:
    % choose pulse width (tpulse)
    % increase pulse amplitude until neuron spikes
    % reduce pulse width, start from previous pulse amplitude (saves time)
    % repeat

tpulse = 10:(-0.1):0.1; %(-0.1):0.1; % ms, pulse width
A1 = 0; % pA, initial pulse amplitude
dA = 0.1; % pA, pulse amplitude increment
Ath = zeros(size(tpulse));

tic
for j=1:length(tpulse)
    % fix tpulse, loop until spike
    while (Ath(j)==0)
        v = HHmodel(A1,0,tpulse(j),0);
        if (max(v)>=0)
            Ath(j) = A1; % save current threshold if spike
            break;
        end
        A1 = A1 + dA; % else increase pulse amplitude
    end
end
toc

% plot results
plot(tpulse,Ath);
xlabel('Pulse width (ms)')
ylabel('Stimulation threshold (pA)')
title('Stimulation threshold vs. pulse width')