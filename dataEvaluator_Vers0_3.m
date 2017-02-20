% @author   : Johanens Klatte   
% @mail     : uidii@student.kit.edu
% @version  : 3.0
% @date     : 17.12.2015
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

% Get all filenames of the current scripts location/path
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
    fileLength = 10000;  %%% TESTING ONLY
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    stringList = {
        'IVS', ...                                               %
        'm_IVS_AU_VAPIClient_EngineSpeed', ...                   %
        'm_IVS_AU_VAPIClient_VehicleSpeed' ...                   %
        'm_IVS_AU_VAPIClient_LongitudinalAcceleration', ...      %
        'm_IVS_AU_VAPIClient_LateralAcceleration', ...           %
        'm_IVS_AU_VAPIClient_SimTD_FilteredPosition', ...        %
        'm_IVS_AU_VAPIClient_SimTD_ObjectDetection', ...         %
        'm_IVS_AU_VAPIClient_Odometer', ...                      %
        'm_IVS_AU_VAPIClient_TripOdometer', ...                  %
        'm_IVS_AU_VAPIClient_SteeringWheelAngle', ...            %
    	'm_IVS_AU_VAPIClient_SteeringWheelAngularVelocity', ...  % 
        'm_IVS_AU_VAPIClient_WiperSystem_Front', ...             % 
        'm_IVS_AU_VAPIClient_WiperSystem_Rear', ...              %
        'm_IVS_AU_VAPIClient_ExteriorTemperature' ...            %
        'm_IVS_AU_VAPIClient_TurnSignalLights_FrontLeft', ...	 % 
        'm_IVS_AU_VAPIClient_TurnSignalLights_FrontRight', ...	 % 
        'm_IVS_AU_VAPIClient_TurnSignalLights_RearLeft', ...     %
        'm_IVS_AU_VAPIClient_TurnSignalLights_RearRight', ...    %
        'm_IVS_AU_VAPIClient_FrontLights_DaytimeRunningLamp', ...% 
        'm_IVS_AU_VAPIClient_FrontLights_HighBeam', ...
        'm_IVS_AU_VAPIClient_FrontLights_LowBeam', ...
        'm_IVS_AU_VAPIClient_FogLight', ...
        'm_IVS_AU_VAPIClient_HazardWarningSystem', ...
        'm_IVS_AU_VAPIClient_AntiLockBrakeSystem', ...
        'm_IVS_AU_VAPIClient_GearSelection', ...
        'm_IVS_AU_VAPIClient_CurrentGear', ...
        'm_IVS_AU_VAPIClient_ClutchSwitchActuation', ...
        'm_IVS_AU_VAPIClient_CruiseControlSystemState', ...
        'm_IVS_AU_VAPIClient_PedalForce', ...
        'm_IVS_AU_VAPIClient_BrakeActuation'
        };
    keywords = categorical(stringList);
    % Pattern for the in row delimiter
    patternDelimiter = ',';
    % Data counter for XML *.gpx GPS-file
    extraGPSDataCounter = 1;
    % Create Timestamp to compare new timestamps t0
    oldTimestamp = ' ';
    positionCounter  = 1;
    filteredData = cell(fileLength, 40); 
    filteredDataCounter = 1;
    %keywordsT= char(zeros(fileLength, 100));
    for a = 1 : 1 : fileLength
        inLoopdata = data{a,1};
        splittedString = strsplit(inLoopdata, patternDelimiter);
        inLoopdata = splittedString{3};
        keywordsT(a) = 'aq'; %inLoopdata;
    end
    toc
    
    
    tic
    for i = 1 : 1 : fileLength
        % 01: Timestamp
        splittedString = strsplit(data{i,1}, patternDelimiter);
        newTimestamp = splittedString{2};
        if(newTimestamp == oldTimestamp)
            %
        else
            filteredData{filteredDataCounter, 1} = newTimestamp;
            filteredDataCounter = filteredDataCounter + 1;
        end
        oldTimestamp = newTimestamp;
        % 02: EngineSpeed
        if(categorical(cellstr(splittedString{1,3})) == keywords(2))
            filteredData{filteredDataCounter - 1, 2} = str2double(splittedString{5});
        end
        % 03: VehicleSpeed 
        if(categorical(cellstr(splittedString{1,3})) == keywords(3))
            filteredData{filteredDataCounter - 1, 3} = str2double(splittedString{5});
        end
        % 04: LongitudinalAcceleration 
        if(categorical(cellstr(splittedString{1,3})) == keywords(4))
            filteredData{filteredDataCounter - 1, 4} = str2double(splittedString{5});
        end
        % 05: LateralAcceleration 
        if(categorical(cellstr(splittedString{1,3})) == keywords(5))
            filteredData{filteredDataCounter - 1, 5} = str2double(splittedString{5});
        end
        % 06: SimTD_FilteredPosition 
        if(categorical(cellstr(splittedString{1,3})) == keywords(6))
            %lat
            filteredData{filteredDataCounter - 1, 6} = str2double(splittedString{5});
            %long
            filteredData{filteredDataCounter - 1, 7} = str2double(splittedString{7});
            %alt
            filteredData{filteredDataCounter - 1, 8} = str2double(splittedString{13});
            %heading
            filteredData{filteredDataCounter - 1, 9} = str2double(splittedString{11});
            %velocity
            filteredData{filteredDataCounter - 1, 3} = str2double(splittedString{21});
         end
        % 07: ObjectDetection 
        if(categorical(cellstr(splittedString{1,3})) == keywords(7))
            %object detected
            filteredData{filteredDataCounter - 1, 10} = str2double(splittedString{5});
            %relative speed
            filteredData{filteredDataCounter - 1, 11} = str2double(splittedString{7});
            %relative distance
            filteredData{filteredDataCounter - 1, 12} = str2double(splittedString{9});
        end
        % 08: Odometer 
        if(categorical(cellstr(splittedString{1,3})) == keywords(8))
            filteredData{filteredDataCounter - 1, 13} = str2double(splittedString{5});
        end
        % 09: TripOdometer 
        if(categorical(cellstr(splittedString{1,3})) == keywords(9))
            filteredData{filteredDataCounter - 1, 14} = str2double(splittedString{5});
        end
        % 10: SteeringWheelAngle 
        if(categorical(cellstr(splittedString{1,3})) == keywords(10))
            filteredData{filteredDataCounter - 1, 15} = str2double(splittedString{5});
        end
        % 11: SteeringWheelAngularVelocity 
        if(categorical(cellstr(splittedString{1,3})) == keywords(11))
            filteredData{filteredDataCounter - 1, 16} = str2double(splittedString{5});
        end
