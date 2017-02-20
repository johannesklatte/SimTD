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
                    chunkResultTable = cell(ceil(chunkSize/5), 22);
                    entryCounter = 0;
                    for iCores = 1 : 1 : numberOfCores
                        for i = 1 : 1 : chunkSize
                            try
                                if(strcmp(dataChunk{i,1}(1,32:42), 'm_IVS_AU_VA'))
                                    entryCounter = entryCounter + 1;
                                    tempEntry  = textscan(dataChunk{i,1}, '%s', chunkSize, 'CommentStyle', '##', 'delimiter', ',');
                                    [length, j2] = size(tempEntry{1,1});
                                    for j = 1 : 1 : length
                                        chunkResultTable{entryCounter,j} = tempEntry{1,1}{j,1};
                                    end                               
                                end                            
                            catch
                            end
                        end
                    end
                    chunkResultTable = chunkResultTable(1:entryCounter, 2:22);
                    toc
                    
                    tic
                    table1 = cell2table(chunkResultTable);
                    toc
                    
                    tic
                    %Engine Speed
                    index = ismember(table1.chunkResultTable2, 'm_IVS_AU_VAPIClient_EngineSpeed');
                    vars  = {'chunkResultTable1', 'chunkResultTable4'};
                    T_Temp1 = table1(index, vars);
                    T_Temp1.Properties.VariableNames = {'Timestamp' 'EngineSpeed'};
                    [C,ia,ic] = unique(T_Temp1(:,1), 'stable');
                    T_Temp1 = T_Temp1(ia, :);
                    toc
                    
                    tic
                    %Vehicle Speed
                    index = ismember(table1.chunkResultTable2, 'm_IVS_AU_VAPIClient_VehicleSpeed');
                    vars  = {'chunkResultTable1', 'chunkResultTable4'};
                    T_Temp2 = table1(index, vars);
                    T_Temp2.Properties.VariableNames = {'Timestamp' 'VehicleSpeed'};
                    [C,ia,ic] = unique(T_Temp2(:,1), 'stable');
                    T_Temp2 = T_Temp2(ia, :);
                    toc
                    tic
                    T_Temp1 = outerjoin(T_Temp1, T_Temp2, 'MergeKeys',true);
                    toc
                    
                    tic
                    %Positiion
                    index = ismember(table1.chunkResultTable2, 'm_IVS_AU_VAPIClient_SimTD_FilteredPosition');
                    vars  = {'chunkResultTable1', 'chunkResultTable4', 'chunkResultTable6', 'chunkResultTable10',...
                             'chunkResultTable12', 'chunkResultTable20'};
                    T_Temp2 = table1(index, vars);
                    T_Temp2.Properties.VariableNames = {'Timestamp' 'Lat', 'Lon', 'Heading', 'Altitude', 'VehicleSpeedGPS'};
                    [C,ia,ic] = unique(T_Temp2(:,1), 'stable');
                    T_Temp2 = T_Temp2(ia, :);
                    toc
                    tic
                    T_Temp1 = outerjoin(T_Temp1, T_Temp2, 'MergeKeys',true);
                    toc                    
                    
                    
                    %LongitudinalAcceleration
                    index = ismember(table1.chunkResultTable2, 'm_IVS_AU_VAPIClient_LongitudinalAcceleration');
                    vars  = {'chunkResultTable1', 'chunkResultTable4'};
                    T_Temp2 = table1(index, vars);
                    T_Temp2.Properties.VariableNames = {'Timestamp' 'LongAcc'};
                    [C,ia,ic] = unique(T_Temp2(:,1), 'stable');
                    T_Temp2 = T_Temp2(ia, :);
                    toc
                    tic
                    T_Temp1 = outerjoin(T_Temp1, T_Temp2, 'MergeKeys',true);
                    toc                    
                    
                    
                    % LateralAcceleration
                    index = ismember(table1.chunkResultTable2, 'm_IVS_AU_VAPIClient_LateralAcceleration');
                    vars  = {'chunkResultTable1', 'chunkResultTable4'};
                    T_Temp2 = table1(index, vars);
                    T_Temp2.Properties.VariableNames = {'Timestamp' 'LatAcc'};
                    [C,ia,ic] = unique(T_Temp2(:,1), 'stable');
                    T_Temp2 = T_Temp2(ia, :);
                    toc
                    tic
                    T_Temp1 = outerjoin(T_Temp1, T_Temp2, 'MergeKeys',true);
                    toc                    
                    
                    
                    %SteeringWheelAngle
                    index = ismember(table1.chunkResultTable2, 'm_IVS_AU_VAPIClient_SteeringWheelAngle');
                    vars  = {'chunkResultTable1', 'chunkResultTable4'};
                    T_Temp2 = table1(index, vars);
                    T_Temp2.Properties.VariableNames = {'Timestamp' 'SteeringWheelAngle'};
                    [C,ia,ic] = unique(T_Temp2(:,1), 'stable');
                    T_Temp2 = T_Temp2(ia, :);
                    toc
                    tic
                    T_Temp1 = outerjoin(T_Temp1, T_Temp2, 'MergeKeys',true);
                    toc                    
                    
                    
                    %ObjectDetection
                    index = ismember(table1.chunkResultTable2, 'm_IVS_AU_VAPIClient_SimTD_ObjectDetection');
                    vars  = {'chunkResultTable1', 'chunkResultTable4', 'chunkResultTable6', 'chunkResultTable8'};
                    T_Temp2 = table1(index, vars);
                    T_Temp2.Properties.VariableNames = {'Timestamp' 'ObjectDeteced', 'ObjectRelSpeed', 'ObjectDist'};
                    [C,ia,ic] = unique(T_Temp2(:,1), 'stable');
                    T_Temp2 = T_Temp2(ia, :);
                    toc
                    tic
                    T_Temp1 = outerjoin(T_Temp1, T_Temp2, 'MergeKeys',true);
                    toc                    
                    
                    
                    %PedalForce
                    index = ismember(table1.chunkResultTable2, 'm_IVS_AU_VAPIClient_PedalForce');
                    vars  = {'chunkResultTable1', 'chunkResultTable4'};
                    T_Temp2 = table1(index, vars);
                    T_Temp2.Properties.VariableNames = {'Timestamp' 'PedalForce'};
                    [C,ia,ic] = unique(T_Temp2(:,1), 'stable');
                    T_Temp2 = T_Temp2(ia, :);
                    toc
                    tic
                    T_Temp1 = outerjoin(T_Temp1, T_Temp2, 'MergeKeys',true);
                    toc                    
                    
                    
                    %TurnSignalLights_FrontLeft
                    index = ismember(table1.chunkResultTable2, 'm_IVS_AU_VAPIClient_TurnSignalLights_FrontLeft');
                    vars  = {'chunkResultTable1', 'chunkResultTable4'};
                    T_Temp2 = table1(index, vars);
                    T_Temp2.Properties.VariableNames = {'Timestamp' 'TurnSignalLights_FL'};
                    [C,ia,ic] = unique(T_Temp2(:,1), 'stable');
                    T_Temp2 = T_Temp2(ia, :);
                    toc
                    tic
                    T_Temp1 = outerjoin(T_Temp1, T_Temp2, 'MergeKeys',true);
                    toc                    
                    
                    
                    %TurnSignalLights_FrontRight
                    index = ismember(table1.chunkResultTable2, 'm_IVS_AU_VAPIClient_TurnSignalLights_FrontRight');
                    vars  = {'chunkResultTable1', 'chunkResultTable4'};
                    T_Temp2 = table1(index, vars);
                    T_Temp2.Properties.VariableNames = {'Timestamp' 'TurnSignalLights_FR'};
                    [C,ia,ic] = unique(T_Temp2(:,1), 'stable');
                    T_Temp2 = T_Temp2(ia, :);
                    toc
                    tic
                    T_Temp1 = outerjoin(T_Temp1, T_Temp2, 'MergeKeys',true);
                    toc                    
                    
                    
                    %TurnSignalLights_RearLeft
                    index = ismember(table1.chunkResultTable2, 'm_IVS_AU_VAPIClient_TurnSignalLights_RearLeft');
                    vars  = {'chunkResultTable1', 'chunkResultTable4'};
                    T_Temp2 = table1(index, vars);
                    T_Temp2.Properties.VariableNames = {'Timestamp' 'TurnSignalLights_RL'};
                    [C,ia,ic] = unique(T_Temp2(:,1), 'stable');
                    T_Temp2 = T_Temp2(ia, :);
                    toc
                    tic
                    T_Temp1 = outerjoin(T_Temp1, T_Temp2, 'MergeKeys',true);
                    toc                    
                    
                    
                    %TurnSignalLights_RearRight
                    index = ismember(table1.chunkResultTable2, 'm_IVS_AU_VAPIClient_TurnSignalLights_RearRight');
                    vars  = {'chunkResultTable1', 'chunkResultTable4'};
                    T_Temp2 = table1(index, vars);
                    T_Temp2.Properties.VariableNames = {'Timestamp' 'TurnSignalLights_RR'};
                    [C,ia,ic] = unique(T_Temp2(:,1), 'stable');
                    T_Temp2 = T_Temp2(ia, :);
                    toc
                    tic
                    T_Temp1 = outerjoin(T_Temp1, T_Temp2, 'MergeKeys',true);
                    toc                    
                    
                    
                    %m_IVS_AU_VAPIClient_ClutchSwitchActuation
                    index = ismember(table1.chunkResultTable2, 'm_IVS_AU_VAPIClient_ClutchSwitchActuation');
                    vars  = {'chunkResultTable1', 'chunkResultTable4'};
                    T_Temp2 = table1(index, vars);
                    T_Temp2.Properties.VariableNames = {'Timestamp' 'ClutchSwitchActuation'};
                    [C,ia,ic] = unique(T_Temp2(:,1), 'stable');
                    T_Temp2 = T_Temp2(ia, :);
                    toc
                    tic
                    T_Temp1 = outerjoin(T_Temp1, T_Temp2, 'MergeKeys',true);
                    toc                    
                    
                    
                    %m_IVS_AU_VAPIClient_GearSelection
                    index = ismember(table1.chunkResultTable2, 'm_IVS_AU_VAPIClient_GearSelection');
                    vars  = {'chunkResultTable1', 'chunkResultTable4'};
                    T_Temp2 = table1(index, vars);
                    T_Temp2.Properties.VariableNames = {'Timestamp' 'GearSelection'};
                    [C,ia,ic] = unique(T_Temp2(:,1), 'stable');
                    T_Temp2 = T_Temp2(ia, :);
                    toc
                    tic
                    T_Temp1 = outerjoin(T_Temp1, T_Temp2, 'MergeKeys',true);
                    toc                    
                    
                    
                    %m_IVS_AU_VAPIClient_CurrentGear
                    index = ismember(table1.chunkResultTable2, 'm_IVS_AU_VAPIClient_CurrentGear');
                    vars  = {'chunkResultTable1', 'chunkResultTable4'};
                    T_Temp2 = table1(index, vars);
                    T_Temp2.Properties.VariableNames = {'Timestamp' 'CurrentGear'};
                    [C,ia,ic] = unique(T_Temp2(:,1), 'stable');
                    T_Temp2 = T_Temp2(ia, :);
                    toc
                    tic
                    T_Temp1 = outerjoin(T_Temp1, T_Temp2, 'MergeKeys',true);
                    toc                    
                    
                    
                    %m_IVS_AU_VAPIClient_SteeringWheelAngularVelocity
                    index = ismember(table1.chunkResultTable2, 'm_IVS_AU_VAPIClient_SteeringWheelAngularVelocity');
                    vars  = {'chunkResultTable1', 'chunkResultTable4'};
                    T_Temp2 = table1(index, vars);
                    T_Temp2.Properties.VariableNames = {'Timestamp' 'SteeringWheelAngularVelocity'};
                    [C,ia,ic] = unique(T_Temp2(:,1), 'stable');
                    T_Temp2 = T_Temp2(ia, :);
                    toc
                    tic
                    T_Temp1 = outerjoin(T_Temp1, T_Temp2, 'MergeKeys',true);
                    toc                    
                    
                    
                    %m_IVS_AU_VAPIClient_Odometer
                    index = ismember(table1.chunkResultTable2, 'm_IVS_AU_VAPIClient_Odometer');
                    vars  = {'chunkResultTable1', 'chunkResultTable4'};
                    T_Temp2 = table1(index, vars);
                    T_Temp2.Properties.VariableNames = {'Timestamp' 'Odometer'};
                    [C,ia,ic] = unique(T_Temp2(:,1), 'stable');
                    T_Temp2 = T_Temp2(ia, :);
                    toc
                    tic
                    T_Temp1 = outerjoin(T_Temp1, T_Temp2, 'MergeKeys',true);
                    toc                                  
                    
                    
                    %m_IVS_AU_VAPIClient_TripOdometer
                    index = ismember(table1.chunkResultTable2, 'm_IVS_AU_VAPIClient_TripOdometer');
                    vars  = {'chunkResultTable1', 'chunkResultTable4'};
                    T_Temp2 = table1(index, vars);
                    T_Temp2.Properties.VariableNames = {'Timestamp' 'TripOdometer'};
                    [C,ia,ic] = unique(T_Temp2(:,1), 'stable');
                    T_Temp2 = T_Temp2(ia, :);
                    toc
                    tic
                    T_Temp1 = outerjoin(T_Temp1, T_Temp2, 'MergeKeys',true);
                    toc                    
                    
                    
                    %m_IVS_AU_VAPIClient_BrakeActuation
                    index = ismember(table1.chunkResultTable2, 'm_IVS_AU_VAPIClient_BrakeActuation');
                    vars  = {'chunkResultTable1', 'chunkResultTable4'};
                    T_Temp2 = table1(index, vars);
                    T_Temp2.Properties.VariableNames = {'Timestamp' 'BrakeActuation'};
                    [C,ia,ic] = unique(T_Temp2(:,1), 'stable');
                    T_Temp2 = T_Temp2(ia, :);
                    toc
                    tic
                    T_Temp1 = outerjoin(T_Temp1, T_Temp2, 'MergeKeys',true);
                    toc                    
                    
                    
                    %m_IVS_AU_VAPIClient_CruiseControlSystemState
                    index = ismember(table1.chunkResultTable2, 'm_IVS_AU_VAPIClient_CruiseControlSystemState');
                    vars  = {'chunkResultTable1', 'chunkResultTable4'};
                    T_Temp2 = table1(index, vars);
                    T_Temp2.Properties.VariableNames = {'Timestamp' 'CruiseControlSystemState'};
                    [C,ia,ic] = unique(T_Temp2(:,1), 'stable');
                    T_Temp2 = T_Temp2(ia, :);
                    toc
                    tic
                    T_Temp1 = outerjoin(T_Temp1, T_Temp2, 'MergeKeys',true);
                    toc                    
                    
                    
                    %m_IVS_AU_VAPIClient_AntiLockBrakeSystem
                    index = ismember(table1.chunkResultTable2, 'm_IVS_AU_VAPIClient_AntiLockBrakeSystem');
                    vars  = {'chunkResultTable1', 'chunkResultTable4'};
                    T_Temp2 = table1(index, vars);
                    T_Temp2.Properties.VariableNames = {'Timestamp' 'AntiLockBrakeSystem'};
                    [C,ia,ic] = unique(T_Temp2(:,1), 'stable');
                    T_Temp2 = T_Temp2(ia, :);
                    toc
                    tic
                    T_Temp1 = outerjoin(T_Temp1, T_Temp2, 'MergeKeys',true);
                    toc                    
                    
                    
                    %m_IVS_AU_VAPIClient_ExteriorTemperature
                    index = ismember(table1.chunkResultTable2, 'm_IVS_AU_VAPIClient_ExteriorTemperature');
                    vars  = {'chunkResultTable1', 'chunkResultTable4'};
                    T_Temp2 = table1(index, vars);
                    T_Temp2.Properties.VariableNames = {'Timestamp' 'ExteriorTemperature'};
                    [C,ia,ic] = unique(T_Temp2(:,1), 'stable');
                    T_Temp2 = T_Temp2(ia, :);
                    toc
                    tic
                    T_Temp1 = outerjoin(T_Temp1, T_Temp2, 'MergeKeys',true);
                    toc                    
                    
                    
                    %m_IVS_AU_VAPIClient_HazardWarningSystem
                    index = ismember(table1.chunkResultTable2, 'm_IVS_AU_VAPIClient_HazardWarningSystem');
                    vars  = {'chunkResultTable1', 'chunkResultTable4'};
                    T_Temp2 = table1(index, vars);
                    T_Temp2.Properties.VariableNames = {'Timestamp' 'HazardWarningSystem'};
                    [C,ia,ic] = unique(T_Temp2(:,1), 'stable');
                    T_Temp2 = T_Temp2(ia, :);
                    toc
                    tic
                    T_Temp1 = outerjoin(T_Temp1, T_Temp2, 'MergeKeys',true);
                    toc                    
                    
                    
                    %m_IVS_AU_VAPIClient_FrontLights_DaytimeRunningLamp
                    index = ismember(table1.chunkResultTable2, 'm_IVS_AU_VAPIClient_FrontLights_DaytimeRunningLamp');
                    vars  = {'chunkResultTable1', 'chunkResultTable4'};
                    T_Temp2 = table1(index, vars);
                    T_Temp2.Properties.VariableNames = {'Timestamp' 'FrontLights_DaytimeRunningLamp'};
                    [C,ia,ic] = unique(T_Temp2(:,1), 'stable');
                    T_Temp2 = T_Temp2(ia, :);
                    toc
                    tic
                    T_Temp1 = outerjoin(T_Temp1, T_Temp2, 'MergeKeys',true);
                    toc                    
                    
                    
                    %m_IVS_AU_VAPIClient_FrontLights_LowBeam
                    index = ismember(table1.chunkResultTable2, 'm_IVS_AU_VAPIClient_FrontLights_LowBeam');
                    vars  = {'chunkResultTable1', 'chunkResultTable4'};
                    T_Temp2 = table1(index, vars);
                    T_Temp2.Properties.VariableNames = {'Timestamp' 'FrontLights_LowBeam'};
                    [C,ia,ic] = unique(T_Temp2(:,1), 'stable');
                    T_Temp2 = T_Temp2(ia, :);
                    toc
                    tic
                    T_Temp1 = outerjoin(T_Temp1, T_Temp2, 'MergeKeys',true);
                    toc                    
                    
                    
                    %m_IVS_AU_VAPIClient_FrontLights_HighBeam
                    index = ismember(table1.chunkResultTable2, 'm_IVS_AU_VAPIClient_FrontLights_HighBeam');
                    vars  = {'chunkResultTable1', 'chunkResultTable4'};
                    T_Temp2 = table1(index, vars);
                    T_Temp2.Properties.VariableNames = {'Timestamp' 'FrontLights_HighBeam'};
                    [C,ia,ic] = unique(T_Temp2(:,1), 'stable');
                    T_Temp2 = T_Temp2(ia, :);
                    toc
                    tic
                    T_Temp1 = outerjoin(T_Temp1, T_Temp2, 'MergeKeys',true);
                    toc                    
                    
                    
                    %m_IVS_AU_VAPIClient_FogLight
                    index = ismember(table1.chunkResultTable2, 'm_IVS_AU_VAPIClient_FogLight');
                    vars  = {'chunkResultTable1', 'chunkResultTable4'};
                    T_Temp2 = table1(index, vars);
                    T_Temp2.Properties.VariableNames = {'Timestamp' 'FogLight'};
                    [C,ia,ic] = unique(T_Temp2(:,1), 'stable');
                    T_Temp2 = T_Temp2(ia, :);
                    toc
                    tic
                    T_Temp1 = outerjoin(T_Temp1, T_Temp2, 'MergeKeys',true);
                    toc                    
                    
                    
                    %m_IVS_AU_VAPIClient_SimTD_EmergencyLighting
                    index = ismember(table1.chunkResultTable2, 'm_IVS_AU_VAPIClient_SimTD_EmergencyLighting');
                    vars  = {'chunkResultTable1', 'chunkResultTable4'};
                    T_Temp2 = table1(index, vars);
                    T_Temp2.Properties.VariableNames = {'Timestamp' 'm_IVS_AU_VAPIClient_SimTD_EmergencyLighting'};
                    [C,ia,ic] = unique(T_Temp2(:,1), 'stable');
                    T_Temp2 = T_Temp2(ia, :);
                    toc
                    tic
                    T_Temp1 = outerjoin(T_Temp1, T_Temp2, 'MergeKeys',true);
                    toc                    
                    
                    
                    %m_IVS_AU_VAPIClient_WiperSystem_Front
                    index = ismember(table1.chunkResultTable2, 'm_IVS_AU_VAPIClient_WiperSystem_Front');
                    vars  = {'chunkResultTable1', 'chunkResultTable4'};
                    T_Temp2 = table1(index, vars);
                    T_Temp2.Properties.VariableNames = {'Timestamp' 'WiperSystem_Front'};
                    [C,ia,ic] = unique(T_Temp2(:,1), 'stable');
                    T_Temp2 = T_Temp2(ia, :);
                    toc
                    tic
                    T_Temp1 = outerjoin(T_Temp1, T_Temp2, 'MergeKeys',true);
                    toc                    
                    
                    
                    %m_IVS_AU_VAPIClient_WiperSystem_Rear
                    index = ismember(table1.chunkResultTable2, 'm_IVS_AU_VAPIClient_WiperSystem_Rear');
                    vars  = {'chunkResultTable1', 'chunkResultTable4'};
                    T_Temp2 = table1(index, vars);
                    T_Temp2.Properties.VariableNames = {'Timestamp' 'WiperSystem_Rear'};
                    [C,ia,ic] = unique(T_Temp2(:,1), 'stable');
                    T_Temp2 = T_Temp2(ia, :);
                    toc
                    tic
                    T_Temp1 = outerjoin(T_Temp1, T_Temp2, 'MergeKeys',true);
                    toc
                                        
                    kWhile = kWhile + 1;
                end%while
            end%if-isEqual
        end%parfor-iFiles
    end%if-isDir
end%for-Untar

test = 1;




















