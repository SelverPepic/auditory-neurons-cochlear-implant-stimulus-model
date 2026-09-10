%%% Population Integrate & fire model - stimulation type
%%% Master thesis, Selver Pepic, 26.09.2018
%%% ETH Zurich, UniSpital Zurich, ORL-Klinik, LEA
function handles = initIFstimulation(handles)
% Function to declare stimulation parameter ONLY for the initial execution of GUI.
% For all other cases IFstimulation function is used (e.g. when pulse
% amplitude is changed, IFstimulation is called to generate new stim waveform)

% INPUTS:
    % handles.parameters - simulation and neural parameters
% OUTPUTS:
    % s - stimulation parameters, stimulus waveform
    % modeltype - defines the type of the stimulation (e.g. pulse train, 
        % saw modulation) and the stimulus model used (e.g. spread of exc)
    
%% setup
p = handles.parameters; % temporary variables, used to keep the code "clean"
modeltype = handles.modeltype;

s.Istim = zeros(p.niter,p.nneurons);
s.npulses = 0;

%% choose stimulation type
% 0 = no stimulation
% 1 = single pulse
% 2 = double pulse
% 3 = (modulated) pulse train
s.stim_type = 3;
    % modulation type
    % 0 = none
    % 1 = sinusoidal
    % 2 = step
    % 3 = sawtooth
    % 4 = reversed sawtooth
if s.stim_type == 3
    s.mod_type = 3;
    s.mod_in_CL = 0;
end

% include spread? (0=no, 1=yes)
modeltype.spread = 1;
% choose spread type (1 = exp-abs, 2 = rounded exp)
modeltype.spread_type = 1;

% choose location of stimulation (0 to d_max)
if modeltype.spread == 1
    s.d_max = 2.25; % mm, length of neuron array (also max distance to the electrode)
    s.xneurons = (0:s.d_max/p.nneurons:s.d_max-s.d_max/p.nneurons)'; % the distances of the neurons to the electrode (equal ditributed)
    s.d_stim = 0; % mm, site of stimulation / shift of the sigmoidal distance function
    s.d_spread = 0.8; % mm, exp abs, width of 1/e falloff
    s.p_left = 4.1; % normalized, rounded exp, falloff left
    s.p_right = 4.54; % normalized, rounded exp, falloff right
end

%% stimulus parameters (default)
s.A = 70; % pA
s.A2 = s.A; % pA
s.to = 0; % ms, initial pulse time
s.wo = round(s.to/p.dt)+1;
s.tw = 0.057; % ms, pulse width
s.w = round(s.tw/p.dt);
s.tIPI = 1; % ms, inter pulse interval
s.wIPI = round(s.tIPI/p.dt);
if (s.tIPI <= s.tw)
    error("Inter-pulse interval tIPI smaller than pulse width tw (pulses overlap!)");
end

if (p.dt >= s.tw)
    error("Simulation step bigger than pulse width!");
end

%% stimulus types
% single pulse
if s.stim_type == 1    
    s.Istim (s.wo : s.wo+s.w,:) = s.A;
    s.npulses = 1;
end

% double pulse
if s.stim_type == 2
    s.Istim (s.wo : s.wo+s.w,:) = s.A;
    s.Istim (s.wo+s.wIPI : s.wo+s.wIPI + s.w,:) = s.A2;
    s.npulses = 2;
end

% (modulated) pulse train
if s.stim_type == 3
    s.A = 100; % pA
    s.npulses = ceil((p.tmax-s.to)/s.tIPI);
    s.mod_freq = 0.1; % frequency, kHz = 1/ms
    s.mod_depth = 0.8; % modulation
    
    for k = 0:s.npulses-1 % sum each pulse separately
        s.Istim (s.wo+k*s.wIPI : s.wo+k*s.wIPI + s.w,:) = s.A;
    end
    
    % modulated pulse train = pulse train * amplitude modulation
    switch s.mod_type
        case 0
            s.mod = 1;
        case 1
            s.mod = 1 + s.mod_depth * sin(2*pi*s.mod_freq * p.t'-pi/2);
        case 2
            s.mod = 1 + s.mod_depth * sign(sin(2*pi*s.mod_freq * p.t'-pi/2));
        case 3
            s.mod = 1 + s.mod_depth * sawtooth(2*pi*s.mod_freq * p.t');
        case 4
            s.mod = 1 + s.mod_depth * sawtooth(2*pi*s.mod_freq * p.t',0);
    end
    % AM
    s.Istim = s.Istim .* s.mod;
end

%plot(p.t,s.Istim(:,1)) % plot to check

%% stimulus spread
% extracellular to intracellular spread
s.scaling_ex_to_in = 91/900; % 91 pA/900 muA;

% longitudinal spread
s.xneurons = (0:s.d_max/p.nneurons:s.d_max-s.d_max/p.nneurons)';
s.spread = ones(size(s.xneurons));

% calculate spread function
if modeltype.spread_type == 1
    % exp abs
    s.spread = exp(-(abs(s.xneurons-s.d_stim)/s.d_spread));
elseif modeltype.spread_type == 2
    % rounded exp
    if s.d_stim < 0.5*s.d_max
        g = (s.xneurons-s.d_stim)/(s.d_max-s.d_stim);
    else
        g = (s.xneurons-s.d_stim)/(s.d_stim);
    end
    s.spread = (g<0) .* (1-s.p_left.*g).*exp(s.p_left.*g) + ...
         (g>=0) .* (1+s.p_right.*g).*exp(-s.p_right.*g);
end
    
% multiply Istim with spread function
if modeltype.spread == 1
    Istim_center = s.Istim; % stimulus just below electrode
                            % other calculated as I_center * spread function
    % x-xo - "horizontal" distance (along the cochlea)
    for k=1:p.nneurons
        s.Istim(:,k) = Istim_center(:,1) .* s.spread(k);
        % or use: .* exp(-1*sqrt((x(k)-x0).^2+y.^2)/dist_spread);
    end
    % plot(s.xneurons, s.Istim(s.wo,:)) % plot to check the spread profile
end

%% "upload" parameters/variables
handles.parameters = p;
handles.stimulation = s;
handles.modeltype = modeltype;