%         % 12: WiperSystem_Front 
%         if(categorical(cellstr(splittedString{1,3})) == keywords(12))
%             filteredData{filteredDataCounter - 1, 17} = str2double(splittedString{5});
%         end
%         % 13: WiperSystem_Rear
%         if(categorical(cellstr(splittedString{1,3})) == keywords(13))
%             filteredData{filteredDataCounter - 1, 18} = str2double(splittedString{5});
%         end
        % 14: ExteriorTemperature  
        if(categorical(cellstr(splittedString{1,3})) == keywords(14))
            filteredData{filteredDataCounter - 1, 19} = str2double(splittedString{5});
        end
        % 15: TurnSignalLights_FrontLeft 
        if(categorical(cellstr(splittedString{1,3})) == keywords(15))
            filteredData{filteredDataCounter - 1, 20} = str2double(splittedString{5});
        end
        % 16: TurnSignalLights_FrontRight 
        if(categorical(cellstr(splittedString{1,3})) == keywords(16))
            filteredData{filteredDataCounter - 1, 21} = str2double(splittedString{5});
        end
        % 17: TurnSignalLights_RearLeft 
        if(categorical(cellstr(splittedString{1,3})) == keywords(17))
            filteredData{filteredDataCounter - 1, 22} = str2double(splittedString{5});
        end
        % 18: TurnSignalLights_RearRight 
        if(categorical(cellstr(splittedString{1,3})) == keywords(18))
            filteredData{filteredDataCounter - 1, 23} = str2double(splittedString{5});
        end
        % 19: FrontLights_DaytimeRunningLamp 
        if(categorical(cellstr(splittedString{1,3})) == keywords(19))
            filteredData{filteredDataCounter - 1, 24} = str2double(splittedString{5});
        end
        % 20: FrontLights_HighBeam  
        if(categorical(cellstr(splittedString{1,3})) == keywords(20))
            filteredData{filteredDataCounter - 1, 25} = str2double(splittedString{5});
        end
        % 21: FrontLights_LowBeam 
        if(categorical(cellstr(splittedString{1,3})) == keywords(21))
            filteredData{filteredDataCounter - 1, 26} = str2double(splittedString{5});
        end
        % 22: FogLight 
        if(categorical(cellstr(splittedString{1,3})) == keywords(22))
            filteredData{filteredDataCounter - 1, 27} = str2double(splittedString{5});
        end
