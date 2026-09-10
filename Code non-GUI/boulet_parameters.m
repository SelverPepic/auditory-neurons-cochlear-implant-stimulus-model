%%% Population Integrate & fire model - parameters list
%%% Master thesis, Selver Pepic, 26.09.2018
%%% ETH Zurich, UniSpital Zurich, ORL-Klinik, LEA
%%% All values taken from J.Boulet PhD thesis

% List of parameters for boulet_stimulation and boulet_model_main
    % INPUTS: none
    % OUTPUTS: neuronal and simulation parameters


%% physical parameters
vrest = 0; % mV, resting potential
vth0 = 30; % mV, threshold potential
vreset = -10; % mV, reset potential
vspike = 100; % mV, spike potential
R = 1.9535; % GOhm
C = 0.0714; % pF
% tau_mem = R*C = 0.1395 ms
% when tau longer than excitatory pulses, passive facillitation possible

%% simulation parameters
nneurons = 1000;
tmax = 60; % ms
dt = 0.001; % ms (dt = 0.1 mus)
niter = round(tmax/dt);
t = dt:dt:tmax;
if length(t)~=niter
    t = linspace(dt,tmax,niter);
end
%k = 1:nneurons; % neuron count array
%x = linspace(0,20,nneurons); % positions of neurons (used for stimulus spread)
% linear distribution used for simplicity, "length" of electrode array = 20

%% OPTIONAL: noise, refractory period, SRA, adaptation, facilitation
noise_mem = 1; % membrane noise
ref = 1;
noise_ref = 1;
SRA = 1;
noise_SRA = 1;
fac = 1;
noise_fac = 1;
acc = 1; % quick
noise_acc = 1;
acc_slow = 1; % slow
noise_acc_slow = 1;

if noise_mem == 1
    RS_mem = 0.0774; % unitless (from Fredelake et al 2012)    
    %noise = normrnd(0,1,[niter,nneurons]); % rand vector, std=1
    % filter noise: lowpass, cutoff 200 Hz, 3 dB/octave (Fredelake 2012)
    n = 1; % order
    fsample = 1/dt*1000; % Hz, since [dt] = ms
    fcut = 200; % Hz
    fcut_norm = fcut/(fsample/2);
    [b,a] = butter(n,fcut_norm,'low');
    noise_filt = single(filter(b,a,normrnd(0,1,[niter,nneurons]))); % rand vector, std now smaller!
    vth_sigma = vth0 .* RS_mem/mean(std(noise_filt)) .* noise_filt; % std scaled
    vth_sigma = single(vth_sigma);
    % the above could be done for each neuron separately, here only the
    % mean std is scaled
    %figure(1)
    %plot(t,vth_sigma)
    %[px,f] = periodogram(vth_sigma);
    %figure(2)
    %plot(f,10*log10(px));
end

if ref == 1
    T_ARP0 = 0.332; % 0.5; % 0.332 ms
    tau_RRP0 = 0.411; % 1.3; % 0.411 ms
    sigma_ref = 0.1; % refractory noisiness
    rho_corr = 0.5;
    a_RS_ref = 1;
    tau_RS_ref = 0.2; % ms
    
    if noise_ref == 1
        T_ARP = T_ARP0*ones(1,nneurons,'single');
        tau_RRP = tau_RRP0*ones(1,nneurons,'single');
        % T and tau vary across neurons
        T_ARP = single(normrnd(T_ARP0, sigma_ref,[1,nneurons]));
        tau_RRP = normrnd(tau_RRP0, sigma_ref,[1,nneurons]);
        tau_RRP = random_correlated(T_ARP',tau_RRP',rho_corr)';
        %r = corr(T_ARP',tau_RRP')
    else
        T_ARP = T_ARP0*ones(1,nneurons,'single');
        tau_RRP = tau_RRP0*ones(1,nneurons,'single');
    end
end

if SRA == 1
    p_th_SRA = 0.2;
    tau_SRA = 50; % ms
    sigma_SRA = 0; % std. deviation, if variation across neurons is included
end

if fac == 1
    a_th_fac = -0.15; % 1/ms
    tau_th_fac = 0.5; % ms
    a_RS_fac = 0.75; % 1/ms
    tau_RS_fac = 0.3; % ms
    sigma_fac = 0;
end

% quick accommodation
if acc == 1
    a_th_acc = 0.5; % 1/ms
    tau_th_acc = 1.5; % ms
    a_RS_acc = 0.75; % 1/ms 
    tau_RS_acc = 0.5; % ms
    sigma_acc = 0;
end

% slow accommodation
if acc_slow == 1
    a_th_acc_slow = 0.01; % 1/ms
    tau_th_acc_slow = 50; % ms
    a_RS_acc_slow = 0; % 1/ms 
    tau_RS_acc_slow = 50; % ms
    sigma_acc_slow = 0;
end