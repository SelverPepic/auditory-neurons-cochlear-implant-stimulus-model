function [v] = HHmodel(A1, A2, tpulse, tIPI)
% Function used for obtaining recovery function, strength-duration curve, 
% and facilitation/accommodation function

% INPUTS:
    % A1, A2 - amplitude of 1st and 2nd stimulus pulse
    % tpulse - duration of pulse / pulse width
    % tIPI - inter-pulse interval
    
% OUTPUT:
    % v - neuron voltage response

%% physical parameters
vrest = -60; % mV
C = 1; % 1 muF/cm^2
g_Na = 120; % mS/cm^2
g_K = 36; % mS/cm^2
g_leak = 0.3; % mS/cm^2
    c_o_Na = 491;
    c_i_Na = 50;
    c_o_K = 20.11;
    c_i_K = 400;
    R = 8.31; % J/mol/K
    T = 6.3; % Celsius
    F = 96.485; % kC/mol
E_Na = R*(T+273.16)/F * log(c_o_Na/c_i_Na); % mV
E_K = R*(T+273.16)/F * log(c_o_K/c_i_K);
E_leak = -49; % mV

% simulation parameters
niter = 10000;
tmax = 100; % ms, physical duration of "experiment"
dt = tmax/niter; % ms, timestep
t = dt:dt:tmax;

%% choose stimulation type
%A1 = 12;
%A2 = 13; % muA
Istim = zeros(1,niter);
to = 10;
wo = round(to/dt);
%dtpulse = 1;
dw = round(tpulse/dt);
%tIPI = 10;
IPI = round(tIPI/dt);
Istim (wo:wo+dw) = A1;
Istim (wo+IPI:wo+IPI+dw) = Istim (wo+IPI:wo+IPI+dw) + A2; % double pulse

%% initial conditions and stimulation type
v = vrest * ones(1,niter);
Kt = 3^((T-6.3)/10);
    % transition variables
    k = 1;
    alpha_m = 0.1 * (v(k)+35) / (1-exp(-0.1*(v(k)+35) )) * Kt;
    beta_m = 4  * exp(-(v(k)+60)/18) * Kt;
    alpha_h = 0.07 * exp(-0.05*(v(k)+60)) * Kt;
    beta_h = 1 / (1+exp(-0.1*(v(k)+30))) * Kt;
    alpha_n = 0.01  * (v(k)+50) / (1-exp(-0.1*(v(k)+50))) * Kt;
    beta_n = 0.125 * exp(-0.0125*(v(k)+60)) * Kt;
m = alpha_m/(alpha_m+beta_m) *ones(1,niter);
h = alpha_h/(alpha_h+beta_h) * ones(1,niter);
n = alpha_n/(alpha_n+beta_n) * ones(1,niter);
I_Na = zeros(1,niter);
I_K = zeros(1,niter);
I_leak = zeros(1,niter);


%% loop the loop
for k = 1:niter-1
    
    % charge conservation C*dv/dt + gx*(v-Ex) = Istim
    I_Na(k)   = g_Na * m(k)^3*h(k) * (v(k)-E_Na);
    I_K(k)    = g_K  * n(k)^4      * (v(k)-E_K);
    I_leak(k) = g_leak             * (v(k)-E_leak);
    
    v(k+1) = v(k) + dt/C *(Istim(k) - I_Na(k) - I_K(k) - I_leak(k));
                          
    % transition variables
    alpha_m = 0.1 * (v(k)+35) / (1-exp(-0.1*(v(k)+35) )) * Kt;
    beta_m = 4  * exp(-(v(k)+60)/18) * Kt;
    alpha_h = 0.07 * exp(-0.05*(v(k)+60)) * Kt;
    beta_h = 1 / (1+exp(-0.1*(v(k)+30))) * Kt;
    alpha_n = 0.01  * (v(k)+50) / (1-exp(-0.1*(v(k)+50))) * Kt;
    beta_n = 0.125 * exp(-0.0125*(v(k)+60)) * Kt;
    % gating variables
    m(k+1) = m(k) + alpha_m*(1-m(k))*dt - beta_m * m(k)*dt;
    h(k+1) = h(k) + alpha_h*(1-h(k))*dt - beta_h * h(k)*dt;
    n(k+1) = n(k) + alpha_n*(1-n(k))*dt - beta_n * n(k)*dt; 
end

end % end of function