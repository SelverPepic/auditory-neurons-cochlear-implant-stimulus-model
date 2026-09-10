%% script: recovery function extraction for HH model 
% pseudocode:
    % find threshold stimulus current (increased from 0 until neuron spikes)
    % then, choose timing of 2nd pulse (IPI)
    % increase pulse amplitude until neuron spikes
    % reduce IPI, start from previous pulse amplitude (saves time)
    % repeat

A2 = 0:0.1:100; % pA, second pulse amplitude
tpulse = 0.5; % ms, pulse width
IPI =  [20:(-0.2):5 5:(-0.1):0.5]; % ms, inter-pulse interval

%% find Ath0, single pulse threshold
for j=1:length(A2)
    v = HHmodel_function(A2(j),0,tpulse,max(IPI));
    if (max(v)>=0)
        Ath0 = A2(j);
        break;
    end
end

%% find (t,A2) data
A1 = Ath0; % 1st pulse causes spike
A2 = 0; % 2nd pulse amplitude is sweeped from 0 up
dA = 0.1; % pA, 2nd pulse amplitude increment
A2data = zeros(size(IPI));

tic
for j=1:length(IPI)
    % increase A2 until neuron spikes
    while (A2data(j)==0)
        v = HHmodel_function(A1,A2,tpulse,IPI(j));
        pks = findpeaks(v(v>=0)); % finds location of peaks in voltage response
        
        % if two peaks present, save data
        if (length(pks) == 2)
            A2data(j) = A2; % save current threshold
            break;
        end
        % if not
        A2 = A2 + dA;
    end
    
    % if A2 is too large then IPI is inside ARP -> break loop
    if (A2>=200)
        A2data(j:end) = Inf; 
        break;
    end
end
toc

%% plot results
plot(IPI,A2data/Ath0);
xlabel('IPI (ms)')
ylabel('Relative threshold')
title('Relative threshold (2nd spike) vs. IPI')