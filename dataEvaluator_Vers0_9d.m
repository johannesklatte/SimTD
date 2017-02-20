% Clear all workplace data
clear;

% Get System Information about system memory
[userview systemview] = memory;

% Start parallel pool
numberOfCores = feature('numcores');
%poolJob = parpool('local', numberOfCores);

% Open the directory that contains all the *.tar.gz data files
%dataFolderName = uigetdir('C:\', 'Select folder that contains all *.tar files');
dataFolderName = 'F:\decoded_test';
%untarFolderName = uigetdir('C:\', 'Select folder to untar data to');
untarFolderName = 'C:\Users\Johannes_Work\Downloads\Studium\HIWI\UNPACK';
%resultsFolderName = uigetdir('C:\', 'Select folder to save filtered data tables in');
resultsFolderName = 'C:\Users\Johannes_Work\Downloads\Studium\HIWI\RESULTS';

cd(dataFolderName);
MyDirInfo = dir;
[dirLength, j1] = size(MyDirInfo);

% Untar the *.tar.gz files one by one and extract valuable information
% and save it in a matlab table
for iUntar = 1 : 1 : dirLength
    try %outer 
        outputdir = '';
        if(isequal(MyDirInfo(iUntar).isdir, 0))
            tarfilename = MyDirInfo(iUntar).name;
            removeExtension = '.tar.gz';
            outputdir = strrep(tarfilename, removeExtension, '');
            %untar(tarfilename, untarFolderName);
            cd(strcat(untarFolderName, '\', outputdir));

            % loop over all extracted *.txt and gather valuable information to
            % save in a matlab table
            MyDirInfoUntared = dir;
            [dirLengthUntar, j1] = size(MyDirInfoUntared);
            % Average memory usage per row of original file in bytes 250 (tested)
            memoryUsageInBytesPerRow = 250;
            chunkSize = userview.MemAvailableAllArrays / (2 * numberOfCores * memoryUsageInBytesPerRow);
            try %inner
                for iFile = 1 : 1 : dirLengthUntar
                    %
                    if(isequal(MyDirInfoUntared(iFile).isdir, 0))
                        filenameCurrent =  MyDirInfoUntared(iFile).name;
                        % Open data (*.txt-file)
                        fileID = fopen(filenameCurrent);
                        filteredResultArray = {};
                        % Read data chunks with textscan as long as the file isn't 
                        % read completely
                        kWhileLoop = 1;
                        while ~feof(fileID)
                            dataChunk = textscan(fileID, '%s', chunkSize, 'CommentStyle', '##', 'delimiter', '');
                            dataChunk = dataChunk{1, 1}; %maybe needs to be rewritten
                            % Create boundary array to split data for parallel processing
                            [numberOfRows, numberOfColumns] = size(dataChunk);
                            boundaryArray = zeros(1, 2 * numberOfCores);
                            boundaryArray(1) = 1;
                            for i = 2 : 2 : (2 * numberOfCores)
                                boundaryArray(i) = (i/2) * (numberOfRows / numberOfCores);
                            end
                            boundaryArray = int64(boundaryArray);
                            % Check boundaries (to make sure, that there is no change in timestamps at a boundary)
                            patternDelimiter = ',';
                            timestampPosition = 2;
                            for iOut = 2 : 2 : ((2 * numberOfCores) - 2)
                                index = boundaryArray(iOut);
                                splittedString = strsplit(dataChunk{index, 1}, patternDelimiter);
                                oldTimestamp = splittedString{1, timestampPosition};
                                for iIn = 1 : 1 : 30
                                    splittedString = strsplit(dataChunk{(index+1), 1}, patternDelimiter);
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
                            end%iOut-Loop

                            % Create a 1 x NumberOfCores cell array to save filtered data in
                            filteredDataChunks = {};
                            filteredDataChunksTemp = {};
                            indices = 1 : 2 : (2 * numberOfCores);
                            for iTemp = 1 : 1 : numberOfCores
                                filteredDataChunksTemp{1, iTemp} = cell((boundaryArray(indices(iTemp)+1)-boundaryArray(indices(iTemp))), 36);
                            end

                            parfor iCores  = 1 : 1 : numberOfCores         %parfor parallel loop
                                entryCounter = 1;
                                tempKey = cell([1 5]);
                                tempKey{1,1} = 0;
                                tempValue = cell([1 5]);
                                indices = 1 : 2 : (2 * numberOfCores);
                                loopBoundaryArray = boundaryArray;                
                                loopData = dataChunk(loopBoundaryArray(indices(iCores)): boundaryArray(indices(iCores)+1), 1);
                                [loopDataLength, j2] = size(loopData);
                                filteredLoopData = filteredDataChunksTemp{1, iCores};
                                % Set first timestamp as oldTimestamp to compare to - in following loop
                                index = strfind(dataChunk(1, 1), 'IVS');  % Pattern for the timestamps
                                oldTimestamp = '';
                                if(index{1,1} > 0)
                                    patternDelimiter = ',';
                                    splittedString = strsplit(loopData{1,1}, patternDelimiter);
                                    timestampPosition = 2;
                                    oldTimestamp = splittedString{1, timestampPosition};
                                    %filteredLoopData{1, 1} = oldTimestamp;     %do not save the first timestamp (may not include valuable data)                                  
                                end

                                % Loop over all entries in the parfor part of the
                                % data chunk
                                for innerLoop = 1 : 1  : loopDataLength
                                    index = strfind(loopData(innerLoop,1), 'IVS');  % Pattern for the timestamps
                                    patternDelimiter = ',';
                                    splittedString = strsplit(loopData{innerLoop,1}, patternDelimiter);

                                    % Keyword in the original data is at Position 3
                                    comparisonPosition = 3;
                                    comparisonElement = splittedString{1, comparisonPosition}; 
                                    
                                    switch comparisonElement

                                        % 02 Rpm
                                        case 'm_IVS_AU_VAPIClient_EngineSpeed'
                                            %matchFound = matchFound + 1;
                                            % rpm position in fitered data = 2, value position = 5
                                            tempKey{1,1} = 2;
                                            tempValue{1, 1} = str2double(splittedString{1, 5});
                                            %filteredLoopData{(entryCounter), 2} = str2double(splittedString{1, 5});

                                        % 03 vehicle speed   
                                        case 'm_IVS_AU_VAPIClient_VehicleSpeed'
                                            matchFound = matchFound + 1;
                                            % vehicle speed position in fitered data = 3, value position = 5
                                            %filteredLoopData{(entryCounter), 3} = str2double(splittedString{1, 5});    

                                        % 04 long. acceleration
                                        case 'm_IVS_AU_VAPIClient_LongitudinalAcceleration'
                                            matchFound = matchFound + 1;
                                            % long. acceleraction position in fitered data = 4, value position = 5
                                            %filteredLoopData{(entryCounter), 4} = str2double(splittedString{1, 5});  

                                        % 05 lat. acceleration    
                                        case 'm_IVS_AU_VAPIClient_LateralAcceleration'
                                            matchFound = matchFound + 1;
                                            % lat. acceleraction position in fitered data = 5, value position = 5
                                            %filteredLoopData{(entryCounter), 5} = str2double(splittedString{1, 5});

                                        % 06 gear selection    
                                        case 'm_IVS_AU_VAPIClient_GearSelection'
                                            matchFound = matchFound + 1;
                                            %
                                            %filteredLoopData{(entryCounter), 6} = splittedString{1, 5}; % string

                                        % 07 current gear    
                                        case 'm_IVS_AU_VAPIClient_CurrentGear' 
                                            matchFound = matchFound + 1;
                                            %
                                            %filteredLoopData{(entryCounter), 7} = splittedString{1, 5}; % string

                                        % 08 steeringwheel angle   
                                        case 'm_IVS_AU_VAPIClient_SteeringWheelAngle'
                                            matchFound = matchFound + 1;
                                            %
                                            %filteredLoopData{(entryCounter), 8} = str2double(splittedString{1, 5});

                                        % 09 steeringwheel velocity   
                                        case 'm_IVS_AU_VAPIClient_SteeringWheelAngularVelocity' 
                                            matchFound = matchFound + 1;
                                            %
                                            %filteredLoopData{(entryCounter), 9} = str2double(splittedString{1, 5});    

                                        % 10 odometer    
                                        case 'm_IVS_AU_VAPIClient_Odometer'
                                            matchFound = matchFound + 1;
                                            %
                                            %filteredLoopData{(entryCounter), 10} = str2double(splittedString{1, 5}); 

                                        case 'm_IVS_AU_VAPIClient_TripOdometer' 
                                            matchFound = matchFound + 1;
                                            % 11 trip odometer
                                            %
                                            %filteredLoopData{(entryCounter), 11} = str2double(splittedString{1, 5});

                                        % 12-17 GPS data    
                                        case 'm_IVS_AU_VAPIClient_SimTD_FilteredPosition'
                                            matchFound = matchFound + 1;
                                            % 12 latitude
                                            %
                                            %filteredLoopData{(entryCounter), 12} = str2double(splittedString{1, 5});
                                            tempKey{1,1}  = 12;
                                            tempValue{1, 1} = str2double(splittedString{1, 5});
                                            
                                            % 13 longitude
                                            %
                                            %filteredLoopData{(entryCounter), 13} = str2double(splittedString{1, 7});
                                            tempKey{1,2}  = 13;
                                            tempValue{1, 2} = str2double(splittedString{1, 7});

                                            % 14 heading     
                                            %                                                    
                                            %filteredLoopData{(entryCounter), 14} = str2double(splittedString{1, 11});
                                            tempKey{1,3}  = 14;
                                            tempValue{1, 3} = str2double(splittedString{1, 11});

                                            % 15 altitude
                                            %                                                    
                                            %filteredLoopData{(entryCounter), 15} = str2double(splittedString{1, 13});
                                            tempKey{1,4}  = 15;
                                            tempValue{1, 4} = str2double(splittedString{1, 13});

                                            % 16 vehicle speed  
                                            %
                                            %filteredLoopData{(entryCounter), 16} = str2double(splittedString{1, 21});
                                            tempKey{1,5} = 16;
                                            tempValue{1, 5} = str2double(splittedString{1, 21});

                                        % 17 brake actuation    
                                        case 'm_IVS_AU_VAPIClient_BrakeActuation'  
                                            matchFound = matchFound + 1;
                                            %
                                            %filteredLoopData{(entryCounter), 17} = str2double(splittedString{1, 5});

                                        % 18 pedal force
                                        case 'm_IVS_AU_VAPIClient_PedalForce'   
                                            matchFound = matchFound + 1;
                                            %
                                            %filteredLoopData{(entryCounter), 18} = str2double(splittedString{1, 5});

                                        % 19-21 object detection
                                        case 'm_IVS_AU_VAPIClient_SimTD_ObjectDetection'
                                            matchFound = matchFound + 1;
                                            % 19 object detected  
                                            %
                                            %filteredLoopData{(entryCounter), 19} = str2double(splittedString{1, 5});

                                            % 20 relative speed 
                                            %
                                            %filteredLoopData{(entryCounter), 20} = str2double(splittedString{1, 7});

                                            % 21 distance to object
                                            %
                                            %filteredLoopData{(entryCounter), 21} = str2double(splittedString{1, 9});

                                        % 22 cruise control active    
                                        case 'm_IVS_AU_VAPIClient_CruiseControlSystemState'
                                            matchFound = matchFound + 1;
                                            %
                                            %filteredLoopData{(entryCounter), 22} = splittedString{1, 5};    % string

                                        % 23 clutch active 
                                        case 'm_IVS_AU_VAPIClient_ClutchSwitchActuation'
                                            matchFound = matchFound + 1;
                                           %
                                           %filteredLoopData{(entryCounter), 23} = str2double(splittedString{1, 5}); 

                                        % 24 ABS active   
                                        case 'm_IVS_AU_VAPIClient_AntiLockBrakeSystem'   
                                            matchFound = matchFound + 1;
                                            % 
                                            %filteredLoopData{(entryCounter), 24} = splittedString{1, 5};    % string
                                            
                                        % 25 exterior temperature   
                                        case 'm_IVS_AU_VAPIClient_ExteriorTemperature'
                                            matchFound = matchFound + 1; 
                                            %
                                            %filteredLoopData{(entryCounter), 25} = str2double(splittedString{1, 5});

                                        % 26 hazard ligths active    
                                        case 'm_IVS_AU_VAPIClient_HazardWarningSystem' 
                                            matchFound = matchFound + 1;                                    
                                            %
                                            %filteredLoopData{(entryCounter), 26} = str2double(splittedString{1, 5});

                                        %  27 daytime running lights active   
                                        case 'm_IVS_AU_VAPIClient_FrontLights_DaytimeRunningLamp' 
                                            matchFound = matchFound + 1;                                    
                                            %
                                            %filteredLoopData{(entryCounter), 27} = str2double(splittedString{1, 5});

                                        % 28 front light low beam active    
                                        case 'm_IVS_AU_VAPIClient_FrontLights_LowBeam' 
                                            matchFound = matchFound + 1;                                    
                                            %
                                            %filteredLoopData{(entryCounter), 28} = str2double(splittedString{1, 5});

                                        % 29 front light high beam active    
                                        case 'm_IVS_AU_VAPIClient_FrontLights_HighBeam'
                                            matchFound = matchFound + 1;                                    
                                            %
                                            %filteredLoopData{(entryCounter), 29} = str2double(splittedString{1, 5});

                                        % 30 fog light active    
                                        case 'm_IVS_AU_VAPIClient_FogLight' 
                                            matchFound = matchFound + 1;                                    
                                            %
                                            %filteredLoopData{(entryCounter), 30} = str2double(splittedString{1, 5});

                                        % 31 turn signal front left active    
                                        case 'm_IVS_AU_VAPIClient_TurnSignalLights_FrontLeft'  
                                            matchFound = matchFound + 1;                                    
                                            %
                                            %filteredLoopData{(entryCounter), 31} = str2double(splittedString{1, 5});

                                        % 32 turn signal front right active   
                                        case 'm_IVS_AU_VAPIClient_TurnSignalLights_FrontRight'  
                                            matchFound = matchFound + 1;                                    
                                            %
                                            %filteredLoopData{(entryCounter), 32} = str2double(splittedString{1, 5});

                                        % 33 turn signal rear left active    
                                        case 'm_IVS_AU_VAPIClient_TurnSignalLights_RearLeft' 
                                            matchFound = matchFound + 1;                                    
                                            %
                                            %filteredLoopData{(entryCounter), 33} = str2double(splittedString{1, 5});

                                        % 34 turn signal rear right active    
                                        case 'm_IVS_AU_VAPIClient_TurnSignalLights_RearRight' 
                                            matchFound = matchFound + 1;                                    
                                            %
                                            %filteredLoopData{(entryCounter), 34} = str2double(splittedString{1, 5});

                                        % 35 wiper front active    
                                        case 'm_IVS_AU_VAPIClient_WiperSystem_Front'   
                                            matchFound = matchFound + 1;                                    
                                            %
                                            %filteredLoopData{(entryCounter), 35} = splittedString{1, 5};    % string

                                        % 36 wiper rear active    
                                        case 'm_IVS_AU_VAPIClient_WiperSystem_Rear' 
                                            matchFound = matchFound + 1;
                                            %
                                            %filteredLoopData{(entryCounter), 36} = splittedString{1, 5};    % string

                                        otherwise
                                            % no pattern matched for this timestamp -> no entry in filtered list
                                            matchFound = 0;

                                    end % switch-end

                                    if(tempKey{1,1} > 0)
                                       if(index{1,1} > 0)
                                        timestampPosition = 2;
                                        newTimestamp = splittedString{1,timestampPosition};
                                        if(~(strcmp(newTimestamp, oldTimestamp)))
                                            % Update entry counter
                                            entryCounter = entryCounter + 1;
                                            filteredLoopData{(entryCounter), 1} = newTimestamp;
                                            % Update timestamp
                                            oldTimestamp = newTimestamp;
                                        else
                                            % use the last timestamp
                                        end
                                        
                                        if (tempKey{1,1} == 12)
                                            for iTemp = 1:1:5
                                                filteredLoopData{(entryCounter), tempKey{1,iTemp}} = tempValue{1, iTemp};
                                            end
                                            
                                        elseif (tempKey{1,1} == 19)
                                            for iTemp = 1:1:3
                                                filteredLoopData{(entryCounter), tempKey{1,iTemp}} = tempValue{1, iTemp};
                                            end
                                        else
                                            filteredLoopData{(entryCounter), tempKey{1,1}} = tempValue{1, 1};
                                        end
                                         
                                       end
                                       % Reset temporary key
                                       tempKey{1,1} = 0; 
                                    end

                                end%innerLoop-forLoop
                                filteredLoopData = filteredLoopData(1 : entryCounter, : );
                                filteredDataChunksTemp{1, iCores} = filteredLoopData;
                            end%parfor
                            % Aggregate the temporary filtered data back to 1 chunk ...
                            % as a result of the parfor loop
                            filteredDataChunksEntry = {};
                            for iAgg = 1 : 1 : numberOfCores
                                filteredDataChunksEntry = vertcat(filteredDataChunksEntry, filteredDataChunksTemp{1, iAgg});
                            end
                            filteredDataChunks{1, kWhileLoop} = filteredDataChunksEntry;
                            kWhileLoop = kWhileLoop + 1;

                        end%whileLoop
                        %Aggrehate all filtered chunks
                        for iAggRes = 1 : 1 : (kWhileLoop - 1)
                            filteredResultArray = vertcat(filteredResultArray, filteredDataChunks{1, iAggRes});
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
                        filteredTable = cell2table(filteredResultArray, 'VariableNames', variablesNames);

                        % Save filtered table in file
                        currentFolderTemp = pwd;
                        mkdir(strcat(resultsFolderName, '\', outputdir));
                        cd(strcat(resultsFolderName, '\', outputdir));
                        tableFilenameDAT = strcat(filenameCurrent, '_Filtered_Data_Table.dat');
                        tableFilenameXLSX = strcat(filenameCurrent, '_Filtered_Data_Table.xlsx');
                        %writetable(filteredTable, tableFilenameDAT);
                        writetable(filteredTable, tableFilenameXLSX);
                        cd(currentFolderTemp);

                    end%if-isDirUntared

                end%iFile-forLoop
                cd(untarFolderName);
                statusClose = fclose('all');
                [statusErase, messageErase, messageidErase] = rmdir(outputdir, 's');
            
            catch %try-inner
                %todo: 
                %   write filenames of failed files into a log file
                %   catch error
            
            end %try-inner
            
                   
        end%if-isDir
        
    catch %outer 
        %todo: 
        %   write filenames of failed files into a log file
        %   catch error
        
    end%try-outer
end%end-Untar


