function [Amp,N1,P1,ECAP] = ECAP_Amplitude2(SpikeTimes, U, sigmaU)
%%% Taken from Hess 2017 semester project paper
%% ECAP Amplitude Model
% The model uses an uniform action potential model, with its position in
% time distributed after the given probability density function, to
% calculate the compound action potential and its amplitude (difference
% between P1 and N1).
%
% Arguments
% =========
% SpikeTimes:   time points, where spikes occur
% U:            [N1, P1] peak of the uniform action potential
% sigmaU:       [N1, P1] width of the uniform action potential

nSpikes = numel(SpikeTimes);
SpikeTimes = SpikeTimes - mean(SpikeTimes); % make it zero mean
t = -1:0.001:1;
ECAP = zeros(nSpikes+1, length(t));
for i=1:nSpikes
    ECAP(i+1,:) = UR(t+SpikeTimes(i), U, sigmaU);
end
ECAP(1,:) = sum(ECAP(2:end,:),1);
[valMax,indMax] = max(ECAP(1,:));
[valMin,indMin] = min(ECAP(1,:));
Amp = valMax - valMin;
N1 = [t(indMin), valMin];
P1 = [t(indMax), valMax];