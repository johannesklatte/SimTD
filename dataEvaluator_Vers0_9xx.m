%
clear;

% Get System Information about system memory
[userview systemview] = memory;

% Start parallel pool
numberOfCores = feature('numcores');

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

for iUntar = 1 : 1 : dirLength
    outputdir = '';
    if(isequal(MyDirInfo(iUntar).isdir, 0))
        tarfilename = MyDirInfo(iUntar).name;
        removeExtension = '.tar.gz';
        outputdir = strrep(tarfilename, removeExtension, '');
        cd(dataFolderName);
        %untar(tarfilename, untarFolderName);
        cd(strcat(untarFolderName, '\', outputdir));
        % loop over all extracted *.txt and gather valuable information to
        % save in a matlab table
        MyDirInfoUntared = dir;
        [dirLengthUntar, j1] = size(MyDirInfoUntared);
        % Average memory usage per row of original file in bytes 250 (tested)
        memoryUsageInBytesPerRow = 250;
        chunkSize = 250000; %userview.MemAvailableAllArrays / (2 * numberOfCores * memoryUsageInBytesPerRow);
        for iFile = 1 : 1 : dirLengthUntar
            if(isequal(MyDirInfoUntared(iFile).isdir, 0))
                filenameCurrent =  MyDirInfoUntared(iFile).name;
                fileID = fopen(filenameCurrent);
                kWhile = 1;
                finalResultsCellArray = cell(1,38);
                while ~feof(fileID)
                    tic
                    dataChunk = textscan(fileID, '%s', chunkSize, 'CommentStyle', '##', 'delimiter', '');
                    dataChunk = dataChunk{1, 1};
                    chunkResultArray = cell(chunkSize/5 ,38);
                    for i = 1 : 1 : chunkSize
                        element = textscan(dataChunk{i,1}, '%s', chunkSize, 'CommentStyle', '##', 'delimiter', ',');
                        dataChunk{i,1} = element{1,1};
                        entryCounter = 0;
                        tester = element{1,1}{3,1}(1,1:11);
                        if(strcmp(tester, 'm_IVS_AU_VA'))
                            %01EngineSpeed
                            if(strcmp(dataChunk{i,1}{3,1}, 'm_IVS_AU_VAPIClient_EngineSpeed'))
                                entryCounter = entryCounter + 1;
                                chunkResultArray{entryCounter, 1} = dataChunk{i,1}{1,1};
                            %02                          
                            elseif(strcmp(dataChunk{i,1}{3,1}, 'm_IVS_AU_VAPIClient_VehicleSpeed'))

                            %03                           
                            elseif(strcmp(dataChunk{i,1}{3,1}, 'm_IVS_AU_VAPIClient_SimTD_FilteredPosition'))

                            %04
                            elseif(strcmp(dataChunk{i,1}{3,1}, 'm_IVS_AU_VAPIClient_LongitudinalAcceleration'))

                            %05
                            elseif(strcmp(dataChunk{i,1}{3,1}, 'm_IVS_AU_VAPIClient_LateralAcceleration'))

                            %06
                            elseif(strcmp(dataChunk{i,1}{3,1}, 'm_IVS_AU_VAPIClient_SteeringWheelAngle'))

                            %07
                            elseif(strcmp(dataChunk{i,1}{3,1}, 'm_IVS_AU_VAPIClient_SimTD_ObjectDetection'))

                            %08
                            elseif(strcmp(dataChunk{i,1}{3,1}, 'm_IVS_AU_VAPIClient_PedalForce'))

                            %09
                            elseif(strcmp(dataChunk{i,1}{3,1}, 'm_IVS_AU_VAPIClient_TurnSignalLights_FrontLeft'))

                            %10
                            elseif(strcmp(dataChunk{i,1}{3,1}, 'm_IVS_AU_VAPIClient_TurnSignalLights_FrontRight'))

                            %11
                            elseif(strcmp(dataChunk{i,1}{3,1}, 'm_IVS_AU_VAPIClient_TurnSignalLights_RearLeft'))

                            %12
                            elseif(strcmp(dataChunk{i,1}{3,1}, 'm_IVS_AU_VAPIClient_TurnSignalLights_RearRight'))

                            %13
                            elseif(strcmp(dataChunk{i,1}{3,1}, 'm_IVS_AU_VAPIClient_ClutchSwitchActuation'))

                            %14
                            elseif(strcmp(dataChunk{i,1}{3,1}, 'm_IVS_AU_VAPIClient_GearSelection'))

                            %15
                            elseif(strcmp(dataChunk{i,1}{3,1}, 'm_IVS_AU_VAPIClient_CurrentGear'))

                            %16
                            elseif(strcmp(dataChunk{i,1}{3,1}, 'm_IVS_AU_VAPIClient_SteeringWheelAngularVelocity'))

                            %17
                            elseif(strcmp(dataChunk{i,1}{3,1}, 'm_IVS_AU_VAPIClient_Odometer'))

                            %18
                            elseif(strcmp(dataChunk{i,1}{3,1}, 'm_IVS_AU_VAPIClient_TripOdometer'))

                            %19
                            elseif(strcmp(dataChunk{i,1}{3,1}, 'm_IVS_AU_VAPIClient_BrakeActuation'))

                            %20
                            elseif(strcmp(dataChunk{i,1}{3,1}, 'm_IVS_AU_VAPIClient_CruiseControlSystemState'))

                            %21
                            elseif(strcmp(dataChunk{i,1}{3,1}, 'm_IVS_AU_VAPIClient_AntiLockBrakeSystem'))       

                            %22
                            elseif(strcmp(dataChunk{i,1}{3,1}, 'm_IVS_AU_VAPIClient_ExteriorTemperature'))

                            %23
                            elseif(strcmp(dataChunk{i,1}{3,1}, 'm_IVS_AU_VAPIClient_HazardWarningSystem'))  

                            %24
                            elseif(strcmp(dataChunk{i,1}{3,1}, 'm_IVS_AU_VAPIClient_FrontLights_DaytimeRunningLamp'))

                            %25
                            elseif(strcmp(dataChunk{i,1}{3,1}, 'm_IVS_AU_VAPIClient_FrontLights_LowBeam'))  

                            %26
                            elseif(strcmp(dataChunk{i,1}{3,1}, 'm_IVS_AU_VAPIClient_FrontLights_HighBeam'))

                            %27
                            elseif(strcmp(dataChunk{i,1}{3,1}, 'm_IVS_AU_VAPIClient_FogLight'))  

                            %28
                            elseif(strcmp(dataChunk{i,1}{3,1}, 'm_IVS_AU_VAPIClient_SimTD_EmergencyLighting'))

                            %29
                            elseif(strcmp(dataChunk{i,1}{3,1}, 'm_IVS_AU_VAPIClient_WiperSystem_Front'))  

                            %30
                            elseif(strcmp(dataChunk{i,1}{3,1}, 'm_IVS_AU_VAPIClient_WiperSystem_Rear'))

                            end
                        end
                    end
                    toc
                    
                    
                    
                    
                    dataChunk = textscan(fileID, '%s', chunkSize, 'CommentStyle', '##', 'delimiter', ',');
                    dataChunk = dataChunk{1, 1};
                    checkWord = dataChunk{1, 1};
                    [sizeDataChunk, j1] = size(dataChunk);
                    dataCellArray = cell(ceil(sizeDataChunk / 5), 38);
                    entryCounterI = 0;
                    entryCounterJ = 1;
                    startIndex = 1;
                    while(~strcmp(dataChunk{startIndex, 1}, checkWord))
                        startIndex = startIndex + 1; 
                    end
                    dataChunk = dataChunk(startIndex:sizeDataChunk, : );
                    iArray = 1;
                    tic%%%%%%%%%%%%%%%%%%%%%%%%%%
                    while(iArray < sizeDataChunk)
                        compareElement = dataChunk{iArray, 1};
                        if(strcmp(compareElement,checkWord))
                            iArray = iArray + 2;
                        elseif(strcmp(compareElement, 'm_IVS_AU_VAPIClient_EngineSpeed'))
                            entryCounterI = entryCounterI + 1;
                            dataCellArray{entryCounterI, 1} = dataChunk(iArray - 1, 1);
                            try
                                dataCellArray{entryCounterI, 2} = dataChunk(iArray + 2, 1);
                            catch
                            end
                            iArray = iArray + 1;
                        elseif(strcmp(compareElement, 'm_IVS_AU_VAPIClient_SimTD_FilteredPosition'))
                            entryCounterI = entryCounterI + 1;
                            dataCellArray{entryCounterI, 1} = dataChunk(iArray - 1, 1);
                            try
                                dataCellArray{entryCounterI, 3} = dataChunk(iArray + 2, 1);
                                dataCellArray{entryCounterI, 4} = dataChunk(iArray + 4, 1);
                                dataCellArray{entryCounterI, 5} = dataChunk(iArray + 8, 1);
                                dataCellArray{entryCounterI, 6} = dataChunk(iArray +10, 1);
                                dataCellArray{entryCounterI, 7} = dataChunk(iArray +18, 1);
                            catch
                            end
                            iArray = iArray + 1;
                        elseif(strcmp(compareElement, 'm_IVS_AU_VAPIClient_LongitudinalAcceleration'))
                            iArray = iArray + 1;
                        else
                            iArray = iArray + 1;
                        end
                    end%while-elseIf   
                    if(kWhile == 1)
                    	finalResultsCellArray =  dataCellArray(1 : entryCounterI-1, 2 : 38);               
                    else
                        finalResultsCellArray = vertcat(finalResultsCellArray, dataCellArray(1 : entryCounterI-1, 2 : 38));
                    end
                    toc%%%%%%%%%%%%
                    kWhile = kWhile + 1;
                end%while
            end%if-isEqual
        end%parfor-iFiles
    end%if-isDir
end%for-Untar





















test = 1;




















