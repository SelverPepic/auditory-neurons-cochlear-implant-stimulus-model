% testing the calculation of neural survival rate using T and C levels, max
% ECAP level and CIF/SoE function

T = [194 202 210 197]; % CL
C = [225 230 232 220]; % CL
A_max =[251 267 242 249]; % muV
N1 = 0.12; % muV
P1 = 0.09; % muV

CIF = [ 1.0 0.8 0.6 0.5;
        0.9 1.0 0.7 0.6;
        0.5 0.7 1.0 0.7;
        0.3 0.5 0.9 1.0 ];

% latency = ones(size(CIF)); % insert values
%CIF = CIF.*latency (phase?)
% sum as vectors with different phases?

A_norm = A_max./(N1+P1);
% A_norm = CIF * N_surv;
% N_surv = CIF^-1 * A_norm = CIF\A_norm;

N_surv = CIF\A_norm'

%% Reconstruct number of neurons from ECAP data
Nweighted = Amp./(APnegVoltage+APposVoltage) % also A_norm_max
%Anorm = Nweighted*ones(nneurons,1);
%CIF = ones(nneurons);
%if spread==1

% single Ith threshold case
Ith = 50;
    for k=1:nneurons
        %CIF(k) = exp(-(abs(xneurons(k)-d_stim)/d_spread)); % distributed Ith
        Ik = A*exp(-(abs(xneurons(k)-d_stim)/d_spread));
        weight(k) = heaviside(Ik/Ith-1);        
    end
%end

sum(weight)

%CIFsum = sum(CIF); % distributed Ith