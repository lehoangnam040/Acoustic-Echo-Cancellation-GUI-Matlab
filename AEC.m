function varargout = AEC(varargin)
% AEC MATLAB code for AEC.fig
%      AEC, by itself, creates a new AEC or raises the existing
%      singleton*.
%
%      H = AEC returns the handle to a new AEC or the handle to
%      the existing singleton*.
%
%      AEC('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in AEC.M with the given input arguments.
%
%      AEC('Property','Value',...) creates a new AEC or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before AEC_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to AEC_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help AEC

% Last Modified by GUIDE v2.5 15-Nov-2019 06:34:44

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @AEC_OpeningFcn, ...
                   'gui_OutputFcn',  @AEC_OutputFcn, ...
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


% --- Executes just before AEC is made visible.
function AEC_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to AEC (see VARARGIN)

% Choose default command line output for AEC
handles.output = hObject;
% Constants
handles.fs = 8000;
handles.M = handles.fs + 1;
handles.frameSize = 2048;
handles.nearend_len = 0;
handles.farend_len = 0;

[B,A] = cheby2(4,20,[0.1 0.7]);
handles.impulseResponseGenerator = dsp.IIRFilter('Numerator', [zeros(1,6) B], ...
    'Denominator', A);
handles.roomImpulseResponse = handles.impulseResponseGenerator( ...
        (log(0.99*rand(1,handles.M)+0.01).*sign(randn(1, handles.M)).*exp(-0.002*(1:handles.M)))');
handles.roomImpulseResponse = handles.roomImpulseResponse / norm(handles.roomImpulseResponse) * 4;
handles.room = dsp.FIRFilter('Numerator', handles.roomImpulseResponse');
% handles.fs = 8000;

% Construct the Frequency-Domain Adaptive Filter
handles.echoCanceller    = dsp.FrequencyDomainAdaptiveFilter('Length', 2048, ...
                    'StepSize', 0.025, ...
                    'InitialPower', 0.01, ...
                    'AveragingFactor', 0.98, ...
                    'BlockLength', handles.frameSize, ... % Set the block length to frameSize
                    'Method', 'Partitioned constrained FDAF');  %'Unconstrained FDAF');
handles.recObj = audiorecorder(handles.fs, 16 , 1, -1);

set(handles.btnSwitchspeaker, 'Enable', 'off');
set(handles.btnStoprecord, 'Enable', 'off');

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes AEC wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = AEC_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;

% --- Executes on button press in btnNearend.
function btnNearend_Callback(hObject, eventdata, handles)
% hObject    handle to btnNearend (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
load nearspeech;    % v la nearspeech
handles.nearspeech = v;
handles.nearend_len = length(handles.nearspeech);
plot(handles.axesNearend, handles.nearspeech);
guidata(hObject, handles);

% --- Executes on button press in btnFarend.
function btnFarend_Callback(hObject, eventdata, handles)
% hObject    handle to btnFarend (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
load farspeech;     % x la farspeech
handles.farspeech = x;
handles.echo_farspeech = handles.room(handles.farspeech);
plot(handles.axesFarend, handles.echo_farspeech);
handles.farend_len = length(handles.echo_farspeech);
guidata(hObject, handles);

% --- Executes on button press in btnMic.
function btnMic_Callback(hObject, eventdata, handles)
% hObject    handle to btnMic (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
if handles.nearend_len == handles.farend_len
    handles.micSignal = handles.nearspeech + handles.echo_farspeech + 0.001*randn(handles.nearend_len ,1);
    plot(handles.axesMic, handles.micSignal);
else
    warndlg('Near end speech and far end speech must be same duration and sampling','Warning');
end
guidata(hObject, handles);

% --- Executes on button press in btnSoundnear.
function btnSoundnear_Callback(hObject, eventdata, handles)
% hObject    handle to btnSoundnear (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
sound(handles.nearspeech, handles.fs);

% --- Executes on button press in btnSoundfar.
function btnSoundfar_Callback(hObject, eventdata, handles)
% hObject    handle to btnSoundfar (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
sound(handles.echo_farspeech, handles.fs);

% --- Executes on button press in btnSoundmic.
function btnSoundmic_Callback(hObject, eventdata, handles)
% hObject    handle to btnSoundmic (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
sound(handles.micSignal, handles.fs);


% --- Executes on button press in btnFilter.
function btnFilter_Callback(hObject, eventdata, handles)
% hObject    handle to btnFilter (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
nearSpeechSrc   = dsp.SignalSource('Signal', handles.nearspeech,'SamplesPerFrame', handles.frameSize);
farSpeechSrc    = dsp.SignalSource('Signal', handles.farspeech,'SamplesPerFrame', handles.frameSize);
farSpeechEchoSrc = dsp.SignalSource('Signal', handles.echo_farspeech, 'SamplesPerFrame', handles.frameSize);
micSrc = dsp.SignalSource('Signal', handles.micSignal, 'SamplesPerFrame', handles.frameSize);

nearSpeechSrc.SamplesPerFrame = handles.frameSize;
farSpeechSrc.SamplesPerFrame = handles.frameSize;
farSpeechEchoSrc.SamplesPerFrame = handles.frameSize;
micSrc.SamplesPerFrame = handles.frameSize;

resultSink = dsp.SignalSink;

% Stream processing loop - adaptive filter step size = 0.025
while(~isDone(micSrc))
    farSpeech = farSpeechSrc();
    micS = micSrc();
    % Apply FDAF
    [y, e] = handles.echoCanceller(farSpeech, micS);
    resultSink(e);
end
handles.result = resultSink.Buffer;
dt = 1/handles.fs;
time_axis = (0:dt:(length(handles.result)*dt)-dt)';
plot(handles.axesResult, time_axis, handles.result);
guidata(hObject, handles);

% --- Executes on button press in btnSoundResult.
function btnSoundResult_Callback(hObject, eventdata, handles)
% hObject    handle to btnSoundResult (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
sound(handles.result, handles.fs);


% --- Executes on button press in btnRoomecho.
function btnRoomecho_Callback(hObject, eventdata, handles)
% hObject    handle to btnRoomecho (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

FVT = fvtool(handles.impulseResponseGenerator);  % Analyze the filter
FVT.Color = [1 1 1];
fig = figure;
plot(0:1/(handles.fs*2):0.5, handles.roomImpulseResponse);
xlabel('Time (s)');
ylabel('Amplitude');
title('Room Impulse Response');
fig.Color = [1 1 1];


% --- Executes on button press in btnRecord.
function btnRecord_Callback(hObject, eventdata, handles)
% hObject    handle to btnRecord (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
handles.signal_frames = {};
record(handles.recObj);
set(handles.btnSwitchspeaker, 'Enable', 'on'); 
set(handles.btnRecord, 'Enable', 'off');
set(handles.txtNoti, 'String', 'Start recording: Voice of person who make the call');
guidata(hObject, handles);

% --- Executes on button press in btnStoprecord.
function btnStoprecord_Callback(hObject, eventdata, handles)
% hObject    handle to btnStoprecord (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
set(handles.txtNoti, 'String', 'End of conversation');
stop(handles.recObj);
handles.signal_frames{end + 1} = getaudiodata(handles.recObj);
L = length(handles.signal_frames);
handles.nearspeech = [];
handles.farspeech = [];

for i = 1:L
    if mod(i, 2) == 0
        handles.nearspeech = cat(1, handles.nearspeech, handles.signal_frames{i});
        handles.farspeech = cat(1, handles.farspeech, zeros(length(handles.signal_frames{i}), 1));
    else
        handles.farspeech = cat(1, handles.farspeech, handles.signal_frames{i}.*0.2);
        handles.nearspeech = cat(1, handles.nearspeech, zeros(length(handles.signal_frames{i}), 1));
    end
end
handles.echo_farspeech = handles.room(handles.farspeech);
handles.farend_len = length(handles.echo_farspeech);
% handles.nearend_len = length(handles.nearspeech);
handles.micSignal = handles.nearspeech + handles.echo_farspeech + 0.001*randn(handles.farend_len ,1);
dt = 1/handles.fs;
time_axis = (0:dt:(handles.farend_len*dt)-dt)';
plot(handles.axesMic, time_axis, handles.micSignal);
plot(handles.axesFarend, time_axis, handles.echo_farspeech);
plot(handles.axesNearend, time_axis, handles.nearspeech);
set(handles.btnSwitchspeaker, 'Enable', 'off');
set(handles.btnStoprecord, 'Enable', 'off');
set(handles.btnRecord, 'Enable', 'on');
guidata(hObject, handles);

% --- Executes on button press in btnSwitchspeaker.
function btnSwitchspeaker_Callback(hObject, eventdata, handles)
% hObject    handle to btnSwitchspeaker (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
stop(handles.recObj);
handles.signal_frames{end + 1} = getaudiodata(handles.recObj);
record(handles.recObj);

str = get(handles.txtNoti, 'String');
if strcmp(str, 'Start recording: Voice of person who make the call')
    set(handles.txtNoti, 'String', 'Switch speaker: Voice of person on the other side');
elseif strcmp(str, 'Switch speaker: Voice of person who make the call')
    set(handles.txtNoti, 'String', 'Switch speaker: Voice of person on the other side');
elseif strcmp(str, 'Switch speaker: Voice of person on the other side')
    set(handles.btnStoprecord, 'Enable', 'on');
    set(handles.txtNoti, 'String', 'Switch speaker: Voice of person who make the call');
end
guidata(hObject, handles);
