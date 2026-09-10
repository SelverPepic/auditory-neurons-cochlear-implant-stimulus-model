function varargout = mainGUI(varargin)
% MAINGUI MATLAB code for mainGUI.fig
%      MAINGUI, by itself, creates a new MAINGUI or raises the existing
%      singleton*.
%
%      H = MAINGUI returns the handle to a new MAINGUI or the handle to
%      the existing singleton*.
%
%      MAINGUI('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in MAINGUI.M with the given input arguments.
%
%      MAINGUI('Property','Value',...) creates a new MAINGUI or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before mainGUI_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to mainGUI_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help mainGUI

% Last Modified by GUIDE v2.5 04-Apr-2019 20:09:24

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @mainGUI_OpeningFcn, ...
                   'gui_OutputFcn',  @mainGUI_OutputFcn, ...
                   'gui_LayoutFcn',  [] , ...
                   'gui_Callback',   []);
if nargin && ischar(varargin{1})
    gui_State.gui_Callback = str2func(varargin{1});
end

if nargout
    [varargout{1:nargout}] = gui_mainfcn(gui_State, varargin{:});
else
    gui_mainfcn(gui_State, varargin{:});
end
% End initialization code - DO NOT EDIT


% --- Executes just before mainGUI is made visible.
function mainGUI_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to mainGUI (see VARARGIN)

% Choose default command line output for mainGUI
handles.output = hObject;

% Enlarge figure to full screen.
set(gcf, 'units','normalized','outerposition',[0 0 1 1]);

% set up parameters:
    handles = init_GUI_parameters(handles);
% execute the algorithm:
    set(handles.text_calculating,'Visible','On'); drawnow;
    handles = IFmain(handles);
    set(handles.text_calculating,'Visible','Off'); drawnow;
% plot results:
    handles = plot_results(handles);

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes mainGUI wait for user response (see UIRESUME)
% uiwait(handles.figure1);

% --- Outputs from this function are returned to the command line.
function varargout = mainGUI_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


%% Initialize parameters function
function handles = init_GUI_parameters(handles)
% get default parameters
handles = initIFparameters(handles); % simulation and neuron parameters
handles = initIFstimulation(handles); % load stimulation parameters
handles.no_go = 0; % variable stopping code execution
handles.light_code = 1; % variable determining which version of IF
set(handles.checkbox_light_code, 'Value', handles.light_code);
handles.modeltype.noise_mem_fixed = 1;
set(handles.checkbox_noise_mem_fixed, 'Value', handles.modeltype.noise_mem_fixed);


% Set model parameters to edit boxes:
% sim parameters
set(handles.edit_nneurons,'String',handles.parameters.nneurons);
set(handles.edit_tmax,'String',handles.parameters.tmax);
set(handles.edit_dt,'String',handles.parameters.dt);
% physical parameters
set(handles.edit_R,'String',handles.parameters.R);
set(handles.edit_C,'String',handles.parameters.C);
set(handles.text_tau_mem,'String',handles.parameters.R .* handles.parameters.C);
set(handles.edit_vrest,'String',handles.parameters.vrest);
set(handles.edit_vth0,'String',handles.parameters.vth0);
set(handles.edit_vth0_spread_norm,'String',handles.parameters.vth0_spread_norm);
set(handles.edit_vreset,'String',handles.parameters.vreset);
set(handles.edit_vspike,'String',handles.parameters.vspike);

% model type choice
set(handles.checkbox_noise_mem, 'Value', handles.modeltype.noise_mem);
set(handles.checkbox_vth0_stochastic, 'Value', handles.modeltype.vth0_stochastic);
set(handles.checkbox_vth0_stochastic_fixed, 'Value', handles.modeltype.vth0_stochastic_fixed);

set(handles.checkbox_ref, 'Value', handles.modeltype.ref);
set(handles.checkbox_noise_ref, 'Value', handles.modeltype.noise_ref);
set(handles.checkbox_ref_stochastic, 'Value', handles.modeltype.ref_stochastic);
set(handles.checkbox_ref_stochastic_fixed, 'Value', handles.modeltype.ref_stochastic_fixed);

set(handles.checkbox_SRA, 'Value', handles.modeltype.SRA);
set(handles.checkbox_noise_SRA, 'Value', handles.modeltype.noise_SRA);
set(handles.checkbox_fac, 'Value', handles.modeltype.fac);
set(handles.checkbox_noise_fac, 'Value', handles.modeltype.noise_fac);
set(handles.checkbox_acc, 'Value', handles.modeltype.acc);
set(handles.checkbox_noise_acc, 'Value', handles.modeltype.noise_acc);
set(handles.checkbox_acc_slow, 'Value', handles.modeltype.acc_slow);
set(handles.checkbox_noise_acc_slow, 'Value', handles.modeltype.noise_acc_slow);

% noise_membrane
if handles.modeltype.noise_mem == 1
    set(handles.edit_RS_mem,'String',handles.parameters.RS_mem);
else    
    set(handles.edit_RS_mem,'String',0.0774);
end
% refractoriness
if handles.modeltype.ref == 1
    set(handles.edit_T_ARP0,'String',handles.parameters.T_ARP0);
    set(handles.edit_tau_RRP0,'String',handles.parameters.tau_RRP0);
    set(handles.edit_sigma_ref,'String',handles.parameters.sigma_ref);
    set(handles.edit_rho_corr,'String',handles.parameters.rho_corr);
    set(handles.edit_a_RS_ref,'String',handles.parameters.a_RS_ref);
    set(handles.edit_tau_RS_ref,'String',handles.parameters.tau_RS_ref);
else
    set(handles.edit_T_ARP0,'String',0.332);
    set(handles.edit_tau_RRP0,'String',0.411);
    set(handles.edit_sigma_ref,'String',0.1);
    set(handles.edit_rho_corr,'String',0.5);
    set(handles.edit_a_RS_ref,'String',1);
    set(handles.edit_tau_RS_ref,'String',0.2);
end
% SRA
if handles.modeltype.SRA == 1
    set(handles.edit_p_th_SRA,'String',handles.parameters.p_th_SRA);
    set(handles.edit_tau_th_SRA,'String',handles.parameters.tau_th_SRA);
    set(handles.text_p_RS_SRA,'String',handles.parameters.p_RS_SRA);
    set(handles.text_tau_RS_SRA,'String',handles.parameters.tau_RS_SRA);
else
    set(handles.edit_p_th_SRA,'String',0.04);
    set(handles.edit_tau_th_SRA,'String',50);
    set(handles.text_p_RS_SRA,'String',0.04);
    set(handles.text_tau_RS_SRA,'String',50);
end
% facilitation
if handles.modeltype.fac == 1
    set(handles.edit_a_th_fac,'String',handles.parameters.a_th_fac);
    set(handles.edit_tau_th_fac,'String',handles.parameters.tau_th_fac);
    set(handles.edit_a_RS_fac,'String',handles.parameters.a_RS_fac);
    set(handles.edit_tau_RS_fac,'String',handles.parameters.tau_RS_fac);
else
    set(handles.edit_a_th_fac,'String',-0.15);
    set(handles.edit_tau_th_fac,'String',0.5);
    set(handles.edit_a_RS_fac,'String',0.75);
    set(handles.edit_tau_RS_fac,'String',0.3);
end
% quick accommodation
if handles.modeltype.acc == 1
    set(handles.edit_a_th_acc,'String',handles.parameters.a_th_acc);
    set(handles.edit_tau_th_acc,'String',handles.parameters.tau_th_acc);
    set(handles.edit_a_RS_acc,'String',handles.parameters.a_RS_acc);
    set(handles.edit_tau_RS_acc,'String',handles.parameters.tau_RS_acc);
else
    set(handles.edit_a_th_acc,'String',0.5);
    set(handles.edit_tau_th_acc,'String',1.5);
    set(handles.edit_a_RS_acc,'String',0.75);
    set(handles.edit_tau_RS_acc,'String',0.5);
end
% slow accommodation
if handles.modeltype.acc_slow == 1
    set(handles.edit_a_th_acc_slow,'String',handles.parameters.a_th_acc_slow);
    set(handles.edit_tau_th_acc_slow,'String',handles.parameters.tau_th_acc_slow);
    set(handles.edit_a_RS_acc_slow,'String',handles.parameters.a_RS_acc_slow);
    set(handles.edit_tau_RS_acc_slow,'String',handles.parameters.tau_RS_acc_slow);
else
    set(handles.edit_a_th_acc_slow,'String',0.01);
    set(handles.edit_tau_th_acc_slow,'String',50);
    set(handles.edit_a_RS_acc_slow,'String',0);
    set(handles.edit_tau_RS_acc_slow,'String',50);
end

% stimulus parameters
% stimulus type
set(handles.edit_A,'String',handles.stimulation.A);
    A_CL = exAmp_to_CL(handles.stimulation.A ./ handles.stimulation.scaling_ex_to_in);
    handles.stimulation.A_CL = A_CL;
set(handles.edit_A_CL,'String',handles.stimulation.A_CL);
set(handles.edit_stimulation_A2,'Visible','off');
set(handles.edit_stimulation_A2_CL,'Visible','off');
set(handles.text_A2,'Visible','off');

set(handles.edit_to,'String',handles.stimulation.to);
set(handles.edit_tw,'String',handles.stimulation.tw);
set(handles.edit_tIPI,'String',handles.stimulation.tIPI);
set(handles.popupmenu_stim_type,'Value',handles.stimulation.stim_type);
if handles.stimulation.stim_type == 3
    set(handles.popupmenu_mod_type,'Value',handles.stimulation.mod_type+1);
    set(handles.edit_mod_freq,'String',handles.stimulation.mod_freq);
    set(handles.edit_mod_depth,'String',handles.stimulation.mod_depth);
        A_max = handles.stimulation.A;
        A_min = A_max * (1-handles.stimulation.mod_depth)/(1+handles.stimulation.mod_depth);
        A_CL_max = exAmp_to_CL (A_max ./ handles.stimulation.scaling_ex_to_in);
        A_CL_min = exAmp_to_CL (A_min ./ handles.stimulation.scaling_ex_to_in);
        mod_depth_CL = (A_CL_max-A_CL_min)/(A_CL_max+A_CL_min);
        handles.stimulation.mod_depth_CL = round(100*mod_depth_CL)/100;
    set(handles.edit_mod_depth_CL,'String',handles.stimulation.mod_depth_CL);
else
    set(handles.popupmenu_mod_type,'String','No modulation');
    set(handles.edit_mod_freq,'String',Inf);
    set(handles.edit_mod_depth,'String',0);
    set(handles.edit_mod_depth_CL,'String',0);
end

% spread
set(handles.checkbox_spread, 'Value', handles.modeltype.spread);
set(handles.popupmenu_spread_type,'Value',handles.modeltype.spread_type);
set(handles.edit_d_spread,'Visible','on');
set(handles.edit_p_left,'String',4.54);
set(handles.edit_p_right,'String',4.1);
set(handles.edit_p_left,'Visible','off');
set(handles.edit_p_right,'Visible','off');

if handles.modeltype.spread == 1
    set(handles.edit_d_max,'String',handles.stimulation.d_max);
    set(handles.edit_d_spread,'String',handles.stimulation.d_spread);
    set(handles.edit_d_stim,'String',handles.stimulation.d_stim);
    set(handles.edit_scaling_ex_to_in,'String',handles.stimulation.scaling_ex_to_in);
