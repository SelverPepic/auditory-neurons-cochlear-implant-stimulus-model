%%% Population Integrate & fire model - stimulation type
%%% Master thesis, Selver Pepic, 26.09.2018
%%% ETH Zurich, UniSpital Zurich, ORL-Klinik, LEA

% List of stimulation parameters for boulet_model_main 
    % INPUTS: parameters from boulet_parameters
    % OUTPUTS: stimulation parameters (stimulus waveform etc)

%% setup
run boulet_parameters
Istim = zeros(niter,nneurons,'single');

%% choose stimulation type
% 1 = single pulse
% 2 = double pulse
% 3 = (modulated) pulse train
type = 3;
    % modulation type
    % 0 = none
    % 1 = sinusoidal
    % 2 = step
    % 3 = sawtooth
    % 4 = reversed sawtooth
    mod_type = 0;

% include spread? (0=no, 1=yes)
spread = 1;
% choose location of stimulation (0 to d_max)
d_max = 2.25; % mm, length of neuron array (also max distance to the electrode)
xneurons = (0:d_max/nneurons:d_max-d_max/nneurons)'; % the distances of the neurons to the electrode (equal ditributed)
d_spread = 0.8; % mm, width of 1/e falloff
d_stim = 0; % mm, site of stimulation / shift of the sigmoidal distance function

%% stimulus parameters (default)
A = 40; % pA
to = 0.2; % ms, initial pulse time
wo = round(to/dt);
tw = 0.057; % ms, pulse width
w = round(tw/dt);
tIPI = 2; % ms, inter pulse interval
wIPI = round(tIPI/dt);
if (tIPI<=tw)
    error("Inter-pulse interval tIPI smaller than pulse width tw (pulses overlap!)");
end

if (dt>=tw)
    error("Simulation step bigger than pulse width!");
end

%% stimulus types
% single pulse
if type == 1    
    Istim (wo:wo+w,:) = A;
    npulses = 1;
end

% double pulse
if type == 2
    Istim (wo:wo+w,:) = A;
    Istim (wo+wIPI:wo+wIPI + w,:) = A;
    npulses = 2;
end

% (modulated) pulse train
if type == 3
    A = 80; % pA
    npulses = ceil((tmax-to)/tIPI);
    mod_freq = 0.1; % frequency, kHz = 1/ms
    mod_depth = 0.08; % modulation
    
    for k = 0:npulses-1 % sum each pulse separately
        Istim (wo+k*wIPI : wo+k*wIPI + w,:) = A;
    end
    
    % modulated pulse train = pulse train * amplitude modulation
    switch mod_type
        case 0
            mod = 1;
        case 1
            mod = 1 + mod_depth * sin(2*pi*mod_freq*t'-pi/2);
        case 2
            mod = 1 + mod_depth * sign(sin(2*pi*mod_freq*t'-pi/2));
        case 3
            mod = 1 + mod_depth * sawtooth(2*pi*mod_freq*t');
        case 4
            mod = 1 + mod_depth * sawtooth(2*pi*mod_freq*t',0);
    end
    % AM
    Istim = Istim .* mod;
end

%plot(t,Istim(:,1)) % plot to check

%% stimulus spread
if spread == 1
    % Istim_center = Istim; % stimulus just below electrode
                          % other calculated as Icenter * spread function
    % x-xo - "horizontal" distance (along the cochlea)
    for k=1:nneurons
        Istim(:,k) = Istim(:,1) .* exp(-(abs(xneurons(k)-d_stim)/d_spread));
        % or use: .* exp(-1*sqrt((x(k)-x0).^2+y.^2)/dist_spread);
    end
    % plot(xneurons, Istim(wo,:)) % plot to check the spread profile
end