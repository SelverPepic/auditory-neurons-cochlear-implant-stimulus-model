%% adaptation/facilitation extraction script
% pseudocode:
% find threshold stimulus current (increased from 0 until neuron spikes)
% then, choose 1st pulse amplitude (lower than threshold)
    % choose timing of 2nd pulse (IPI, inter-pulse amplitude)
    % increase 2nd pulse amplitude until neuron spikes
    % reduce IPI
    % repeat

A2 = 0:0.1:30; % pA, second pulse amplitude
tpulse = 0.5; % ms, pulse width
IPI =  [20:(-0.2):5 5:(-0.1):0.5]; % ms, inter-pulse interval

%% find Ath0, single pulse threshold
for j=1:length(A2)
    v = HHmodel_function(0,A2(j),tpulse,max(IPI));
    if (max(v)>=0)
        Ath0 = A2(j);
        % [val1 ind1] = max(v);
        % [val2 ind2] = max(flip(v));
        % ind_sum = ind1+ind2; 
        break;
    end
end

%% find IPI, A2 data
A1 = 10; % round(*0.5),1:round(Ath0*0.9);
A2data = zeros(length(IPI),length(A1));
tic
for k=1:length(A1)
    A2 = 0:0.1:30;
    for i=1:length(IPI)
        % IPI fixed, vary A2   
        for j=1:length(A2)
            v = HHmodel_function(A1(k),A2(j),tpulse,IPI(i));
            % [val1 ind1] = max(v);
            % [val2 ind2] = max(flip(v));
            % if (ind1+ind2 ~= ind_sum 
            if (max(v)>=0)
                A2data(i,k) = A2(j);
                % new A2 searched +-20% away from previous A2 threshold
                A2 = round(0.8*A2(j)):0.1:round(1.2*A2(j));
                break; % save data, goto next IPI
            end
        end % A2 loop        
    end % IPI loop
    
end % A1 loop
toc

%% plot results
for k=1:length(A1)
    hold on;
    plot(IPI,A2data(:,k)/Ath0);
    xlabel('MPI (ms)')
    ylabel('Relative threshold')
    title('Probe relative threshold vs. masker-probe interval')
end
plot(IPI,ones(size(IPI)),'-.black');