else
    set(handles.edit_d_max,'String',2.25);
    set(handles.edit_d_spread,'String',0.8);
    set(handles.edit_d_stim,'String',0);
    set(handles.edit_scaling_ex_to_in,'String',91/900);
end

% load/show data
set(handles.checkbox_show_data, 'Value', 0);
set(handles.checkbox_ECAP_normalized, 'Value', 1);
handles.ECAP_normalized = 1;
handles.data_available = 0;
handles.index_neuron = 1;
handles.fig_v_average = 1;
handles.fig_v_single_neuron = 0;
set(handles.radiobutton_fig_v_average,'Value',1);
set(handles.radiobutton_fig_v_single_neuron,'Value',0);

%%%%%%%%%%%%%%%%%
% optimization %%
set(handles.pushbutton_opt_go,'Enable','off');
% list of parameter names
handles.opt.var_string = {'handles.stimulation.A'; 'handles.parameters.nneurons'};
handles.par_list = string([fieldnames(handles.parameters); fieldnames(handles.stimulation)]);
par_prefix = [string(repmat('handles.parameters.', size(fieldnames(handles.parameters)))) ;...
               string(repmat('handles.stimulation.',size(fieldnames(handles.stimulation))))];
handles.opt.var_string = [strcat(par_prefix, handles.par_list)];

%set popupmenu string
set(handles.popupmenu_opt_list_parameters,'String',handles.par_list);
% binary vector, selected/not selected
handles.opt.var_vector = zeros(length(handles.opt.var_string),1);
% low, high, step matrix
handles.opt.bound_matrix = zeros(length(handles.opt.var_string),3);
handles.opt.bound_matrix(1:2,1:3) = [10 10 200; 10 50 1000];
% create a loop for all variable names?
set(handles.edit_opt_A_low,'String',handles.opt.bound_matrix(1,1));
set(handles.edit_opt_A_step,'String',handles.opt.bound_matrix(1,2));
set(handles.edit_opt_A_high,'String',handles.opt.bound_matrix(1,3));
set(handles.edit_opt_nneurons_low,'String',handles.opt.bound_matrix(2,1));
set(handles.edit_opt_nneurons_step,'String',handles.opt.bound_matrix(2,2));
set(handles.edit_opt_nneurons_high,'String',handles.opt.bound_matrix(2,3));
set(handles.edit_opt_parameter_low,'String',handles.opt.bound_matrix(3,1));
set(handles.edit_opt_parameter_step,'String',handles.opt.bound_matrix(3,2));
set(handles.edit_opt_parameter_high,'String',handles.opt.bound_matrix(3,3));


%% PLOT RESULTS
function handles = plot_results(handles)

t = handles.parameters.t;
tmax = handles.parameters.tmax;
nneurons = handles.parameters.nneurons;
tIPI = handles.stimulation.tIPI;

if ~handles.light_code
    v = handles.v;
    vth = handles.vth;
end
Istim = handles.stimulation.Istim;
index_neuron = handles.index_neuron;

% Istim
axes(handles.fig_Istim), cla;
plot(t,Istim(:,1),'-blue')%-1.2*A
hold on;
plot(t,50*ones(size(t)),'-.blue')%-1.2*A
axis([0 tmax 0 1.2*max(Istim(:,1))]);
%title('I_{stim} vs. time')
xlabel('t (ms)');
ylabel('I_{stim} (pA)');

% spread
xneurons = handles.stimulation.xneurons;
spread = handles.stimulation.spread;
axes(handles.fig_spread), cla;
plot(xneurons,spread,'-blue');
xlabel('x (mm)');
if handles.parameters.nneurons ~= 1
    axis([min(xneurons) max(xneurons) 0 1.1]);
end

% v,vth
axes(handles.fig_v), cla;
%title('V_{mem avr} and V_{th avr} vs. time')
%xlabel('t (ms)');
%legend('V_{mem avr}, V_{th avr}');
if handles.fig_v_average
    if ~handles.light_code
        hold on;
        plot(t,sum(v,2)./nneurons,'-black');
        plot(t,sum(vth,2)./nneurons,'-red');
        ylabel('V_{mem avr}, V_{th avr}(mV)');
    else
        %ylabel('V_{mem avr}');
    end
    axis([0 tmax -20 100]);
    set(gca,'XTick',[])
end

if handles.fig_v_single_neuron
    if ~handles.light_code
        hold on;
        plot(t,v(:,index_neuron),'-black');
        plot(t,vth(:,index_neuron),'-red');
        ylabel('V_{mem}, V_{th}(mV)');
    else
        ylabel('V_{mem}');
    end
    axis([0 tmax -20 100]);
    set(gca,'XTick',[])
end


% spike histogram
axes(handles.fig_hist), cla;
h1 = histogram(cell2mat(handles.spiketimes),round(tmax/tIPI),'BinLimits',[0 tmax]);
% normalized histogram
hold on;
edges = [0 2 6 12 20:10:tmax];
st = cell2mat(handles.spiketimes);
clear bin;
for i=1:length(edges)-1
    spikes_in_bin = length(st(st>=edges(i) & st<edges(i+1)));
    bin_count(i) = spikes_in_bin/(edges(i+1)-edges(i)); %* 1000/nneurons;
    bin_time(i) = 0.5*(edges(i)+edges(i+1));
end
plot(bin_time, bin_count,'-r*');
%title('Spike histogram vs. time')
axis([0 tmax 0 nneurons]);
set(gca,'XTick',[])
%xlabel('t (ms)');
ylabel('Num. spikes per bin');


% ECAP
axes(handles.fig_ECAP), cla;
if handles.ECAP_normalized    
    plot(handles.ECAP_time,handles.ECAP_amp/max(handles.ECAP_amp),'-o blue');
    axis([0 tmax 0 1]);
    ylabel('ECAP (normalized)');
else
    plot(handles.ECAP_time,handles.ECAP_amp,'-o blue');
    axis([0 tmax 0 max(handles.ECAP_amp)]);
end
set(gca,'XTick',[])
%title('ECAP vs. time')
%xlabel('t (ms)');

% plot ECAP data if available (loaded) and toggled on
if handles.checkbox_show_data.Value
    if handles.data_available
        hold on;
        if handles.ECAP_normalized    
            plot(handles.data.ECAP_time,handles.data.ECAP_amp,'-x black');
            axis([0 tmax 0 1]);
        else
            plot(handles.data.ECAP_time,handles.data.ECAP_amp.*handles.data.ECAP_scale,'-x black');
            axis([0 tmax 0 max(max(handles.ECAP_amp),handles.data.ECAP_scale)]);
        end
    end
end

%if handles.checkbox_show_stimulus.Value
%Istim_reduced = ones(size(handles.ECAP_time));
%for i=1:length(handles.ECAP_time)
    %if sum( (handles.parameters.t-handles.parameters.dt) == handles.ECAP_time(i)) == 1
    %    Istim_reduced(i) = handles.stimulation.mod( (handles.parameters.t-handles.parameters.dt) == handles.ECAP_time(i+1));
    %end
    %ind = handles.ECAP_time(i)/handles.parameters.dt;
%    ind(ind==0) = 1;
%    ind(ind>handles.parameters.niter) = handles.parameters.niter;
%    Istim_reduced = handles.stimulation.mod(ind);
%end
%end
        
