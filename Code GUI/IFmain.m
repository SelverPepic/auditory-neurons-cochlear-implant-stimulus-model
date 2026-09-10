%%% MAIN
function handles = IFmain(handles)
% Function used in mainGUI to set up variables needed to execute the 
% Integrate & Fire model, execute the model to obtain voltage response and 
% spiketimes, and then calculate the corresponding ECAP response.

% All parameters are taken directly from the GUI, and when necessary
% stimulus waveform is calculated before the loop in function IFmodel is
% executed.

% INPUTS:
    % handles.parameters - neuronal and simulation parameters (GUI)
    % handles. stimulation - stimulus parameters and waveform (GUI,IFstimulation)
    % APamp - unit action potential positive and negative peak heights (hardcoded)
    % APstd - unit action potential positive and negative peak widths (hardcoded)
    % noise filtering: n - order, fcut - lowpass cutoff, filter type (hardcoded)
    
% OUTPUTS:
    % v - voltage response (for each neuron)
    % spiketimes (for each neuron)
    % ECAP_time - ECAP time points
    % ECAP_amp - ECAP amplitudes at ECAP time points 

    % IF light version of the code is NOT used:
    % vth - membrane threshold over time (for each neuron)
    % x - threshold/noise modifiers due to ref/sra/fac/acc
    

%% do NOT execute if no go command is activated
if handles.no_go == 1
    return;
end
% this creates issues later on, see readme file!

%% "download" all parameters
p = handles.parameters;
s = handles.stimulation;
modeltype = handles.modeltype;

%% Calculate dependent parameters/variables
p.niter = round(p.tmax/p.dt);
p.t = p.dt:p.dt:p.tmax;
if length(p.t) ~= p.niter
    p.t = linspace(p.dt,p.tmax,p.niter);
end

% Get stimulus current
[s, modeltype] = IFstimulation(p,s,modeltype);


% Threshold stochasticity
if modeltype.vth0_stochastic == 0
    p.vth0_stoch = p.vth0 * ones(1,p.nneurons,'single');
elseif modeltype.vth0_stochastic_fixed == 1 && length(p.vth0_stoch) == p.nneurons
    % keep previous values
else
    % calculate new values
    %vth0 = 30;
    %p.vth0_spread_norm = 0.3;
    vth0_spread = p.vth0 * p.vth0_spread_norm;
    p.vth0_stoch = single( normrnd(p.vth0,vth0_spread,[1,p.nneurons]) );
    p.vth0_stoch(p.vth0_stoch<=0) = p.vth0;
end

% Membrane threshold noise
    % filter: lowpass, cutoff 200 Hz, 3 dB/octave (Fredelake 2012)
    n = 1; % order
    fsample = 1/p.dt*1000; % Hz, since [dt] = ms
    fcut = 200; % Hz
    fcut_norm = fcut/(fsample/2);
[b,a] = butter(n,fcut_norm,'low');
noise_filt = filter(b,a,normrnd(0,1,[p.niter,p.nneurons])); % rand vector, std now smaller!
p.vth_sigma = single(p.vth0 * p.RS_mem/mean(std(noise_filt)) * noise_filt); % std scaled

% ARP-RRP noise correlation
% if (ref_noise fixed) and number of neurons has not changed
% keep same values,
% else calculate new T_arp and tau_rrp vectors
if modeltype.ref_stochastic == 0
    p.T_ARP = p.T_ARP0*ones(1,p.nneurons,'single');
    p.tau_RRP = p.tau_RRP0*ones(1,p.nneurons,'single');
else
    if modeltype.ref_stochastic_fixed == 1 && length(p.T_ARP) == p.nneurons
        %p.T_ARP = p.T_ARP; % keep previous values
        %p.tau_RRP = p.tau_RRP;
    else
        % calculate new values
        T_ARP = p.T_ARP0*ones(1,p.nneurons,'single');
        tau_RRP = p.tau_RRP0*ones(1,p.nneurons,'single');
        % T and tau vary across neurons, but not in time
        p.T_ARP = single(normrnd(p.T_ARP0, p.sigma_ref,[1,p.nneurons]));
            p.T_ARP (p.T_ARP<0.05) = p.T_ARP0; % ensures no zeros exist;
        p.tau_RRP = normrnd(p.tau_RRP0, p.sigma_ref,[1,p.nneurons]);
        p.tau_RRP = single(random_correlated(p.T_ARP',p.tau_RRP',p.rho_corr)');
            p.tau_RRP (p.tau_RRP<0.05) = p.tau_RRP0; % ensures no zeros exist;
        %r = corr(T_ARP',tau_RRP')
    end
end

%% main loop
% calculate v,vth,spiketimes,x (or only v,spiketimes if using light version)
if ~handles.light_code
    [v, vth, spiketimes, x] = IFmodel(p,s,modeltype);
else
    [v, spiketimes] = IFmodel_light2(p,s,modeltype);
end

%% post processing
% plot v, vth, Istim, histogram, ISI
%plot_results(v,vth,spiketimes, parameters, stimulation)

% get ECAP
APamp = [0.12 0.09]; % muV
APstd = [0.12 0.16]; % ms
[ECAP_amp, ECAP_time] = getECAP(spiketimes, APamp, APstd, ...
    s.npulses, s.tIPI, s.to, p.nneurons, p.tmax);

%% save results ("upload" variables)
handles.parameters = p;
handles.stimulation = s;
handles.v = v;
if ~handles.light_code
    handles.vth = vth;
    handles.x = x;
end
handles.spiketimes = spiketimes;
handles.ECAP_amp = ECAP_amp;
handles.ECAP_time = ECAP_time;