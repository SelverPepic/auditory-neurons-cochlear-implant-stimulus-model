%% recovery function extraction script
function handles = recovery_function(handles)
% pseudocode:
% find threshold stimulus current (increased from 0 until neuron spikes)
% then, choose timing of 2nd pulse (IPI)
% increase pulse amplitude until neuron spikes
% reduce IPI, start from previous pulse amplitude (saves time)
% repeat
% NOTE: all noise is temporarily disabled in this function

%% initialize
% save old pulse amplitude and width, noise and stim type setting
A_temp = handles.stimulation.A;
A2_temp = handles.stimulation.A2;
tIPI_temp = handles.stimulation.tIPI;
nneurons_temp = handles.parameters.nneurons;
modeltype_temp = handles.modeltype;
stimtype_temp = handles.stimulation.stim_type;
handles.parameters.nneurons = 1;
handles.modeltype.noise_mem = 0; % shut down noise
handles.modeltype.noise_ref = 0;
handles.stimulation.stim_type = 2; % use double pulse stimulation

% initializate (tIPI,A2) data
tIPI = [ 1:(-0.05):0.1]; % ms, tIPI
A2 = zeros(size(tIPI)); % pA, saves A2 threshold data
handles.stimulation.A = 40; % pA, first pulse amplitude
handles.stimulation.A2 = 0;  % pA, second pulse amplitude
dA = 1; % pA, pulse amplitude increment

%% find Ath0, single pulse threshold
while handles.stimulation.A < 200 % dummy, normally will not be exceeded
    handles = IFmain(handles);
    if isempty(cell2mat(handles.spiketimes)) % check if neuron spiked
        % if no spike, increase A by dA
        handles.stimulation.A = handles.stimulation.A + dA;
    else
        Ath0 = handles.stimulation.A;
        break;
    end
end
handles.stimulation.A = 1.2*Ath0;
handles.stimulation.A2 = Ath0;
%nspikes = length(cell2mat(handles.spiketimes));

%% loop
tic
for j=1:length(tIPI)
    % fix one tIPI, loop A2
    handles.stimulation.tIPI = tIPI(j);
    
    while (A2(j)==0)
        handles = IFmain(handles);
        % check if neuron spiked two times
        if length(cell2mat(handles.spiketimes)) < 2
            % if not, increase A2 by dA
            handles.stimulation.A2 = handles.stimulation.A2 + dA;
        else        
            A2(j) = handles.stimulation.A2;  % save current threshold
            break; % breaks while loop over A
        end
        
        % if A2 is too large, IPI inside ARP, break loop
        if (handles.stimulation.A2>=200)
            A2(j:end) = 0;
            break;
        end
        
    end % end of A2 loop
    disp([ num2str(j) ' out of ' num2str(length(tIPI)) ' iterations done.']);
    
    % special:
    % extrapolate new Ath, set dA to 1% of expected A, search from A-5*dA
    %if j>1 && j<length(tIPI)
    %    A2_extrapol = A2(j) + (A2(j)-A2(j-1))/(tIPI(j)-tIPI(j-1)) * (tIPI(j+1) - tIPI(j));
    %    dA = max(0.1, 0.01*A2_extrapol);
    %    handles.stimulation.A2 = A2_extrapol - 5*dA;
    %end
end
toc

% restore old values
handles.stimulation.A = A_temp;
handles.stimulation.A2 = A2_temp;
handles.stimulation.tIPI = tIPI_temp;
handles.parameters.nneurons = nneurons_temp;
handles.modeltype = modeltype_temp;
handles.stimulation.stim_type = stimtype_temp;

% save data
handles.recovery_tIPI = tIPI;
handles.recovery_A2 = A2;
save('test_recovery.mat','A2','tIPI','Ath0');