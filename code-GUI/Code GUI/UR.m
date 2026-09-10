function AP = UR(t, U, sigma)
%% Uniform Action Potential
% taken from V. Hamacher (2004)
%
% Arguments
% =========
% U:            [N1, P1] peak of the uniform action potential
% sigmaU:       [N1, P1] width of the uniform action potential


% load defaults from Hamacher, if no values passed:
if nargin < 3
    sigma = [120, 160]; % in us
end
if nargin < 2
    U = [0.12, 0.09]; % in uV
end
U_N = U(1);
sigma_N = sigma(1);
if length(U) == 2
    U_P = U(2);
else
    U_P = U(1);
end
if length(sigma) == 2
    sigma_P = sigma(2);
else
    sigma_P = sigma(1);
end

sqrt_e = 1.648721270700128;

% split in negative and positive range and concatenate again after the
% calculation:
t_N = t(t<0);
t_P = t(t>=0);
AP_N = sqrt_e / sigma_N * t_N .* exp(-((t_N/sigma_N).^2)/2) * U_N;
AP_P = sqrt_e / sigma_P * t_P .* exp(-((t_P/sigma_P).^2)/2) * U_P;
AP = [AP_N, AP_P];
