function [newValue, mean_error, std_error, handles] = LinearOptimization(handles, value_start, value_step, value_end, name)
%% Taken from Hess 2017 semester project paper
% Function to find the optimal value of a neural parameter - parameter value
% is changed inside the given bounds and the value creating the smallest
% mean_error (predicted minus measured ECAP) is choosen.

% INPUTS:
    % name - string name of parameter to be optimized
    % value_start - lower bound for parameter value
    % value_end - upper bound for parameter value
    % value_step - increment/step in parameter value
% OUTPUTS:
    % newValue - value of parameter for minimum mean_error
    % mean_error - minimum mean error (i.e. for parameter=newValue)
    % std_error - minimum square differences error (i.e. for parameter=newValue)

value_vector = value_start:value_step:value_end;
mean_error_list = zeros(size(value_vector));
std_error_list = zeros(size(value_vector));


for index = 1:length(value_vector)
    current_value = value_vector(index);
    eval([ name '=' num2str(current_value) ';']); % set new value
    testvar(index) = handles.stimulation.A;
    handles = IFmain(handles);
    ECAP_amp_norm = handles.ECAP_amp'/max(handles.ECAP_amp);
    error_distance = ECAP_amp_norm - handles.data.ECAP_amp;
    mean_error_list(index) = mean(abs(error_distance));
    std_error_list(index) = std(abs(error_distance));
end

index_min = find(mean_error_list == min(mean_error_list),1,'first');
newValue = value_vector(index_min);
mean_error = mean_error_list(index_min);
std_error = std_error_list(index_min);

ECAP_amp_data = handles.data.ECAP_amp;
%save('test.mat','ECAP_amp_data','ECAP_amp_norm','mean_error_list');