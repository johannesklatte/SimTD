% @author   : Johanens Klatte   
% @mail     : uidii@student.kit.edu
% @version  : 0.40a
% @date     : 17.12.2015
% 
% 

% Clear all workplace data
clear;
% Set current folder to scripts location/path)
cd(fileparts(mfilename('fullpath')))

% Get all filenames of the current scripts location/path
tic
MyDirInfo = dir;
fileNameList = {};                      % List of all filenames in the dir
[dirLength, j] = size(MyDirInfo);
patternTextFiles = 'decoded.txt';       % Naming pattern for the *.txt files
excludedPatternGPX = 'GPS_DATA.gpx';
excludedPatternFilteredData = '';
fileNameCounter = 1;
for i = 1 : 1 : dirLength
    indexTextFiles = strfind(MyDirInfo(i).name, patternTextFiles);
    indexGPXFiles = strfind(MyDirInfo(i).name, excludedPatternGPX);
    indexFilteredFiles = strfind(MyDirInfo(i).name, excludedPatternFilteredData);
    if(indexTextFiles > 0)
        if(isempty(indexGPXFiles)) 
            if (isempty(indexFilteredFiles))
                fileNameList{fileNameCounter, 1} = MyDirInfo(i).name; 
                fileNameCounter = fileNameCounter + 1;
            end
        end
    end
end
toc

tic
parfor iFile = 1 : 1 : fileNameCounter-1
    filenameCurrent = fileNameList{iFile};
    % Create XML for the GPX file
    fileNameGPX = strcat(filenameCurrent, '.GPS_DATA.gpx');
    fidGPX = fopen(fileNameGPX(1, :), 'wt');
    fprintf(fidGPX,'<?xml version="1.0" encoding="UTF-8"?>\n');
    fprintf(fidGPX,'<gpx version="1.0">\n');
    fprintf(fidGPX,'	<name>');
    fprintf(fidGPX, fileNameGPX(1, :));
    fprintf(fidGPX,'</name>\n');
    fprintf(fidGPX,'	<trk><name>');
    fprintf(fidGPX, fileNameGPX(1, :));
    fprintf(fidGPX,'</name><number>1</number><trkseg>\n');
    % Import the data of the current file using the delimiter delimiterTXT
    delimiterTXT = ' ';
    data = importdata(filenameCurrent, delimiterTXT);
    [fileLengthCurrent, j] = size(data);
%     stringList = {
%         'IVS', ...                                               %
%         'm_IVS_AU_VAPIClient_EngineSpeed', ...                   %
%         'm_IVS_AU_VAPIClient_VehicleSpeed' ...                   %
%         'm_IVS_AU_VAPIClient_LongitudinalAcceleration', ...      %
%         'm_IVS_AU_VAPIClient_LateralAcceleration', ...           %
%         'm_IVS_AU_VAPIClient_SimTD_FilteredPosition', ...        %
%         'm_IVS_AU_VAPIClient_SimTD_ObjectDetection', ...         %
%         'm_IVS_AU_VAPIClient_Odometer', ...                      %
%         'm_IVS_AU_VAPIClient_TripOdometer', ...                  %
%         'm_IVS_AU_VAPIClient_SteeringWheelAngle', ...            %
%     	'm_IVS_AU_VAPIClient_SteeringWheelAngularVelocity', ...  % 
%         'm_IVS_AU_VAPIClient_WiperSystem_Front', ...             % 
%         'm_IVS_AU_VAPIClient_WiperSystem_Rear', ...              %
%         'm_IVS_AU_VAPIClient_ExteriorTemperature' ...            %
%         'm_IVS_AU_VAPIClient_TurnSignalLights_FrontLeft', ...	 % 
%         'm_IVS_AU_VAPIClient_TurnSignalLights_FrontRight', ...	 % 
%         'm_IVS_AU_VAPIClient_TurnSignalLights_RearLeft', ...     %
%         'm_IVS_AU_VAPIClient_TurnSignalLights_RearRight', ...    %
%         'm_IVS_AU_VAPIClient_FrontLights_DaytimeRunningLamp', ...% 
%         'm_IVS_AU_VAPIClient_FrontLights_HighBeam', ...
%         'm_IVS_AU_VAPIClient_FrontLights_LowBeam', ...
%         'm_IVS_AU_VAPIClient_FogLight', ...
%         'm_IVS_AU_VAPIClient_HazardWarningSystem', ...
%         'm_IVS_AU_VAPIClient_AntiLockBrakeSystem', ...
%         'm_IVS_AU_VAPIClient_GearSelection', ...
%         'm_IVS_AU_VAPIClient_CurrentGear', ...
%         'm_IVS_AU_VAPIClient_ClutchSwitchActuation', ...
%         'm_IVS_AU_VAPIClient_CruiseControlSystemState', ...
%         'm_IVS_AU_VAPIClient_PedalForce', ...
%         'm_IVS_AU_VAPIClient_BrakeActuation'
%         };
%     keywords = categorical(stringList);
%   
    
    %fileNameList{iFile} = inLOOPfileNameList;
    
    
    
    
    
    fclose(fidGPX);
end
toc
a = 4;























