%%% Population Integrate & fire model - neural and simulation parameter list
%%% Master thesis, Selver Pepic, 26.09.2018
%%% ETH Zurich, UniSpital Zurich, ORL-Klinik, LEA
%%% All values taken from J.Boulet PhD thesis (unless otherwise noted)

function handles = initIFparameters(handles)
% Function to declare parameter ONLY for the initial execution of GUI.
% For all other cases parameters are obtained from the GUI and all
% dependent variables (e.g. timevector) are calculated inside IFmain function

% INPUTS: none
% OUTPUTS:
    % p - list of neuronal and simulation parameters
    % modeltype - defines the type of the model used (which effects are
        % included e.g. SRA, noise etc)
        
        
%% physical parameters
p.vrest = 0; % mV, resting potential
p.vth0 = 30; % mV, threshold potential
p.vth0_spread_norm = 0.3;
p.vreset = -10; % mV, reset potential
p.vspike = 100; % mV, spike potential
p.R = 1.9535; % GOhm
p.C = 0.0714; % pF
% tau_mem = R*C = 0.1395 ms
% when tau longer than excitatory pulses, passive facillitation possible

%% simulation parameters
p.nneurons = 100;
p.tmax = 60; % ms
p.dt = 0.005; % ms (dt = 0.1 mus)
p.niter = round(p.tmax/p.dt);
p.t = p.dt:p.dt:p.tmax;
if length(p.t) ~= p.niter
    t = linspace(p.dt,p.tmax,niter);
end
%k = 1:nneurons; % neuron count array
%x = linspace(0,20,nneurons); % positions of neurons (used for stimulus spread)
% linear distribution used for simplicity, "length" of electrode array = 20

%% MODEL TYPE CHOICE
% OPTIONAL: membrane noise, refractory period, SRA, adaptation, facilitation
modeltype.noise_mem = 1; % membrane noise
modeltype.vth0_stochastic = 0;
    modeltype.vth0_stochastic_fixed = 0;

modeltype.ref = 1;
modeltype.noise_ref = 1;
    modeltype.ref_stochastic = 1;
    modeltype.ref_stochastic_fixed = 1;
modeltype.SRA = 1;
modeltype.noise_SRA = 1;
modeltype.fac = 1;
modeltype.noise_fac = 1;
modeltype.acc = 1; % quick
modeltype.noise_acc = 1;
modeltype.acc_slow = 1; % slow
modeltype.noise_acc_slow = 1;

%% neuronal parameters
if modeltype.noise_mem == 1
    p.RS_mem = 0.0774; % unitless (from Fredelake et al 2012)    
    noise = normrnd(0,1,[p.niter,p.nneurons]); % rand vector, std=1
    % filter noise: lowpass, cutoff 200 Hz, 3 dB/octave (Fredelake et al 2012)
    n = 1; % order
    fsample = 1/p.dt*1000; % Hz, since [dt] = ms
    fcut = 200; % Hz
    fcut_norm = fcut/(fsample/2);
    [b,a] = butter(n,fcut_norm,'low');
    noise_filt = filter(b,a,noise); % rand vector, std now smaller!
    p.vth_sigma = single( p.vth0 * p.RS_mem/mean(std(noise_filt)) * noise_filt); % std scaled
    % the above could be done for each neuron separately, here only the
    % mean std is scaled
    %figure(1)
    %plot(t,vth_sigma)
    %[px,f] = periodogram(vth_sigma);
    %figure(2)
    %plot(f,10*log10(px));
end

if modeltype.ref == 1
    p.T_ARP0 = 0.332; % 0.5; % 0.332 ms
    p.tau_RRP0 = 0.411; % 1.3; % 0.411 ms
    p.sigma_ref = 0.1; % refractory noisiness
    p.rho_corr = 0.5;
    p.a_RS_ref = 1;
    p.tau_RS_ref = 0.2; % ms
    
    if modeltype.ref_stochastic == 1
        T_ARP = p.T_ARP0*ones(1,p.nneurons,'single');
        tau_RRP = p.tau_RRP0*ones(1,p.nneurons,'single');
        % T and tau vary across neurons
        p.T_ARP = single(normrnd(p.T_ARP0, p.sigma_ref,[1,p.nneurons]));
            p.T_ARP (p.T_ARP<0.05) = p.T_ARP0; % ensures no zeros exist;
        p.tau_RRP = normrnd(p.tau_RRP0, p.sigma_ref,[1,p.nneurons]);
        p.tau_RRP = single(random_correlated(p.T_ARP',p.tau_RRP',p.rho_corr)');
            p.tau_RRP (p.tau_RRP<0.05) = p.tau_RRP0; % ensures no zeros exist;
        %r = corr(T_ARP',tau_RRP')
    else
        p.T_ARP = p.T_ARP0*ones(1,p.nneurons,'single');
        p.tau_RRP = p.tau_RRP0*ones(1,p.nneurons,'single');
    end
end

if modeltype.SRA == 1
    p.p_th_SRA = 0.04;
    p.tau_th_SRA = 50; % ms
    % RS variables are taken to be identical
    p.p_RS_SRA = 0.04;
    p.tau_RS_SRA = 50; % ms
    p.sigma_SRA = 0; % std. deviation, if variation across neurons is included
end

if modeltype.fac == 1
    p.a_th_fac = -0.15; % 1/ms
    p.tau_th_fac = 0.5; % ms
    p.a_RS_fac = 0.75; % 1/ms
    p.tau_RS_fac = 0.3; % ms
    p.sigma_fac = 0;
end

% quick accommodation
if modeltype.acc == 1
    p.a_th_acc = 0.5; % 1/ms
    p.tau_th_acc = 1.5; % ms
    p.a_RS_acc = 0.75; % 1/ms 
    p.tau_RS_acc = 0.5; % ms
    p.sigma_acc = 0;
end

% slow accommodation
if modeltype.acc_slow == 1
    p.a_th_acc_slow = 0.01; % 1/ms
    p.tau_th_acc_slow = 50; % ms
    p.a_RS_acc_slow = 0; % 1/ms 
    p.tau_RS_acc_slow = 50; % ms
    p.sigma_acc_slow = 0;
end

%% save all parameters
handles.parameters = p;
handles.modeltype = modeltype;