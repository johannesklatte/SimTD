% Clear all workplace data
clear;

% Get System Information about system memory
[userview systemview] = memory;

% Start parallel pool
numberOfCores = feature('numcores');
%poolJob = parpool('local', numberOfCores);

% Open the directory that contains all the *.tar.gz data files
%dataFolderName = uigetdir('C:\', 'Select folder that contains all *.tar files');
%dataFolderName = 'G:\decoded';
dataFolderName = 'C:\Users\Johannes_Work\Downloads\Studium\HIWI\TEST\DATA';

%untarFolderName = uigetdir('C:\', 'Select folder to untar data to');
%untarFolderName = 'C:\Users\Johannes_Work\Downloads\Studium\HIWI\UNPACK';
%untarFolderName = 'G:\decoded_test';
untarFolderName = 'C:\Users\Johannes_Work\Downloads\Studium\HIWI\TEST\UNPACK';

%resultsFolderName = uigetdir('C:\', 'Select folder to save filtered data tables in');
%resultsFolderName = 'C:\Users\Johannes_Work\Downloads\Studium\HIWI\RESULTS';
resultsFolderName = 'C:\Users\Johannes_Work\Downloads\Studium\HIWI\TEST\RESULTS';

keyWords = {'IVS', 'm_IVS_AU_VAPIClient_EngineSpeed', ...                                                       % 01-02
    'm_IVS_AU_VAPIClient_VehicleSpeed', 'm_IVS_AU_VAPIClient_SimTD_FilteredPosition', ...                       % 03-04  
    'm_IVS_AU_VAPIClient_LongitudinalAcceleration', 'm_IVS_AU_VAPIClient_LateralAcceleration', ...              % 05-06
    'm_IVS_AU_VAPIClient_SteeringWheelAngle', 'm_IVS_AU_VAPIClient_SimTD_ObjectDetection', ...                  % 07-08
    'm_IVS_AU_VAPIClient_PedalForce', 'm_IVS_AU_VAPIClient_TurnSignalLights_FrontLeft', ...                     % 09-10
    'm_IVS_AU_VAPIClient_TurnSignalLights_FrontRight', 'm_IVS_AU_VAPIClient_TurnSignalLights_RearLeft', ...     % 11-12
    'm_IVS_AU_VAPIClient_TurnSignalLights_RearRight',  'm_IVS_AU_VAPIClient_ClutchSwitchActuation', ...         % 13-14
    'm_IVS_AU_VAPIClient_ExteriorTemperature', 'm_IVS_AU_VAPIClient_GearSelection', ...                         % 15-16
    'm_IVS_AU_VAPIClient_CurrentGear', 'm_IVS_AU_VAPIClient_SteeringWheelAngularVelocity', ...                  % 17-18
    'm_IVS_AU_VAPIClient_Odometer', 'm_IVS_AU_VAPIClient_TripOdometer', ...                                     % 19-20
    'm_IVS_AU_VAPIClient_BrakeActuation', 'm_IVS_AU_VAPIClient_CruiseControlSystemState', ...                   % 21-22
    'm_IVS_AU_VAPIClient_AntiLockBrakeSystem', 'm_IVS_AU_VAPIClient_ExteriorTemperature', ...                   % 23-24
    'm_IVS_AU_VAPIClient_HazardWarningSystem', 'm_IVS_AU_VAPIClient_FrontLights_DaytimeRunningLamp', ...        % 25-26
    'm_IVS_AU_VAPIClient_FrontLights_LowBeam', 'm_IVS_AU_VAPIClient_FrontLights_HighBeam', ...                  % 27-28
    'm_IVS_AU_VAPIClient_FogLight', 'm_IVS_AU_VAPIClient_SimTD_EmergencyLighting', ...                          % 29-30
    'm_IVS_AU_VAPIClient_WiperSystem_Front', 'm_IVS_AU_VAPIClient_WiperSystem_Rear'};                           % 31-32

keyWordsAsCategoricals = categorical(keyWords);

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
            cd(dataFolderName);
            untar(tarfilename, untarFolderName);
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
                    % Date format
                    formatIn = 'yyyy-mm-dd HH:MM:SS:FFF';
                    emptyDate = '0000-00-00 00:00:00:000';
                    firstTimestamp = datevec(emptyDate, formatIn);
                    lastTimestamp = datevec(emptyDate, formatIn);
                    % Create a 1 x NumberOfCores cell array to save filtered data in
                    filteredDataChunks = {};
                    if(isequal(MyDirInfoUntared(iFile).isdir, 0))
                        filenameCurrent =  MyDirInfoUntared(iFile).name;
                        % Open data (*.txt-file)
                        fileID = fopen(filenameCurrent);
                        filteredResultArray = {};
                        % Read data chunks with textscan as long as the file isn't 
                        % read completely
                        kWhileLoop = 1;
                        %%timing%%
                        tic
                        %%timing%%
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
                            
                            % Set first Timetamp of the dataset
                            patternDelimiter = ',';
                            timestampPosition = 2;
                            if(kWhileLoop == 1)
                                splittedString = strsplit(dataChunk{1, 1}, patternDelimiter);
                                firstTimestampTemp = splittedString{1, timestampPosition};
                                firstTimestamp = datevec(firstTimestampTemp, formatIn);
                            end
                            % Check boundaries (to make sure, that there is no change in timestamps at a boundary)
                            
                            
                            for iOut = 2 : 2 : ((2 * numberOfCores) - 2)
                                index = boundaryArray(iOut);
                                splittedString = strsplit(dataChunk{index, 1}, patternDelimiter);
                                % Create Timestamp vector
                                oldTimestampTemp = splittedString{1, timestampPosition};
                                oldTimestamp = datevec(oldTimestampTemp, formatIn);
                                for iIn = 1 : 1 : 30
                                    splittedString = strsplit(dataChunk{(index+1), 1}, patternDelimiter);
                                    newTimestampTemp = splittedString{1, timestampPosition};
                                    newTimestamp = datevec(newTimestampTemp, formatIn);
                                    if(isequal(newTimestamp, oldTimestamp)) 
                                        oldTimestamp = newTimestamp;
                                        index = index + 1;
                                    else
                                        boundaryArray(iOut + 0) = index + 0;
                                        boundaryArray(iOut + 1) = index + 1;
                                        break
                                    end   
                                end
                            end%iOut-Loop

                            filteredDataChunksTemp = {};
                            indices = 1 : 2 : (2 * numberOfCores);
                            for iTemp = 1 : 1 : numberOfCores
                                filteredDataChunksTemp{1, iTemp} = cell((boundaryArray(indices(iTemp)+1)-boundaryArray(indices(iTemp))), 37);
                            end
                            
                            %oldDirectory = pwd;
                            %temp = strcat(resultsFolderName, '\' , 'temp');
                            %cd(temp); 
                            
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
                                
                                keyWordsInner = keyWordsAsCategoricals; 
                                
                                % Continue only after all threads rech this barrier
                                labBarrier;
                                
                                % Set first timestamp as oldTimestamp to compare to - in following loop
                                index = strfind(dataChunk(1, 1), 'IVS');  % Pattern for the timestamps
                                oldTimestampTemp = '0000-00-00 00:00:00:000';
                                oldTimestamp = datevec(oldTimestampTemp, formatIn);
                                if(index{1,1} > 0)
                                    patternDelimiter = ',';
                                    splittedString = strsplit(loopData{1,1}, patternDelimiter);
                                    timestampPosition = 2;
                                    oldTimestampTemp = splittedString{1, timestampPosition};
                                    oldTimestamp = datevec(oldTimestampTemp, formatIn);
                                    %filteredLoopData{1, 1} = oldTimestamp;     %do not save the first timestamp (may not include valuable data)                                  
                                end

                                % Loop over all entries in the parfor part of the
                                % data chunk
                                for innerLoop = 1 : 1  : loopDataLength
                                    % keyWord 01
                                    index = strfind(loopData(innerLoop,1), 'IVS');  % Pattern for the timestamps
                                    patternDelimiter = ',';
                                    splittedString = strsplit(loopData{innerLoop,1}, patternDelimiter);

                                    % Keyword in the original data is at Position 3
                                    comparisonPosition = 3;
                                    comparisonElement = splittedString{1, comparisonPosition};
                                    comparisonElementTemp = {comparisonElement};
                                    comparisonElementCategorical = categorical(comparisonElementTemp);
                                    tempValue{1, 1} = 1;
                                    
                                    % 02 Rpm
                                    % keyWord 02 
                                    %if(strcmp(comparisonElement, 'm_IVS_AU_VAPIClient_EngineSpeed'))
                                    if(keyWordsInner(1, 2) == comparisonElementCategorical(1,1))
                                        % rpm position in fitered data = 2, value position = 5
                                        tempKey{1,1} = 2;
                                        tempValue{1, 1} = str2double(splittedString{1, 5});
                                    
                                    % 03 vehicle speed
                                    % keyWord 03
                                    %elseif(strcmp(comparisonElement, 'm_IVS_AU_VAPIClient_VehicleSpeed'))
                                    elseif(keyWordsInner(1, 3) == comparisonElementCategorical(1,1))
                                        % vehicle speed position in fitered data = 3, value position = 5
                                        tempKey{1,1} = 3;
                                        tempValue{1, 1} = str2double(splittedString{1, 5});
                                        
                                    % 12-17 GPS data 
                                    % keyWord 04
                                    %elseif(strcmp(comparisonElement, 'm_IVS_AU_VAPIClient_SimTD_FilteredPosition')) 
                                    elseif(keyWordsInner(1, 4) == comparisonElementCategorical(1,1))
                                    % 12 latitude
                                    	%
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
                                        
                                    % 04 long. acceleration
                                    % keyWord 05
                                    %elseif(strcmp(comparisonElement, 'm_IVS_AU_VAPIClient_LongitudinalAcceleration'))
                                    elseif(keyWordsInner(1, 5) == comparisonElementCategorical(1,1))
                                        % long. acceleraction position in fitered data = 4, value position = 5
                                        tempKey{1,1} = 4;
                                        tempValue{1, 1} = str2double(splittedString{1, 5}); 
                                              
                                    % 05 lat.
                                    % acceleration                                    % 
                                    % keyWord 06
                                    %elseif(strcmp(comparisonElement, 'm_IVS_AU_VAPIClient_LateralAcceleration'))
                                    elseif(keyWordsInner(1, 6) == comparisonElementCategorical(1,1))    
                                        % lat. acceleraction position in fitered data = 5, value position = 5
                                        tempKey{1,1} = 5;
                                        tempValue{1, 1} = str2double(splittedString{1, 5});
                                       
                                    % 08 steeringwheel angle 
                                    % keyWord 07
                                    %elseif(strcmp(comparisonElement, 'm_IVS_AU_VAPIClient_SteeringWheelAngle'))    
                                    elseif(keyWordsInner(1, 7) == comparisonElementCategorical(1,1))
                                        %
                                    	tempKey{1,1} = 8;
                                      	tempValue{1, 1} = str2double(splittedString{1, 5});    
                                   
                                    % 19-21 object detection
                                    % keyWord 08
                                    %elseif(strcmp(comparisonElement, 'm_IVS_AU_VAPIClient_SimTD_ObjectDetection'))
                                    elseif(keyWordsInner(1, 8) == comparisonElementCategorical(1,1))    
                                        % 19 object detected  
                                     	%
                                     	tempKey{1,1} = 19;
                                      	tempValue{1, 1} = str2double(splittedString{1, 5});

                                       	% 20 relative speed 
                                     	%
                                      	tempKey{1,2} = 20;
                                       	tempValue{1, 2} = str2double(splittedString{1, 7});

                                       	% 21 distance to object
                                     	%
                                     	tempKey{1,3} = 21;
                                      	tempValue{1, 3} = str2double(splittedString{1, 9});
                                               
                                    % 18 pedal force
                                    % keyWord 09
                                    %elseif(strcmp(comparisonElement, 'm_IVS_AU_VAPIClient_PedalForce'))
                                    elseif(keyWordsInner(1, 9) == comparisonElementCategorical(1,1))    
                                        %
                                      	tempKey{1,1} = 18;
                                      	tempValue{1, 1} = str2double(splittedString{1, 5});
                                    
                                    % 31 turn signal front left active   
                                    % keyWord 10
                                    %elseif(strcmp(comparisonElement, 'm_IVS_AU_VAPIClient_TurnSignalLights_FrontLeft'))
                                    elseif(keyWordsInner(1, 10) == comparisonElementCategorical(1,1))
                                        %
                                       	tempKey{1,1} = 31;
                                       	tempValue{1, 1} = str2double(splittedString{1, 5});
                                        
                                    % 32 turn signal front right active 
                                    % keyWord 11
                                    %elseif(strcmp(comparisonElement, 'm_IVS_AU_VAPIClient_TurnSignalLights_FrontRight'))
                                    elseif(keyWordsInner(1, 11) == comparisonElementCategorical(1,1))
                                    	%
                                      	tempKey{1,1} = 32;
                                       	tempValue{1, 1} = str2double(splittedString{1, 5});   
                                        
                                    % 33 turn signal rear left active 
                                    % keyWord 12
                                    %elseif(strcmp(comparisonElement, 'm_IVS_AU_VAPIClient_TurnSignalLights_RearLeft'))
                                    elseif(keyWordsInner(1, 12) == comparisonElementCategorical(1,1))    
                                        %
                                       	tempKey{1,1} = 33;
                                      	tempValue{1, 1} = str2double(splittedString{1, 5});
                                        
                                    % 34 turn signal rear right active
                                    % keyWord 13
                                    %elseif(strcmp(comparisonElement, 'm_IVS_AU_VAPIClient_TurnSignalLights_RearRight'))
                                    elseif(keyWordsInner(1, 13) == comparisonElementCategorical(1,1))
                                        %
                                       	tempKey{1,1} = 34;
                                     	tempValue{1, 1} = str2double(splittedString{1, 5});
                                         
                                    % 23 clutch active 
                                    % keyWord 14
                                    %elseif(strcmp(comparisonElement, 'm_IVS_AU_VAPIClient_ClutchSwitchActuation'))
                                    elseif(keyWordsInner(1, 14) == comparisonElementCategorical(1,1))
                                        %
                                      	tempKey{1,1} = 23;
                                      	tempValue{1, 1} = str2double(splittedString{1, 5}); 
                                    
                                    % 25 exterior temperature 
                                    % keyWord 15
                                    %elseif(strcmp(comparisonElement, 'm_IVS_AU_VAPIClient_ExteriorTemperature'))
                                    elseif(keyWordsInner(1, 15) == comparisonElementCategorical(1,1))
                                        %
                                       	tempKey{1,1} = 25;
                                       	tempValue{1, 1} = str2double(splittedString{1, 5});
                                       
                                    % 06 gear selection
                                    % keyWord 16
                                    elseif(keyWordsInner(1, 16) == comparisonElementCategorical(1,1))
                                    elseif(strcmp(comparisonElement, 'm_IVS_AU_VAPIClient_GearSelection'))    
                                        %
                                    	tempKey{1,1} = 6;
                                    	tempValue{1, 1} = splittedString{1, 5}; % string 
          
                                    % 07 current gear  
                                    % keyWord 17
                                    %elseif(strcmp(comparisonElement, 'm_IVS_AU_VAPIClient_CurrentGear'))   
                                    elseif(keyWordsInner(1, 17) == comparisonElementCategorical(1,1))
                                        %
                                        tempKey{1,1} = 7;
                                     	tempValue{1, 1} = splittedString{1, 5}; % string    
                                    
                                    % 09 steeringwheel velocity
                                    % keyWord 18
                                    %elseif(strcmp(comparisonElement, 'm_IVS_AU_VAPIClient_SteeringWheelAngularVelocity'))
                                    elseif(keyWordsInner(1, 18) == comparisonElementCategorical(1,1))
                                        %
                                    	tempKey{1,1} = 9;
                                      	tempValue{1, 1} = str2double(splittedString{1, 5});
                                        
                                    % 10 odometer
                                    % keyWord 19
                                    %elseif(strcmp(comparisonElement, 'm_IVS_AU_VAPIClient_Odometer'))
                                    elseif(keyWordsInner(1, 19) == comparisonElementCategorical(1,1))
                                        %
                                       	tempKey{1,1} = 10;
                                       	tempValue{1, 1} = str2double(splittedString{1, 5}); 
                                        
                                    % 11 trip odometer
                                    % keyWord 20
                                    %elseif(strcmp(comparisonElement, 'm_IVS_AU_VAPIClient_TripOdometer')) 
                                    elseif(keyWordsInner(1, 20) == comparisonElementCategorical(1,1))
                                        %
                                      	tempKey{1,1} = 11;
                                      	tempValue{1, 1} = str2double(splittedString{1, 5});
                                            
                                    % 17 brake actuation 
                                    % keyWord 21
                                    %elseif(strcmp(comparisonElement, 'm_IVS_AU_VAPIClient_BrakeActuation')) 
                                    elseif(keyWordsInner(1, 21) == comparisonElementCategorical(1,1))
                                        %
                                        tempKey{1,5} = 17;
                                    	tempValue{1, 5} = str2double(splittedString{1, 5});
                                        
                                    % 22 cruise control active
                                    % keyWord 22
                                    %elseif(strcmp(comparisonElement, 'm_IVS_AU_VAPIClient_CruiseControlSystemState'))
                                    elseif(keyWordsInner(1, 22) == comparisonElementCategorical(1,1))
                                        %
                                      	tempKey{1,1} = 22;
                                      	tempValue{1, 1} = splittedString{1, 5};    % string
                                       
                                    % 24 ABS active
                                    % keyWord 23
                                    %elseif(strcmp(comparisonElement, 'm_IVS_AU_VAPIClient_AntiLockBrakeSystem'))
                                    elseif(keyWordsInner(1, 23) == comparisonElementCategorical(1,1))
                                        % 
                                       	tempKey{1,1} = 24;
                                       	tempValue{1, 1} = splittedString{1, 5};    % string
                                        
                                    % 25 exterior temperature 
                                    % keyWord 24
                                    %elseif(strcmp(comparisonElement, 'm_IVS_AU_VAPIClient_ExteriorTemperature'))
                                    elseif(keyWordsInner(1, 24) == comparisonElementCategorical(1,1))
                                        %
                                       	tempKey{1,1} = 25;
                                       	tempValue{1, 1} = str2double(splittedString{1, 5});
                                        
                                    % 26 hazard ligths active  
                                    % keyWord 25
                                    %elseif(strcmp(comparisonElement, 'm_IVS_AU_VAPIClient_HazardWarningSystem'))
                                    elseif(keyWordsInner(1, 25) == comparisonElementCategorical(1,1))
                                        %
                                     	tempKey{1,1} = 26;
                                      	tempValue{1, 1} = str2double(splittedString{1, 5});
                                        
                                    %  27 daytime running lights active 
                                    % keyWord 26
                                    %elseif(strcmp(comparisonElement, 'm_IVS_AU_VAPIClient_FrontLights_DaytimeRunningLamp'))
                                    elseif(keyWordsInner(1, 26) == comparisonElementCategorical(1,1))
                                        %
                                      	tempKey{1,1} = 27;
                                        tempValue{1, 1} = str2double(splittedString{1, 5});
                                        
                                    % 28 front light low beam active  
                                    % keyWord 27
                                    %elseif(strcmp(comparisonElement, 'm_IVS_AU_VAPIClient_FrontLights_LowBeam'))
                                    elseif(keyWordsInner(1, 27) == comparisonElementCategorical(1,1))
                                        %
                                      	tempKey{1,1} = 28;
                                      	tempValue{1, 1} = str2double(splittedString{1, 5});
                                        
                                    % 29 front light high beam active
                                    % keyWord 28
                                    %elseif(strcmp(comparisonElement, 'm_IVS_AU_VAPIClient_FrontLights_HighBeam'))
                                    elseif(keyWordsInner(1, 28) == comparisonElementCategorical(1,1))
                                        %
                                      	tempKey{1,1} = 29;
                                       	tempValue{1, 1} = str2double(splittedString{1, 5});
                                        
                                    % 30 fog light active 
                                    % keyWord 29
                                    %elseif(strcmp(comparisonElement, 'm_IVS_AU_VAPIClient_FogLight'))
                                    elseif(keyWordsInner(1, 29) == comparisonElementCategorical(1,1))
                                        %
                                      	tempKey{1,1} = 30;
                                    	tempValue{1, 1} = str2double(splittedString{1, 5});
                                        
                                    % 35 emergency light active 
                                    % keyWord 30
                                    %elseif(strcmp(comparisonElement, 'm_IVS_AU_VAPIClient_SimTD_EmergencyLighting'))
                                    elseif(keyWordsInner(1, 30) == comparisonElementCategorical(1,1))
                                        %
                                       	tempKey{1,1} = 35;
                                       	tempValue{1, 1} = str2double(splittedString{1, 5});
                                        
                                    % 36 wiper front active  
                                    % keyWord 31
                                    %elseif(strcmp(comparisonElement, 'm_IVS_AU_VAPIClient_WiperSystem_Front'))
                                    elseif(keyWordsInner(1, 31) == comparisonElementCategorical(1,1))
                                        %
                                       	tempKey{1,1} = 36;
                                       	tempValue{1, 1} = splittedString{1, 5};    % string
                                        
                                    % 37 wiper rear active  
                                    % keyWord 32
                                    %elseif(strcmp(comparisonElement, 'm_IVS_AU_VAPIClient_WiperSystem_Rear'))
                                    elseif(keyWordsInner(1, 32) == comparisonElementCategorical(1,1))
                                        %
                                      	tempKey{1,1} = 37;
                                      	tempValue{1, 1} = splittedString{1, 5};    % string   
                                    %
                                    else
                                        % no pattern matched for this timestamp -> no entry in filtered list
                                      	matchFound = 0;

                                    end % elseif-end

                                    if(tempKey{1,1} > 0)
                                       if(index{1,1} > 0)
                                        timestampPosition = 2;
                                        newTimestampTemp = splittedString{1,timestampPosition};
                                        newTimestamp = datevec(newTimestampTemp, formatIn);
                                        if(~(isequal(newTimestamp, oldTimestamp)))
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
                                                %filteredLoopData{(entryCounter), tempKey{1,38}} = 1;
                                            end
                                            
                                        elseif (tempKey{1,1} == 19)
                                            for iTemp = 1:1:3
                                                filteredLoopData{(entryCounter), tempKey{1,iTemp}} = tempValue{1, iTemp};
                                                %filteredLoopData{(entryCounter), tempKey{1,38}} = 'id';
                                            end
                                        else
                                            filteredLoopData{(entryCounter), tempKey{1,1}} = tempValue{1, 1};
                                            %filteredLoopData{(entryCounter), tempKey{1,38}} = 'id';
                                        end
                                         
                                       end
                                       % Reset temporary key
                                       tempKey{1,1} = 0; 
                                    end

                                end%innerLoop-forLoop
                                filteredLoopData = filteredLoopData(1 : entryCounter, : );
                                filteredDataChunksTemp{1, iCores} = filteredLoopData;
                            end%parfor
                            
                            %cd(oldDirectory);
                            
                            % Aggregate the temporary filtered data back to 1 chunk ...
                            % as a result of the parfor loop
                            filteredDataChunksEntry = {};
                            for iAgg = 1 : 1 : numberOfCores
                                filteredDataChunksEntry = vertcat(filteredDataChunksEntry, filteredDataChunksTemp{1, iAgg});
                            end
                            filteredDataChunks{1, kWhileLoop} = filteredDataChunksEntry;
                            kWhileLoop = kWhileLoop + 1;
                            
                            % Save last timestamp
                            patternDelimiter = ',';
                            timestampPosition = 2;
                            splittedString = strsplit(dataChunk{numberOfRows, 1}, patternDelimiter);
                            lastTimestampTemp = splittedString{1, timestampPosition};
                            lastTimestamp = datevec(lastTimestampTemp, formatIn);                     
                            
                        end%whileLoop
                        %%timimg%%
                        toc
                        %%timimg%%
                        %Aggrehate all filtered chunks
                        for iAggRes = 1 : 1 : (kWhileLoop - 1)
                            filteredResultArray = vertcat(filteredResultArray, filteredDataChunks{1, iAggRes});
                        end
                        
                        % Dummy-entry to ensure correct data type for empty columns
                      	[length, width] = size(filteredResultArray);
                        for iEntry = 1 : 1 : width
                            if(iEntry == 6 || iEntry == 7 || iEntry == 22 || iEntry == 24 || iEntry == 36 || iEntry == 37)
                                    filteredResultArray{1,  iEntry} = 'empty';
                          	else
                                    filteredResultArray{1,  iEntry} = 0;
                            end
                        end
                        
                        % write first and last timestamp into the filtered result array
                        filteredResultArray{1,  1} = firstTimestamp;
                        filteredResultArray{length + 1,  1} = lastTimestamp;
                              
                        % Create table with colum descriptions
                        variablesNames = {'Timestamp' 'Rpm' 'Vehicle_speed' 'Long_acceleration' 'Lat_acceleration' ...
                            'Gear_selection' 'Current_gear' 'Steeringwheel_angle' 'Steeringwheel_velocity' 'Odometer' ...
                            'Trip_odometer' 'Latitude_GPS' 'Longitude_GPS' 'Heading_GPS' 'Altitude_GPS' ...
                            'Vehicle_speed_GPS' 'Brake_actuation' 'Pedal_force' 'Object_detected' 'Relative_speed_to_object' ...
                            'Distance_to_object' 'cruise_control' 'clutch' 'ABS' 'Exterior_temperature' ...
                            'Hazard_ligths' 'Daytime_running_lights' 'Front_light_low_beam' 'Front_light_high_beam' 'Fog_light' ...
                            'Turn_signal_front_left' 'Turn_signal_front_right' 'Turn_signal_rear_left' 'Turn_signal_rear_right' ...
                            'Emergency_Light' 'Wiper_front' 'Wiper_rear'};
                        filteredTable = cell2table(filteredResultArray, 'VariableNames', variablesNames);
                        
                        % Save filtered table in file
                        currentFolderTemp = pwd;
                        mkdir(strcat(resultsFolderName, '\', outputdir));
                        cd(strcat(resultsFolderName, '\', outputdir));
                        %tableFilenameDAT = strcat(filenameCurrent, '_Filtered_Data_Table.dat');
                        %tableFilenameCSV = strcat(filenameCurrent, '_Filtered_Data_Table.csv');
                        %tableFilenameXLSX = strcat(filenameCurrent, '_Filtered_Data_Table.xlsx');
                        %writetable(filteredTable, tableFilenameDAT);
                        %writetable(filteredTable, tableFilenameCSV);
                        %writetable(filteredTable, tableFilenameXLSX);
                        saveFileNameTemp = strsplit(filenameCurrent, '.decoded.txt');
                        saveFileName = saveFileNameTemp{1, 1};
                        save(saveFileName, 'filteredTable');
                        
                        
                        
                        cd(currentFolderTemp);

                    end%if-isDirUntared                    

                end%iFile-forLoop

                %OLD PLACE
             	cd(untarFolderName);
             	removeDir = strcat(untarFolderName, '\', outputdir);
                
                statusClose1 = fclose(fileID);
                statusClose2 = fclose('all');               	             
                
                fIDs = fopen('all');
                
              	[statusErase, messageErase, messageidErase] = rmdir(outputdir, 's');
                %OLD PLACE
            
            
            catch %try-inner
                % todo: 
                %  - write filenames of failed files into a log file
                %  - catch error
            
            end %try-inner
            
                   
        end%if-isDir
        
    catch %outer 
        %todo: 
        %   write filenames of failed files into a log file
        %   catch error
        
    end%try-outer
end%end-Untar

endPoint = 4;


