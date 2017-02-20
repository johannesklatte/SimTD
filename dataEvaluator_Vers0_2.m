% @author   : Johanens Klatte   
% @mail     : uidii@student.kit.edu
% @version  : 2.0
% @date     : 11.12.2015
% 
% 
% TODO-LIST: 
% 1. Finding its own gps file in the dir list !!!??             DONE!!
% 2. Add GPS velocity to speed (speedometer / bus da            DONE!!
% 3. Add all remaining object detection params                  open
% 4. Merge identical timestamps to one entry                    open
% 5. 
% 6. 
%
%
%

% Clear all workplace data
clear;

% Set current folder to scripts location/path)
cd(fileparts(mfilename('fullpath')))

% Get all files of the current scripts location/path)
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
fileNameCounter = fileNameCounter - 1;
% If no files were found (fileNameCounter == 0), exit script and display error message
if (fileNameCounter == 0)
    errorMessage = strcat('No files found matching the given pattern : ',' ', patternTextFiles);
    errorWindow = msgbox(errorMessage, 'Error!', 'error')
    return;
end
% Display a progress bar
messageProgress = strcat('Processing file 1/', num2str(fileNameCounter));
progressBar = waitbar(0, messageProgress);
% Loop over all files in the current dir and create a new FilteredData and a GPX file for each
for iFile = 1 : 1 : 1 %fileNameCounter
    filenameCurrent = fileNameList(iFile);
    % Create XML for the GPX file
    fileNameGPX = strcat(filenameCurrent, '.GPS_DATA.gpx');
    fidGPX = fopen(fileNameGPX{1,1}, 'wt');
    fprintf(fidGPX,'<?xml version="1.0" encoding="UTF-8"?>\n');
    fprintf(fidGPX,'<gpx version="1.0">\n');
    fprintf(fidGPX,'	<name>');
    fprintf(fidGPX, fileNameGPX{1,1});
    fprintf(fidGPX,'</name>\n');
    fprintf(fidGPX,'	<trk><name>');
    fprintf(fidGPX, fileNameGPX{1,1});
    fprintf(fidGPX,'</name><number>1</number><trkseg>\n');
    % Create File to save filtered data in 
    fileNameFilteredData = strcat(filenameCurrent, '.Filtered_DATA.txt');
    % Import the data of the current file using the delimiter delimiterTXT
    delimiterTXT = ' ';
    data = importdata(filenameCurrent{1,1}, delimiterTXT);
    [fileLength, j] = size(data);
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %fileLength = 1000;  %%% TESTING ONLY
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % Create cell array to save filtered data in. Currently saved data:
    % timestamp | engine speed | vehicle speed | curent gear | lat. acceleration
    % long. acceleration | lat. position | long. position | elevation | heading |distance | 
    filteredResult = cell((fileLength+1), 11);              %
    filteredResult{1, 1} = 'Timestamp[Y-M-D h:m:s:ms]';     %
    filteredResult{1, 2} = 'Engine Speed [U/min]';          %
    filteredResult{1, 3} = 'Vehicle Speed [km/h]';          %
    filteredResult{1, 4} = 'Current Gear';                  %
    filteredResult{1, 5} = 'Lateral Acceleration';          %
    filteredResult{1, 6} = 'Longitudinal Acceleration';     %
    filteredResult{1, 7} = 'Position: Latitude';            %
    filteredResult{1, 8} = 'Position: Longitude';           %
    filteredResult{1, 9} = 'Elevation';                     %
    filteredResult{1,10} = 'Heading';                       %
    filteredResult{1,11} = 'Distance';                      %
    
    
    % Loop over all rows of the current file to extract timestamps, engine speed, ...
    % Patterns used to filter for the respective entries
    % Timestamps
    patternTimestamp = 'IVS';
    timestampResultlistIndex = 1;
    timestampPosition = 2;
    % Engine speed
    patternEngineSpeed = 'm_IVS_AU_VAPIClient_EngineSpeed';
    enginespeedResultIndex = 2;
    enginespeedPosition = 5;
    % Vehicle speed
    patternVehicleSpeed = 'm_IVS_AU_VAPIClient_VehicleSpeed';
    vehiclespeedResultIndex = 3;
    vehiclespeedPosition = 5; 
    % Current gear
    patternCurrentGear = 'm_IVS_AU_VAPIClient_CurrentGear';
    currentGearResultlistIndex = 4;
    currentGearPosition = -1;
    % Lat. acceleration 
    patternLateralAcceleration = 'm_IVS_AU_VAPIClient_LateralAcceleration';
    LateralAccelerationResultlistIndex = 5;
    LateralAccelerationPosition = -1;
    % Long. acceleration
    patternLongitudinalAcceleration = 'm_IVS_AU_VAPIClient_LongitudinalAcceleration';
    LongitudinalAccelerationResultlistIndex = 6;
    LongitudinalAccelerationPosition = -1;
    % Lat. Position
    patternPositionLatitude = 'm_IVS_AU_VAPIClient_SimTD_FilteredPosition';
    PositionLatitudeResultlistIndex = 7;
    PositionLatitudePosition = 5;
    % Long. position
    patternPositionLongitude = 'm_IVS_AU_VAPIClient_SimTD_FilteredPosition';
    PositionLongitudeResultlistIndex = 8;
    PositionLongitudePosition = 7;
    % Eleveation / altitude
    patternElevation = 'm_IVS_AU_VAPIClient_SimTD_FilteredPosition';
    ElevationResultlistIndex = 9;
    ElevationPosition = 13;
    % Heading
    patternHeading = 'm_IVS_AU_VAPIClient_SimTD_FilteredPosition';
    HeadingResultlistIndex = 10; 
    HeadingPosition = 11;
    % Velocity
    patternVelocity = 'm_IVS_AU_VAPIClient_SimTD_FilteredPosition';
    VelocityResultlistIndex = 3; 
    VelocityPosition = 21;
    % Distance (to next car in front)
    patternDistance = 'm_IVS_AU_VAPIClient_SimTD_ObjectDetection';
    DistanceResultlistIndex = 11; 
    DistancePosition = -1;
    % Pattern for the in row delimiter
    patternDelimiter = ',';
    % Data counter for XML *.gpx GPS-file
    extraGPSDataCounter = 1;
    % Create Timestamp to compare new timestamps t0
    oldTimestamp = ' ';
    positionCounter  = 1;
    for i = 1 : 1 : fileLength
        positionCounter  = 1;
        % Timestamps
        index = strfind(data(i,j), patternTimestamp);
        if(index{1,1} > 0)
            splittedString = strsplit(data{i,j}, patternDelimiter);
            newTimestamp = splittedString{1,timestampPosition};
            if(~(strcmp(newTimestamp, oldTimestamp)))
                filteredResult{(i+1),timestampResultlistIndex}= newTimestamp;
            end
            oldTimestamp = newTimestamp;
        end
        % Engine speed
        index = strfind(data(i,j), patternEngineSpeed);
        if(index{1,1} > 0)
            splittedString = strsplit(data{i,j}, patternDelimiter);
            filteredResult{(i+1),enginespeedResultIndex}=str2double(splittedString{1,enginespeedPosition});        
        end
        % Vehicle speed
        index = strfind(data(i,j), patternVehicleSpeed);
        if(index{1,1} > 0)
            splittedString = strsplit(data{i,j}, patternDelimiter);
            filteredResult{(i+1),vehiclespeedResultIndex}=str2double(splittedString{1,vehiclespeedPosition});        
        end
        % Current Gear
        
        % lat. acceleration
        
        % long. acceleration
         
        % lat. Position, long. Position, elevation/altitude + writing XML in GPX-file
        index = strfind(data(i,j), patternPositionLatitude);
        if(index{1,1} > 0)
            splittedString = strsplit(data{i,j}, patternDelimiter);
            % check if GPS signal is found (i.e.: long./lat. Pos ~= 0)
            if((str2double(splittedString{1,PositionLatitudePosition}) ~= 0) && (str2double(splittedString{1,PositionLongitudePosition})~= 0))
                % lat. Position
                lat = str2double(splittedString{1,PositionLatitudePosition});
                filteredResult{(i+1),PositionLatitudeResultlistIndex}= lat;  
                % long Position
                long = str2double(splittedString{1,PositionLongitudePosition});
                filteredResult{(i+1),PositionLongitudeResultlistIndex} = long;
                % evelation / altitude
                elev = str2double(splittedString{1,ElevationPosition});
                filteredResult{(i+1),ElevationResultlistIndex} = elev;
                % heading
                heading = str2double(splittedString{1,HeadingPosition});
                filteredResult{(i+1),HeadingResultlistIndex} = heading;
                % velocity (additional entries to vehicle speed (speedometer))
                filteredResult{(i+1),VelocityResultlistIndex}=str2double(splittedString{1,VelocityPosition});
                % Write GPS data into the appropriate gpx file
                fprintf(fidGPX,'		<trkpt lat="');
                fprintf(fidGPX, num2str(lat));
                fprintf(fidGPX,'" lon="');
                fprintf(fidGPX, num2str(long)); 
                fprintf(fidGPX,'"><ele>');
                fprintf(fidGPX, num2str(elev));
                fprintf(fidGPX,'</ele>');
                % Model timestamp to the gpx-timestamp pattern
                timestamp = splittedString{1,timestampPosition};
                timestampGPX = strrep(timestamp, ' ', 'T');
                timestampGPX = strcat(timestampGPX(1:end-4),'Z');
                fprintf(fidGPX,'<time>');
                fprintf(fidGPX, timestampGPX);
                fprintf(fidGPX,'</time></trkpt>\n');
                extraGPSDataCounter = extraGPSDataCounter + 1;
            end
        end
        % distance  
        %index = strfind(data(i,j), patternDistance);
        %if(index{1,1} > 0)
        %    splittedString = strsplit(data{i,j}, patternDelimiter);
        %    filteredResult{(i+1),DistanceResultlistIndex}= splittedString{1,DistancePosition};
        %end
        % Update position counter
        positionCounter = positionCounter + 1;   
        % Display Progress in Waitbar 
        waitbar(i / fileLength);
    end
    % Closing XML's of the current GPX file
    fprintf(fidGPX,'	</trkseg></trk>\n');
    fprintf(fidGPX,'</gpx>');
    % Close current Waitbar
    close(progressBar);
end

% Close all (during script execution) opened files 
close('all');











