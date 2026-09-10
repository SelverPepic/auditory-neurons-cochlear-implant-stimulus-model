function varargout = random_correlated_GUI(varargin)
% RANDOM_CORRELATED_GUI MATLAB code for random_correlated_GUI.fig
%      RANDOM_CORRELATED_GUI, by itself, creates a new RANDOM_CORRELATED_GUI or raises the existing
%      singleton*.
%
%      H = RANDOM_CORRELATED_GUI returns the handle to a new RANDOM_CORRELATED_GUI or the handle to
%      the existing singleton*.
%
%      RANDOM_CORRELATED_GUI('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in RANDOM_CORRELATED_GUI.M with the given input arguments.
%
%      RANDOM_CORRELATED_GUI('Property','Value',...) creates a new RANDOM_CORRELATED_GUI or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before random_correlated_GUI_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to random_correlated_GUI_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help random_correlated_GUI

% Last Modified by GUIDE v2.5 26-Oct-2018 17:19:08

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @random_correlated_GUI_OpeningFcn, ...
                   'gui_OutputFcn',  @random_correlated_GUI_OutputFcn, ...
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


% --- Executes just before random_correlated_GUI is made visible.
function random_correlated_GUI_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to random_correlated_GUI (see VARARGIN)

% Choose default command line output for random_correlated_GUI
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes random_correlated_GUI wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = random_correlated_GUI_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


% --- Executes on button press in button_generate_rand.
function button_generate_rand_Callback(hObject, eventdata, handles)
% hObject    handle to button_generate_rand (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
N = 100;
x = randn(N,1);
y = randn(N,1);
r = corr(x,y);
set(handles.x,'string',x);
set(handles.y,'string',y);
set(handles.rho_old,'string',r);

%handles.new_generated = 0;
%disp(handles.new_generated)
handles = plot_results(handles);



function rho_new_Callback(hObject, eventdata, handles)
% hObject    handle to rho_new (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of rho_new as text
%        str2double(get(hObject,'String')) returns contents of rho_new as a double
rho_new = 0;
rho_new = str2double(get(hObject,'string'));
set(handles.rho_new,'string',rho_new);
% disp(x) - does not work since x is locally defined!

% --- Executes during object creation, after setting all properties.
function rho_new_CreateFcn(hObject, eventdata, handles)
% hObject    handle to rho_new (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in button_generate_correlated.
function button_generate_correlated_Callback(hObject, eventdata, handles)
% hObject    handle to button_generate_correlated (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
x = get(handles.x,'string');
y = get(handles.y,'string');
rho_new = get(handles.rho_new,'string');
x = str2num(x);
y = str2num(y);
rho_new = str2num(rho_new);

C = [1 rho_new; rho_new 1];
[xy_new] = [x y] * chol(C);
x_new = xy_new(:,1);
y_new = xy_new(:,2);
r_new = corr(x_new,y_new);

set(handles.x_new,'string',x_new);
set(handles.y_new,'string',y_new);
set(handles.rho_new_calc,'string',r_new);

handles = plot_results(handles);

% --- Executes during object creation, after setting all properties.
function plot1_CreateFcn(hObject, eventdata, handles)
% hObject    handle to plot1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

title('Random variable 1 vs. 2','fontweight','bold');
xlabel('x');
ylabel('y');
% Hint: place code in OpeningFcn to populate plot1

function handles = plot_results(handles)
    if length(get(handles.x_new,'String')) == 5
        x = get(handles.x,'string');
        y = get(handles.y,'string');
        x = str2num(x);
        y = str2num(y);
        scatter(x,y);
    else
        x_new = get(handles.x_new,'string');
        y_new = get(handles.y_new,'string');
        x_new = str2num(x_new);
        y_new = str2num(y_new);
        scatter(x_new,y_new);
        
        hold on;
        X0 = [ones(length(x_new),1) x_new];
        b0 = X0\y_new;
        y_calc = X0*b0;
        plot(x_new,y_calc,'--')
    end