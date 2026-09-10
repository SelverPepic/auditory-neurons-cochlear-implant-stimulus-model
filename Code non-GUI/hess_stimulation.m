%%% Population Integrate & fire model - stimulation type
%%% Master thesis, Selver Pepic, 26.09.2018
%%% ETH Zurich, UniSpital Zurich, ORL-Klinik, LEA

% Replica of stimulation parameters used in Hess 2017 semester project paper

%% setup
run hess_parameters
Istim = zeros(niter,nneurons);

%% choose stimulation type
% 1 = single pulse
% 2 = double pulse
% 3 = (modulated) pulse train
type = 3;
    % modulation type
    % 0 = none
    % 1 = sinusoidal
    % 2 = step/square
    % 3 = sawtooth
    % 4 = reversed sawtooth
    mod_type = 4;

% include spread? (0=no, 1=yes)
spread = 1;
% choose location of stimulation (0 to 20 mm)
x0 = 0;

%% stimulus parameters (default)
A = 100; % pA
to = 1; % ms, initial pulse time
wo = round(to/dt);
tw = 0.057; % ms, pulse width
w = round(tw/dt);
tIPI = 1; % ms, inter pulse interval
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
end

% double pulse
if type == 2
    Istim (wo:wo+w,:) = A;
    Istim (wo+wIPI:wo+wIPI + w,:) = A;
end

% (modulated) pulse train
if type == 3
    A = 100; % pA
    npulses = ceil((tmax-to)/tIPI);
    mod_freq = 0.1; % frequency, kHz = 1/ms
    mod_depth = 0.8; % modulation
    
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
    Istim_center = Istim; % stimulus just below electrode (can be changed)
                          % other calculated as Icenter * spread function
    dist_max = 2.25; % max distance of the neurons to the electrode
    dist_shift = 0; % shift of the sigmoidal distance function
    dist_spread = 0.8; % slope of the sigmoidal distance function
    xNeurons = (0:dist_max/nneurons:dist_max-dist_max/nneurons)'; % the distances of the neurons to the electrode (equal ditributed)
    %ScaledAmps = PulseAmp * exp(-(abs(xNeurons-dist_shift)/dist_spread));
    
    y = 0; % "perpendicular" distance of electrode to the nerve
    % x-xo - "horizontal" distance (along the cochlea)
    for k=1:nneurons
        Istim(:,k) = Istim_center(:,1) .* exp(-(abs(xNeurons(k)-dist_shift)/dist_spread));
        %.* exp(-1*sqrt((x(k)-x0).^2+y.^2)/dist_spread);
    end
    % also possible: exp(-1*abs(x(k)-x0)/dspread)
    % plot(Istim(wo,:)) % plot to check the spread profile
end