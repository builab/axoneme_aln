function move_stage_new(distance)
% move_stage(newPosition)
% 20080902
% initialization
options =['noImageProcessing' ' ' 'noStage'];
options_stage = 'noImageProcessing';
COMS=tom_make_all_coms;
[Tiltseries, Search, Tracking, Focus, Acquisition, Slit]=tom_make_acquisition_structure(COMS);
handles.COMS=COMS;
handles.Acquisition = tom_get_state(Acquisition,COMS,options_stage);

% Set parameters
handles.Acquisition.Stage.Position = handles.Acquisition.Stage.Position + distance; % Stage position

% Send parameters to machine
tom_set_state(handles.Acquisition,handles.COMS,options);

