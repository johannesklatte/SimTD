% Clear all workplace data
clear;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%TEST






%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%TEST


% Get System Information about system memory
[userview, systemview] = memory;

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

cd(dataFolderName);
MyDirInfo = dir;
[dirLength, j1] = size(MyDirInfo);

keys = {'IVS',      'En',	'VehicleS',	'SimTD_F', ... 
        'Lo',       'La',   'SteeringWheelAngle', ...                                       %05-07       
        'SimTD_O',  'Pe',   'TurnSignalLights_FrontLeft', ...                               %08-10
        'TurnSignalLights_FrontRight',  'TurnSignalLights_RearLeft',    'TurnSignalLights_RearRight', ...                               %11-13
        'ClutchSwitchActuation',        'GearSelection',                'CurrentGear', ...                                              %14-16
        'SteeringWheelAngularVelocity', 'Odometer',                     'TripOdometer', ...                                             %17-19
        'BrakeActuation',               'CruiseControlSystemState',     'AntiLockBrakeSystem', ...                                      %20-22
        'ExteriorTemperature',          'HazardWarningSystem',          'FrontLights_DaytimeRunningLamp', ...                           %23-25
        'FrontLights_LowBeam',          'FrontLights_HighBeam',         'FogLight', ...                                                 %26-28
        'SimTD_EmergencyLighting',      'WiperSystem_Front',            'WiperSystem_Rear'};                                            %29-31
    
keysChar = char(keys);    
    
keysLength = {};
for i = 1 : 1 : length(keys)
    keysLength{1,i} = length(keys{1,i});
end

keysLengthDouble = zeros(1,length(keysLength));
for i = 1 : 1 : length(keysLength)
    keysLengthDouble(1, i) = keysLength{1,i};
end

