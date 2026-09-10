% Script to calculate ECAP amplitude "by hand"
%% Arguments
% =========
% SpikeTimes:   time points, where spikes occur
% U:            [N1, P1] peak of the uniform action potential
% sigmaU:       [N1, P1] width of the uniform action potential
SpikeTimes = cell2mat(spiketimes);
%SpikeTimes = [0 1];
U = [0.12 0.09]; % mV
sigmaU = [0.120 0.160]; % ms

%% prep
nSpikes = numel(SpikeTimes);
%SpikeTimes = SpikeTimes - mean(SpikeTimes); % make it zero mean
%t = -1:0.001:1;
ECAP = zeros(nSpikes+1, length(t));

%% calculate
for i=1:nSpikes
    ECAP(i+1,:) = UR(t-SpikeTimes(i), U, sigmaU);
end

%% postprocessing
ECAP(1,:) = sum(ECAP(2:end,:),1);
[valMax,indMax] = max(ECAP(1,:));
[valMin,indMin] = min(ECAP(1,:));
Amp = valMax - valMin;
N1 = [t(indMin), valMin];
P1 = [t(indMax), valMax];

plot(t,(1,:));
hold on;
plot(t,Istim(:,1));