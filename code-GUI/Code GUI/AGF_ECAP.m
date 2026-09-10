%% recovery function extraction script
function handles = AGF_ECAP(handles)
% pseudocode:
% set pulse amplitude
% measure ECAP response amplitude
% increase pulse amplitude, repeat

% INPUTS:
    % model parameters (handles)
    % initial amplitude = 0 (hardcoded)
    % Amax - maximum pulse amplitude (hardcoded)
    % dA - pulse amplitude step (hardcoded)
    % N - number of averages (hardcoded)
    
    
%% save old pulse amplitude and width, noise and stim type setting
A_temp = handles.stimulation.A;
stimtype_temp = handles.stimulation.stim_type;
modeltype_temp = handles.modeltype; % restore settings (noise etc)

%% loop
handles.stimulation.stim_type = 1; % single pulse
handles.modeltype.ref_stochastic_fixed = 1; % noise kept the same for all iterations

dA = 10; % pA, pulse amplitude increment
Amax = 250;
A = 0:dA:Amax; % pA, first pulse amplitude
ECAP_amp_AGF = zeros(size(A));
N = 3; % number of averages

tic
for j=1:length(A)
    sum = 0;
    for n=1:N
        handles.stimulation.A = A(j);
        handles = IFmain(handles);
        ECAP_amp = handles.ECAP_amp(handles.ECAP_time == handles.stimulation.to);
        sum = sum + ECAP_amp;
    end
    ECAP_amp_AGF(j) = sum/N;
    disp(['Recovery function: ' num2str(j) ' out of ' num2str(length(A)) ' iterations done']);
end
toc

% fit data
%f = fit(tIPI',max(ECAP_amp2_avr)-ECAP_amp2_avr','exp1');
%recovery_fit_tau = -1/f.b;

% restore old values
handles.stimulation.A = A_temp;
handles.modeltype = modeltype_temp;
handles.stimulation.stim_type = stimtype_temp;

% save data
handles.AGF_ECAP_amp = ECAP_amp_AGF;
handles.AGF_A = A;
%handles.recovery_ECAP_amp1 = ECAP_amp1/length(tIPI);
save('test_AGF.mat','A','ECAP_amp_AGF');