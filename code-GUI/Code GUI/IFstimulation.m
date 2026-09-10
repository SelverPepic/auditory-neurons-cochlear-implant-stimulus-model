%%% Population Integrate & fire model - stimulation type
%%% Master thesis, Selver Pepic, 26.09.2018
%%% ETH Zurich, UniSpital Zurich, ORL-Klinik, LEA
function [s, modeltype] = IFstimulation(p,s,modeltype)

% Function used in GUI to calculate stimulation parameters. Called when e.g.
% pulse amplitude is changed and new stimulus waveform needs to be generate.

% INPUTS:
    % handles.parameters - simulation and neural parameters (from GUI)
    % handles.s - stimulus parameters (from GUI)
% OUTPUT:
    % s - stimulus waveform

%% setup
s.Istim = zeros(p.niter,p.nneurons);
s.npulses = 0;
s.wo = round(s.to/p.dt)+1;
s.w = round(s.tw/p.dt);
s.wIPI = round(s.tIPI/p.dt);
%if (s.tIPI <= s.tw) && s.stim_type == 3
%    error("Inter-pulse interval tIPI smaller than pulse width tw (pulses overlap!)");
%end
if (p.dt >= s.tw)
    error("Simulation step bigger than pulse width!");
end

%% stimulus types
% single pulse
if s.stim_type == 1
    s.Istim (s.wo:s.wo+s.w,:) = s.A;
    s.npulses = 1;
end

% double pulse
if s.stim_type == 2
    s.Istim(s.wo:s.wo+s.w,:) = s.A;
    s.Istim(s.wo+s.wIPI:s.wo+s.wIPI + s.w,:) = s.A2 + s.Istim(s.wo+s.wIPI:s.wo+s.wIPI + s.w,:);
    s.npulses = 2;
end

% (modulated) pulse train
if s.stim_type == 3
    s.npulses = ceil((p.tmax-s.to)/s.tIPI);
    if s.npulses == 0
        s.npulses == 1;
    end
    % unit pulse train
    for k = 0:s.npulses-1 % sum each pulse separately
        s.Istim (s.wo+k*s.wIPI : s.wo+k*s.wIPI + s.w,:) = 1;
    end
    
    if s.mod_in_CL
        mod_depth = s.mod_depth_CL;
    else
        mod_depth = s.mod_depth;
    end
    
    %    A_avr = s.A/(1+s.mod_depth_CL);
    %else
    %    A_avr = s.A/(1+s.mod_depth);
    %end
    
    % modulated pulse train = amplitude * unit pulse train * modulation
    switch s.mod_type
        case 0
            s.mod = 1;
        case 1
            s.mod = 1 + mod_depth * sin(2*pi*s.mod_freq * p.t'-pi/2);
        case 2
            s.mod = 1 + mod_depth * sign(sin(2*pi*s.mod_freq * p.t'));
        case 3
            s.mod = 1 + mod_depth * sawtooth(2*pi*s.mod_freq * p.t');
        case 4
            s.mod = 1 + mod_depth * sawtooth(2*pi*s.mod_freq * p.t',0);
    end    
    
    if s.mod_in_CL
        s.Istim = s.Istim .* s.mod .* s.A_CL/(1+s.mod_depth_CL);
        s.Istim = CL_to_exAmp(s.Istim) .* s.scaling_ex_to_in;
    else
        s.Istim = s.Istim .* s.mod .* s.A/(1+s.mod_depth);        
    end
end
s.Istim = s.Istim(1:p.niter,:);
%plot(p.t,s.Istim(:,1)) % plot to check

%% stimulus spread
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