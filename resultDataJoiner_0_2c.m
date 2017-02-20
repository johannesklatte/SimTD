%
clear all;
setenv('TEMP', 'C:\Temp');% TEMP for Windows
clear;

% Start parallel pool
numberOfCores = feature('numcores');


resultFolderPath = 'C:\Users\Johannes_Work\Downloads\Studium\HIWI\TEST\RESULTS';

resultFolderCleandedPath = 'C:\Users\Johannes_Work\Downloads\Studium\HIWI\TEST\RESULTS_JOINED';

cd(resultFolderPath);

resultFolderDirInfo = dir;

[ResultFolderDirInfoLength , j1] = size(resultFolderDirInfo);

for i = 1 : 1 : ResultFolderDirInfoLength
    if(strcmp(resultFolderDirInfo(i).name, '.') || strcmp(resultFolderDirInfo(i).name, '..' ))
        %do nothing       
    else
        resultSubFolderPath = strcat(resultFolderPath, '\', resultFolderDirInfo(i).name);
        cd(resultSubFolderPath);
        resultSubFolderDirInfo = dir;
        [ResultSubFolderDirInfoLength , j2] = size(resultSubFolderDirInfo);
        i2 = 1;
        while i2 <= ResultSubFolderDirInfoLength
            if(strcmp(resultSubFolderDirInfo(i2).name, '.') || strcmp(resultSubFolderDirInfo(i2).name, '..' ))
                %do nothing
                i2 = i2 +1;
            else 
                if(strcmp(resultSubFolderDirInfo(i2).name(end-4:end-4), 'a'))
                    T_filtered = load(resultSubFolderDirInfo(i2).name, 'T_filtered');
                    T_filtered = T_filtered.T_filtered;
                    tic
                    T_Temp = T_filtered.Timestamp;
                    formatIn = 'yyyy-mm-dd HH:MM:SS:FFF';
                    T_Time = datevec(T_Temp,formatIn);
                    T_Time = array2table(T_Time, 'VariableNames',{'Year','Month','Day', 'Hours', 'Minutes', 'Seconds'});
                    T_Time_Elapsed =  datenum(T_Temp, formatIn);
                    baseline = T_Time_Elapsed(1,1);
                    T_Time_Elapsed = (T_Time_Elapsed - baseline) * 24 * 60 * 60; 
                    T_Time_Elapsed = array2table(T_Time_Elapsed, 'VariableNames', {'Elapsed_time'});
                    T_data = T_filtered{:,2:14};
                    T_data = str2double(T_data);
                    T_data = array2table(T_data, 'VariableNames',{'EngineSpeed', 'VehicleSpeed', 'Lat', 'Lon', ...
                        'Heading', 'Altitude', 'VehicleSpeedGPS', 'LongAcc', 'LatAcc', ...
                        'SteeringWheelAngle', 'ObjectDeteced', 'ObjectRelSpeed', 'ObjectDist'});
                    T_final = [T_Time, T_Time_Elapsed, T_data, T_filtered(:,15:37)]; 
                    
                    i2 = i2 + 1;
                    while(i2 <= ResultSubFolderDirInfoLength ...
                          && isletter(resultSubFolderDirInfo(i2).name(end-4:end-4)) ...
                          && ~(strcmp(resultSubFolderDirInfo(i2).name(end-4:end-4), 'a')))
                        TempTable = load(resultSubFolderDirInfo(i2).name, 'T_filtered');
                        TempTable = TempTable.T_filtered;
                        [TempTable2Size j3] = size(TempTable);
                      %empty last tables
                        if(TempTable2Size > 0)
                            T_filtered = vertcat(T_filtered, TempTable);
                        end
                        i2 = i2 + 1;
                    end
                    currentDir = pwd;
                    mkdir(resultFolderCleandedPath, resultFolderDirInfo(i).name);
                    resultFolderCleaned = strcat(resultFolderCleandedPath, '\', resultFolderDirInfo(i).name);
                    cd(resultFolderCleaned);
                    saveFilename = strcat(resultSubFolderDirInfo(i2-1).name(1 : end-6), '.mat');
                    save(saveFilename, 'T_filtered');
                    cd(currentDir);
                else
                    %copy file to new folder
                    currentDir = pwd;
                    mkdir(resultFolderCleandedPath, resultFolderDirInfo(i).name);
                    resultFolderCleaned = strcat(resultFolderCleandedPath, '\', resultFolderDirInfo(i).name);
                    %cd(resultFolderCleaned);
                    copyfile(resultSubFolderDirInfo(i2).name, resultFolderCleaned)
                    cd(currentDir);
                    i2 = i2 + 1;
                end
            end           
        end
    end
end







