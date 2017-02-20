% 
%
%
%
%
%
%
%
%
%

% Clear all workplace data
clear;
% Set current folder to scripts location/path)
cd(fileparts(mfilename('fullpath')))
% Start parallel pool
numberOfCores = feature('numcores');
%poolJob = parpool('local', numberOfCores);

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
    errorWindow = msgbox(errorMessage, 'Error!', 'error');
    return;
end

% Loop over all files in the current dir and create a new table with 
% the filtered data for each file
for iFile = 1 : 1 : fileNameCounter
    tic
    filenameCurrent = fileNameList(iFile);
    delimiterTXT = ' ';
    %dataLoaded = importdata(filenameCurrent{1,1}, delimiterTXT);
    fileID = fopen(filenameCurrent{1,1});
    blockSize = 25000;
    fiteredDataResult = {};
    kFile = 0;
    while ~feof(fileID)
        kFile = kFile + 1;
        dataLoaded = textscan(fileID, '%s', blockSize, 'CommentStyle', '##', 'delimiter', '');

        data = {};
        % Check if imported data is struct
        if(isstruct(dataLoaded))
            data = dataLoaded.textdata;
        else
            data = dataLoaded{1, 1};
        end
        
        
        
        
        [test1, test2] = size(dataLoaded{1,1});
        testLength = min(test1, 1000);
        
        sum = 0.0;
        for iAverageCharLength = 1 : 1 : testLength
            [d, tempSum]  = size(dataLoaded{1, 1}{iAverageCharLength, 1});
            sum = sum + tempSum;
        end
        averageCharLength = sum / testLength;
        % 2 Bytes per Char, original and filtered table and 50% overspend to avoid mem errors
        memoryUsageInBytesPerRow = averageCharLength * 2 * 2 * 1,5; 
        
        [userview systemview] = memory;
        chunkSize = userview.MemAvailableAllArrays / (8 * memoryUsageInBytesPerRow);
        
        
        
        
        
        
        
        
        % Create boundary array to split data for parallel processing
        [numberOfRows, numberOfColumns] = size(data);
        boundaryArray = zeros(1, 2*numberOfCores);
        boundaryArray(1) = 1;
        numberOfSegments = numberOfRows / 5000;
        numberOfSegments = int64(numberOfSegments);
        if(numberOfSegments < 4)
            numberOfSegments = 4;
            for i = 2 : 2 : 2*numberOfCores
                boundaryArray(i) = (i/2) * (numberOfRows / numberOfCores);
            end
        else
            for i = 2 : 2 : 2*numberOfSegments
                boundaryArray(i) = (i/2) * (numberOfRows / numberOfSegments);
            end
        end
        boundaryArray = int64(boundaryArray);

        % Check boundaries (to make sure, that there is no change in timestamps at a boundary)
        patternDelimiter = ',';
        timestampPosition = 2;
        for iOut = 2 : 2 : ((2*numberOfSegments) - 2)
            index = boundaryArray(iOut);
            splittedString = strsplit(data{index, 1}, patternDelimiter);
            oldTimestamp = splittedString{1, timestampPosition};
            for iIn = 1 : 1 : 30
                splittedString = strsplit(data{(index+1), 1}, patternDelimiter);
                newTimestamp = splittedString{1, timestampPosition};
                if(strcmp(newTimestamp, oldTimestamp)) 
                    oldTimestamp = newTimestamp;
                    index = index + 1;
                else
                    boundaryArray(iOut + 0) = index + 0;
                    boundaryArray(iOut + 1) = index + 1;
                    break
                end   
            end
        end

        % Set first timestamp as oldTimestamp to compare to in following loop
        index = strfind(data(1, j), 'IVS');  % Pattern for the timestamps
        oldTimestamp = '';
        if(index{1,1} > 0)
            patternDelimiter = ',';
            splittedString = strsplit(data{1,j}, patternDelimiter);
            timestampPosition = 2;
            oldTimestamp = splittedString{1, timestampPosition};
            filteredData{1, 1} = oldTimestamp;
        end

        % Create a 1xNumberOfCores cell array to save filtered data in
        filteredDataTemp = {};
        indices = 1 : 2 : (2 * numberOfSegments);
        for iTemp = 1 : 1 : numberOfSegments
            filteredDataTemp{1, iTemp} = cell((boundaryArray(indices(iTemp)+1)-boundaryArray(indices(iTemp))), 36);
        end

        % Loop over data
        parfor iCores = 1 : 1 : numberOfSegments
            indices = 1 : 2 : (2 * numberOfSegments);
            loopBoundaryArray = boundaryArray;
            loopData = data(loopBoundaryArray(indices(iCores)): boundaryArray(indices(iCores)+1), 1);
            [fileLength, j] = size(loopData);
            loopFilteredDataTemp = filteredDataTemp{1, iCores};

            % Set first timestamp as oldTimestamp to compare to in the following loop
            index = strfind(loopData(1, j), 'IVS');  % Pattern for the timestamps
            oldTimestamp = '';
            if(index{1,1} > 0)
                patternDelimiter = ',';
                splittedString = strsplit(loopData{1,j}, patternDelimiter);
                timestampPosition = 2;
                oldTimestamp = splittedString{1, timestampPosition};
                loopFilteredDataTemp{1, 1} = oldTimestamp;
            end

            entryCounter = 1;
            for iLoop = 1 : 1 : fileLength
                index = strfind(loopData(iLoop,1), 'IVS');  % Pattern for the timestamps
                patternDelimiter = ',';
                splittedString = strsplit(loopData{iLoop,1}, patternDelimiter);
                if(index{1,1} > 0)
                    timestampPosition = 2;
                    newTimestamp = splittedString{1,timestampPosition};
                    if(~(strcmp(newTimestamp, oldTimestamp)))
                        loopFilteredDataTemp{(entryCounter + 1), 1} = newTimestamp;
                        % Update entry counter
                        entryCounter = entryCounter + 1; 
                    else
                        % use the last timestamp
                    end
                    oldTimestamp = newTimestamp;
                end
                % Keyword in the original data is at Position 3
                comparisonPosition = 3;
                comparisonElement = splittedString{1, comparisonPosition};

                switch comparisonElement

                    % 02 Rpm
                    case 'm_IVS_AU_VAPIClient_EngineSpeed'
                        % rpm position in fitered data = 2, value position = 5
                        loopFilteredDataTemp{(entryCounter), 2} = splittedString{1, 5};

                    % 03 vehicle speed   
                    case 'm_IVS_AU_VAPIClient_VehicleSpeed'
                        % vehicle speed position in fitered data = 3, value position = 5
                        loopFilteredDataTemp{(entryCounter), 3} = splittedString{1, 5};    

                    % 04 long. acceleration
                    case 'm_IVS_AU_VAPIClient_LongitudinalAcceleration' 
                        % long. acceleraction position in fitered data = 4, value position = 5
                        loopFilteredDataTemp{(entryCounter), 4} = splittedString{1, 5};                

                    % 05 lat. acceleration    
                    case 'm_IVS_AU_VAPIClient_LateralAcceleration' 
                        % lat. acceleraction position in fitered data = 5, value position = 5
                        loopFilteredDataTemp{(entryCounter), 5} = splittedString{1, 5};

                    % 06 gear selection    
                    case 'm_IVS_AU_VAPIClient_GearSelection'                
                        %
                        loopFilteredDataTemp{(entryCounter), 6} = splittedString{1, 5};

                    % 07 current gear    
                    case 'm_IVS_AU_VAPIClient_CurrentGear' 
                        %
                        loopFilteredDataTemp{(entryCounter), 7} = splittedString{1, 5};

                    % 08 steeringwheel angle   
                    case 'm_IVS_AU_VAPIClient_SteeringWheelAngle'
                        %
                        loopFilteredDataTemp{(entryCounter), 8} = splittedString{1, 5};

                    % 09 steeringwheel velocity   
                    case 'm_IVS_AU_VAPIClient_SteeringWheelAngularVelocity' 
                        %
                        loopFilteredDataTemp{(entryCounter), 9} = splittedString{1, 5};    

                    % 10 odometer    
                    case 'm_IVS_AU_VAPIClient_Odometer'
                        %
                        loopFilteredDataTemp{(entryCounter), 10} = splittedString{1, 5}; 

                    case 'm_IVS_AU_VAPIClient_TripOdometer'                 
                        % 11 trip odometer
                        %
                        loopFilteredDataTemp{(entryCounter), 11} = splittedString{1, 5};

                    % 12-17 GPS data    
                    case 'm_IVS_AU_VAPIClient_SimTD_FilteredPosition'       
                        % 12 latitude
                        %
                        loopFilteredDataTemp{(entryCounter), 12} = splittedString{1, 5};

                        % 13 longitude
                        %
                        loopFilteredDataTemp{(entryCounter), 13} = splittedString{1, 7};

                        % 14 heading     
                        %                                                    
                        loopFilteredDataTemp{(entryCounter), 14} = splittedString{1, 11};

                        % 15 altitude
                        %                                                    
                        loopFilteredDataTemp{(entryCounter), 15} = splittedString{1, 13};

                        % 16 vehicle speed  
                        %
                        loopFilteredDataTemp{(entryCounter), 16} = splittedString{1, 21};

                    % 17 brake actuation    
                    case 'm_IVS_AU_VAPIClient_BrakeActuation'               
                        %
                        loopFilteredDataTemp{(entryCounter), 17} = splittedString{1, 5};

                    % 18 pedal force
                    case 'm_IVS_AU_VAPIClient_PedalForce'                   
                        %
                        loopFilteredDataTemp{(entryCounter), 18} = splittedString{1, 5};

                    % 19-21 object detection
                    case 'm_IVS_AU_VAPIClient_SimTD_ObjectDetection'        
                        % 19 object detected  
                        %
                        loopFilteredDataTemp{(entryCounter), 19} = splittedString{1, 5};

                        % 20 relative speed 
                        %
                        loopFilteredDataTemp{(entryCounter), 20} = splittedString{1, 7};

                        % 21 distance to object
                        %
                        loopFilteredDataTemp{(entryCounter), 21} = splittedString{1, 9};

                    % 22 cruise control active    
                    case 'm_IVS_AU_VAPIClient_CruiseControlSystemState'     
                        %
                        loopFilteredDataTemp{(entryCounter), 22} = splittedString{1, 5};

                    % 23 clutch active 
                    case 'm_IVS_AU_VAPIClient_ClutchSwitchActuation'           
                       %
                       loopFilteredDataTemp{(entryCounter), 23} = splittedString{1, 5}; 

                    % 24 ABS active   
                    case 'm_IVS_AU_VAPIClient_AntiLockBrakeSystem'          
                        % 
                        loopFilteredDataTemp{(entryCounter), 24} = splittedString{1, 5}; 

                    % 25 exterior temperature   
                    case 'm_IVS_AU_VAPIClient_ExteriorTemperature'
                        %
                        loopFilteredDataTemp{(entryCounter), 25} = splittedString{1, 5};

                    % 26 hazard ligths active    
                    case 'm_IVS_AU_VAPIClient_HazardWarningSystem'          
                        %
                        loopFilteredDataTemp{(entryCounter), 26} = splittedString{1, 5};

                    %  27 daytime running lights active   
                    case 'm_IVS_AU_VAPIClient_FrontLights_DaytimeRunningLamp'   
                        %
                        loopFilteredDataTemp{(entryCounter), 27} = splittedString{1, 5};

                    % 28 front light low beam active    
                    case 'm_IVS_AU_VAPIClient_FrontLights_LowBeam'          
                        %
                        loopFilteredDataTemp{(entryCounter), 28} = splittedString{1, 5};

                    % 29 front light high beam active    
                    case 'm_IVS_AU_VAPIClient_FrontLights_HighBeam'         
                        %
                        loopFilteredDataTemp{(entryCounter), 29} = splittedString{1, 5};

                    % 30 fog light active    
                    case 'm_IVS_AU_VAPIClient_FogLight'                     
                        %
                        loopFilteredDataTemp{(entryCounter), 30} = splittedString{1, 5};

                    % 31 turn signal front left active    
                    case 'm_IVS_AU_VAPIClient_TurnSignalLights_FrontLeft'   
                        %
                        loopFilteredDataTemp{(entryCounter), 31} = splittedString{1, 5};

                    % 32 turn signal front right active   
                    case 'm_IVS_AU_VAPIClient_TurnSignalLights_FrontRight'  
                        %
                        loopFilteredDataTemp{(entryCounter), 32} = splittedString{1, 5};

                    % 33 turn signal rear left active    
                    case 'm_IVS_AU_VAPIClient_TurnSignalLights_RearLeft'    
                        %
                        loopFilteredDataTemp{(entryCounter), 33} = splittedString{1, 5};

                    % 34 turn signal rear right active    
                    case 'm_IVS_AU_VAPIClient_TurnSignalLights_RearRight'   
                        %
                        loopFilteredDataTemp{(entryCounter), 34} = splittedString{1, 5};

                    % 35 wiper front active    
                    case 'm_IVS_AU_VAPIClient_WiperSystem_Front'            
                        %
                        loopFilteredDataTemp{(entryCounter), 35} = splittedString{1, 5};

                    % 36 wiper rear active    
                    case 'm_IVS_AU_VAPIClient_WiperSystem_Rear'             
                        %
                        loopFilteredDataTemp{(entryCounter), 36} = splittedString{1, 5};

                    otherwise
                        % no pattern matched for this timestamp -> no entry in filtered list

                end % switch-end
            end % iLoop-end
            loopFilteredDataTemp = loopFilteredDataTemp(1 : entryCounter, : );
            filteredDataTemp{1, iCores} = loopFilteredDataTemp;
        end % parfor-end

        % Aggregate the temporary filtered data (cell arrays) of the parfor-loop
        filteredData =  {};
        for iAgg = 1 : 1 : numberOfSegments
            filteredData = vertcat(filteredData, filteredDataTemp{1, iAgg});
        end
        fiteredDataResultTemp{1, kFile} = filteredData;
    end%while-end
    fiteredDataResult = {};
    for iAggRes = 1 : 1 : size(fiteredDataResultTemp)
        fiteredDataResult = vertcat(fiteredDataResult, fiteredDataResultTemp{1, iAggRes});
	end
    
    % Create table with colum descriptions
    variablesNames = {'Timestamp' 'Rpm' 'Vehicle_speed' 'Long_acceleration' 'Lat_acceleration' ...
        'Gear_selection' 'Current_gear' 'Steeringwheel_angle' 'Steeringwheel_velocity' 'Odometer' ...
        'Trip_odometer' 'Latitude_GPS' 'Longitude_GPS' 'Heading_GPS' 'Altitude_GPS' ...
        'Vehicle_speed_GPS' 'Brake_actuation' 'Pedal_force' 'Object_detected' 'Relative_speed_to_object' ...
        'Distance_to_object' 'cruise_control' 'clutch' 'ABS' 'Exterior_temperature' ...
        'Hazard_ligths' 'Daytime_running_lights' 'Front_light_low_beam' 'Front_light_high_beam' 'Fog_light' ...
        'Turn_signal_front_left' 'Turn_signal_front_right' 'Turn_signal_rear_left' 'Turn_signal_rear_right' 'Wiper_front' ...
        'Wiper_rear'};
	filteredTable = cell2table(fiteredDataResult, 'VariableNames', variablesNames);
    
    % Save filtered table in file
    tableFilename = strcat(filenameCurrent, '_Filtered_Data_Table.mat');
    save(tableFilename{1, 1}, 'filteredTable')
    toc
end

%shut down pool
delete(poolJob);






