%

tempdir
clear all
setenv('TEMP','C:\UNPACK'); % TEMP for Windows
getenv('TEMP')
tempdir
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
alphaLetters = ('a':'z');
for iUntar = 1 : 1 : dirLength
    outputdir = '';
    dirBool = 0;
    if(isequal(MyDirInfo(iUntar).isdir, 0))
        dirBool = 1;
        tarfilename = MyDirInfo(iUntar).name;
        removeExtension = '.tar.gz';
        outputdir = strrep(tarfilename, removeExtension, '');
        cd(dataFolderName);
        %check if unpack file exists
        currentDirTemp = pwd;
        cd(untarFolderName);
        MyDirInfoTemp = dir;
        [dirLength, jD] = size(MyDirInfoTemp);
        overWrite = 0;
        untarError = 0;
        for iDir = 1 : 1 : dirLength
            if(strcmp(MyDirInfoTemp(iDir).name, outputdir))
                overWrite = 1;
            end
        end
        cd(currentDirTemp);
        if(overWrite == 1)
            %do not untar files, they already exist
        else
            try
                untar(tarfilename, untarFolderName);
            catch
                untarError = 1;
            end
        end
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
                saveCouunter = 0;
                T_filtered = table;
                while ~feof(fileID)
                    tic
                    dataChunk = textscan(fileID, '%s', chunkSize, 'CommentStyle', '##', 'delimiter', '');
                    dataChunk = dataChunk{1, 1};
                    chunkResultTable = cell(1,4);
                    boundaryArray = ones(2, numberOfCores);
                    boundaryArray(2,1) = chunkSize / numberOfCores;
                    for iBoundary = 2 : 1 : numberOfCores
                        boundaryArray(1, iBoundary) = boundaryArray(2,iBoundary-1)+1; 
                        boundaryArray(2, iBoundary) = iBoundary * chunkSize / numberOfCores;
                    end
                    parfor iCores = 1 : 1 : numberOfCores
                        boundaryArrayLocal = boundaryArray;
                        dataChunkLocal = dataChunk;
                        chunkResultTablePart = cell(boundaryArrayLocal(2,1),22);
                        entryCounter = 0;
                        firstIndex = boundaryArrayLocal(1, iCores);
                        lastIndex = boundaryArrayLocal(2, iCores);
                        for i = firstIndex : 1 : lastIndex
                            try
                                if(strcmp(dataChunkLocal{i,1}(1,32:42), 'm_IVS_AU_VA'))
                                    entryCounter = entryCounter + 1;
                                    tempEntry  = textscan(dataChunkLocal{i,1}, '%s', chunkSize, 'CommentStyle', '##', 'delimiter', ',');
                                    [length, j2] = size(tempEntry{1,1});
                                    for j = 1 : 1 : length
                                        chunkResultTablePart{entryCounter,j} = tempEntry{1,1}{j,1};
                                    end                               
                                end                            
                            catch
                            end
                        end 
                        chunkResultTable{1,iCores}= chunkResultTablePart(1:entryCounter, 2:22);
                    end
                    
                    for iJoin = 1 : 1 : numberOfCores
                        chunkResultTable{1,iJoin} = cell2table(chunkResultTable{1,iJoin});
                    end
                    toc
                    
                    tic
                    chunkTable = vertcat(chunkResultTable{1,1}, chunkResultTable{1,2});
                    for i = 3 : 1 : numberOfCores
                        chunkTable = vertcat(chunkTable, chunkResultTable{1,i}); 
                    end
                    toc
                    
                    
                    tic
                    %Engine Speed
                    index = ismember(chunkTable.Var2, 'm_IVS_AU_VAPIClient_EngineSpeed');
                    vars  = {'Var1', 'Var4'};
                    T_Temp1 = chunkTable(index, vars);
                    T_Temp1.Properties.VariableNames = {'Timestamp' 'EngineSpeed'};
                    [C,ia,ic] = unique(T_Temp1(:,1), 'stable');
                    T_Temp1 = T_Temp1(ia, :);
                    toc
                    
                    tic
                    %Vehicle Speed
                    index = ismember(chunkTable.Var2, 'm_IVS_AU_VAPIClient_VehicleSpeed');
                    vars  = {'Var1', 'Var4'};
                    T_Temp2 = chunkTable(index, vars);
                    T_Temp2.Properties.VariableNames = {'Timestamp' 'VehicleSpeed'};
                    [C,ia,ic] = unique(T_Temp2(:,1), 'stable');
                    T_Temp2 = T_Temp2(ia, :);
                    toc
                    tic
                    T_Temp1 = outerjoin(T_Temp1, T_Temp2, 'MergeKeys',true);
                    toc
                    
                    tic
                    %Positiion
                    index = ismember(chunkTable.Var2, 'm_IVS_AU_VAPIClient_SimTD_FilteredPosition');
                    vars  = {'Var1', 'Var4', 'Var6', 'Var10',...
                             'Var12', 'Var20'};
                    T_Temp2 = chunkTable(index, vars);
                    T_Temp2.Properties.VariableNames = {'Timestamp' 'Lat', 'Lon', 'Heading', 'Altitude', 'VehicleSpeedGPS'};
                    [C,ia,ic] = unique(T_Temp2(:,1), 'stable');
                    T_Temp2 = T_Temp2(ia, :);
                    toc
                    tic
                    T_Temp1 = outerjoin(T_Temp1, T_Temp2, 'MergeKeys',true);
                    toc                    
                    
                    
                    %LongitudinalAcceleration
                    index = ismember(chunkTable.Var2, 'm_IVS_AU_VAPIClient_LongitudinalAcceleration');
                    vars  = {'Var1', 'Var4'};
                    T_Temp2 = chunkTable(index, vars);
                    T_Temp2.Properties.VariableNames = {'Timestamp' 'LongAcc'};
                    [C,ia,ic] = unique(T_Temp2(:,1), 'stable');
                    T_Temp2 = T_Temp2(ia, :);
                    toc
                    tic
                    T_Temp1 = outerjoin(T_Temp1, T_Temp2, 'MergeKeys',true);
                    toc                    
                    
                    
                    % LateralAcceleration
                    index = ismember(chunkTable.Var2, 'm_IVS_AU_VAPIClient_LateralAcceleration');
                    vars  = {'Var1', 'Var4'};
                    T_Temp2 = chunkTable(index, vars);
                    T_Temp2.Properties.VariableNames = {'Timestamp' 'LatAcc'};
                    [C,ia,ic] = unique(T_Temp2(:,1), 'stable');
                    T_Temp2 = T_Temp2(ia, :);
                    toc
                    tic
                    T_Temp1 = outerjoin(T_Temp1, T_Temp2, 'MergeKeys',true);
                    toc                    
                    
                    
                    %SteeringWheelAngle
                    index = ismember(chunkTable.Var2, 'm_IVS_AU_VAPIClient_SteeringWheelAngle');
                    vars  = {'Var1', 'Var4'};
                    T_Temp2 = chunkTable(index, vars);
                    T_Temp2.Properties.VariableNames = {'Timestamp' 'SteeringWheelAngle'};
                    [C,ia,ic] = unique(T_Temp2(:,1), 'stable');
                    T_Temp2 = T_Temp2(ia, :);
                    toc
                    tic
                    T_Temp1 = outerjoin(T_Temp1, T_Temp2, 'MergeKeys',true);
                    toc                    
                    
                    
                    %ObjectDetection
                    index = ismember(chunkTable.Var2, 'm_IVS_AU_VAPIClient_SimTD_ObjectDetection');
                    vars  = {'Var1', 'Var4', 'Var6', 'Var8'};
                    T_Temp2 = chunkTable(index, vars);
                    T_Temp2.Properties.VariableNames = {'Timestamp' 'ObjectDeteced', 'ObjectRelSpeed', 'ObjectDist'};
                    [C,ia,ic] = unique(T_Temp2(:,1), 'stable');
                    T_Temp2 = T_Temp2(ia, :);
                    toc
                    tic
                    T_Temp1 = outerjoin(T_Temp1, T_Temp2, 'MergeKeys',true);
                    toc                    
                    
                    
                    %PedalForce
                    index = ismember(chunkTable.Var2, 'm_IVS_AU_VAPIClient_PedalForce');
                    vars  = {'Var1', 'Var4'};
                    T_Temp2 = chunkTable(index, vars);
                    T_Temp2.Properties.VariableNames = {'Timestamp' 'PedalForce'};
                    [C,ia,ic] = unique(T_Temp2(:,1), 'stable');
                    T_Temp2 = T_Temp2(ia, :);
                    toc
                    tic
                    T_Temp1 = outerjoin(T_Temp1, T_Temp2, 'MergeKeys',true);
                    toc                    
                    
                    
                    %TurnSignalLights_FrontLeft
                    index = ismember(chunkTable.Var2, 'm_IVS_AU_VAPIClient_TurnSignalLights_FrontLeft');
                    vars  = {'Var1', 'Var4'};
                    T_Temp2 = chunkTable(index, vars);
                    T_Temp2.Properties.VariableNames = {'Timestamp' 'TurnSignalLights_FL'};
                    [C,ia,ic] = unique(T_Temp2(:,1), 'stable');
                    T_Temp2 = T_Temp2(ia, :);
                    toc
                    tic
                    T_Temp1 = outerjoin(T_Temp1, T_Temp2, 'MergeKeys',true);
                    toc                    
                    
                    
                    %TurnSignalLights_FrontRight
                    index = ismember(chunkTable.Var2, 'm_IVS_AU_VAPIClient_TurnSignalLights_FrontRight');
                    vars  = {'Var1', 'Var4'};
                    T_Temp2 = chunkTable(index, vars);
                    T_Temp2.Properties.VariableNames = {'Timestamp' 'TurnSignalLights_FR'};
                    [C,ia,ic] = unique(T_Temp2(:,1), 'stable');
                    T_Temp2 = T_Temp2(ia, :);
                    toc
                    tic
                    T_Temp1 = outerjoin(T_Temp1, T_Temp2, 'MergeKeys',true);
                    toc                    
                    
                    
                    %TurnSignalLights_RearLeft
                    index = ismember(chunkTable.Var2, 'm_IVS_AU_VAPIClient_TurnSignalLights_RearLeft');
                    vars  = {'Var1', 'Var4'};
                    T_Temp2 = chunkTable(index, vars);
                    T_Temp2.Properties.VariableNames = {'Timestamp' 'TurnSignalLights_RL'};
                    [C,ia,ic] = unique(T_Temp2(:,1), 'stable');
                    T_Temp2 = T_Temp2(ia, :);
                    toc
                    tic
                    T_Temp1 = outerjoin(T_Temp1, T_Temp2, 'MergeKeys',true);
                    toc                    
                    
                    
                    %TurnSignalLights_RearRight
                    index = ismember(chunkTable.Var2, 'm_IVS_AU_VAPIClient_TurnSignalLights_RearRight');
                    vars  = {'Var1', 'Var4'};
                    T_Temp2 = chunkTable(index, vars);
                    T_Temp2.Properties.VariableNames = {'Timestamp' 'TurnSignalLights_RR'};
                    [C,ia,ic] = unique(T_Temp2(:,1), 'stable');
                    T_Temp2 = T_Temp2(ia, :);
                    toc
                    tic
                    T_Temp1 = outerjoin(T_Temp1, T_Temp2, 'MergeKeys',true);
                    toc                    
                    
                    
                    %m_IVS_AU_VAPIClient_ClutchSwitchActuation
                    index = ismember(chunkTable.Var2, 'm_IVS_AU_VAPIClient_ClutchSwitchActuation');
                    vars  = {'Var1', 'Var4'};
                    T_Temp2 = chunkTable(index, vars);
                    T_Temp2.Properties.VariableNames = {'Timestamp' 'ClutchSwitchActuation'};
                    [C,ia,ic] = unique(T_Temp2(:,1), 'stable');
                    T_Temp2 = T_Temp2(ia, :);
                    toc
                    tic
                    T_Temp1 = outerjoin(T_Temp1, T_Temp2, 'MergeKeys',true);
                    toc                    
                    
                    
                    %m_IVS_AU_VAPIClient_GearSelection
                    index = ismember(chunkTable.Var2, 'm_IVS_AU_VAPIClient_GearSelection');
                    vars  = {'Var1', 'Var4'};
                    T_Temp2 = chunkTable(index, vars);
                    T_Temp2.Properties.VariableNames = {'Timestamp' 'GearSelection'};
                    [C,ia,ic] = unique(T_Temp2(:,1), 'stable');
                    T_Temp2 = T_Temp2(ia, :);
                    toc
                    tic
                    T_Temp1 = outerjoin(T_Temp1, T_Temp2, 'MergeKeys',true);
                    toc                    
                    
                    
                    %m_IVS_AU_VAPIClient_CurrentGear
                    index = ismember(chunkTable.Var2, 'm_IVS_AU_VAPIClient_CurrentGear');
                    vars  = {'Var1', 'Var4'};
                    T_Temp2 = chunkTable(index, vars);
                    T_Temp2.Properties.VariableNames = {'Timestamp' 'CurrentGear'};
                    [C,ia,ic] = unique(T_Temp2(:,1), 'stable');
                    T_Temp2 = T_Temp2(ia, :);
                    toc
                    tic
                    T_Temp1 = outerjoin(T_Temp1, T_Temp2, 'MergeKeys',true);
                    toc                    
                    
                    
                    %m_IVS_AU_VAPIClient_SteeringWheelAngularVelocity
                    index = ismember(chunkTable.Var2, 'm_IVS_AU_VAPIClient_SteeringWheelAngularVelocity');
                    vars  = {'Var1', 'Var4'};
                    T_Temp2 = chunkTable(index, vars);
                    T_Temp2.Properties.VariableNames = {'Timestamp' 'SteeringWheelAngularVelocity'};
                    [C,ia,ic] = unique(T_Temp2(:,1), 'stable');
                    T_Temp2 = T_Temp2(ia, :);
                    toc
                    tic
                    T_Temp1 = outerjoin(T_Temp1, T_Temp2, 'MergeKeys',true);
                    toc                    
                    
                    
                    %m_IVS_AU_VAPIClient_Odometer
                    index = ismember(chunkTable.Var2, 'm_IVS_AU_VAPIClient_Odometer');
                    vars  = {'Var1', 'Var4'};
                    T_Temp2 = chunkTable(index, vars);
                    T_Temp2.Properties.VariableNames = {'Timestamp' 'Odometer'};
                    [C,ia,ic] = unique(T_Temp2(:,1), 'stable');
                    T_Temp2 = T_Temp2(ia, :);
                    toc
                    tic
                    T_Temp1 = outerjoin(T_Temp1, T_Temp2, 'MergeKeys',true);
                    toc                                  
                    
                    
                    %m_IVS_AU_VAPIClient_TripOdometer
                    index = ismember(chunkTable.Var2, 'm_IVS_AU_VAPIClient_TripOdometer');
                    vars  = {'Var1', 'Var4'};
                    T_Temp2 = chunkTable(index, vars);
                    T_Temp2.Properties.VariableNames = {'Timestamp' 'TripOdometer'};
                    [C,ia,ic] = unique(T_Temp2(:,1), 'stable');
                    T_Temp2 = T_Temp2(ia, :);
                    toc
                    tic
                    T_Temp1 = outerjoin(T_Temp1, T_Temp2, 'MergeKeys',true);
                    toc                    
                    
                    
                    %m_IVS_AU_VAPIClient_BrakeActuation
                    index = ismember(chunkTable.Var2, 'm_IVS_AU_VAPIClient_BrakeActuation');
                    vars  = {'Var1', 'Var4'};
                    T_Temp2 = chunkTable(index, vars);
                    T_Temp2.Properties.VariableNames = {'Timestamp' 'BrakeActuation'};
                    [C,ia,ic] = unique(T_Temp2(:,1), 'stable');
                    T_Temp2 = T_Temp2(ia, :);
                    toc
                    tic
                    T_Temp1 = outerjoin(T_Temp1, T_Temp2, 'MergeKeys',true);
                    toc                    
                    
                    
                    %m_IVS_AU_VAPIClient_CruiseControlSystemState
                    index = ismember(chunkTable.Var2, 'm_IVS_AU_VAPIClient_CruiseControlSystemState');
                    vars  = {'Var1', 'Var4'};
                    T_Temp2 = chunkTable(index, vars);
                    T_Temp2.Properties.VariableNames = {'Timestamp' 'CruiseControlSystemState'};
                    [C,ia,ic] = unique(T_Temp2(:,1), 'stable');
                    T_Temp2 = T_Temp2(ia, :);
                    toc
                    tic
                    T_Temp1 = outerjoin(T_Temp1, T_Temp2, 'MergeKeys',true);
                    toc                    
                    
                    
                    %m_IVS_AU_VAPIClient_AntiLockBrakeSystem
                    index = ismember(chunkTable.Var2, 'm_IVS_AU_VAPIClient_AntiLockBrakeSystem');
                    vars  = {'Var1', 'Var4'};
                    T_Temp2 = chunkTable(index, vars);
                    T_Temp2.Properties.VariableNames = {'Timestamp' 'AntiLockBrakeSystem'};
                    [C,ia,ic] = unique(T_Temp2(:,1), 'stable');
                    T_Temp2 = T_Temp2(ia, :);
                    toc
                    tic
                    T_Temp1 = outerjoin(T_Temp1, T_Temp2, 'MergeKeys',true);
                    toc                    
                    
                    
                    %m_IVS_AU_VAPIClient_ExteriorTemperature
                    index = ismember(chunkTable.Var2, 'm_IVS_AU_VAPIClient_ExteriorTemperature');
                    vars  = {'Var1', 'Var4'};
                    T_Temp2 = chunkTable(index, vars);
                    T_Temp2.Properties.VariableNames = {'Timestamp' 'ExteriorTemperature'};
                    [C,ia,ic] = unique(T_Temp2(:,1), 'stable');
                    T_Temp2 = T_Temp2(ia, :);
                    toc
                    tic
                    T_Temp1 = outerjoin(T_Temp1, T_Temp2, 'MergeKeys',true);
                    toc                    
                    
                    
                    %m_IVS_AU_VAPIClient_HazardWarningSystem
                    index = ismember(chunkTable.Var2, 'm_IVS_AU_VAPIClient_HazardWarningSystem');
                    vars  = {'Var1', 'Var4'};
                    T_Temp2 = chunkTable(index, vars);
                    T_Temp2.Properties.VariableNames = {'Timestamp' 'HazardWarningSystem'};
                    [C,ia,ic] = unique(T_Temp2(:,1), 'stable');
                    T_Temp2 = T_Temp2(ia, :);
                    toc
                    tic
                    T_Temp1 = outerjoin(T_Temp1, T_Temp2, 'MergeKeys',true);
                    toc                    
                    
                    
                    %m_IVS_AU_VAPIClient_FrontLights_DaytimeRunningLamp
                    index = ismember(chunkTable.Var2, 'm_IVS_AU_VAPIClient_FrontLights_DaytimeRunningLamp');
                    vars  = {'Var1', 'Var4'};
                    T_Temp2 = chunkTable(index, vars);
                    T_Temp2.Properties.VariableNames = {'Timestamp' 'FrontLights_DaytimeRunningLamp'};
                    [C,ia,ic] = unique(T_Temp2(:,1), 'stable');
                    T_Temp2 = T_Temp2(ia, :);
                    toc
                    tic
                    T_Temp1 = outerjoin(T_Temp1, T_Temp2, 'MergeKeys',true);
                    toc                    
                    
                    
                    %m_IVS_AU_VAPIClient_FrontLights_LowBeam
                    index = ismember(chunkTable.Var2, 'm_IVS_AU_VAPIClient_FrontLights_LowBeam');
                    vars  = {'Var1', 'Var4'};
                    T_Temp2 = chunkTable(index, vars);
                    T_Temp2.Properties.VariableNames = {'Timestamp' 'FrontLights_LowBeam'};
                    [C,ia,ic] = unique(T_Temp2(:,1), 'stable');
                    T_Temp2 = T_Temp2(ia, :);
                    toc
                    tic
                    T_Temp1 = outerjoin(T_Temp1, T_Temp2, 'MergeKeys',true);
                    toc                    
                    
                    
                    %m_IVS_AU_VAPIClient_FrontLights_HighBeam
                    index = ismember(chunkTable.Var2, 'm_IVS_AU_VAPIClient_FrontLights_HighBeam');
                    vars  = {'Var1', 'Var4'};
                    T_Temp2 = chunkTable(index, vars);
                    T_Temp2.Properties.VariableNames = {'Timestamp' 'FrontLights_HighBeam'};
                    [C,ia,ic] = unique(T_Temp2(:,1), 'stable');
                    T_Temp2 = T_Temp2(ia, :);
                    toc
                    tic
                    T_Temp1 = outerjoin(T_Temp1, T_Temp2, 'MergeKeys',true);
                    toc                    
                    
                    
                    %m_IVS_AU_VAPIClient_FogLight
                    index = ismember(chunkTable.Var2, 'm_IVS_AU_VAPIClient_FogLight');
                    vars  = {'Var1', 'Var4'};
                    T_Temp2 = chunkTable(index, vars);
                    T_Temp2.Properties.VariableNames = {'Timestamp' 'FogLight'};
                    [C,ia,ic] = unique(T_Temp2(:,1), 'stable');
                    T_Temp2 = T_Temp2(ia, :);
                    toc
                    tic
                    T_Temp1 = outerjoin(T_Temp1, T_Temp2, 'MergeKeys',true);
                    toc                    
                    
                    
                    %m_IVS_AU_VAPIClient_SimTD_EmergencyLighting
                    index = ismember(chunkTable.Var2, 'm_IVS_AU_VAPIClient_SimTD_EmergencyLighting');
                    vars  = {'Var1', 'Var4'};
                    T_Temp2 = chunkTable(index, vars);
                    T_Temp2.Properties.VariableNames = {'Timestamp' 'm_IVS_AU_VAPIClient_SimTD_EmergencyLighting'};
                    [C,ia,ic] = unique(T_Temp2(:,1), 'stable');
                    T_Temp2 = T_Temp2(ia, :);
                    toc
                    tic
                    T_Temp1 = outerjoin(T_Temp1, T_Temp2, 'MergeKeys',true);
                    toc                    
                    
                    
                    %m_IVS_AU_VAPIClient_WiperSystem_Front
                    index = ismember(chunkTable.Var2, 'm_IVS_AU_VAPIClient_WiperSystem_Front');
                    vars  = {'Var1', 'Var4'};
                    T_Temp2 = chunkTable(index, vars);
                    T_Temp2.Properties.VariableNames = {'Timestamp' 'WiperSystem_Front'};
                    [C,ia,ic] = unique(T_Temp2(:,1), 'stable');
                    T_Temp2 = T_Temp2(ia, :);
                    toc
                    tic
                    T_Temp1 = outerjoin(T_Temp1, T_Temp2, 'MergeKeys',true);
                    toc                    
                    
                    
                    %m_IVS_AU_VAPIClient_WiperSystem_Rear
                    index = ismember(chunkTable.Var2, 'm_IVS_AU_VAPIClient_WiperSystem_Rear');
                    vars  = {'Var1', 'Var4'};
                    T_Temp2 = chunkTable(index, vars);
                    T_Temp2.Properties.VariableNames = {'Timestamp' 'WiperSystem_Rear'};
                    [C,ia,ic] = unique(T_Temp2(:,1), 'stable');
                    T_Temp2 = T_Temp2(ia, :);
                    toc
                    tic
                    T_Temp1 = outerjoin(T_Temp1, T_Temp2, 'MergeKeys',true);
                    toc
                    if(kWhile == 1)
                        T_filtered = T_Temp1;
                    else
                        tic
                        T_filtered = vertcat(T_filtered, T_Temp1);
                        toc
                    end                                        
                    kWhile = kWhile + 1;
                    [sizeT_filtered, j2] = size(T_filtered);
                    if(sizeT_filtered > 100000)
                        saveCouunter = saveCouunter + 1;
                      	currentFolderTemp = pwd;
                        mkdir(strcat(resultsFolderName, '\', outputdir));
                        cd(strcat(resultsFolderName, '\', outputdir));
                        saveFileNameTemp = strsplit(filenameCurrent, '.decoded.txt');
                        letter = alphaLetters(1, saveCouunter);
                        saveFileName = strcat(saveFileNameTemp{1, 1}, '_', letter, '.mat','');
                        save(saveFileName, 'T_filtered');
                        T_filtered = table;
                        cd(currentFolderTemp);
                    end                    
                end%while
                % Save filtered table in file
                if(saveCouunter == 0)
                    currentFolderTemp = pwd;
                    mkdir(strcat(resultsFolderName, '\', outputdir));
                    cd(strcat(resultsFolderName, '\', outputdir));
                    saveFileNameTemp = strsplit(filenameCurrent, '.decoded.txt');
                    saveFileName = strcat(saveFileNameTemp{1, 1}, '.mat');
                    save(saveFileName, 'T_filtered');
                    cd(currentFolderTemp);
                else
                    saveCouunter = saveCouunter + 1;
                  	currentFolderTemp = pwd;
                   	mkdir(strcat(resultsFolderName, '\', outputdir));
                   	cd(strcat(resultsFolderName, '\', outputdir));
                   	saveFileNameTemp = strsplit(filenameCurrent, '.decoded.txt');
                   	letter = alphaLetters(1, saveCouunter);
                   	saveFileName = strcat(saveFileNameTemp{1, 1}, '_', letter, '.mat','');
                   	save(saveFileName, 'T_filtered');
                   	cd(currentFolderTemp);
                end
            end%if-isEqual
        end%for-iFiles
        
    end%if-isDir
    if(dirBool == 1)
        cd(untarFolderName);
        removeDir = strcat(untarFolderName, '\', outputdir);
        statusClose1 = fclose(fileID);
        statusClose2 = fclose('all');               	             
        FIDs = fopen('all');
        [statusErase, messageErase, messageidErase] = rmdir(outputdir, 's');
    end;
    dirBool = 0;
end%for-Untar


check =1;



















