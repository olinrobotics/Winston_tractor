function varargout = ARDCommander(varargin)
% ARDCOMMANDER MATLAB code for ARDCommander.fig
%      ARDCOMMANDER, by itself, creates a new ARDCOMMANDER or raises the existing
%      singleton*.
%
%      H = ARDCOMMANDER returns the handle to a new ARDCOMMANDER or the handle to
%      the existing singleton*.
%
%      ARDCOMMANDER('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in ARDCOMMANDER.M with the given input arguments.
%
%      ARDCOMMANDER('Property','Value',...) creates a new ARDCOMMANDER or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the ARDCOMMANDER before ARDCommander_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to ARDCommander_OpeningFcn via varargin.
%
%      *See ARDCOMMANDER Options on GUIDE's Tools menu.  Choose "ARDCOMMANDER allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help ARDCommander

% Last Modified by GUIDE v2.5 27-Jul-2016 14:30:26

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @ARDCommander_OpeningFcn, ...
                   'gui_OutputFcn',  @ARDCommander_OutputFcn, ...
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


% --- Executes just before ARDCommander is made visible.
function ARDCommander_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to ARDCommander (see VARARGIN)

% Choose default command line output for ARDCommander
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes ARDCommander wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = ARDCommander_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


% --- Executes during object creation, after setting all properties.
function figure1_CreateFcn(hObject, eventdata, handles)
% hObject    handle to figure1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called
hAxes = axes('units', 'normalized', 'position', [0 0 1 1], 'Parent', hObject);
% Move the background axes to the bottom
uistack(hAxes, 'bottom');
% Load in a background image and display it using the correct colors
% The image used below, is in the Image Processing Toolbox.  If you do not have %access to this toolbox, you can use another image file instead.
I = imread('ARDCommander.jpg');
image(I, 'Parent', hAxes);
% Turn the handlevisibility off so that we don't inadvertently plot into the axes again
% Also, make the axes invisible
set(hAxes,'handlevisibility','off', 'visible', 'off')


% --- Executes on button press in buttonOFF.
function buttonOFF_Callback(hObject, eventdata, handles)
% hObject    handle to buttonOFF (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
system('./guard OFF');


% --- Executes on button press in buttonIDLE.
function buttonIDLE_Callback(hObject, eventdata, handles)
% hObject    handle to buttonIDLE (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
system('./guard IDLE');


% --- Executes on button press in buttonRUN.
function buttonRUN_Callback(hObject, eventdata, handles)
% hObject    handle to buttonRUN (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
system('./guard RUN');


% --- Executes on button press in buttonLOITER.
function buttonLOITER_Callback(hObject, eventdata, handles)
% hObject    handle to buttonLOITER (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
system('./guard LOITER');


% --- Executes on button press in buttonAPPROACH.
function buttonAPPROACH_Callback(hObject, eventdata, handles)
% hObject    handle to buttonAPPROACH (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
system('./guard APPROACH');


% --- Executes on button press in buttonCAPTURE.
function buttonCAPTURE_Callback(hObject, eventdata, handles)
% hObject    handle to buttonCAPTURE (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
system('./guard CAPTURE');


% --- Executes on button press in buttonRELEASE.
function buttonRELEASE_Callback(hObject, eventdata, handles)
% hObject    handle to buttonRELEASE (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
system('./guard RELEASE');


% --- Executes on button press in buttonDEPART.
function buttonDEPART_Callback(hObject, eventdata, handles)
% hObject    handle to buttonDEPART (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
system('./guard DEPART');