maximumKeyLength = max(keysLengthDouble);


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
                            dataChunk = textscan(fileID, '%s',chunkSize, 'CommentStyle', '##', 'delimiter', ',');
                            dataChunk = dataChunk{1, 1}; %maybe needs to be rewritten
                            
                            [sizeDataChunk, j1] = size(dataChunk);
                            
                            checkWord = dataChunk{1, 1};
                            
                            dataCellArray = cell(ceil(sizeDataChunk / 5), 25);
                            
                            entryCounterI = 0;
                            entryCounterJ = 1;
                            
                            maxWidth = 1;
                            
                            for iArray = 1 : 1 : sizeDataChunk
                                %dataCellArray{iArray, entryCounter} = dataChunk(iArray, 1);
                                if(strcmp(dataChunk{iArray, 1}, checkWord))
                                
                                    entryCounterI = entryCounterI + 1;
                                    entryCounterJ = 1;
                                    dataCellArray{entryCounterI, entryCounterJ} = dataChunk(iArray, 1);
                                else
                                    entryCounterJ = entryCounterJ + 1;
                                    if(entryCounterJ > maxWidth)
                                        maxWidth = entryCounterJ;
                                    end
                                    dataCellArray{entryCounterI, entryCounterJ} = dataChunk(iArray, 1);
                                end
                            end
                            
                            dataCellArray = dataCellArray(1 : entryCounterI, 2 : maxWidth);
                            
                            [sizeDataCellArray, j2] = size(dataCellArray);
                            
                            oldTimeStamp = dataCellArray{1,1}{1,1};
                            
                            resultChunk = cell(sizeDataCellArray, 37);
                            
                            resultChunk{1,1} = oldTimeStamp;
                            
                            entryCounter = 1;
                            
                          	% Create boundary array to split data for parallel processing
                            boundaryArray = zeros(1, 2 * numberOfCores);
                            boundaryArray(1) = 1;
                            for i = 2 : 2 : (2 * numberOfCores)
                                boundaryArray(i) = (i/2) * (sizeDataCellArray / numberOfCores);
                            end
                            boundaryArray = int64(boundaryArray); 
                            
                            compareTimeStamp = dataCellArray{boundaryArray(1, 2), 1}{1, 1};
                            
                            % Check boundaries (to make sure, that there is no change in timestamps at a boundary)
                            for iOut = 2 : 2 : ((2 * numberOfCores) - 2)
                                index = boundaryArray(iOut);
                                currentTimeStamp = dataCellArray{index, 1}{1, 1};
                                for iIn = 1 : 1 : 30
                                    newTimestamp = dataCellArray{(index+1), 1}{1, 1};
                                    if(strcmp(currentTimeStamp, newTimestamp)) 
                                        currentTimeStamp = newTimestamp;
                                        index = index + 1;
                                    else
                                        boundaryArray(iOut + 0) = index + 0;
                                        boundaryArray(iOut + 1) = index + 1;
                                        break
                                    end   
                                end
                            end%iOut-Loop
                            
                            toc
                            
                            for iParallel = 1 : 1 : numberOfCores
                            
                                for iArray = 1 : 1 : sizeDataCellArray
                                    try
                                        if(strcmp(dataCellArray{iArray, 2}{1, 1}(3 : 11), 'IVS_AU_VA'))


                                            %02
                                            %Engine Speed
                                            if(strcmp(dataCellArray{iArray, 3}{1, 1}, 'engineSpeed'))
                                                newTimeStamp = dataCellArray{iArray,1}{1,1};
                                                if(strcmp(dataCellArray{iArray,1}{1,1}, oldTimeStamp))
                                                    resultChunk{entryCounter, 2} = dataCellArray{iArray, 4}; 
                                                else
                                                    entryCounter = entryCounter + 1;
                                                     resultChunk{entryCounter, 1} = newTimeStamp;
                                                    resultChunk{entryCounter, 2} = dataCellArray{iArray, 4};
                                                    oldTimeStamp = newTimeStamp;
                                                end

                                            %03
                                            %Vehicle Speed
                                            elseif(strcmp(dataCellArray{iArray, 3}{1, 1}, 'vehicleSpeed'))  % EDIT IN KEYWORD
                                                newTimeStamp = dataCellArray{iArray,1}{1,1};
                                                if(strcmp(dataCellArray{iArray,1}{1,1}, oldTimeStamp))
                                                    resultChunk{entryCounter, 3} = dataCellArray{iArray, 4}; % EDIT IN 2 POSITIONS
                                                else
                                                    entryCounter = entryCounter + 1;
                                                    resultChunk{entryCounter, 1} = newTimeStamp;
                                                    resultChunk{entryCounter, 3} = dataCellArray{iArray, 4};  % EDIT IN 2 POSITIONS
                                                    oldTimeStamp = newTimeStamp;
                                                end

                                            %04-08
                                            %SimTD Filtered Position
                                            elseif(strcmp(dataCellArray{iArray, 3}{1, 1}, 'simTD_FilteredPosition_Latitude'))  % EDIT IN KEYWORD
                                                newTimeStamp = dataCellArray{iArray,1}{1,1};
                                                if(strcmp(dataCellArray{iArray,1}{1,1}, oldTimeStamp))
                                                    resultChunk{entryCounter, 4} = dataCellArray{iArray,  4}; % EDIT IN 2 POSITIONS
                                                    resultChunk{entryCounter, 5} = dataCellArray{iArray,  6}; % EDIT IN 2 POSITIONS
                                                    resultChunk{entryCounter, 6} = dataCellArray{iArray, 10}; % EDIT IN 2 POSITIONS
                                                    resultChunk{entryCounter, 7} = dataCellArray{iArray, 12}; % EDIT IN 2 POSITIONS
                                                    resultChunk{entryCounter, 8} = dataCellArray{iArray, 20}; % EDIT IN 2 POSITIONS
                                                else
                                                    entryCounter = entryCounter + 1;
                                                    resultChunk{entryCounter, 1} = newTimeStamp;
                                                    resultChunk{entryCounter, 4} = dataCellArray{iArray,  4}; % EDIT IN 2 POSITIONS
                                                    resultChunk{entryCounter, 5} = dataCellArray{iArray,  6}; % EDIT IN 2 POSITIONS
                                                    resultChunk{entryCounter, 6} = dataCellArray{iArray, 10}; % EDIT IN 2 POSITIONS
                                                    resultChunk{entryCounter, 7} = dataCellArray{iArray, 12}; % EDIT IN 2 POSITIONS
                                                    resultChunk{entryCounter, 8} = dataCellArray{iArray, 20}; % EDIT IN 2 POSITIONS
                                                    oldTimeStamp = newTimeStamp;
                                                end

                                            %09
                                            %Longitudinal Acceleration
                                            elseif(strcmp(dataCellArray{iArray, 3}{1, 1}, 'longitudinalAcceleration'))  % EDIT IN KEYWORD
                                                newTimeStamp = dataCellArray{iArray,1}{1,1};
                                                if(strcmp(dataCellArray{iArray,1}{1,1}, oldTimeStamp))
                                                    resultChunk{entryCounter, 9} = dataCellArray{iArray, 4}; % EDIT IN 2 POSITIONS
                                                else
                                                    entryCounter = entryCounter + 1;
                                                    resultChunk{entryCounter, 1} = newTimeStamp;
                                                    resultChunk{entryCounter, 9} = dataCellArray{iArray, 4};  % EDIT IN 2 POSITIONS
                                                    oldTimeStamp = newTimeStamp;
                                                end


                                            %10
                                            %Lateral Acceleration
                                            elseif(strcmp(dataCellArray{iArray, 3}{1, 1}, 'lateralAcceleration'))  % EDIT IN KEYWORD
                                                newTimeStamp = dataCellArray{iArray,1}{1,1};
                                                if(strcmp(dataCellArray{iArray,1}{1,1}, oldTimeStamp))
                                                    resultChunk{entryCounter, 10} = dataCellArray{iArray, 4}; % EDIT IN 2 POSITIONS
                                                else
                                                    entryCounter = entryCounter + 1;
                                                    resultChunk{entryCounter, 1} = newTimeStamp;
                                                    resultChunk{entryCounter, 10} = dataCellArray{iArray, 4};  % EDIT IN 2 POSITIONS
                                                    oldTimeStamp = newTimeStamp;
                                                end


                                            %11
                                            %Steering Wheel Angle
                                            elseif(strcmp(dataCellArray{iArray, 3}{1, 1}, 'steeringWheelAngle'))  % EDIT IN KEYWORD
                                                newTimeStamp = dataCellArray{iArray,1}{1,1};
                                                if(strcmp(dataCellArray{iArray,1}{1,1}, oldTimeStamp))
                                                    resultChunk{entryCounter, 11} = dataCellArray{iArray, 4}; % EDIT IN 2 POSITIONS
                                                else
                                                    entryCounter = entryCounter + 1;
                                                    resultChunk{entryCounter, 1} = newTimeStamp;
                                                    resultChunk{entryCounter, 11} = dataCellArray{iArray, 4};  % EDIT IN 2 POSITIONS
                                                    oldTimeStamp = newTimeStamp;
                                                end


                                            %12-14
                                            %simTD_ObjectDetection_Detected
                                            elseif(strcmp(dataCellArray{iArray, 3}{1, 1}, 'simTD_ObjectDetection_Detected'))  % EDIT IN KEYWORD
                                                newTimeStamp = dataCellArray{iArray,1}{1,1};
                                                if(strcmp(dataCellArray{iArray,1}{1,1}, oldTimeStamp))
                                                    resultChunk{entryCounter, 12} = dataCellArray{iArray, 4}; % EDIT IN 2 POSITIONS
                                                    resultChunk{entryCounter, 13} = dataCellArray{iArray, 6}; % EDIT IN 2 POSITIONS
                                                    resultChunk{entryCounter, 14} = dataCellArray{iArray, 8}; % EDIT IN 2 POSITIONS
                                                else
                                                    entryCounter = entryCounter + 1;
                                                    resultChunk{entryCounter, 1} = newTimeStamp;
                                                    resultChunk{entryCounter, 12} = dataCellArray{iArray, 4};  % EDIT IN 2 POSITIONS
                                                    resultChunk{entryCounter, 13} = dataCellArray{iArray, 6}; % EDIT IN 2 POSITIONS
                                                    resultChunk{entryCounter, 14} = dataCellArray{iArray, 8}; % EDIT IN 2 POSITIONS
                                                    oldTimeStamp = newTimeStamp;
                                                end


                                            %15
                                            %Pedal Force
                                            elseif(strcmp(dataCellArray{iArray, 3}{1, 1}, 'pedalForce'))  % EDIT IN KEYWORD
                                                newTimeStamp = dataCellArray{iArray,1}{1,1};
                                                if(strcmp(dataCellArray{iArray,1}{1,1}, oldTimeStamp))
                                                    resultChunk{entryCounter, 15} = dataCellArray{iArray, 4}; % EDIT IN 2 POSITIONS
                                                else
                                                    entryCounter = entryCounter + 1;
                                                    resultChunk{entryCounter, 1} = newTimeStamp;
                                                    resultChunk{entryCounter, 15} = dataCellArray{iArray, 4};  % EDIT IN 2 POSITIONS
                                                    oldTimeStamp = newTimeStamp;
                                                end


                                            %16
                                            %Turn Signal Lights Front Left
                                            elseif(strcmp(dataCellArray{iArray, 3}{1, 1}, 'turnSignalLights_FrontLeft'))  % EDIT IN KEYWORD
                                                newTimeStamp = dataCellArray{iArray,1}{1,1};
                                                if(strcmp(dataCellArray{iArray,1}{1,1}, oldTimeStamp))
                                                    resultChunk{entryCounter, 16} = dataCellArray{iArray, 4}; % EDIT IN 2 POSITIONS
                                                else
                                                    entryCounter = entryCounter + 1;
                                                    resultChunk{entryCounter, 1} = newTimeStamp;
                                                    resultChunk{entryCounter, 16} = dataCellArray{iArray, 4};  % EDIT IN 2 POSITIONS
                                                    oldTimeStamp = newTimeStamp;
                                                end


                                            %17
                                            %Turn Signal Lights Front Right
                                            elseif(strcmp(dataCellArray{iArray, 3}{1, 1}, 'turnSignalLights_FrontRight'))  % EDIT IN KEYWORD
                                                newTimeStamp = dataCellArray{iArray,1}{1,1};
                                                if(strcmp(dataCellArray{iArray,1}{1,1}, oldTimeStamp))
                                                    resultChunk{entryCounter, 17} = dataCellArray{iArray, 4}; % EDIT IN 2 POSITIONS
                                                else
                                                    entryCounter = entryCounter + 1;
                                                    resultChunk{entryCounter, 1} = newTimeStamp;
                                                    resultChunk{entryCounter, 17} = dataCellArray{iArray, 4};  % EDIT IN 2 POSITIONS
                                                    oldTimeStamp = newTimeStamp;
                                                end


                                            %18
                                            %Turn Signal Lights Rear Left
                                            elseif(strcmp(dataCellArray{iArray, 3}{1, 1}, 'turnSignalLights_RearLeft'))  % EDIT IN KEYWORD
                                                newTimeStamp = dataCellArray{iArray,1}{1,1};
                                                if(strcmp(dataCellArray{iArray,1}{1,1}, oldTimeStamp))
                                                    resultChunk{entryCounter, 18} = dataCellArray{iArray, 4}; % EDIT IN 2 POSITIONS
                                                else
                                                    entryCounter = entryCounter + 1;
                                                    resultChunk{entryCounter, 1} = newTimeStamp;
                                                    resultChunk{entryCounter, 18} = dataCellArray{iArray, 4};  % EDIT IN 2 POSITIONS
                                                    oldTimeStamp = newTimeStamp;
                                                end                                            



                                            %19
                                            %Turn Signal Lights Rear Right
                                            elseif(strcmp(dataCellArray{iArray, 3}{1, 1}, 'turnSignalLights_RearRight'))  % EDIT IN KEYWORD
                                                newTimeStamp = dataCellArray{iArray,1}{1,1};
                                                if(strcmp(dataCellArray{iArray,1}{1,1}, oldTimeStamp))
                                                    resultChunk{entryCounter, 19} = dataCellArray{iArray, 4}; % EDIT IN 2 POSITIONS
                                                else
                                                    entryCounter = entryCounter + 1;
                                                    resultChunk{entryCounter, 1} = newTimeStamp;
                                                    resultChunk{entryCounter, 19} = dataCellArray{iArray, 4};  % EDIT IN 2 POSITIONS
                                                    oldTimeStamp = newTimeStamp;
                                                end                                            


                                            %20
                                            %Clutch Switch Actuation
                                            elseif(strcmp(dataCellArray{iArray, 3}{1, 1}, 'clutchSwitchActuation'))  % EDIT IN KEYWORD
                                                newTimeStamp = dataCellArray{iArray,1}{1,1};
                                                if(strcmp(dataCellArray{iArray,1}{1,1}, oldTimeStamp))
                                                    resultChunk{entryCounter, 20} = dataCellArray{iArray, 4}; % EDIT IN 2 POSITIONS
                                                else
                                                    entryCounter = entryCounter + 1;
                                                    resultChunk{entryCounter, 1} = newTimeStamp;
                                                    resultChunk{entryCounter, 20} = dataCellArray{iArray, 4};  % EDIT IN 2 POSITIONS
                                                    oldTimeStamp = newTimeStamp;
                                                end  


                                            %21
                                            %Gear Selection
                                            elseif(strcmp(dataCellArray{iArray, 3}{1, 1}, 'gearSelection'))  % EDIT IN KEYWORD
                                                newTimeStamp = dataCellArray{iArray,1}{1,1};
                                                if(strcmp(dataCellArray{iArray,1}{1,1}, oldTimeStamp))
                                                    resultChunk{entryCounter, 21} = dataCellArray{iArray, 4}; % EDIT IN 2 POSITIONS
                                                else
                                                    entryCounter = entryCounter + 1;
                                                    resultChunk{entryCounter, 1} = newTimeStamp;
                                                    resultChunk{entryCounter, 21} = dataCellArray{iArray, 4};  % EDIT IN 2 POSITIONS
                                                    oldTimeStamp = newTimeStamp;
                                                end                                              


                                            %22
                                            %Current Gear
                                            elseif(strcmp(dataCellArray{iArray, 3}{1, 1}, 'currentGear'))  % EDIT IN KEYWORD
                                                newTimeStamp = dataCellArray{iArray,1}{1,1};
                                                if(strcmp(dataCellArray{iArray,1}{1,1}, oldTimeStamp))
                                                    resultChunk{entryCounter, 22} = dataCellArray{iArray, 4}; % EDIT IN 2 POSITIONS
                                                else
                                                    entryCounter = entryCounter + 1;
                                                    resultChunk{entryCounter, 1} = newTimeStamp;
                                                    resultChunk{entryCounter, 22} = dataCellArray{iArray, 4};  % EDIT IN 2 POSITIONS
                                                    oldTimeStamp = newTimeStamp;
                                                end                                              


                                            %23
                                            %Steerin Wheel Angular Velocity
                                            elseif(strcmp(dataCellArray{iArray, 3}{1, 1}, 'steeringWheelAngularVelocity'))  % EDIT IN KEYWORD
                                                newTimeStamp = dataCellArray{iArray,1}{1,1};
                                                if(strcmp(dataCellArray{iArray,1}{1,1}, oldTimeStamp))
                                                    resultChunk{entryCounter, 23} = dataCellArray{iArray, 4}; % EDIT IN 2 POSITIONS
                                                else
                                                    entryCounter = entryCounter + 1;
                                                    resultChunk{entryCounter, 1} = newTimeStamp;
                                                    resultChunk{entryCounter, 23} = dataCellArray{iArray, 4};  % EDIT IN 2 POSITIONS
                                                    oldTimeStamp = newTimeStamp;
                                                end                                              


                                            %24
                                            %Odometer
                                            elseif(strcmp(dataCellArray{iArray, 3}{1, 1}, ''))  % EDIT IN KEYWORD
                                                newTimeStamp = dataCellArray{iArray,1}{1,1};
                                                if(strcmp(dataCellArray{iArray,1}{1,1}, oldTimeStamp))
                                                    %resultChunk{entryCounter, 24} = dataCellArray{iArray, 4}; % EDIT IN 2 POSITIONS
                                                else
                                                    entryCounter = entryCounter + 1;
                                                    resultChunk{entryCounter, 1} = newTimeStamp;
                                                    %resultChunk{entryCounter, 24} = dataCellArray{iArray, 4};  % EDIT IN 2 POSITIONS
                                                    oldTimeStamp = newTimeStamp;
                                                end 


                                            %25
                                            %TripOdometer
                                            elseif(strcmp(dataCellArray{iArray, 3}{1, 1}, ''))  % EDIT IN KEYWORD
                                                newTimeStamp = dataCellArray{iArray,1}{1,1};
                                                if(strcmp(dataCellArray{iArray,1}{1,1}, oldTimeStamp))
                                                    %resultChunk{entryCounter, 25} = dataCellArray{iArray, 4}; % EDIT IN 2 POSITIONS
                                                else
                                                    entryCounter = entryCounter + 1;
                                                    resultChunk{entryCounter, 1} = newTimeStamp;
                                                    %resultChunk{entryCounter, 25} = dataCellArray{iArray, 4};  % EDIT IN 2 POSITIONS
                                                    oldTimeStamp = newTimeStamp;
                                                end                                             


                                            %26
                                            %Brake Actuation
                                            elseif(strcmp(dataCellArray{iArray, 3}{1, 1}, 'brakeActuation'))  % EDIT IN KEYWORD
                                                newTimeStamp = dataCellArray{iArray,1}{1,1};
                                                if(strcmp(dataCellArray{iArray,1}{1,1}, oldTimeStamp))
                                                    resultChunk{entryCounter, 26} = dataCellArray{iArray, 4}; % EDIT IN 2 POSITIONS
                                                else
                                                    entryCounter = entryCounter + 1;
                                                    resultChunk{entryCounter, 1} = newTimeStamp;
                                                    resultChunk{entryCounter, 26} = dataCellArray{iArray, 4};  % EDIT IN 2 POSITIONS
                                                    oldTimeStamp = newTimeStamp;
                                                end                                             


                                            %27
                                            %Cruise Control System State
                                            elseif(strcmp(dataCellArray{iArray, 3}{1, 1}, ''))  % EDIT IN KEYWORD
                                                newTimeStamp = dataCellArray{iArray,1}{1,1};
                                                if(strcmp(dataCellArray{iArray,1}{1,1}, oldTimeStamp))
                                                    %resultChunk{entryCounter, 27} = dataCellArray{iArray, 4}; % EDIT IN 2 POSITIONS
                                                else
                                                    entryCounter = entryCounter + 1;
                                                    resultChunk{entryCounter, 1} = newTimeStamp;
                                                    %resultChunk{entryCounter, 27} = dataCellArray{iArray, 4};  % EDIT IN 2 POSITIONS
                                                    oldTimeStamp = newTimeStamp;
                                                end                                             


                                            %28
                                            %Anti Lock Brake System
                                            elseif(strcmp(dataCellArray{iArray, 3}{1, 1}, ''))  % EDIT IN KEYWORD
                                                newTimeStamp = dataCellArray{iArray,1}{1,1};
                                                if(strcmp(dataCellArray{iArray,1}{1,1}, oldTimeStamp))
                                                    resultChunk{entryCounter, 28} = dataCellArray{iArray, 4}; % EDIT IN 2 POSITIONS
                                                else
                                                    entryCounter = entryCounter + 1;
                                                    resultChunk{entryCounter, 1} = newTimeStamp;
                                                    resultChunk{entryCounter, 28} = dataCellArray{iArray, 4};  % EDIT IN 2 POSITIONS
                                                    oldTimeStamp = newTimeStamp;
                                                end                                             


                                            %29
                                            %Exterior Temperature
                                            elseif(strcmp(dataCellArray{iArray, 3}{1, 1}, 'exteriorTemperature'))  % EDIT IN KEYWORD
                                                newTimeStamp = dataCellArray{iArray,1}{1,1};
                                                if(strcmp(dataCellArray{iArray,1}{1,1}, oldTimeStamp))
                                                    resultChunk{entryCounter, 29} = dataCellArray{iArray, 4}; % EDIT IN 2 POSITIONS
                                                else
                                                    entryCounter = entryCounter + 1;
                                                    resultChunk{entryCounter, 1} = newTimeStamp;
                                                    resultChunk{entryCounter, 29} = dataCellArray{iArray, 4};  % EDIT IN 2 POSITIONS
                                                    oldTimeStamp = newTimeStamp;
                                                end                                             


                                            %30
                                            %Hazard Warning System
                                            elseif(strcmp(dataCellArray{iArray, 3}{1, 1}, 'hazardWarningSystem'))  % EDIT IN KEYWORD
                                                newTimeStamp = dataCellArray{iArray,1}{1,1};
                                                if(strcmp(dataCellArray{iArray,1}{1,1}, oldTimeStamp))
                                                    resultChunk{entryCounter, 30} = dataCellArray{iArray, 4}; % EDIT IN 2 POSITIONS
                                                else
                                                    entryCounter = entryCounter + 1;
                                                    resultChunk{entryCounter, 1} = newTimeStamp;
                                                    resultChunk{entryCounter, 30} = dataCellArray{iArray, 4};  % EDIT IN 2 POSITIONS
                                                    oldTimeStamp = newTimeStamp;
                                                end 



                                            %31
                                            %Front Lights Daytime Running Lamp
                                            elseif(strcmp(dataCellArray{iArray, 3}{1, 1}, 'frontLights_DaytimeRunningLamp'))  % EDIT IN KEYWORD
                                                newTimeStamp = dataCellArray{iArray,1}{1,1};
                                                if(strcmp(dataCellArray{iArray,1}{1,1}, oldTimeStamp))
                                                    resultChunk{entryCounter, 31} = dataCellArray{iArray, 4}; % EDIT IN 2 POSITIONS
                                                else
                                                    entryCounter = entryCounter + 1;
                                                    resultChunk{entryCounter, 1} = newTimeStamp;
                                                    resultChunk{entryCounter, 31} = dataCellArray{iArray, 4};  % EDIT IN 2 POSITIONS
                                                    oldTimeStamp = newTimeStamp;
                                                end 


                                            %32
                                            %Front Lights Low Beam
                                            elseif(strcmp(dataCellArray{iArray, 3}{1, 1}, 'FrontLights_LowBeam'))  % EDIT IN KEYWORD
                                                newTimeStamp = dataCellArray{iArray,1}{1,1};
                                                if(strcmp(dataCellArray{iArray,1}{1,1}, oldTimeStamp))
                                                    resultChunk{entryCounter, 32} = dataCellArray{iArray, 4}; % EDIT IN 2 POSITIONS
                                                else
                                                    entryCounter = entryCounter + 1;
                                                    resultChunk{entryCounter, 1} = newTimeStamp;
                                                    resultChunk{entryCounter, 32} = dataCellArray{iArray, 4};  % EDIT IN 2 POSITIONS
                                                    oldTimeStamp = newTimeStamp;
                                                end 


                                            %33
                                            %Front Lights High Beam
                                            elseif(strcmp(dataCellArray{iArray, 3}{1, 1}, 'frontLights_HighBeam'))  % EDIT IN KEYWORD
                                                newTimeStamp = dataCellArray{iArray,1}{1,1};
                                                if(strcmp(dataCellArray{iArray,1}{1,1}, oldTimeStamp))
                                                    resultChunk{entryCounter, 33} = dataCellArray{iArray, 4}; % EDIT IN 2 POSITIONS
                                                else
                                                    entryCounter = entryCounter + 1;
                                                    resultChunk{entryCounter, 1} = newTimeStamp;
                                                    resultChunk{entryCounter, 33} = dataCellArray{iArray, 4};  % EDIT IN 2 POSITIONS
                                                    oldTimeStamp = newTimeStamp;
                                                end 


                                            %34
                                            %Fog Light
                                            elseif(strcmp(dataCellArray{iArray, 3}{1, 1}, 'fogLight'))  % EDIT IN KEYWORD
                                                newTimeStamp = dataCellArray{iArray,1}{1,1};
                                                if(strcmp(dataCellArray{iArray,1}{1,1}, oldTimeStamp))
                                                    resultChunk{entryCounter, 34} = dataCellArray{iArray, 4}; % EDIT IN 2 POSITIONS
                                                else
                                                    entryCounter = entryCounter + 1;
                                                    resultChunk{entryCounter, 1} = newTimeStamp;
                                                    resultChunk{entryCounter, 34} = dataCellArray{iArray, 4};  % EDIT IN 2 POSITIONS
                                                    oldTimeStamp = newTimeStamp;
                                                end 


                                            %35
                                            %Emergency Lighting
                                            elseif(strcmp(dataCellArray{iArray, 3}{1, 1}, 'simTD_EmergencyLighting'))  % EDIT IN KEYWORD
                                                newTimeStamp = dataCellArray{iArray,1}{1,1};
                                                if(strcmp(dataCellArray{iArray,1}{1,1}, oldTimeStamp))
                                                    resultChunk{entryCounter, 35} = dataCellArray{iArray, 4}; % EDIT IN 2 POSITIONS
                                                else
                                                    entryCounter = entryCounter + 1;
                                                    resultChunk{entryCounter, 1} = newTimeStamp;
                                                    resultChunk{entryCounter, 35} = dataCellArray{iArray, 4};  % EDIT IN 2 POSITIONS
                                                    oldTimeStamp = newTimeStamp;
                                                end 


                                            %36
                                            %Wiper System Front
                                            elseif(strcmp(dataCellArray{iArray, 3}{1, 1}, 'wiperSystem_Front'))  % EDIT IN KEYWORD
                                                newTimeStamp = dataCellArray{iArray,1}{1,1};
                                                if(strcmp(dataCellArray{iArray,1}{1,1}, oldTimeStamp))
                                                    resultChunk{entryCounter, 36} = dataCellArray{iArray, 4}; % EDIT IN 2 POSITIONS
                                                else
                                                    entryCounter = entryCounter + 1;
                                                    resultChunk{entryCounter, 1} = newTimeStamp;
                                                    resultChunk{entryCounter, 36} = dataCellArray{iArray, 4};  % EDIT IN 2 POSITIONS
                                                    oldTimeStamp = newTimeStamp;
                                                end 



                                            %37
                                            %Wiper System Rear
                                            elseif(strcmp(dataCellArray{iArray, 3}{1, 1}, 'wiperSystem_Rear'))  % EDIT IN KEYWORD
                                                newTimeStamp = dataCellArray{iArray,1}{1,1};
                                                if(strcmp(dataCellArray{iArray,1}{1,1}, oldTimeStamp))
                                                    resultChunk{entryCounter, 37} = dataCellArray{iArray, 4}; % EDIT IN 2 POSITIONS
                                                else
                                                    entryCounter = entryCounter + 1;
                                                    resultChunk{entryCounter, 1} = newTimeStamp;
                                                    resultChunk{entryCounter, 37} = dataCellArray{iArray, 4};  % EDIT IN 2 POSITIONS
                                                    oldTimeStamp = newTimeStamp;
                                                end 


                                             %
                                            %
                                            elseif(strcmp(dataCellArray{iArray, 3}{1, 1}, ''))  % EDIT IN KEYWORD
                                                newTimeStamp = dataCellArray{iArray,1}{1,1};
                                                if(strcmp(dataCellArray{iArray,1}{1,1}, oldTimeStamp))
                                                    %resultChunk{entryCounter, } = dataCellArray{iArray, }; % EDIT IN 2 POSITIONS
                                                else
                                                    entryCounter = entryCounter + 1;
                                                    resultChunk{entryCounter, 1} = newTimeStamp;
                                                    %resultChunk{entryCounter, } = dataCellArray{iArray, };  % EDIT IN 2 POSITIONS
                                                    oldTimeStamp = newTimeStamp;
                                                end 


                                            %
                                            %
                                            elseif(strcmp(dataCellArray{iArray, 3}{1, 1}, ''))  % EDIT IN KEYWORD
                                                newTimeStamp = dataCellArray{iArray,1}{1,1};
                                                if(strcmp(dataCellArray{iArray,1}{1,1}, oldTimeStamp))
                                                    %resultChunk{entryCounter, } = dataCellArray{iArray, }; % EDIT IN 2 POSITIONS
                                                else
                                                    entryCounter = entryCounter + 1;
                                                    resultChunk{entryCounter, 1} = newTimeStamp;
                                                    %resultChunk{entryCounter, } = dataCellArray{iArray, };  % EDIT IN 2 POSITIONS
                                                    oldTimeStamp = newTimeStamp;
                                                end 

                                            else  

                                            end
                                        end
                                    catch
                                        %do nothing
                                    end
                                end
                            end
                            
                            toc    
                            
                            
                            
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
                            
                           for iCores  = 1 : 1 : numberOfCores         %parfor parallel loop
                                entryCounter = 1;
                                tempKey = cell([1 5]);
                                tempKey{1,1} = 0;
                                tempValue = cell([1 5]);
                                indices = 1 : 2 : (2 * numberOfCores);
                                loopBoundaryArray = boundaryArray;                
                                loopData = dataChunk(loopBoundaryArray(indices(iCores)): boundaryArray(indices(iCores)+1), 1);
                                [loopDataLength, j2] = size(loopData);
                                filteredLoopData = filteredDataChunksTemp{1, iCores};
                                keysLengthDoubleInner = keysLengthDouble;
                                keysInner = keys;
                                
                                patternDelimiter = ',';
                                
                                % Continue only after all threads rech this barrier
                                labBarrier;
                                
                                % Set first timestamp as oldTimestamp to compare to - in following loop
                                index = strfind(dataChunk{1, 1}, 'IVS');  % Pattern for the timestamps
                                oldTimestampTemp = '0000-00-00 00:00:00:000';
                                oldTimestamp = datevec(oldTimestampTemp, formatIn);
                                if(index(1,1) > 0)
                                    patternDelimiter = ',';
                                    splittedStringTime = strsplit(loopData{1,1}, patternDelimiter);
                                    timestampPosition = 2;
                                    oldTimestampTemp = splittedStringTime{1, timestampPosition};
                                    oldTimestamp = datevec(oldTimestampTemp, formatIn);
                                    %filteredLoopData{1, 1} = oldTimestamp;     %do not save the first timestamp (may not include valuable data)                                  
                                end

                                % Loop over all entries in the parfor part of the
                                % data chunk
                                string1 = '';
                                string2 = '';
                                
                                
                                for innerLoop = 1 : 1  : loopDataLength
                                    string0 = loopData{innerLoop,1};
                                    errorString1ToShort = 0;
                                    try
                                        string1 = string0(1,32:41);
                                    catch
                                        errorString1ToShort = 1;
                                    end
                                    
                                    %test = loopData{innerLoop,1}(1,52:52 + keysLengthDouble(1,2) - 1)
                                    
                                    if(errorString1ToShort == 0 && strcmp(string1, 'm_IVS_AU_V'))
                                    
                                        
                                        
                                        
                                        
                                        
