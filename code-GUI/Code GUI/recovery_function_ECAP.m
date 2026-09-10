%% script: recovery function extraction from ECAP
function handles = recovery_function_ECAP(handles)
% pseudocode:
% 1) find threshold stimulus current (increased from 0 until neuron spikes)
% 2) choose timing of 2nd pulse tIPI
%     measure ECAP response to the 2nd pulse
%     repeat with new tIPI
% Mosc(..) paper: "The masker stimulus CL corresponded to LAPL,
% and the probe stimulus CL was 10 CL lower than LAPL."

% INPUTS:
    % parameters (from handles)
    % A, A2 - masker and probe pulse amplitudes (hardcoded, see below)
    % tIPI - inter-pulse intervals vector (hardcoded, see below)
    % N - number of averages (needed due to the noise)
    
    
%% save old pulse amplitude and width, noise and stim type setting
A_temp = handles.stimulation.A;
A2_temp = handles.stimulation.A2;
tIPI_temp = handles.stimulation.tIPI;
nneurons_temp = handles.parameters.nneurons;
modeltype_temp = handles.modeltype;
stimtype_temp = handles.stimulation.stim_type;

%% find Ath0, single pulse threshold
% threshold should be found from AGF first, load data!
handles.stimulation.stim_type = 1;
handles.parameters.nneurons = 1;
handles.modeltype.noise_mem = 0; % shut down noise

% bisection search for Ath0 (only bottom and top values are hardcoded)
bottom = 0;
handles.stimulation.A = bottom;
handles = IFmain(handles);
cond_bottom = ~isempty(cell2mat(handles.spiketimes)); % 0 if empty
top = 200;
handles.stimulation.A = top;
handles = IFmain(handles);
cond_top = ~isempty(cell2mat(handles.spiketimes));   % 1 if NOT empty

while (top-bottom) > 1
    middle = (top+bottom)/2;
    handles.stimulation.A = middle;
    handles = IFmain(handles);
    cond_middle = ~isempty(cell2mat(handles.spiketimes));
    
    if cond_bottom==0 && cond_top == 1
        if cond_middle == 0
            bottom = middle;
            handles.stimulation.A = bottom;
            handles = IFmain(handles);
            cond_bottom = ~isempty(cell2mat(handles.spiketimes));
    
        elseif cond_middle == 1
            top = middle;
            handles.stimulation.A = top;
            handles = IFmain(handles);
            cond_top = ~isempty(cell2mat(handles.spiketimes)); 
        end
    else
        error('EITHER spike(BOTTOM) == 1 or spike(TOP) == 0');
    end
end
Ath0 = handles.stimulation.A;

%% loop
handles.stimulation.stim_type = 2; % double pulse
handles.stimulation.A = 2*Ath0; % masker (fixed)
handles.stimulation.A2 = 2*Ath0; % pulse (fixed)
handles.parameters.nneurons = nneurons_temp;
handles.modeltype = modeltype_temp; % restore settings (noise etc)
handles.modeltype.ref_stochastic_fixed = 1;
% T_ARP/tau_RRP is variable across neurons, but kept constant in time for all iterations!

% initializate (tIPI,ECAP_amp2) data
tIPI = [2:(-0.1):0.5 0.4:(-0.1):0]; % ms, tIPI
ECAP_amp2_avr = zeros(size(tIPI)); % 2nd pulse ECAP amplitude
N = 5; % number of averages

tic
for j=1:length(tIPI)
    sum = 0;
    for n=1:N
        handles.stimulation.tIPI = tIPI(j);
        handles = IFmain(handles);
        %ECAP_save{j} = handles.ECAP_amp;
        % get ECAP amp of 2nd pulse
        t2 = handles.stimulation.to + handles.stimulation.tIPI;
        ECAP_amp2 = handles.ECAP_amp(handles.ECAP_time == t2);
        % get ECAP amp of 1nd pulse (added and averaged later)
        t1 = handles.stimulation.to;
        ECAP_amp1 = handles.ECAP_amp(handles.ECAP_time == t1);
        sum = sum + ECAP_amp2/ECAP_amp1;
    end
    ECAP_amp2_avr(j) = sum/N;
    disp(['Recovery function: ' num2str(j) ' out of ' num2str(length(tIPI)) ' iterations done']);
end
toc

% fit data
%f = fit(tIPI',max(ECAP_amp2_avr)-ECAP_amp2_avr','exp1');
%recovery_fit_tau = -1/f.b;

% restore old values
handles.stimulation.A = A_temp;
handles.stimulation.A2 = A2_temp;
handles.stimulation.tIPI = tIPI_temp;
handles.parameters.nneurons = nneurons_temp;
handles.modeltype = modeltype_temp;
handles.stimulation.stim_type = stimtype_temp;

% save data
handles.recovery_tIPI = tIPI;
handles.recovery_ECAP_amp2_avr = ECAP_amp2_avr;
%handles.recovery_ECAP_amp1 = ECAP_amp1/length(tIPI);
save('test_recovery.mat','ECAP_amp2_avr','tIPI');