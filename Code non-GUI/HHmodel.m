%%% Hodgkin-Huxley model
%%% Master thesis prep, 09.07.2018
%%% ETH Zurich, UniSpital Zurich, ORL-Klinik, LEA

%% Setup
% physical parameters
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
    T = 6.3; % ?Celsius
    F = 96.485; % kC/mol
E_Na = R*(T+273.16)/F * log(c_o_Na/c_i_Na); % mV
E_K = R*(T+273.16)/F * log(c_o_K/c_i_K);
E_leak = -49; % mV

% simulation parameters
niter = 10000;
tmax = 20; % ms, physical duration of the "experiment"
dt = tmax/niter; % ms, timestep
t = dt:dt:tmax;

%% initial conditions and stimulation type
v = vrest * ones(1,niter);
Kt = 3^((T-6.3)/10);
    % transition variables
    i = 1;
    alpha_m = 0.1 * (v(i)+35) / (1-exp(-0.1*(v(i)+35) )) * Kt;
    beta_m = 4  * exp(-(v(i)+60)/18) * Kt;
    alpha_h = 0.07 * exp(-0.05*(v(i)+60)) * Kt;
    beta_h = 1 / (1+exp(-0.1*(v(i)+30))) * Kt;
    alpha_n = 0.01  * (v(i)+50) / (1-exp(-0.1*(v(i)+50))) * Kt;
    beta_n = 0.125 * exp(-0.0125*(v(i)+60)) * Kt;

m = alpha_m/(alpha_m+beta_m) * ones(1,niter);
h = alpha_h/(alpha_h+beta_h) * ones(1,niter);
n = alpha_n/(alpha_n+beta_n) * ones(1,niter);

% choose stimulation type
A1 = 10; % 13 th
A2 = 20; % pA
mod = 0;
Istim = zeros(1,niter);
to = 2;
wo = round(to/dt);
tw = 0.5;
dw = round(tw/dt);
tIPI = 5;
IPI = round(tIPI/dt);
Istim (wo:wo+dw) = A1;
Istim (wo+IPI:wo+IPI+dw) = A2; % double pulse

%Istim = A*(1+mod*sin(2*pi*t/20) );
I_Na = zeros(1,niter);
I_K = zeros(1,niter);
I_leak = zeros(1,niter);

%% loop the loop
for i = 1:niter-1
    
    % charge conservation C*dv/dt + gx*(v-Ex) = Istim
    I_Na(i)   = g_Na * m(i)^3*h(i) * (v(i)-E_Na);
    I_K(i)    = g_K  * n(i)^4      * (v(i)-E_K);
    I_leak(i) = g_leak             * (v(i)-E_leak);
    
    v(i+1) = v(i) + dt/C *(Istim(i) - I_Na(i) - I_K(i) - I_leak(i));
                          
    % transition variables
    alpha_m = 0.1 * (v(i)+35) / (1-exp(-0.1*(v(i)+35) )) * Kt;
    beta_m = 4  * exp(-(v(i)+60)/18) * Kt;
    alpha_h = 0.07 * exp(-0.05*(v(i)+60)) * Kt;
    beta_h = 1 / (1+exp(-0.1*(v(i)+30))) * Kt;
    alpha_n = 0.01  * (v(i)+50) / (1-exp(-0.1*(v(i)+50))) * Kt;
    beta_n = 0.125 * exp(-0.0125*(v(i)+60)) * Kt;
    % gating variables
    m(i+1) = m(i) + alpha_m*(1-m(i))*dt - beta_m * m(i)*dt;
    h(i+1) = h(i) + alpha_h*(1-h(i))*dt - beta_h * h(i)*dt;
    n(i+1) = n(i) + alpha_n*(1-n(i))*dt - beta_n * n(i)*dt;
    
end

%% plot results
figure(1)
    plot(t,Istim-3*A1,'red');
    hold on;
    plot(t,13*ones(size(t))-3*A1,'-.black');
    axis([0 tmax -4*A1 20]);
    %plot(t,-0.1*ones(size(t)),'-.black');
    plot(t,v+60,'blue');
    title('I_{stim} and V_{mem} vs. time')
    xlabel('t (ms)');
    ylabel('I_{stim} (pA), V_{mem}(mV)');
    legend('I_{stim}', 'V_{mem}');
    %%
figure(2)
    plot(t,Istim-I_Na-I_K-I_leak); % total current I
    hold on;
    plot(t,-I_Na);
    plot(t,-I_K);
    plot(t,-I_leak);
    plot(t,Istim);
    title('Membrane currents vs. time')
    xlabel('t (ms)');
    ylabel('I_{mem}, I_{Na}, I_K, I_{leak}, I_{stim}  (\muA)');
    legend('I_{mem}', 'I_{Na}', 'I_K', 'I_{leak}','I_{stim}');
    
figure(3)
    plot(t,m);
    hold on;
    plot(t,h);
    plot(t,n);
    plot(t,Istim./A1);
    title('Gating variables vs. time')
    xlabel('t (ms)');
    ylabel('m, h, n  (a.u.) & I_{stim}');
    legend('m','h','n','I_{stim}');    