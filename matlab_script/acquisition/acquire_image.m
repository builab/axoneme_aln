function image = acquire_image(handles,options, mode, fileName, binning, aqTime)
% aquire_image(handles,options,mode,Filename,Binning,AqTime)
% HB 20080901 (code from spotscan.m by Martin Beck)

switch mode
    case 'exposure'
        handles.Acquisition.CCD.Binning = binning;
        handles.Acquisition.CCD.ExposureActTime = aqTime;
        handles.Acquisition.CCD.ExposureBaseTime = aqTime;

        tom_set_state(handles.Acquisition,handles.COMS,options);
        disp(['Acquiring image ' fileName]);
        acquisition=tom_acquire_image(handles.Acquisition,handles.COMS,options);
        image = tom_emheader(acquisition);
    case 'focus'
    case 'search'
end

% storage
image.Header.Voltage = 200000;
image.Header.Tiltangle = handles.Acquisition.Stage.Angle;
tom_emwrite(fileName,image);
