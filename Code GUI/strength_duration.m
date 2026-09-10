function handles = strength_duration(handles)
%% function to obtain strength-duration curve
% pseudocode:
% choose pulse width (tpulse)
% increase pulse amplitude until neuron spikes
% reduce pulse width, start from previous pulse amplitude OR expected amplitude (linear extrapolation)
% repeat
% NOTE: all noise is temporarily disabled in this function

% save old pulse amplitude and width, noise and stim type setting
A_temp = handles.stimulation.A;
tw_temp = handles.stimulation.tw;
nneurons_temp = handles.parameters.nneurons;
modeltype_temp = handles.modeltype.noise_mem;
stimtype_temp = handles.stimulation.stim_type;

% initializate (tw,A) data
tw = [ 0.5:(-0.05):0.2 0.1:(-0.005):0.01 ]; %   ms, pulse width
A = zeros(size(tw));
A_extrapol = zeros(size(tw));

% pre-loop
handles.modeltype.noise_mem = 0; % shut down noise
handles.stimulation.stim_type = 1; % use single pulse stimulation
handles.parameters.nneurons = 1;
handles.stimulation.A = 0; % pA, initial pulse amplitude
dA = 1; % pA, pulse amplitude increment, initially coarse, later fine

tic
for j=1:length(tw)
    % fix pulse width, loop A
    handles.stimulation.tw = tw(j);
    
    while (A(j)==0)
        handles = IFmain(handles);
        
        if (isempty(cell2mat(handles.spiketimes))) % check if neuron spiked
            % if no spike, increase A by dA
            handles.stimulation.A = handles.stimulation.A + dA;
        else
            % if this is the 1st spike overall (resolution is course),
            % then step back and increase the resolution
            % otherwise, save current threshold and go to new tw
            if j==1 && dA == 1
                handles.stimulation.A = handles.stimulation.A - dA;
                dA = dA/10;
            else
                A(j) = handles.stimulation.A;
                break; % breaks while loop over A
            end
        end       
    end % end of A loop
    disp([ num2str(j) ' out of ' num2str(length(tw)) ' iterations done.']);
    
    % special:
    % extrapolate new Ath, set dA to 1% of expected A, search from A-5*dA
    if j>1 && j<length(tw)
        A_extrapol(j+1) = A(j) + (A(j)-A(j-1))/(tw(j)-tw(j-1)) * (tw(j+1)-tw(j));
        dA = max(0.1, 0.01*A_extrapol(j+1));
        handles.stimulation.A = A_extrapol(j+1) - 5*dA;
    end
end
toc

% restore old values
handles.stimulation.A = A_temp;
handles.stimulation.tw = tw_temp;
handles.modeltype.noise_mem = modeltype_temp;
handles.stimulation.stim_type = stimtype_temp;
handles.parameters.nneurons = nneurons_temp;

% save data
handles.chronaxie_tw = tw;
handles.chronaxie_A = A;

A_extrapol(1) = A(1);
A_extrapol(2) = A(2);
save('test.mat','A','tw','A_extrapol');