% plot show stimulus is toggled on
if handles.checkbox_show_stimulus.Value
    hold on;
    Istim_mod = handles.stimulation.mod/max(handles.stimulation.mod);
    %Istim_mod = handles.stimulation.Istim/handles.stimulation.A;
    %plot(handles.parameters.t,handles.stimulation.mod/max(handles.stimulation.mod),'-r');
    plot(handles.parameters.t,min(Istim_mod) + Istim_mod,'o red');
    %legend(['ECAP, model', 'I_{stim} mod', 'ECAP, data'])
    %axis([0 tmax 0 max(Istim_mod)]);
    %plot(handles.parameters.t,min(Istim_reduced) + Istim_reduced,'o red');
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% CHECKBOXES, EDITS AND STUFF BELOW %%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% Model variant checkboxes
% --- Executes on button press in checkbox_noise_mem.
function checkbox_noise_mem_Callback(hObject, eventdata, handles)
% hObject    handle to checkbox_noise_mem (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% Hint: get(hObject,'Value') returns toggle state of checkbox_noise_mem
handles.modeltype.noise_mem = get(hObject,'Value');
set(handles.text_calculating,'Visible','On'); drawnow;
handles = IFmain(handles);
set(handles.text_calculating,'Visible','Off'); drawnow;
handles = plot_results(handles);
guidata(hObject, handles);

% --- Executes on button press in checkbox_noise_mem_fixed.
function checkbox_noise_mem_fixed_Callback(hObject, eventdata, handles)
% hObject    handle to checkbox_noise_mem_fixed (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% Hint: get(hObject,'Value') returns toggle state of checkbox_noise_mem_fixed
handles.modeltype.noise_mem_fixed = get(hObject,'Value');
guidata(hObject, handles);

% --- Executes on button press in checkbox_vth0_stochastic.
function checkbox_vth0_stochastic_Callback(hObject, eventdata, handles)
% hObject    handle to checkbox_vth0_stochastic (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% Hint: get(hObject,'Value') returns toggle state of checkbox_vth0_stochastic
handles.modeltype.vth0_stochastic = get(hObject,'Value');
set(handles.text_calculating,'Visible','On'); drawnow;
handles = IFmain(handles);
set(handles.text_calculating,'Visible','Off'); drawnow;
handles = plot_results(handles);
guidata(hObject, handles);

% --- Executes on button press in checkbox_vth0_stochastic_fixed.
function checkbox_vth0_stochastic_fixed_Callback(hObject, eventdata, handles)
% hObject    handle to checkbox_vth0_stochastic_fixed (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% Hint: get(hObject,'Value') returns toggle state of checkbox_vth0_stochastic_fixed
handles.modeltype.vth0_stochastic_fixed = get(hObject,'Value');
guidata(hObject, handles);

% --- Executes on button press in checkbox_ref.
function checkbox_ref_Callback(hObject, eventdata, handles)
% hObject    handle to checkbox_ref (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% Hint: get(hObject,'Value') returns toggle state of checkbox_ref
handles.modeltype.ref = get(hObject,'Value');
set(handles.text_calculating,'Visible','On'); drawnow;
handles = IFmain(handles);
set(handles.text_calculating,'Visible','Off'); drawnow;
handles = plot_results(handles);
guidata(hObject, handles);

% --- Executes on button press in checkbox_noise_ref.
function checkbox_noise_ref_Callback(hObject, eventdata, handles)
% hObject    handle to checkbox_noise_ref (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% Hint: get(hObject,'Value') returns toggle state of checkbox_noise_ref
handles.modeltype.noise_ref = get(hObject,'Value');
set(handles.text_calculating,'Visible','On'); drawnow;
handles = IFmain(handles);
set(handles.text_calculating,'Visible','Off'); drawnow;
handles = plot_results(handles);
guidata(hObject, handles);

% --- Executes on button press in checkbox_ref_stochastic.
function checkbox_ref_stochastic_Callback(hObject, eventdata, handles)
% hObject    handle to checkbox_ref_stochastic (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% Hint: get(hObject,'Value') returns toggle state of checkbox_ref_stochastic
handles.modeltype.ref_stochastic = get(hObject,'Value');
set(handles.text_calculating,'Visible','On'); drawnow;
handles = IFmain(handles);
set(handles.text_calculating,'Visible','Off'); drawnow;
handles = plot_results(handles);
guidata(hObject, handles);

% --- Executes on button press in checkbox_ref_stochastic_fixed.
function checkbox_ref_stochastic_fixed_Callback(hObject, eventdata, handles)
% hObject    handle to checkbox_ref_stochastic_fixed (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% Hint: get(hObject,'Value') returns toggle state of checkbox_ref_stochastic_fixed
handles.modeltype.ref_stochastic_fixed = get(hObject,'Value');
guidata(hObject, handles);

% --- Executes on button press in checkbox_SRA.
function checkbox_SRA_Callback(hObject, eventdata, handles)
% hObject    handle to checkbox_SRA (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% Hint: get(hObject,'Value') returns toggle state of checkbox_SRA
handles.modeltype.SRA = get(hObject,'Value');
set(handles.text_calculating,'Visible','On'); drawnow;
handles = IFmain(handles);
set(handles.text_calculating,'Visible','Off'); drawnow;
handles = plot_results(handles);
guidata(hObject,handles)

% --- Executes on button press in checkbox_noise_SRA.
function checkbox_noise_SRA_Callback(hObject, eventdata, handles)
% hObject    handle to checkbox_noise_SRA (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% Hint: get(hObject,'Value') returns toggle state of checkbox_noise_SRA
handles.modeltype.noise_SRA = get(hObject,'Value');
set(handles.text_calculating,'Visible','On'); drawnow;
handles = IFmain(handles);
set(handles.text_calculating,'Visible','Off'); drawnow;
handles = plot_results(handles);
guidata(hObject, handles);

% --- Executes on button press in checkbox_fac.
function checkbox_fac_Callback(hObject, eventdata, handles)
% hObject    handle to checkbox_fac (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% Hint: get(hObject,'Value') returns toggle state of checkbox_fac
handles.modeltype.fac = get(hObject,'Value');
set(handles.text_calculating,'Visible','On'); drawnow;
handles = IFmain(handles);
set(handles.text_calculating,'Visible','Off'); drawnow;
handles = plot_results(handles);
guidata(hObject,handles)

% --- Executes on button press in checkbox_noise_fac.
function checkbox_noise_fac_Callback(hObject, eventdata, handles)
% hObject    handle to checkbox_noise_fac (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% Hint: get(hObject,'Value') returns toggle state of checkbox_noise_fac
handles.modeltype.noise_fac = get(hObject,'Value');
set(handles.text_calculating,'Visible','On'); drawnow;
handles = IFmain(handles);
set(handles.text_calculating,'Visible','Off'); drawnow;
handles = plot_results(handles);
guidata(hObject, handles);

% --- Executes on button press in checkbox_acc.
function checkbox_acc_Callback(hObject, eventdata, handles)
% hObject    handle to checkbox_acc (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% Hint: get(hObject,'Value') returns toggle state of checkbox_acc
handles.modeltype.acc = get(hObject,'Value');
set(handles.text_calculating,'Visible','On'); drawnow;
handles = IFmain(handles);
set(handles.text_calculating,'Visible','Off'); drawnow;
handles = plot_results(handles);
guidata(hObject,handles)

% --- Executes on button press in checkbox_noise_acc.
function checkbox_noise_acc_Callback(hObject, eventdata, handles)
% hObject    handle to checkbox_noise_acc (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% Hint: get(hObject,'Value') returns toggle state of checkbox_noise_acc
handles.modeltype.noise_acc = get(hObject,'Value');
set(handles.text_calculating,'Visible','On'); drawnow;
handles = IFmain(handles);
set(handles.text_calculating,'Visible','Off'); drawnow;
handles = plot_results(handles);
guidata(hObject, handles);

% --- Executes on button press in checkbox_acc_slow.
function checkbox_acc_slow_Callback(hObject, eventdata, handles)
% hObject    handle to checkbox_acc_slow (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% Hint: get(hObject,'Value') returns toggle state of checkbox_acc_slow
handles.modeltype.acc_slow = get(hObject,'Value');
set(handles.text_calculating,'Visible','On'); drawnow;
handles = IFmain(handles);
set(handles.text_calculating,'Visible','Off'); drawnow;
handles = plot_results(handles);
guidata(hObject,handles)

% --- Executes on button press in checkbox_noise_acc_slow.
function checkbox_noise_acc_slow_Callback(hObject, eventdata, handles)
% hObject    handle to checkbox_noise_acc_slow (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% Hint: get(hObject,'Value') returns toggle state of checkbox_noise_acc_slow
handles.modeltype.noise_acc_slow = get(hObject,'Value');
set(handles.text_calculating,'Visible','On'); drawnow;
handles = IFmain(handles);
set(handles.text_calculating,'Visible','Off'); drawnow;
handles = plot_results(handles);
guidata(hObject, handles);


%% Membrane parameters
function edit_R_Callback(hObject, eventdata, handles)
% hObject    handle to edit_R (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% Hints: get(hObject,'String') returns contents of edit_R as text
%        str2double(get(hObject,'String')) returns contents of edit_R as a double
handles.parameters.R = str2double(get(hObject,'string'));
set(handles.text_tau_mem,'String',handles.parameters.R .* handles.parameters.C);
set(handles.text_calculating,'Visible','On'); drawnow;
handles = IFmain(handles);
set(handles.text_calculating,'Visible','Off'); drawnow;
handles = plot_results(handles);
guidata(hObject,handles);

% --- Executes during object creation, after setting all properties.
function edit_R_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit_R (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


function edit_C_Callback(hObject, eventdata, handles)
% hObject    handle to edit_C (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% Hints: get(hObject,'String') returns contents of edit_C as text
%        str2double(get(hObject,'String')) returns contents of edit_C as a double
handles.parameters.C = str2double(get(hObject,'string'));
set(handles.text_tau_mem,'String',handles.parameters.R .* handles.parameters.C);
set(handles.text_calculating,'Visible','On'); drawnow;
handles = IFmain(handles);
set(handles.text_calculating,'Visible','Off'); drawnow;
handles = plot_results(handles);
guidata(hObject,handles);

% --- Executes during object creation, after setting all properties.
function edit_C_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit_C (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


function edit_vrest_Callback(hObject, eventdata, handles)
% hObject    handle to edit_vrest (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% Hints: get(hObject,'String') returns contents of edit_vrest as text
%        str2double(get(hObject,'String')) returns contents of edit_vrest as a double
handles.parameters.vrest = str2double(get(hObject,'string'));
set(handles.text_calculating,'Visible','On'); drawnow;
handles = IFmain(handles);
set(handles.text_calculating,'Visible','Off'); drawnow;
handles = plot_results(handles);
guidata(hObject,handles);

% --- Executes during object creation, after setting all properties.
function edit_vrest_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit_vrest (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


function edit_vth0_Callback(hObject, eventdata, handles)
% hObject    handle to edit_vth0 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% Hints: get(hObject,'String') returns contents of edit_vth0 as text
%        str2double(get(hObject,'String')) returns contents of edit_vth0 as a double
handles.parameters.vth0 = str2double(get(hObject,'string'));
set(handles.text_calculating,'Visible','On'); drawnow;
handles = IFmain(handles);
set(handles.text_calculating,'Visible','Off'); drawnow;
handles = plot_results(handles);
guidata(hObject,handles);

% --- Executes during object creation, after setting all properties.
function edit_vth0_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit_vth0 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called
% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function edit_vth0_spread_norm_Callback(hObject, eventdata, handles)
% hObject    handle to edit_vth0_spread_norm (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% Hints: get(hObject,'String') returns contents of edit_vth0_spread_norm as text
%        str2double(get(hObject,'String')) returns contents of edit_vth0_spread_norm as a double
handles.parameters.vth0_spread_norm = str2double(get(hObject,'string'));
set(handles.text_calculating,'Visible','On'); drawnow;
handles = IFmain(handles);
set(handles.text_calculating,'Visible','Off'); drawnow;
handles = plot_results(handles);
guidata(hObject,handles);

% --- Executes during object creation, after setting all properties.
function edit_vth0_spread_norm_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit_vth0_spread_norm (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called
% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edit_vspike_Callback(hObject, eventdata, handles)
% hObject    handle to edit_vspike (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% Hints: get(hObject,'String') returns contents of edit_vspike as text
%        str2double(get(hObject,'String')) returns contents of edit_vspike as a double
handles.parameters.vspike = str2double(get(hObject,'string'));
set(handles.text_calculating,'Visible','On'); drawnow;
handles = IFmain(handles);
set(handles.text_calculating,'Visible','Off'); drawnow;
handles = plot_results(handles);
guidata(hObject,handles);

% --- Executes during object creation, after setting all properties.
function edit_vspike_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit_vspike (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edit_vreset_Callback(hObject, eventdata, handles)
% hObject    handle to edit_vreset (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% Hints: get(hObject,'String') returns contents of edit_vreset as text
%        str2double(get(hObject,'String')) returns contents of edit_vreset as a double
handles.parameters.vreset = str2double(get(hObject,'string'));
set(handles.text_calculating,'Visible','On'); drawnow;
handles = IFmain(handles);
set(handles.text_calculating,'Visible','Off'); drawnow;
handles = plot_results(handles);
guidata(hObject,handles);

% --- Executes during object creation, after setting all properties.
function edit_vreset_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit_vreset (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Simulation parameters
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% --- Executes on button press in checkbox_light_code.
function checkbox_light_code_Callback(hObject, eventdata, handles)
% hObject    handle to checkbox_light_code (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% Hint: get(hObject,'Value') returns toggle state of checkbox_light_code
handles.light_code = get(hObject,'Value');
set(handles.text_calculating,'Visible','On'); drawnow;
handles = IFmain(handles);
set(handles.text_calculating,'Visible','Off'); drawnow;
handles = plot_results(handles);
guidata(hObject, handles);

function edit_nneurons_Callback(hObject, eventdata, handles)
% hObject    handle to edit_nneurons (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit_nneurons as text
%        str2double(get(hObject,'String')) returns contents of edit_nneurons as a double
handles.parameters.nneurons = round(str2double(get(hObject,'String')));
if handles.index_neuron > handles.parameters.nneurons
    handles.index_neuron = handles.parameters.nneurons;
end
set(handles.text_calculating,'Visible','On'); drawnow;
handles = IFmain(handles);
set(handles.text_calculating,'Visible','Off'); drawnow;
handles = plot_results(handles);
guidata(hObject,handles);

% --- Executes during object creation, after setting all properties.
function edit_nneurons_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit_nneurons (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function edit_dt_Callback(hObject, eventdata, handles)
% hObject    handle to edit_dt (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit_dt as text
%        str2double(get(hObject,'String')) returns contents of edit_dt as a double
handles.parameters.dt = str2double(get(hObject,'string'));
set(handles.text_calculating,'Visible','On'); drawnow;
handles = IFmain(handles);
set(handles.text_calculating,'Visible','Off'); drawnow;
handles = plot_results(handles);
guidata(hObject,handles);

% --- Executes during object creation, after setting all properties.
function edit_dt_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit_dt (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function edit_tmax_Callback(hObject, eventdata, handles)
% hObject    handle to edit_tmax (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit_tmax as text
%        str2double(get(hObject,'String')) returns contents of edit_tmax as a double
handles.parameters.tmax = str2double(get(hObject,'string'));
set(handles.text_calculating,'Visible','On'); drawnow;
handles = IFmain(handles);
set(handles.text_calculating,'Visible','Off'); drawnow;
handles = plot_results(handles);
guidata(hObject,handles);

% --- Executes during object creation, after setting all properties.
function edit_tmax_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit_tmax (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Stimulus parameters %%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% --- Executes on selection change in popupmenu_stim_type.
function popupmenu_stim_type_Callback(hObject, eventdata, handles)
% hObject    handle to popupmenu_stim_type (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% Hints: contents = cellstr(get(hObject,'String')) returns popupmenu_stim_type contents as cell array
%        contents{get(hObject,'Value')} returns selected item from popupmenu_stim_type
str = get(hObject,'String');
val = get(hObject,'Value');
% Set current data to the selected data set.
switch str{val}
case 'Single pulse'
    handles.stimulation.stim_type = 1;
    set(handles.edit_stimulation_A2,'Visible','off');
    set(handles.edit_stimulation_A2_CL,'Visible','off');
    set(handles.text_A2,'Visible','off');
case 'Double pulse'
    handles.stimulation.stim_type = 2;
    set(handles.edit_stimulation_A2,'Visible','on');
    set(handles.edit_stimulation_A2_CL,'Visible','on');
    set(handles.text_A2,'Visible','on');
case 'Pulse train'
    handles.stimulation.stim_type = 3;
    set(handles.edit_stimulation_A2,'Visible','off');
    set(handles.edit_stimulation_A2_CL,'Visible','off');
    set(handles.text_A2,'Visible','off');
end

guidata(hObject,handles);
set(handles.text_calculating,'Visible','On'); drawnow;
handles = IFmain(handles);
set(handles.text_calculating,'Visible','Off'); drawnow;
handles = plot_results(handles);


% --- Executes during object creation, after setting all properties.
function popupmenu_stim_type_CreateFcn(hObject, eventdata, handles)
% hObject    handle to popupmenu_stim_type (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

% --- Executes on selection change in popupmenu_mod_type.
function popupmenu_mod_type_Callback(hObject, eventdata, handles)
% hObject    handle to popupmenu_mod_type (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns popupmenu_mod_type contents as cell array
%        contents{get(hObject,'Value')} returns selected item from popupmenu_mod_type
str = get(hObject,'String');
val = get(hObject,'Value');
% Set current data to the selected data set.
switch str{val}
case 'No modulation'
    handles.stimulation.mod_type = 0;
case 'Sinusoidal'
    handles.stimulation.mod_type = 1;
case 'Square'
    handles.stimulation.mod_type = 2;
case 'Saw'
    handles.stimulation.mod_type = 3;
case 'Reverse saw'
    handles.stimulation.mod_type = 4;
end

guidata(hObject,handles);
set(handles.text_calculating,'Visible','On'); drawnow;
handles = IFmain(handles);
set(handles.text_calculating,'Visible','Off'); drawnow;
handles = plot_results(handles);

% --- Executes during object creation, after setting all properties.
function popupmenu_mod_type_CreateFcn(hObject, eventdata, handles)
% hObject    handle to popupmenu_mod_type (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



% --- Executes on button press in checkbox_mod_in_CL.
function checkbox_mod_in_CL_Callback(hObject, eventdata, handles)
% hObject    handle to checkbox_mod_in_CL (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% Hint: get(hObject,'Value') returns toggle state of checkbox_mod_in_CL
handles.stimulation.mod_in_CL = get(hObject,'Value');
set(handles.text_calculating,'Visible','On'); drawnow;
handles = IFmain(handles);
set(handles.text_calculating,'Visible','Off'); drawnow;
handles = plot_results(handles);
guidata(hObject, handles);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function edit_A_Callback(hObject, eventdata, handles)
% hObject    handle to edit_A (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit_A as text
%        str2double(get(hObject,'String')) returns contents of edit_A as a double
handles.stimulation.A = str2double(get(hObject,'string'));
A_ex = handles.stimulation.A./handles.stimulation.scaling_ex_to_in;
handles.stimulation.A_CL = exAmp_to_CL(A_ex);
set(handles.edit_A_CL,'String',handles.stimulation.A_CL);

set(handles.text_calculating,'Visible','On'); drawnow;
handles = IFmain(handles);
set(handles.text_calculating,'Visible','Off'); drawnow;
handles = plot_results(handles);
guidata(hObject,handles);

% --- Executes during object creation, after setting all properties.
function edit_A_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit_A (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called
% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function edit_A_CL_Callback(hObject, eventdata, handles)
% hObject    handle to edit_A_CL (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% Hints: get(hObject,'String') returns contents of edit_A_CL as text
%        str2double(get(hObject,'String')) returns contents of edit_A_CL as a double
handles.stimulation.A_CL = str2double(get(hObject,'string'));
A_ex = CL_to_exAmp(handles.stimulation.A_CL);
A_in = A_ex .* handles.stimulation.scaling_ex_to_in;
set(handles.edit_A,'String',A_in);

set(handles.text_calculating,'Visible','On'); drawnow;
handles = IFmain(handles);
set(handles.text_calculating,'Visible','Off'); drawnow;
handles = plot_results(handles);
guidata(hObject,handles);

% --- Executes during object creation, after setting all properties.
function edit_A_CL_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit_A_CL (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edit_stimulation_A2_Callback(hObject, eventdata, handles)
% hObject    handle to edit_stimulation_A2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% Hints: get(hObject,'String') returns contents of edit_stimulation_A2 as text
%        str2double(get(hObject,'String')) returns contents of edit_stimulation_A2 as a double
if handles.stimulation.stim_type == 2
    handles.stimulation.A2 = str2double(get(hObject,'string'));
    A2_ex = handles.stimulation.A2 ./ handles.stimulation.scaling_ex_to_in;
    handles.stimulation.A2_CL = exAmp_to_CL(A2_ex);
    set(handles.edit_stimulation_A2_CL,'String',handles.stimulation.A2_CL);
    
    set(handles.text_calculating,'Visible','On'); drawnow;
    handles = IFmain(handles);
    set(handles.text_calculating,'Visible','Off'); drawnow;
    handles = plot_results(handles);
    guidata(hObject,handles);
end

% --- Executes during object creation, after setting all properties.
function edit_stimulation_A2_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit_stimulation_A2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function edit_stimulation_A2_CL_Callback(hObject, eventdata, handles)
% hObject    handle to edit_stimulation_A2_CL (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% Hints: get(hObject,'String') returns contents of edit_stimulation_A2_CL as text
%        str2double(get(hObject,'String')) returns contents of edit_stimulation_A2_CL as a double
if handles.stimulation.stim_type == 2
    handles.stimulation.A2_CL = str2double(get(hObject,'string'));
    A2_ex = CL_to_exAmp(handles.stimulation.A2_CL);
    handles.stimulation.A2 = A2_ex .* scaling_ex_to_in;
    set(handles.edit_stimulation_A2,'String',handles.stimulation.A2);    
    
    set(handles.text_calculating,'Visible','On'); drawnow;
    handles = IFmain(handles);
    set(handles.text_calculating,'Visible','Off'); drawnow;
    handles = plot_results(handles);
    guidata(hObject,handles);
end

% --- Executes during object creation, after setting all properties.
function edit_stimulation_A2_CL_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit_stimulation_A2_CL (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edit_to_Callback(hObject, eventdata, handles)
% hObject    handle to edit_to (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit_to as text
%        str2double(get(hObject,'String')) returns contents of edit_to as a double
handles.stimulation.to = str2double(get(hObject,'String'));
set(handles.text_calculating,'Visible','On'); drawnow;
handles = IFmain(handles);
set(handles.text_calculating,'Visible','Off'); drawnow;
handles = plot_results(handles);
guidata(hObject,handles);

% --- Executes during object creation, after setting all properties.
function edit_to_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit_to (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called
% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


function edit_tw_Callback(hObject, eventdata, handles)
% hObject    handle to edit_tw (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% Hints: get(hObject,'String') returns contents of edit_tw as text
%        str2double(get(hObject,'String')) returns contents of edit_tw as a double
handles.stimulation.tw = str2double(get(hObject,'string'));
set(handles.text_calculating,'Visible','On'); drawnow;
handles = IFmain(handles);
set(handles.text_calculating,'Visible','Off'); drawnow;
handles = plot_results(handles);
guidata(hObject,handles);

% --- Executes during object creation, after setting all properties.
function edit_tw_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit_tw (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


function edit_tIPI_Callback(hObject, eventdata, handles)
% hObject    handle to edit_tIPI (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit_tIPI as text
%        str2double(get(hObject,'String')) returns contents of edit_tIPI as a double
handles.stimulation.tIPI = str2double(get(hObject,'string'));
set(handles.text_calculating,'Visible','On'); drawnow;
handles = IFmain(handles);
set(handles.text_calculating,'Visible','Off'); drawnow;
Istim = handles.stimulation.Istim;
t = handles.parameters.t;
save('test.mat','t','Istim');
handles = plot_results(handles);
guidata(hObject,handles);

% --- Executes during object creation, after setting all properties.
function edit_tIPI_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit_tIPI (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


function edit_mod_freq_Callback(hObject, eventdata, handles)
% hObject    handle to edit_mod_freq (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit_mod_freq as text
%        str2double(get(hObject,'String')) returns contents of edit_mod_freq as a double
handles.stimulation.mod_freq = str2double(get(hObject,'string'));
set(handles.text_calculating,'Visible','On'); drawnow;
handles = IFmain(handles);
set(handles.text_calculating,'Visible','Off'); drawnow;
handles = plot_results(handles);
guidata(hObject,handles);

% --- Executes during object creation, after setting all properties.
function edit_mod_freq_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit_mod_freq (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


function edit_mod_depth_Callback(hObject, eventdata, handles)
% hObject    handle to edit_mod_depth (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% Hints: get(hObject,'String') returns contents of edit_mod_depth as text
%        str2double(get(hObject,'String')) returns contents of edit_mod_depth as a double
handles.stimulation.mod_depth = str2double(get(hObject,'string'));
    A_max = handles.stimulation.A;
    A_min = A_max * (1-handles.stimulation.mod_depth)/(1+handles.stimulation.mod_depth);
    A_CL_max = exAmp_to_CL (A_max ./ handles.stimulation.scaling_ex_to_in);
    A_CL_min = exAmp_to_CL (A_min ./ handles.stimulation.scaling_ex_to_in);
    mod_depth_CL = (A_CL_max-A_CL_min)/(A_CL_max+A_CL_min);
    handles.stimulation.mod_depth_CL = round(100*mod_depth_CL)/100;
    set(handles.edit_mod_depth_CL,'String',handles.stimulation.mod_depth_CL);

set(handles.text_calculating,'Visible','On'); drawnow;
handles = IFmain(handles);
set(handles.text_calculating,'Visible','Off'); drawnow;
handles = plot_results(handles);
guidata(hObject,handles);

% --- Executes during object creation, after setting all properties.
function edit_mod_depth_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit_mod_depth (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


function edit_mod_depth_CL_Callback(hObject, eventdata, handles)
% hObject    handle to edit_mod_depth_CL (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% Hints: get(hObject,'String') returns contents of edit_mod_depth_CL as text
%        str2double(get(hObject,'String')) returns contents of edit_mod_depth_CL as a double
handles.stimulation.mod_depth_CL = str2double(get(hObject,'string'));
    A_CL_max = handles.stimulation.A_CL;
    A_CL_min = A_CL_max * (1-handles.stimulation.mod_depth_CL)/(1+handles.stimulation.mod_depth_CL);
    A_max = CL_to_exAmp(A_CL_max) .* handles.stimulation.scaling_ex_to_in;
    A_min= CL_to_exAmp(A_CL_min) .* handles.stimulation.scaling_ex_to_in;
    mod_depth = (A_max-A_min)/(A_max+A_min);
    handles.stimulation.mod_depth = round(100*mod_depth)/100;
    set(handles.edit_mod_depth,'String',handles.stimulation.mod_depth);
    
set(handles.text_calculating,'Visible','On'); drawnow;
handles = IFmain(handles);
set(handles.text_calculating,'Visible','Off'); drawnow;
handles = plot_results(handles);
guidata(hObject,handles);

% --- Executes during object creation, after setting all properties.
function edit_mod_depth_CL_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit_mod_depth_CL (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Edit spread parameters
% --- Executes on button press in checkbox_spread.
function checkbox_spread_Callback(hObject, eventdata, handles)
% hObject    handle to checkbox_spread (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% Hint: get(hObject,'Value') returns toggle state of checkbox_spread
handles.modeltype.spread = get(hObject,'Value');
set(handles.text_calculating,'Visible','On'); drawnow;
handles = IFmain(handles);
set(handles.text_calculating,'Visible','Off'); drawnow;
handles = plot_results(handles);
guidata(hObject,handles)

% --- Executes on selection change in popupmenu_spread_type.
function popupmenu_spread_type_Callback(hObject, eventdata, handles)
% hObject    handle to popupmenu_spread_type (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns popupmenu_spread_type contents as cell array
%        contents{get(hObject,'Value')} returns selected item from popupmenu_spread_type
str = get(hObject,'String');
val = get(hObject,'Value');
% Set current data to the selected data set.
switch str{val}
case 'Exp Abs'
    handles.modeltype.spread_type = 1;
    set(handles.edit_d_spread,'Visible','on');
    set(handles.edit_p_left,'Visible','off');
    set(handles.edit_p_right,'Visible','off');
case 'Rounded Exp'
    handles.modeltype.spread_type = 2;
    set(handles.edit_d_spread,'Visible','off');
    set(handles.edit_p_left,'Visible','on');
    set(handles.edit_p_right,'Visible','on');
end

guidata(hObject,handles);
set(handles.text_calculating,'Visible','On'); drawnow;
handles = IFmain(handles);
set(handles.text_calculating,'Visible','Off'); drawnow;
handles = plot_results(handles);

% --- Executes during object creation, after setting all properties.
function popupmenu_spread_type_CreateFcn(hObject, eventdata, handles)
% hObject    handle to popupmenu_spread_type (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


function edit_scaling_ex_to_in_Callback(hObject, eventdata, handles)
% hObject    handle to edit_scaling_ex_to_in (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% Hints: get(hObject,'String') returns contents of edit_scaling_ex_to_in as text
%        str2double(get(hObject,'String')) returns contents of edit_scaling_ex_to_in as a double
handles.stimulation.scaling_ex_to_in = str2double(get(hObject,'String'));
set(handles.text_calculating,'Visible','On'); drawnow;
handles = IFmain(handles);
set(handles.text_calculating,'Visible','Off'); drawnow;
handles = plot_results(handles);
guidata(hObject,handles);

% --- Executes during object creation, after setting all properties.
function edit_scaling_ex_to_in_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit_scaling_ex_to_in (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called
% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


function edit_d_max_Callback(hObject, eventdata, handles)
% hObject    handle to edit_d_max (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit_d_max as text
%        str2double(get(hObject,'String')) returns contents of edit_d_max as a double
handles.stimulation.d_max = str2double(get(hObject,'string'));
set(handles.text_calculating,'Visible','On'); drawnow;
handles = IFmain(handles);
set(handles.text_calculating,'Visible','Off'); drawnow;
handles = plot_results(handles);
guidata(hObject,handles)

% --- Executes during object creation, after setting all properties.
function edit_d_max_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit_d_max (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


function edit_d_spread_Callback(hObject, eventdata, handles)
% hObject    handle to edit_d_spread (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit_d_spread as text
%        str2double(get(hObject,'String')) returns contents of edit_d_spread as a double
handles.stimulation.d_spread = str2double(get(hObject,'string'));
set(handles.text_calculating,'Visible','On'); drawnow;
handles = IFmain(handles);
set(handles.text_calculating,'Visible','Off'); drawnow;
handles = plot_results(handles);
guidata(hObject,handles)

% --- Executes during object creation, after setting all properties.
function edit_d_spread_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit_d_spread (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


function edit_d_stim_Callback(hObject, eventdata, handles)
% hObject    handle to edit_d_stim (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit_d_stim as text
%        str2double(get(hObject,'String')) returns contents of edit_d_stim as a double
handles.stimulation.d_stim = str2double(get(hObject,'string'));
set(handles.text_calculating,'Visible','On'); drawnow;
handles = IFmain(handles);
set(handles.text_calculating,'Visible','Off'); drawnow;
handles = plot_results(handles);
guidata(hObject,handles);

% --- Executes during object creation, after setting all properties.
function edit_d_stim_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit_d_stim (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


function edit_p_left_Callback(hObject, eventdata, handles)
% hObject    handle to edit_p_left (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit_p_left as text
%        str2double(get(hObject,'String')) returns contents of edit_p_left as a double
handles.stimulation.p_left = str2double(get(hObject,'String'));
set(handles.text_calculating,'Visible','On'); drawnow;
handles = IFmain(handles);
set(handles.text_calculating,'Visible','Off'); drawnow;
handles = plot_results(handles);
guidata(hObject,handles);

% --- Executes during object creation, after setting all properties.
function edit_p_left_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit_p_left (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


function edit_p_right_Callback(hObject, eventdata, handles)
% hObject    handle to edit_p_right (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit_p_right as text
%        str2double(get(hObject,'String')) returns contents of edit_p_right as a double
handles.stimulation.p_right = str2double(get(hObject,'String'));
set(handles.text_calculating,'Visible','On'); drawnow;
handles = IFmain(handles);
set(handles.text_calculating,'Visible','Off'); drawnow;
handles = plot_results(handles);
guidata(hObject,handles);


% --- Executes during object creation, after setting all properties.
function edit_p_right_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit_p_right (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


%% Advanced parameters
function edit_RS_mem_Callback(hObject, eventdata, handles)
% hObject    handle to edit_RS_mem (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit_RS_mem as text
%        str2double(get(hObject,'String')) returns contents of edit_RS_mem as a double
handles.parameters.RS_mem = str2double(get(hObject,'string'));
set(handles.text_calculating,'Visible','On'); drawnow;
handles = IFmain(handles);
set(handles.text_calculating,'Visible','Off'); drawnow;
handles = plot_results(handles);
guidata(hObject,handles);

% --- Executes during object creation, after setting all properties.
function edit_RS_mem_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit_RS_mem (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function edit_p_th_SRA_Callback(hObject, eventdata, handles)
% hObject    handle to edit_p_th_SRA (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit_p_th_SRA as text
%        str2double(get(hObject,'String')) returns contents of edit_p_th_SRA as a double
handles.parameters.p_th_SRA = str2double(get(hObject,'string'));
set(handles.text_p_RS_SRA,'String',handles.parameters.p_th_SRA);
set(handles.text_calculating,'Visible','On'); drawnow;
handles = IFmain(handles);
set(handles.text_calculating,'Visible','Off'); drawnow;
handles = plot_results(handles);
guidata(hObject,handles);

% --- Executes during object creation, after setting all properties.
function edit_p_th_SRA_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit_p_th_SRA (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


function edit_tau_th_SRA_Callback(hObject, eventdata, handles)
% hObject    handle to edit_tau_th_SRA (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit_tau_th_SRA as text
%        str2double(get(hObject,'String')) returns contents of edit_tau_th_SRA as a double
handles.parameters.tau_th_SRA = str2double(get(hObject,'string'));
set(handles.text_tau_RS_SRA,'String',handles.parameters.tau_th_SRA);
set(handles.text_calculating,'Visible','On'); drawnow;
handles = IFmain(handles);
set(handles.text_calculating,'Visible','Off'); drawnow;
handles = plot_results(handles);
guidata(hObject,handles);

% --- Executes during object creation, after setting all properties.
function edit_tau_th_SRA_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit_tau_th_SRA (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


function edit_a_th_fac_Callback(hObject, eventdata, handles)
% hObject    handle to edit_a_th_fac (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit_a_th_fac as text
%        str2double(get(hObject,'String')) returns contents of edit_a_th_fac as a double
handles.parameters.a_th_fac = str2double(get(hObject,'string'));
set(handles.text_calculating,'Visible','On'); drawnow;
handles = IFmain(handles);
set(handles.text_calculating,'Visible','Off'); drawnow;
handles = plot_results(handles);
guidata(hObject,handles);

% --- Executes during object creation, after setting all properties.
function edit_a_th_fac_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit_a_th_fac (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


function edit_tau_th_fac_Callback(hObject, eventdata, handles)
% hObject    handle to edit_tau_th_fac (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit_tau_th_fac as text
%        str2double(get(hObject,'String')) returns contents of edit_tau_th_fac as a double
handles.parameters.tau_th_fac = str2double(get(hObject,'string'));
set(handles.text_calculating,'Visible','On'); drawnow;
handles = IFmain(handles);
set(handles.text_calculating,'Visible','Off'); drawnow;
handles = plot_results(handles);
guidata(hObject,handles);

% --- Executes during object creation, after setting all properties.
function edit_tau_th_fac_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit_tau_th_fac (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


function edit_a_RS_fac_Callback(hObject, eventdata, handles)
% hObject    handle to edit_a_RS_fac (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit_a_RS_fac as text
%        str2double(get(hObject,'String')) returns contents of edit_a_RS_fac as a double
handles.parameters.a_RS_fac = str2double(get(hObject,'string'));
set(handles.text_calculating,'Visible','On'); drawnow;
handles = IFmain(handles);
set(handles.text_calculating,'Visible','Off'); drawnow;
handles = plot_results(handles);
guidata(hObject,handles);

% --- Executes during object creation, after setting all properties.
function edit_a_RS_fac_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit_a_RS_fac (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function edit_tau_RS_fac_Callback(hObject, eventdata, handles)
% hObject    handle to edit_tau_RS_fac (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit_tau_RS_fac as text
%        str2double(get(hObject,'String')) returns contents of edit_tau_RS_fac as a double
handles.parameters.tau_RS_fac = str2double(get(hObject,'string'));
set(handles.text_calculating,'Visible','On'); drawnow;
handles = IFmain(handles);
set(handles.text_calculating,'Visible','Off'); drawnow;
handles = plot_results(handles);
guidata(hObject,handles);

% --- Executes during object creation, after setting all properties.
function edit_tau_RS_fac_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit_tau_RS_fac (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


function edit_a_th_acc_Callback(hObject, eventdata, handles)
% hObject    handle to edit_a_th_acc (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit_a_th_acc as text
%        str2double(get(hObject,'String')) returns contents of edit_a_th_acc as a double
handles.parameters.a_th_acc = str2double(get(hObject,'string'));
set(handles.text_calculating,'Visible','On'); drawnow;
handles = IFmain(handles);
set(handles.text_calculating,'Visible','Off'); drawnow;
handles = plot_results(handles);
guidata(hObject,handles);

% --- Executes during object creation, after setting all properties.
function edit_a_th_acc_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit_a_th_acc (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


function edit_tau_th_acc_Callback(hObject, eventdata, handles)
% hObject    handle to edit_tau_th_acc (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit_tau_th_acc as text
%        str2double(get(hObject,'String')) returns contents of edit_tau_th_acc as a double
handles.parameters.tau_th_acc = str2double(get(hObject,'string'));
set(handles.text_calculating,'Visible','On'); drawnow;
handles = IFmain(handles);
set(handles.text_calculating,'Visible','Off'); drawnow;
handles = plot_results(handles);
guidata(hObject,handles);

% --- Executes during object creation, after setting all properties.
function edit_tau_th_acc_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit_tau_th_acc (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


function edit_a_RS_acc_Callback(hObject, eventdata, handles)
% hObject    handle to edit_a_RS_acc (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit_a_RS_acc as text
%        str2double(get(hObject,'String')) returns contents of edit_a_RS_acc as a double
handles.parameters.a_RS_acc = str2double(get(hObject,'string'));
set(handles.text_calculating,'Visible','On'); drawnow;
handles = IFmain(handles);
set(handles.text_calculating,'Visible','Off'); drawnow;
handles = plot_results(handles);
guidata(hObject,handles);

% --- Executes during object creation, after setting all properties.
function edit_a_RS_acc_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit_a_RS_acc (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


function edit_tau_RS_acc_Callback(hObject, eventdata, handles)
% hObject    handle to edit_tau_RS_acc (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit_tau_RS_acc as text
%        str2double(get(hObject,'String')) returns contents of edit_tau_RS_acc as a double
handles.parameters.tau_RS_fac = str2double(get(hObject,'string'));
set(handles.text_calculating,'Visible','On'); drawnow;
handles = IFmain(handles);
set(handles.text_calculating,'Visible','Off'); drawnow;
handles = plot_results(handles);
guidata(hObject,handles);

% --- Executes during object creation, after setting all properties.
function edit_tau_RS_acc_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit_tau_RS_acc (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


function edit_a_th_acc_slow_Callback(hObject, eventdata, handles)
% hObject    handle to edit_a_th_acc_slow (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit_a_th_acc_slow as text
%        str2double(get(hObject,'String')) returns contents of edit_a_th_acc_slow as a double
handles.parameters.a_th_acc_slow = str2double(get(hObject,'string'));
set(handles.text_calculating,'Visible','On'); drawnow;
handles = IFmain(handles);
set(handles.text_calculating,'Visible','Off'); drawnow;
handles = plot_results(handles);
guidata(hObject,handles);

% --- Executes during object creation, after setting all properties.
function edit_a_th_acc_slow_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit_a_th_acc_slow (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


function edit_tau_th_acc_slow_Callback(hObject, eventdata, handles)
% hObject    handle to edit_tau_th_acc_slow (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit_tau_th_acc_slow as text
%        str2double(get(hObject,'String')) returns contents of edit_tau_th_acc_slow as a double
handles.parameters.tau_th_acc_slow = str2double(get(hObject,'string'));
set(handles.text_calculating,'Visible','On'); drawnow;
handles = IFmain(handles);
set(handles.text_calculating,'Visible','Off'); drawnow;
handles = plot_results(handles);
guidata(hObject,handles);

% --- Executes during object creation, after setting all properties.
function edit_tau_th_acc_slow_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit_tau_th_acc_slow (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


function edit_a_RS_acc_slow_Callback(hObject, eventdata, handles)
% hObject    handle to edit_a_RS_acc_slow (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit_a_RS_acc_slow as text
%        str2double(get(hObject,'String')) returns contents of edit_a_RS_acc_slow as a double
handles.parameters.a_RS_acc_slow = str2double(get(hObject,'string'));
set(handles.text_calculating,'Visible','On'); drawnow;
handles = IFmain(handles);
set(handles.text_calculating,'Visible','Off'); drawnow;
handles = plot_results(handles);
guidata(hObject,handles);

% --- Executes during object creation, after setting all properties.
function edit_a_RS_acc_slow_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit_a_RS_acc_slow (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


function edit_tau_RS_acc_slow_Callback(hObject, eventdata, handles)
% hObject    handle to edit_tau_RS_acc_slow (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit_tau_RS_acc_slow as text
%        str2double(get(hObject,'String')) returns contents of edit_tau_RS_acc_slow as a double
handles.parameters.tau_th_acc_slow = str2double(get(hObject,'string'));
set(handles.text_calculating,'Visible','On'); drawnow;
handles = IFmain(handles);
set(handles.text_calculating,'Visible','Off'); drawnow;
handles = plot_results(handles);
guidata(hObject,handles);

% --- Executes during object creation, after setting all properties.
function edit_tau_RS_acc_slow_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit_tau_RS_acc_slow (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


function edit_T_ARP0_Callback(hObject, eventdata, handles)
% hObject    handle to edit_T_ARP0 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit_T_ARP0 as text
%        str2double(get(hObject,'String')) returns contents of edit_T_ARP0 as a double
handles.parameters.T_ARP0 = str2double(get(hObject,'string'));
set(handles.text_calculating,'Visible','On'); drawnow;
handles = IFmain(handles);
set(handles.text_calculating,'Visible','Off'); drawnow;
handles = plot_results(handles);
guidata(hObject,handles);

% --- Executes during object creation, after setting all properties.
function edit_T_ARP0_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit_T_ARP0 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


function edit_tau_RRP0_Callback(hObject, eventdata, handles)
% hObject    handle to edit_tau_RRP0 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit_tau_RRP0 as text
%        str2double(get(hObject,'String')) returns contents of edit_tau_RRP0 as a double
handles.parameters.tau_RRP0 = str2double(get(hObject,'string'));
set(handles.text_calculating,'Visible','On'); drawnow;
handles = IFmain(handles);
set(handles.text_calculating,'Visible','Off'); drawnow;
handles = plot_results(handles);
guidata(hObject,handles);

% --- Executes during object creation, after setting all properties.
function edit_tau_RRP0_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit_tau_RRP0 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


function edit_sigma_ref_Callback(hObject, eventdata, handles)
% hObject    handle to edit_sigma_ref (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit_sigma_ref as text
%        str2double(get(hObject,'String')) returns contents of edit_sigma_ref as a double
handles.parameters.sigma_ref = str2double(get(hObject,'string'));
set(handles.text_calculating,'Visible','On'); drawnow;
handles = IFmain(handles);
set(handles.text_calculating,'Visible','Off'); drawnow;
handles = plot_results(handles);
guidata(hObject,handles);

% --- Executes during object creation, after setting all properties.
function edit_sigma_ref_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit_sigma_ref (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


function edit_rho_corr_Callback(hObject, eventdata, handles)
% hObject    handle to edit_rho_corr (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit_rho_corr as text
%        str2double(get(hObject,'String')) returns contents of edit_rho_corr as a double
handles.parameters.rho_corr = str2double(get(hObject,'string'));
set(handles.text_calculating,'Visible','On'); drawnow;
handles = IFmain(handles);
set(handles.text_calculating,'Visible','Off'); drawnow;
handles = plot_results(handles);
guidata(hObject,handles);

% --- Executes during object creation, after setting all properties.
function edit_rho_corr_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit_rho_corr (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


function edit_a_RS_ref_Callback(hObject, eventdata, handles)
% hObject    handle to edit_a_RS_ref (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit_a_RS_ref as text
%        str2double(get(hObject,'String')) returns contents of edit_a_RS_ref as a double
handles.parameters.a_RS_ref = str2double(get(hObject,'string'));
set(handles.text_calculating,'Visible','On'); drawnow;
handles = IFmain(handles);
set(handles.text_calculating,'Visible','Off'); drawnow;
handles = plot_results(handles);
guidata(hObject,handles);

% --- Executes during object creation, after setting all properties.
function edit_a_RS_ref_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit_a_RS_ref (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


function edit_tau_RS_ref_Callback(hObject, eventdata, handles)
% hObject    handle to edit_tau_RS_ref (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit_tau_RS_ref as text
%        str2double(get(hObject,'String')) returns contents of edit_tau_RS_ref as a double
handles.parameters.tau_RS_ref = str2double(get(hObject,'string'));
set(handles.text_calculating,'Visible','On'); drawnow;
handles = IFmain(handles);
set(handles.text_calculating,'Visible','Off'); drawnow;
handles = plot_results(handles);
guidata(hObject,handles);

% --- Executes during object creation, after setting all properties.
function edit_tau_RS_ref_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit_tau_RS_ref (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% --- Executes during object creation, after setting all properties.
function figure1_CreateFcn(hObject, eventdata, handles)
% hObject    handle to figure1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called


% --- Executes during object creation, after setting all properties.
function text_calculating_CreateFcn(hObject, eventdata, handles)
% hObject    handle to text_calculating (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% LOAD OR SAVE DATA/FIGURES %%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% --- Executes on button press in pushbutton_index_neuron_down.
function pushbutton_index_neuron_down_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton_index_neuron_down (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
if handles.index_neuron > 1
    handles.index_neuron = handles.index_neuron - 1;
    set(handles.edit_index_neuron,'String',handles.index_neuron)
    handles = plot_results(handles);
end
guidata(hObject,handles);

% --- Executes on button press in pushbutton_index_neuron_up.
function pushbutton_index_neuron_up_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton_index_neuron_up (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
if handles.index_neuron < handles.parameters.nneurons
    handles.index_neuron = handles.index_neuron + 1;
    set(handles.edit_index_neuron,'String',handles.index_neuron)
    handles = plot_results(handles);
end
guidata(hObject,handles);

function edit_index_neuron_Callback(hObject, eventdata, handles)
% hObject    handle to edit_index_neuron (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% Hints: get(hObject,'String') returns contents of edit_index_neuron as text
%        str2double(get(hObject,'String')) returns contents of edit_index_neuron as a double
new_val = str2double(get(hObject,'string'));
if new_val >= 1 && new_val <= handles.parameters.nneurons
    handles.index_neuron = round(str2double(get(hObject,'string')));
    handles = plot_results(handles);
else
    set(handles.edit_index_neuron,'String',handles.index_neuron)
end
guidata(hObject,handles);

% --- Executes during object creation, after setting all properties.
function edit_index_neuron_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit_index_neuron (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in radiobutton_fig_v_average.
function radiobutton_fig_v_average_Callback(hObject, eventdata, handles)
% hObject    handle to radiobutton_fig_v_average (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% Hint: get(hObject,'Value') returns toggle state of radiobutton_fig_v_average
handles.fig_v_average = get(hObject,'Value');
handles.fig_v_single_neuron = 0;
set(handles.radiobutton_fig_v_single_neuron,'Value',0);
handles = plot_results(handles);
guidata(hObject, handles);

% --- Executes on button press in radiobutton_fig_v_single_neuron.
function radiobutton_fig_v_single_neuron_Callback(hObject, eventdata, handles)
% hObject    handle to radiobutton_fig_v_single_neuron (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% Hint: get(hObject,'Value') returns toggle state of radiobutton_fig_v_single_neuron
handles.fig_v_single_neuron = get(hObject,'Value');
set(handles.edit_index_neuron,'String',handles.index_neuron)
handles.fig_v_average = 0;
set(handles.radiobutton_fig_v_average,'Value',0);
handles = plot_results(handles);
guidata(hObject, handles);

% --- Executes on button press in pushbutton_load_data_ECAP.
function pushbutton_load_data_ECAP_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton_load_data_ECAP (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

%%% select file
[FileName,PathName] = uigetfile('*.mat','Select Data-file');
data_temp = load([PathName, FileName]);

%%% process and "upload" data into handles
% stimulus
handles.data.A_CL = max(data_temp.stim);
handles.data.A = CL_to_exAmp(handles.data.A_CL) .* handles.stimulation.scaling_ex_to_in;
handles.data.mod = data_temp.stim_A;
handles.data.pr = data_temp.pulserates;
handles.data.tIPI = round(1000/handles.data.pr);
set(handles.text_data_A_CL,'String',handles.data.A_CL);
set(handles.text_data_A,'String',handles.data.A);
set(handles.text_data_tIPI,'String',handles.data.tIPI);

% ECAP
handles.data.ECAP_time = data_temp.t_1000;
handles.data.ECAP_amp = data_temp.amp_1000;
handles.data.ECAP_scale = data_temp.scaleFactor;
if max(handles.data.ECAP_amp) > 1
    handles.data.scale = max(handles.data.ECAP_amp);
    handles.data.ECAP_amp = handles.data.ECAP_amp/handles.data.scale;
end

% mod depth CL
A_CL_max = max(data_temp.stim);
A_CL_min = min(data_temp.stim);
mod_depth = (A_CL_max-A_CL_min)/(A_CL_max+A_CL_min);
handles.data.mod_depth_CL = round(100*mod_depth)/100;
set(handles.text_data_mod_depth_CL,'String',handles.data.mod_depth_CL);

% mod depth Amperes
A_max = CL_to_exAmp(A_CL_max) .* handles.stimulation.scaling_ex_to_in;
A_min = CL_to_exAmp(A_CL_min) .* handles.stimulation.scaling_ex_to_in;
mod_depth = (A_max-A_min)/(A_max+A_min);
handles.data.mod_depth = round(100*mod_depth)/100;
set(handles.text_data_mod_depth,'String',handles.data.mod_depth);

% mod freq
str_begin = strfind(FileName,'f');
str_begin = str_begin(end);
str_end = strfind(FileName,'Hz');
str_end = str_end(2);
str_mod_freq = FileName(str_begin+1:str_end-1);
handles.data.mod_freq = str2double(str_mod_freq);
set(handles.text_data_mod_freq,'String',handles.data.mod_freq/1000);

% mod type
if length(strfind(FileName,'Sinusoid')) ~= 0
   handles.data.mod_type = 1;
   handles.data.mod_type_str = 'Sinusoidal';
   set(handles.text_data_mod_type,'String','Sinusoidal');

end
if length(strfind(FileName,'Square')) ~= 0
   handles.data.mod_type = 2;
   handles.data.mod_type_str = 'Square';
   set(handles.text_data_mod_type,'String','Square');
end
if length(strfind(FileName,'Sawtooth')) ~= 0
   handles.data.mod_type = 3;
   handles.data.mod_type_str = 'Saw';
   set(handles.text_data_mod_type,'String','Saw');
end
if length(strfind(FileName,'Reversed Sawtooth')) ~= 0
   handles.data.mod_type = 4;
   handles.data.mod_type_str = 'Reverse Saw';
   set(handles.text_data_mod_type,'String','Reverse Saw');   
end

%ea = handles.data.ECAP_amp;
%et = handles.data.ECAP_time;
%save('test.mat','ea','et');
set(handles.checkbox_show_data, 'Value', 1);
handles.data_available = 1;
guidata(hObject,handles);
handles = plot_results(handles);

function pushbutton_load_data_AGF_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton_load_data_AGF (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
%%% NOT DEFINED YET

% --- Executes on button press in checkbox_show_data.
function checkbox_show_data_Callback(hObject, eventdata, handles)
% hObject    handle to checkbox_show_data (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% Hint: get(hObject,'Value') returns toggle state of checkbox_show_data
guidata(hObject,handles);
handles = plot_results(handles);

% --- Executes on button press in checkbox_show_stimulus.
function checkbox_show_stimulus_Callback(hObject, eventdata, handles)
% hObject    handle to checkbox_show_stimulus (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% Hint: get(hObject,'Value') returns toggle state of checkbox_show_stimulus
guidata(hObject,handles);
handles = plot_results(handles);


% --- Executes on button press in pushbutton_export_data.
function pushbutton_export_data_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton_export_data (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
tm = fix(clock);
timestr = [num2str(tm(1)),'_',num2str(tm(2)),'_',num2str(tm(3)),'_',...
    num2str(tm(4)),'_',num2str(tm(5)),'_',num2str(tm(6))];

p = handles.parameters;
s = handles.stimulation;
modeltype = handles.modeltype;
v = handles.v;
if ~handles.light_code
    vth = handles.vth;
    x = handles.x;
end
spiketimes = handles.spiketimes;
    
ECAP_amp = handles.ECAP_amp;
ECAP_time = handles.ECAP_time;
%chronaxie_A = handles.chronaxie_A;
%chronaxie_tw = handles.chronaxie_tw;
%recovery_A2 = handles.recovery_A2;
%recovery_tIPI = handles.recovery_tIPI;

set(handles.text_calculating,'Visible','On'); drawnow;
save([timestr,'_data','.mat'],...
    'p','s','modeltype', 'v','spiketimes',...%'vth','x',...
    'ECAP_amp','ECAP_time');%,'chronaxie_A','chronaxie_tw','recovery_A2','recovery_tIPI');

if handles.data_available
    data = handles.data;
    save([timestr,'_data','.mat'],'data','-append');
end
set(handles.text_calculating,'Visible','Off'); drawnow;

% --- Executes on button press in pushbutton_save_fig_ECAP.
function pushbutton_save_fig_ECAP_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton_save_fig_ECAP (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% ECAP
figure('units','normalized', 'position',[0.2 0.4 0.6 0.3])

if handles.ECAP_normalized
    plot(handles.ECAP_time,handles.ECAP_amp/max(handles.ECAP_amp),'-o blue');
    axis([0 handles.parameters.tmax 0 1]);
    ylabel('ECAP model (normalized)');
else
    plot(handles.ECAP_time,handles.ECAP_amp,'-o blue');
    ylabel('ECAP model');
end
title('ECAP model vs. time')
xlabel('t (ms)');

% plot ECAP data if avaible (loaded) and toggled on
% plot show stimulus is toggled on
if handles.checkbox_show_stimulus.Value
    hold on;
    Istim_mod = handles.stimulation.mod/max(handles.stimulation.mod);
    plot(handles.parameters.t,1.1-min(Istim_mod) + Istim_mod,'-red');
    %plot(handles.parameters.t,handles.stimulation.mod/max(handles.stimulation.mod),'-r');
    hold off;
end

if handles.checkbox_show_data.Value
    if handles.data_available
        hold on;
        if handles.ECAP_normalized
            plot(handles.data.ECAP_time,handles.data.ECAP_amp,'-x black');        
            ylabel('ECAP model, ECAP data (normalized)');
        else
            plot(handles.data.ECAP_time,handles.data.ECAP_amp.*handles.data.ECAP_scale,'-x black');
            ylabel('ECAP model, ECAP data (normalized)');
        end
        title('ECAP model and ECAP data vs. time')
        xlabel('t (ms)');
        hold off;
    end
end


% --- Executes on button press in pushbutton_save_fig_v.
function pushbutton_save_fig_v_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton_save_fig_v (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
t = handles.parameters.t;
tmax = handles.parameters.tmax;
nneurons = handles.parameters.nneurons;
v = handles.v;
vth = handles.vth;
index_neuron = handles.index_neuron;

figure('units','normalized', 'position',[0.2 0.4 0.6 0.3])
xlabel('t (ms)');

if handles.fig_v_average
    plot(t,sum(v,2)./nneurons,'-black');
    axis([0 tmax -20 100]);
    
    if ~handles.light_code
        hold on;
        plot(t,sum(vth,2)./nneurons,'-red');
        title('V_{mem avr} and V_{th avr} vs. time')
        ylabel('V_{mem avr}, V_{th avr}(mV)')
        legend('V_{mem avr}, V_{th avr}')
    else
        title('V_{mem avr} vs. time')
        ylabel('V_{mem avr}')
        legend('V_{mem avr}')
    end
end

if handles.fig_v_single_neuron
    plot(t,v(:,index_neuron),'-black');
    axis([0 tmax -20 100]);
    if ~handles.light_code
        hold on;
        plot(t,vth(:,index_neuron),'-red');
        title(['V_{mem} and V_{th} of neuron ' num2str(index_neuron) ,' vs. time'])
        ylabel('V_{mem}, V_{th}(mV)')   
        legend('V_{mem}, V_{th}')
    else
        title(['V_{mem} of neuron ' num2str(index_neuron) ,' vs. time'])
        ylabel('V_{mem}')   
        legend('V_{mem}')
    end        
end
hold off;


% --- Executes on button press in pushbutton_save_fig_hist.
function pushbutton_save_fig_hist_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton_save_fig_hist (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
tmax = handles.parameters.tmax;
nneurons = handles.parameters.nneurons;
tIPI = handles.stimulation.tIPI;

figure('units','normalized', 'position',[0.2 0.4 0.6 0.3])
% histogram
histogram(cell2mat(handles.spiketimes),round(tmax/tIPI),'BinLimits',[0 tmax]);

% normalized histogram
hold on;
edges = [0 2 6 12 20 30 40 50 tmax];
st = cell2mat(handles.spiketimes);
clear bin;
for i=1:length(edges)-1
    spikes_in_bin = length(st(st>=edges(i) & st<edges(i+1)));
    bin_count(i) = spikes_in_bin/(edges(i+1)-edges(i)); %* 1000/nneurons;
    bin_time(i) = 0.5*(edges(i)+edges(i+1));
end
plot(bin_time, bin_count,'-r*');
hold off;

title('Spike histogram vs. time')
axis([0 tmax 0 nneurons]);
xlabel('t (ms)');
ylabel('(Normalized) Number of spikes per bin');
%legend('Histogram, Normalized histogram');


% --- Executes on button press in pushbutton_load_data_recovery.
function pushbutton_load_data_recovery_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton_load_data_recovery (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% --- Executes on button press in checkbox_ECAP_normalized.
function checkbox_ECAP_normalized_Callback(hObject, eventdata, handles)
% hObject    handle to checkbox_ECAP_normalized (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% Hint: get(hObject,'Value') returns toggle state of checkbox_ECAP_normalized
handles.ECAP_normalized = get(hObject,'Value');
handles = plot_results(handles);
guidata(hObject, handles);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% OPTIMIZATION %%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% --- Executes on button press in radiobutton_opt_A.
function radiobutton_opt_A_Callback(hObject, eventdata, handles)
% hObject    handle to radiobutton_opt_A (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% Hint: get(hObject,'Value') returns toggle state of radiobutton_opt_A
set(handles.pushbutton_opt_go,'Enable','on','BackGroundColor','g');
handles.opt.var_vector(1,1) = get(hObject,'Value');
guidata(hObject, handles);

function edit_opt_A_low_Callback(hObject, eventdata, handles)
% hObject    handle to edit_opt_A_low (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% Hints: get(hObject,'String') returns contents of edit_opt_A_low as text
%        str2double(get(hObject,'String')) returns contents of edit_opt_A_low as a double
handles.opt.bound_matrix(1,1) = str2num(get(hObject,'String'));
guidata(hObject, handles);

% --- Executes during object creation, after setting all properties.
function edit_opt_A_low_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit_opt_A_low (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function edit_opt_A_step_Callback(hObject, eventdata, handles)
% hObject    handle to edit_opt_A_step (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% Hints: get(hObject,'String') returns contents of edit_opt_A_step as text
%        str2double(get(hObject,'String')) returns contents of edit_opt_A_step as a double
handles.opt.bound_matrix(1,2) = str2num(get(hObject,'String'));
guidata(hObject, handles);

% --- Executes during object creation, after setting all properties.
function edit_opt_A_step_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit_opt_A_step (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


function edit_opt_A_high_Callback(hObject, eventdata, handles)
% hObject    handle to edit_opt_A_high (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% Hints: get(hObject,'String') returns contents of edit_opt_A_high as text
%        str2double(get(hObject,'String')) returns contents of edit_opt_A_high as a double
handles.opt.bound_matrix(1,3) = str2num(get(hObject,'String'));
guidata(hObject, handles);

% --- Executes during object creation, after setting all properties.
function edit_opt_A_high_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit_opt_A_high (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in radiobutton_opt_nneurons.
function radiobutton_opt_nneurons_Callback(hObject, eventdata, handles)
% hObject    handle to radiobutton_opt_nneurons (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% Hint: get(hObject,'Value') returns toggle state of radiobutton_opt_nneurons
set(handles.pushbutton_opt_go,'Enable','on','BackGroundColor','g');
handles.opt.var_vector(2,1) = get(hObject,'Value');
guidata(hObject, handles);


function edit_opt_nneurons_low_Callback(hObject, eventdata, handles)
% hObject    handle to edit_opt_nneurons_low (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% Hints: get(hObject,'String') returns contents of edit_opt_nneurons_low as text
%        str2double(get(hObject,'String')) returns contents of edit_opt_nneurons_low as a double
handles.opt.bound_matrix(2,1) = str2num(get(hObject,'String'));
guidata(hObject, handles);

% --- Executes during object creation, after setting all properties.
function edit_opt_nneurons_low_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit_opt_nneurons_low (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edit_opt_nneurons_step_Callback(hObject, eventdata, handles)
% hObject    handle to edit_opt_nneurons_step (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit_opt_nneurons_step as text
%        str2double(get(hObject,'String')) returns contents of edit_opt_nneurons_step as a double
handles.opt.bound_matrix(2,2) = str2num(get(hObject,'String'));
guidata(hObject, handles);

% --- Executes during object creation, after setting all properties.
function edit_opt_nneurons_step_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit_opt_nneurons_step (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function edit_opt_nneurons_high_Callback(hObject, eventdata, handles)
% hObject    handle to edit_opt_nneurons_high (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% Hints: get(hObject,'String') returns contents of edit_opt_nneurons_high as text
%        str2double(get(hObject,'String')) returns contents of edit_opt_nneurons_high as a double
handles.opt.bound_matrix(2,3) = str2num(get(hObject,'String'));
guidata(hObject, handles);

% --- Executes during object creation, after setting all properties.
function edit_opt_nneurons_high_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit_opt_nneurons_high (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in popupmenu_opt_list_parameters.
function popupmenu_opt_list_parameters_Callback(hObject, eventdata, handles)
% hObject    handle to popupmenu_opt_list_parameters (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns popupmenu_opt_list_parameters contents as cell array
%        contents{get(hObject,'Value')} returns selected item from popupmenu_opt_list_parameters
set(handles.pushbutton_opt_go,'Enable','on','BackGroundColor','g');
val = get(hObject,'Value');
handles.opt.var_vector(3:end,1) = 0; % reset all
handles.opt.var_vector(val,1) = 1; % except selected and first two variables
handles.opt.var_selected = val;
guidata(hObject, handles);

% --- Executes during object creation, after setting all properties.
function popupmenu_opt_list_parameters_CreateFcn(hObject, eventdata, handles)
% hObject    handle to popupmenu_opt_list_parameters (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


function edit_opt_parameter_low_Callback(hObject, eventdata, handles)
% hObject    handle to edit_opt_parameter_low (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit_opt_parameter_low as text
%        str2double(get(hObject,'String')) returns contents of edit_opt_parameter_low as a double
handles.opt.bound_matrix(handles.opt.var_selected,1) = str2num(get(hObject,'String'));
guidata(hObject, handles);

% --- Executes during object creation, after setting all properties.
function edit_opt_parameter_low_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit_opt_parameter_low (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function edit_opt_parameter_step_Callback(hObject, eventdata, handles)
% hObject    handle to edit_opt_parameter_step (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit_opt_parameter_step as text
%        str2double(get(hObject,'String')) returns contents of edit_opt_parameter_step as a double
handles.opt.bound_matrix(handles.opt.var_selected,2) = str2num(get(hObject,'String'));
guidata(hObject, handles);

% --- Executes during object creation, after setting all properties.
function edit_opt_parameter_step_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit_opt_parameter_step (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


function edit_opt_parameter_high_Callback(hObject, eventdata, handles)
% hObject    handle to edit_opt_parameter_high (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit_opt_parameter_high as text
%        str2double(get(hObject,'String')) returns contents of edit_opt_parameter_high as a double
handles.opt.bound_matrix(handles.opt.var_selected,3) = str2num(get(hObject,'String'));
guidata(hObject, handles);

% --- Executes during object creation, after setting all properties.
function edit_opt_parameter_high_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit_opt_parameter_high (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end




%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% OPTIM BELOW %%%%%%%%%%%%%%%%%%%%%%%%%%%%
% --- Executes on button press in pushbutton_opt_go.
function pushbutton_opt_go_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton_opt_go (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles       structure with handles and user data (see GUIDATA)
    %optmatrix = handles.opt.bound_matrix;
    %optvar = handles.opt.var_vector;
    %save('test.mat','optvar','optmatrix');
    %handles.opt.var_string = {'handles.stimulus.A'; 'handles.parameter.nneurons'};
if handles.data_available
    set(handles.text_calculating,'Visible','On'); drawnow;
    set(handles.pushbutton_opt_go,'BackGroundColor','r'); drawnow;
    var_to_optimize = find(handles.opt.var_vector == 1);
    
    tic
    for index_opt = 1:length(var_to_optimize) % loop across variables
        cur_index = var_to_optimize(index_opt);
        var_string_name = handles.opt.var_string{cur_index,1}; % var name
        low = handles.opt.bound_matrix(cur_index,1);
        step = handles.opt.bound_matrix(cur_index,2);
        high = handles.opt.bound_matrix(cur_index,3);
        
        [newValue, mean_error, std_error, handles] = ...
            LinearOptimization(handles, low, step, high, var_string_name);
        
        eval([var_string_name '=' num2str(newValue) ';']);
    end
    toc
    
    set(handles.edit_A,'String',handles.stimulation.A);
    set(handles.edit_nneurons,'String',handles.parameters.nneurons);
    st = strcat('set(handles.edit_', handles.par_list(cur_index), ',', '''String''', ',', num2str(newValue), ');');
    eval(st);
    
    set(handles.text_opt_error_mean,'String',num2str(mean_error));
    set(handles.text_opt_error_std,'String',num2str(std_error));
        handles = IFmain(handles);
        handles = plot_results(handles);    
    set(handles.pushbutton_opt_go,'BackGroundColor','g'); drawnow;
    set(handles.text_calculating,'Visible','Off'); drawnow;
    guidata(hObject,handles);
end    
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%    
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% --- Executes during object creation, after setting all properties.
function text_opt_error_mean_CreateFcn(hObject, eventdata, handles)
% hObject    handle to text_opt_error_mean (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

% --- Executes during object creation, after setting all properties.
function text_opt_error_std_CreateFcn(hObject, eventdata, handles)
% hObject    handle to text_opt_error_std (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



%% RESET PARAMETERS, GO/NO GO control
% --- Executes on button press in pushbutton_reset.
function pushbutton_reset_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton_reset (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% initialized parameters again:
handles = init_GUI_parameters(handles);
% execute the algorithm:
set(handles.text_calculating,'Visible','On'); drawnow;
handles = IFmain(handles);
set(handles.text_calculating,'Visible','Off'); drawnow;
% plot results:
handles = plot_results(handles);
% Update handles structure
guidata(hObject, handles);

% --- Executes on button press in pushbutton_go.
function pushbutton_go_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton_go (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
handles.no_go = 0;
set(handles.text_calculating,'Visible','On'); drawnow;
handles = IFmain(handles);
set(handles.text_calculating,'Visible','Off'); drawnow;
guidata(hObject,handles);

% --- Executes on button press in pushbutton_no_go.
function pushbutton_no_go_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton_no_go (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
handles.no_go = 1;
set(handles.pushbutton_no_go,'BackgroundColor',[0.8 0.8 0.8]); drawnow;
guidata(hObject,handles);


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% CALCULATE RECOVERY, CHRONAXIE, AGF etc
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% --- Executes on button press in pushbutton_chronaxie_calculate.
function pushbutton_chronaxie_calculate_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton_chronaxie_calculate (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
set(handles.text_calculating,'Visible','On'); drawnow;
handles = strength_duration(handles);
set(handles.text_calculating,'Visible','Off'); drawnow;
axes(handles.fig_chronaxie), cla;
plot(handles.chronaxie_tw,handles.chronaxie_A,'rO');
guidata(hObject, handles);

% --- Executes on button press in pushbutton_calculate_recovery_function.
function pushbutton_calculate_recovery_function_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton_calculate_recovery_function (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
set(handles.text_calculating,'Visible','On'); drawnow;
handles = recovery_function_ECAP(handles);
set(handles.text_calculating,'Visible','Off'); drawnow;
axes(handles.fig_chronaxie), cla;
plot(handles.recovery_tIPI,handles.recovery_ECAP_amp2_avr,'rO');
guidata(hObject, handles);


% --- Executes on button press in pushbutton_calculate_AGF.
function pushbutton_calculate_AGF_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton_calculate_AGF (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
set(handles.text_calculating,'Visible','On'); drawnow;
handles = AGF_ECAP(handles);
set(handles.text_calculating,'Visible','Off'); drawnow;
axes(handles.fig_chronaxie), cla;
plot(handles.AGF_A,handles.AGF_ECAP_amp,'rO');
guidata(hObject, handles);


% --- Executes during object creation, after setting all properties.
function fig_chronaxie_CreateFcn(hObject, eventdata, handles)
% hObject    handle to fig_chronaxie (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: place code in OpeningFcn to populate fig_chronaxie
