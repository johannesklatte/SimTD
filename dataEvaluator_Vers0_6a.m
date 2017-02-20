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
    filenameCurrent = fileNameList(iFile);
    delimiterTXT = ' ';
    data = importdata(filenameCurrent{1,1}, delimiterTXT);
    [fileLength, j] = size(data);
    % Create cell array to save filtered data in
    filteredData = cell(fileLength, 36);
    
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
    
    % Loop over data
    entryCounter = 1;
    for i = 1 : 1 : fileLength
        index = strfind(data(i,j), 'IVS');  % Pattern for the timestamps
        patternDelimiter = ',';
        splittedString = strsplit(data{i,j}, patternDelimiter);
        if(index{1,1} > 0)
            timestampPosition = 2;
            newTimestamp = splittedString{1,timestampPosition};
            if(~(strcmp(newTimestamp, oldTimestamp)))
                filteredData{(entryCounter + 1), 1} = newTimestamp;
                % Update entry counter
                entryCounter = entryCounter + 1; 
            else
                % use the last timestamp
            end
            oldTimestamp = newTimestamp;
        end
        
        comparisonPosition = 3;
        comparisonElement = splittedString{1, comparisonPosition};
        
        switch comparisonElement
            
            % 02 rpm
            case 'm_IVS_AU_VAPIClient_EngineSpeed'                  
                
                % rpm position in fitered data = 2, value position = 5
                filteredData{(entryCounter), 2} = splittedString{1, 5};
                
            % 03 vehicle speed   
            case 'm_IVS_AU_VAPIClient_VehicleSpeed'
                % vehicle speed position in fitered data = 3, value position = 5
                filteredData{(entryCounter), 3} = splittedString{1, 5};    
                
            % 04 long. acceleration
            case 'm_IVS_AU_VAPIClient_LongitudinalAcceleration' 
                % long. acceleraction position in fitered data = 4, value position = 5
                filteredData{(entryCounter), 4} = splittedString{1, 5};                
             
            % 05 lat. acceleration    
            case 'm_IVS_AU_VAPIClient_LateralAcceleration' 
                % lat. acceleraction position in fitered data = 5, value position = 5
                filteredData{(entryCounter), 5} = splittedString{1, 5};
           
            % 06 gear selection    
            case 'm_IVS_AU_VAPIClient_GearSelection'                
                %
                filteredData{(entryCounter), 6} = splittedString{1, 5};
                
            % 07 current gear    
            case 'm_IVS_AU_VAPIClient_CurrentGear' 
                %
                filteredData{(entryCounter), 7} = splittedString{1, 5};
                
            % 08 steeringwheel angle   
            case 'm_IVS_AU_VAPIClient_SteeringWheelAngle'
                %
                filteredData{(entryCounter), 8} = splittedString{1, 5};
              
            % 09 steeringwheel velocity   
            case 'm_IVS_AU_VAPIClient_SteeringWheelAngularVelocity' 
                %
                filteredData{(entryCounter), 9} = splittedString{1, 5};    
                
            % 10 odometer    
            case 'm_IVS_AU_VAPIClient_Odometer'
                %
                filteredData{(entryCounter), 10} = splittedString{1, 5}; 
                
            case 'm_IVS_AU_VAPIClient_TripOdometer'                 
                % 11 trip odometer
                %
                filteredData{(entryCounter), 11} = splittedString{1, 5};
               
            % 12-17 GPS data    
            case 'm_IVS_AU_VAPIClient_SimTD_FilteredPosition'       
                % 12 latitude
                %
                filteredData{(entryCounter), 12} = splittedString{1, 5};
                
                % 13 longitude
                %
                filteredData{(entryCounter), 13} = splittedString{1, 7};
                
                % 14 heading     
                %                                                    
                filteredData{(entryCounter), 14} = splittedString{1, 11};
                
                % 15 altitude
                %                                                    
                filteredData{(entryCounter), 15} = splittedString{1, 13};
               
                % 16 vehicle speed  
                %
                filteredData{(entryCounter), 16} = splittedString{1, 21};
            
            % 17 brake actuation    
            case 'm_IVS_AU_VAPIClient_BrakeActuation'               
                %
                filteredData{(entryCounter), 17} = splittedString{1, 5};
            
            % 18 pedal force
            case 'm_IVS_AU_VAPIClient_PedalForce'                   
                %
                filteredData{(entryCounter), 18} = splittedString{1, 5};
            
            % 19-21 object detection
            case 'm_IVS_AU_VAPIClient_SimTD_ObjectDetection'        
                % 19 object detected  
                %
                filteredData{(entryCounter), 19} = splittedString{1, 5};
                
                % 20 relative speed 
                %
                filteredData{(entryCounter), 20} = splittedString{1, 7};
                
                % 21 distance to object
                %
                filteredData{(entryCounter), 21} = splittedString{1, 9};
                
            % 22 cruise control active    
            case 'm_IVS_AU_VAPIClient_CruiseControlSystemState'     
                %
                filteredData{(entryCounter), 22} = splittedString{1, 5};
                
            % 23 clutch active 
            case 'm_IVS_AU_VAPIClient_ClutchSwitchActuation'           
               %
               filteredData{(entryCounter), 23} = splittedString{1, 5}; 
                
            % 24 ABS active   
            case 'm_IVS_AU_VAPIClient_AntiLockBrakeSystem'          
               % 
               filteredData{(entryCounter), 24} = splittedString{1, 5}; 
                
            % 25 exterior temperature   
            case 'm_IVS_AU_VAPIClient_ExteriorTemperature'
                %
                filteredData{(entryCounter), 25} = splittedString{1, 5};
               
            % 26 hazard ligths active    
            case 'm_IVS_AU_VAPIClient_HazardWarningSystem'          
              %
              filteredData{(entryCounter), 26} = splittedString{1, 5};
                
            %  27 daytime running lights active   
            case 'm_IVS_AU_VAPIClient_FrontLights_DaytimeRunningLamp'   
                %
                filteredData{(entryCounter), 27} = splittedString{1, 5};
                
            % 28 front light low beam active    
            case 'm_IVS_AU_VAPIClient_FrontLights_LowBeam'          
                %
                filteredData{(entryCounter), 28} = splittedString{1, 5};
                
            % 29 front light high beam active    
            case 'm_IVS_AU_VAPIClient_FrontLights_HighBeam'         
                %
                filteredData{(entryCounter), 29} = splittedString{1, 5};
                
            % 30 fog light active    
            case 'm_IVS_AU_VAPIClient_FogLight'                     
                %
                filteredData{(entryCounter), 30} = splittedString{1, 5};
                
            % 31 turn signal front left active    
            case 'm_IVS_AU_VAPIClient_TurnSignalLights_FrontLeft'   
                %
                filteredData{(entryCounter), 31} = splittedString{1, 5};
                
            % 32 turn signal front right active   
            case 'm_IVS_AU_VAPIClient_TurnSignalLights_FrontRight'  
                %
                filteredData{(entryCounter), 32} = splittedString{1, 5};
                
            % 33 turn signal rear left active    
            case 'm_IVS_AU_VAPIClient_TurnSignalLights_RearLeft'    
                %
                filteredData{(entryCounter), 33} = splittedString{1, 5};
                
            % 34 turn signal rear right active    
            case 'm_IVS_AU_VAPIClient_TurnSignalLights_RearRight'   
                %
                filteredData{(entryCounter), 34} = splittedString{1, 5};
                
            % 35 wiper front active    
            case 'm_IVS_AU_VAPIClient_WiperSystem_Front'            
                %
                filteredData{(entryCounter), 35} = splittedString{1, 5};
                
            % 36 wiper rear active    
            case 'm_IVS_AU_VAPIClient_WiperSystem_Rear'             
                %
                filteredData{(entryCounter), 36} = splittedString{1, 5};
                                                                                              
            otherwise
                % no pattern matched for this timestamp -> no entry in filtered list
                
        end % Switch end
    end % Data loop end  
    
    % Cut off unused entries of fitered data cell array
    filteredData = filteredData(1 : entryCounter, : );
    
    % Create table with colum descriptions
    variablesNames = {'Timestamp' 'Rpm' 'Vehicle_speed' 'Long_acceleration' 'Lat_acceleration' ...
        'Gear_selection' 'Current_gear' 'Steeringwheel_angle' 'Steeringwheel_velocity' 'Odometer' ...
        'Trip_odometer' 'Latitude_GPS' 'Longitude_GPS' 'Heading_GPS' 'Altitude_GPS' ...
        'Vehicle_speed_GPS' 'Brake_actuation' 'Pedal_force' 'Object_detected' 'Relative_speed_to_object' ...
        'Distance_to_object' 'cruise_control' 'clutch' 'ABS' 'Exterior_temperature' ...
        'Hazard_ligths' 'Daytime_running_lights' 'Front_light_low_beam' 'Front_light_high_beam' 'Fog_light' ...
        'Turn_signal_front_left' 'Turn_signal_front_right' 'Turn_signal_rear_left' 'Turn_signal_rear_right' 'Wiper_front' ...
        'Wiper_rear'};
	filteredTable = cell2table(filteredData, 'VariableNames', variablesNames);
    
    % Save filtered table in file
    tableFilename = strcat(filenameCurrent, '_Filtered_Data_Table.mat');
    save(tableFilename{1, 1}, 'filteredTable')
end