%                                         % 02
%                                         % 02 engine speed
%                                         try
%                                             if(strcmp(string0(1,52:52 + keysLengthDouble(1,2) - 1), keys(1, 2)))
%                                             	splittedString02 = strsplit(loopData{innerLoop,1}, patternDelimiter);
%                                                tempKey{1,1} = 2;
%                                             	tempValue{1, 1} = str2double(splittedString02{1, 5});
%                                             end
%                                         catch
                                             %do nothing
%                                         end
                                        
                                        
                                        
                                        
                                        
                                        % 02
                                        % 02 engine speed
%                                        test1 = string2(1, 1 : keysLengthDouble(1,2));
%                                        test2 = keysChar(2,:);
%                                        if(strcmp(string2(1, 1 : keysLengthDouble(1,2)), keysChar(2, :)))
%                                        	splittedString02 = strsplit(loopData{innerLoop,1}, patternDelimiter);
%                                        	tempKey{1,1} = 2;
%                                           	tempValue{1, 1} = str2double(splittedString02{1, 5});
%                                        
%                                         % 03    
%                                         % 03 vehicle speed
%                                         elseif(((LengthS2 > keysLengthDouble(1,3)) && (strcmp(string2(1, 1:keysLengthDouble(1,3)), keys{1,3}))))
%                                             splittedString03 = strsplit(loopData{innerLoop,1}, patternDelimiter);
%                                             tempKey{1,1} = 3;
%                                             tempValue{1, 1} = str2double(splittedString03{1, 5});
% 
%                                         % 04    
%                                         % 12-16 GPS data
%                                         elseif(((LengthS2 > keysLengthDouble(1,4)) && (strcmp(string2(1, 1:keysLengthDouble(1,4)), keys{1,4}))))
%                                             splittedString04 = strsplit(loopData{innerLoop,1}, patternDelimiter);
%                                             % 12 latitude
%                                             tempKey{1,1}  = 12;
%                                             tempValue{1, 1} = str2double(splittedString04{1, 5});
% 
%                                             % 13 longitude
%                                             tempKey{1,2}  = 13;
%                                             tempValue{1, 2} = str2double(splittedString04{1, 7});
% 
%                                             % 14 heading     
%                                             tempKey{1,3}  = 14;
%                                             tempValue{1, 3} = str2double(splittedString04{1, 11});
% 
%                                             % 15 altitude
%                                             tempKey{1,4}  = 15;
%                                             tempValue{1, 4} = str2double(splittedString04{1, 13});
% 
%                                             % 16 vehicle speed  
%                                             tempKey{1,5} = 16;
%                                             tempValue{1, 5} = str2double(splittedString04{1, 21});                 
% 
%                                         % 05
%                                         % 04 long. acceleration 
%                                         elseif(((LengthS2 > keysLengthDouble(1,5)) && (strcmp(string2(1, 1:keysLengthDouble(1,5)), keys{1,5}))))
%                                             splittedString05 = strsplit(loopData{innerLoop,1}, patternDelimiter);
%                                             tempKey{1,1} = 4;
%                                             tempValue{1, 1} = str2double(splittedString05{1, 5}); 
% 
% 
%                                         % 06
%                                         % 05 lat. acceleration  
%                                         elseif(((LengthS2 > keysLengthDouble(1,6)) && (strcmp(string2(1, 1:keysLengthDouble(1,6)), keys{1,6}))))    
%                                             splittedString06 = strsplit(loopData{innerLoop,1}, patternDelimiter);
%                                             tempKey{1,1} = 5;
%                                             tempValue{1, 1} = str2double(splittedString06{1, 5});
% 
% 
%                                         % 07
%                                         % 08 steeringwheel angle 
%                                         elseif(((LengthS2 > keysLengthDouble(1,7)) && (strcmp(string2(1, 1:keysLengthDouble(1,7)), keys{1,7})))) 
%                                             splittedString07 = strsplit(loopData{innerLoop,1}, patternDelimiter);
%                                             tempKey{1,1} = 8;
%                                             tempValue{1, 1} = str2double(splittedString07{1, 5});
% 
%                                         % 08
%                                         % 19-21 object detection
%                                         elseif(((LengthS2 > keysLengthDouble(1, 8)) && (strcmp(string2(1, 1:keysLengthDouble(1, 8)), keys{1, 8})))) 
%                                             splittedString08 = strsplit(loopData{innerLoop,1}, patternDelimiter);
%                                             % 19 object detected 
%                                             tempKey{1,1} = 19;
%                                             tempValue{1, 1} = str2double(splittedString08{1, 5});
% 
%                                             % 20 relative speed 
%                                             tempKey{1,2} = 20;
%                                             tempValue{1, 2} = str2double(splittedString08{1, 7});
% 
%                                             % 21 distance to object
%                                             tempKey{1,3} = 21;
%                                             tempValue{1, 3} = str2double(splittedString08{1, 9});
% 
%                                        % 09
%                                        % 18 pedal force
%                                        elseif(((LengthS2 > keysLengthDouble(1, 9)) && (strcmp(string2(1, 1:keysLengthDouble(1, 9)), keys{1, 9}))))
%                                             splittedString09 = strsplit(loopData{innerLoop,1}, patternDelimiter);
%                                             tempKey{1,1} = 18;
%                                             tempValue{1, 1} = str2double(splittedString09{1, 5});
% 
%                                         % 10
%                                         % 31 turn signal front left active
%                                         elseif(((LengthS2 > keysLengthDouble(1, 10)) && (strcmp(string2(1, 1:keysLengthDouble(1, 10)), keys{1, 10}))))
%                                             splittedString10 = strsplit(loopData{innerLoop,1}, patternDelimiter);
%                                             tempKey{1,1} = 31;
%                                             tempValue{1, 1} = str2double(splittedString10{1, 5});
% 
%                                         % 11
%                                         % 32 turn signal front right active 
%                                         elseif(((LengthS2 > keysLengthDouble(1, 11)) && (strcmp(string2(1, 1:keysLengthDouble(1, 11)), keys{1, 11}))))
%                                             splittedString11 = strsplit(loopData{innerLoop,1}, patternDelimiter);
%                                             tempKey{1,1} = 32;
%                                             tempValue{1, 1} = str2double(splittedString11{1, 5}); 
% 
%                                         % 12
%                                         % 33 turn signal rear left active 
%                                         elseif(((LengthS2 > keysLengthDouble(1, 12)) && (strcmp(string2(1, 1:keysLengthDouble(1, 12)), keys{1, 12}))))
%                                             splittedString12 = strsplit(loopData{innerLoop,1}, patternDelimiter);
%                                             tempKey{1,1} = 33;
%                                             tempValue{1, 1} = str2double(splittedString12{1, 5});
% 
% 
%                                        % 13
%                                        % 34 turn signal rear right active 
%                                        elseif(((LengthS2 > keysLengthDouble(1, 13)) && (strcmp(string2(1, 1:keysLengthDouble(1, 13)), keys{1, 13}))))
%                                             splittedString13 = strsplit(loopData{innerLoop,1}, patternDelimiter); 
%                                             tempKey{1,1} = 34;
%                                             tempValue{1, 1} = str2double(splittedString13{1, 5});                            
% 
%                                         % 14
%                                         % 23 clutch active 
%                                         elseif(((LengthS2 > keysLengthDouble(1, 14)) && (strcmp(string2(1, 1:keysLengthDouble(1, 14)), keys{1, 14}))))
%                                             splittedString14 = strsplit(loopData{innerLoop,1}, patternDelimiter);
%                                             tempKey{1,1} = 23;
%                                             tempValue{1, 1} = str2double(splittedString14{1, 5});   
% 
%                                         % 15
%                                         % 06 gear selection
%                                         elseif(((LengthS2 > keysLengthDouble(1, 15)) && (strcmp(string2(1, 1:keysLengthDouble(1, 15)), keys{1, 15}))))
%                                             splittedString15 = strsplit(loopData{innerLoop,1}, patternDelimiter);
%                                             tempKey{1,1} = 6;
%                                             tempValue{1, 1} = splittedString15{1, 5};
% 
%                                         % 16
%                                         % 07 current gear
%                                         elseif(((LengthS2 > keysLengthDouble(1, 16)) && (strcmp(string2(1, 1:keysLengthDouble(1, 16)), keys{1, 16}))))
%                                             splittedString16 = strsplit(loopData{innerLoop,1}, patternDelimiter);
%                                             tempKey{1,1} = 7;
%                                             tempValue{1, 1} = splittedString16{1, 5};
% 
%                                         % 17
%                                         % 09 steeringwheel velocity
%                                         elseif(((LengthS2 > keysLengthDouble(1, 17)) && (strcmp(string2(1, 1:keysLengthDouble(1, 17)), keys{1, 17}))))
%                                             splittedString17 = strsplit(loopData{innerLoop,1}, patternDelimiter);
%                                             tempKey{1,1} = 9;
%                                             tempValue{1, 1} = str2double(splittedString17{1, 5});
% 
%                                         % 18
%                                         % 10 odometer
%                                         elseif(((LengthS2 > keysLengthDouble(1, 18)) && (strcmp(string2(1, 1:keysLengthDouble(1, 18)), keys{1, 18}))))
%                                             splittedString18 = strsplit(loopData{innerLoop,1}, patternDelimiter);
%                                             tempKey{1,1} = 10;
%                                             tempValue{1, 1} = str2double(splittedString18{1, 5});
% 
% 
%                                         % 19
%                                         % 11 trip odometer
%                                         elseif(((LengthS2 > keysLengthDouble(1, 19)) && (strcmp(string2(1, 1:keysLengthDouble(1, 19)), keys{1, 19}))))
%                                             splittedString19 = strsplit(loopData{innerLoop,1}, patternDelimiter);
%                                             tempKey{1,1} = 11;
%                                             tempValue{1, 1} = str2double(splittedString19{1, 5});
% 
%                                         % 20
%                                         % 17 brake actuation
%                                         elseif(((LengthS2 > keysLengthDouble(1, 20)) && (strcmp(string2(1, 1:keysLengthDouble(1, 20)), keys{1, 20}))))
%                                             splittedString20 = strsplit(loopData{innerLoop,1}, patternDelimiter);
%                                             tempKey{1,1} = 17;
%                                             tempValue{1, 1} = str2double(splittedString20{1, 5});
% 
%                                         % 21
%                                         % 22 cruise control active
%                                         elseif(((LengthS2 > keysLengthDouble(1, 21)) && (strcmp(string2(1, 1:keysLengthDouble(1, 21)), keys{1, 21}))))
%                                             splittedString21 = strsplit(loopData{innerLoop,1}, patternDelimiter);
%                                             tempKey{1,1} = 22;
%                                             tempValue{1, 1} = splittedString21{1, 5};
% 
%                                         % 22
%                                         % 24 ABS active
%                                         elseif(((LengthS2 > keysLengthDouble(1, 22)) && (strcmp(string2(1, 1:keysLengthDouble(1, 22)), keys{1, 22}))))
%                                             splittedString22 = strsplit(loopData{innerLoop,1}, patternDelimiter);
%                                             tempKey{1,1} = 24;
%                                             tempValue{1, 1} = splittedString22{1, 5};
% 
%                                         % 23
%                                         % 25 exterior temperature 
%                                         elseif(((LengthS2 > keysLengthDouble(1, 23)) && (strcmp(string2(1, 1:keysLengthDouble(1, 23)), keys{1, 23}))))
%                                             splittedString23 = strsplit(loopData{innerLoop,1}, patternDelimiter);
%                                             tempKey{1,1} = 25;
%                                             tempValue{1, 1} = str2double(splittedString23{1, 5});
% 
% 
%                                         % 24
%                                         % 26 hazard ligths active
%                                         elseif(((LengthS2 > keysLengthDouble(1, 24)) && (strcmp(string2(1, 1:keysLengthDouble(1, 24)), keys{1, 24}))))
%                                             splittedString24 = strsplit(loopData{innerLoop,1}, patternDelimiter);
%                                             tempKey{1,1} = 26;
%                                             tempValue{1, 1} = str2double(splittedString24{1, 5});
% 
%                                         % 25
%                                         % 27 daytime running lights active
%                                         elseif(((LengthS2 > keysLengthDouble(1, 25)) && (strcmp(string2(1, 1:keysLengthDouble(1, 25)), keys{1, 25}))))
%                                             splittedString25 = strsplit(loopData{innerLoop,1}, patternDelimiter);
%                                             tempKey{1,1} = 27;
%                                             tempValue{1, 1} = str2double(splittedString25{1, 5});
% 
%                                         % 26
%                                         % 28 front light low beam active 
%                                         elseif(((LengthS2 > keysLengthDouble(1, 26)) && (strcmp(string2(1, 1:keysLengthDouble(1, 26)), keys{1, 26}))))
%                                             splittedString26 = strsplit(loopData{innerLoop,1}, patternDelimiter);
%                                             tempKey{1,1} = 28;
%                                             tempValue{1, 1} = str2double(splittedString26{1, 5});
% 
%                                         % 27
%                                         % 29 front light high beam active
%                                         elseif(((LengthS2 > keysLengthDouble(1, 27)) && (strcmp(string2(1, 1:keysLengthDouble(1, 27)), keys{1, 27}))))
%                                             splittedString27 = strsplit(loopData{innerLoop,1}, patternDelimiter);
%                                             tempKey{1,1} = 29;
%                                             tempValue{1, 1} = str2double(splittedString27{1, 5});
% 
%                                         % 28
%                                         % 30 fog light active 
%                                         elseif(((LengthS2 > keysLengthDouble(1, 28)) && (strcmp(string2(1, 1:keysLengthDouble(1, 28)), keys{1, 28}))))
%                                             splittedString28 = strsplit(loopData{innerLoop,1}, patternDelimiter);
%                                             tempKey{1,1} = 30;
%                                             tempValue{1, 1} = str2double(splittedString28{1, 5});
% 
%                                         % 29
%                                         % 35 emergency light active 
%                                         elseif(((LengthS2 > keysLengthDouble(1, 29)) && (strcmp(string2(1, 1:keysLengthDouble(1, 29)), keys{1, 29}))))
%                                             splittedString29 = strsplit(loopData{innerLoop,1}, patternDelimiter);
%                                             tempKey{1,1} = 35;
%                                             tempValue{1, 1} = str2double(splittedString29{1, 5});
% 
%                                         % 30
%                                         % 36 wiper front active
%                                         elseif(((LengthS2 > keysLengthDouble(1, 30)) && (strcmp(string2(1, 1:keysLengthDouble(1, 30)), keys{1, 30}))))
%                                             splittedString30 = strsplit(loopData{innerLoop,1}, patternDelimiter);
%                                             tempKey{1,1} = 36;
%                                             tempValue{1, 1} = splittedString30{1, 5};
% 
%                                         % 31
%                                         % 37 wiper rear active
%                                         elseif(((LengthS2 > keysLengthDouble(1, 31)) && (strcmp(string2(1, 1:keysLengthDouble(1, 31)), keys{1, 31}))))
%                                             splittedString31 = strsplit(loopData{innerLoop,1}, patternDelimiter);
%                                             tempKey{1,1} = 37;
%                                             tempValue{1, 1} = splittedString31{1, 5};                                            
%                                        end
                                    end
                                    

                                    if(tempKey{1,1} > 0)
                                            newTimestampTemp = loopData{innerLoop,1};
                                            newTimestampTemp = newTimestampTemp(1, 8:30);
                                            newTimestamp = datevec(newTimestampTemp, formatIn);
                                            if(newTimestamp(1,5) == 0.042)
                                                check = 1;                                                
                                            end
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
                        %%timing%%
                        toc
                        %%timing%%
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
                        %writetable(filteredTable, tableFilenameXLSX);spö
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
                
              	%[statusErase, messageErase, messageidErase] = rmdir(outputdir, 's');
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