%         % 23: HazardWarningSystem 
%         if(categorical(cellstr(splittedString{1,3})) == keywords())
%             filteredData{filteredDataCounter - 1, } = str2double(splittedString{});
%         end
%         % 24: AntiLockBrakeSystem 
%         if(categorical(cellstr(splittedString{1,3})) == keywords())
%             filteredData{filteredDataCounter - 1, } = str2double(splittedString{});
%         end
%         % 25: GearSelection 
%         if(categorical(cellstr(splittedString{1,3})) == keywords())
%             filteredData{filteredDataCounter - 1, } = str2double(splittedString{});
%         end
%         % 26: CurrentGear 
%         if(categorical(cellstr(splittedString{1,3})) == keywords())
%             filteredData{filteredDataCounter - 1, } = str2double(splittedString{});
%         end
%         % 27: ClutchSwitchActuation 
%         if(categorical(cellstr(splittedString{1,3})) == keywords())
%             filteredData{filteredDataCounter - 1, } = str2double(splittedString{});
%         end
%         % 28: CruiseControlSystemState 
%         if(categorical(cellstr(splittedString{1,3})) == keywords())
%             filteredData{filteredDataCounter - 1, } = str2double(splittedString{});
%         end
%         % 29: PedalForce 
%         if(categorical(cellstr(splittedString{1,3})) == keywords())
%             filteredData{filteredDataCounter - 1, } = str2double(splittedString{});
%         end
%         % 30: BrakeActuation 
%         if(categorical(cellstr(splittedString{1,3})) == keywords())
%             filteredData{filteredDataCounter - 1, } = str2double(splittedString{});
%         end
    end
    toc
    
    filteredData = filteredData(1 : filteredDataCounter, : );
 
    for i = 1 : 1 : fileLength
        % Timestamps
        index = strfind(data(i,j), patternTimestamp);
        if(index{1,1} > 0)
            splittedString = strsplit(data{i,j}, patternDelimiter);
            newTimestamp = splittedString{1,timestampPosition};
            if(~(strcmp(newTimestamp, oldTimestamp)))
                filteredResult{(positionCounter+1),timestampResultlistIndex}= newTimestamp;
                % Update position counter
                positionCounter = positionCounter + 1; 
            end
            oldTimestamp = newTimestamp;
        end
        % Engine speed
        index = strfind(data(i,j), patternEngineSpeed);
        if(index{1,1} > 0)
            splittedString = strsplit(data{i,j}, patternDelimiter);
            filteredResult{(positionCounter),enginespeedResultIndex}=str2double(splittedString{1,enginespeedPosition});        
        end
        % Vehicle speed
        index = strfind(data(i,j), patternVehicleSpeed);
        if(index{1,1} > 0)
            splittedString = strsplit(data{i,j}, patternDelimiter);
            filteredResult{(positionCounter),vehiclespeedResultIndex}=str2double(splittedString{1,vehiclespeedPosition});        
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
                filteredResult{(positionCounter),PositionLatitudeResultlistIndex}= lat;  
                % long Position
                long = str2double(splittedString{1,PositionLongitudePosition});
                filteredResult{(positionCounter),PositionLongitudeResultlistIndex} = long;
                % evelation / altitude
                elev = str2double(splittedString{1,ElevationPosition});
                filteredResult{(positionCounter),ElevationResultlistIndex} = elev;
                % heading
                heading = str2double(splittedString{1,HeadingPosition});
                filteredResult{(positionCounter),HeadingResultlistIndex} = heading;
                % velocity (additional entries to vehicle speed (speedometer))
                filteredResult{(positionCounter),VelocityResultlistIndex}=str2double(splittedString{1,VelocityPosition});
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











