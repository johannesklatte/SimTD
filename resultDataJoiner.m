%
clear all;
setenv('TEMP', 'D:\SimTD\temp');% TEMP for Windows
clear;

% Start parallel pool
numberOfCores = feature('numcores');


resultFolderPath = 'D:\SimTD\TEST\results';

resultFolderCleandedPath = 'D:\SimTD\TEST\results_joined';

cd(resultFolderPath);

resultFolderDirInfo = dir;

[ResultFolderDirInfoLength , j1] = size(resultFolderDirInfo);

for i = 1 : 1 : ResultFolderDirInfoLength
    if(strcmp(resultFolderDirInfo(i).name, '.') || strcmp(resultFolderDirInfo(i).name, '..' ))
        %NoFile      
    else
        resultSubFolderPath = strcat(resultFolderPath, '\', resultFolderDirInfo(i).name);
        cd(resultSubFolderPath);
        resultSubFolderDirInfo = dir;
        [ResultSubFolderDirInfoLength , j2] = size(resultSubFolderDirInfo);
        i2 = 1;
        while i2 <= ResultSubFolderDirInfoLength
            if(strcmp(resultSubFolderDirInfo(i2).name, '.') || strcmp(resultSubFolderDirInfo(i2).name, '..' ))
                %NoFile
                i2 = i2 +1;
            else 
                % check if file has already been joined
                currentDir = pwd;
                checkFileFolder = strcat(resultFolderCleandedPath, '\', resultFolderDirInfo(i).name); 
                cd(checkFileFolder);
                fileExists = exist(resultSubFolderDirInfo(i2).name, 'file') == 2;
                cd(pwd);
                if(~fileExists)
                    if(strcmp(resultSubFolderDirInfo(i2).name(end-4:end-4), 'a'))
                        loading_incomplete = 1;
                        T_filtered = [];
                        retryCounter = 0;
                        while(loading_incomplete)
                            try
                                memory
                                userview = memory
                                [userview systemview] = memory
                                T_filtered = load(resultSubFolderDirInfo(i2).name); %, 'T_filtered');
                                loading_incomplete = 0;
                            catch
                                loading_incomplete = 1;
                                retryCounter = retryCounter + 1
                                disp('RETRY:  "Error using load!!! Bad version or endian-key"')
                                pause(4)
                            end
                        end    
                        T_filtered = T_filtered.T_filtered;

                        %Formatting time
                        formatIn = 'yyyy-mm-dd HH:MM:SS:FFF';
                        tTimeVec = datevec(T_filtered.Timestamp, formatIn);
                        tTimeNum = datenum(T_filtered.Timestamp, formatIn);
                        baseline = tTimeNum(1,1);
                        tTimeNum = (tTimeNum - baseline) * 24 * 60 * 60;
                        timeVecFinal = array2table(tTimeVec, 'VariableNames',{'Year','Month','Day', 'Hours', 'Minutes', 'Seconds'});
                        timeNumFinal = array2table(tTimeNum, 'VariableNames',{'ElapsedTime'});

                        %Formatting rest
                        tic
                        tFormattedTable = T_filtered(:, 2:14);
                        func = @str2double;
                        tFormattedTable = varfun(func, tFormattedTable);
                        toc
                        tFormattedTable.Properties.VariableNames = {'EngineSpeed' 'VehicleSpeed' 'Lat' 'Lon' 'Heading' 'Altitude' ...
                            'VehicleSpeedGPS' 'LonAcc' 'LatAcc' 'SteeringWheelAngle' 'ObjectDetected' 'ObjectRelSpeed' 'ObjectDist'};

                        data = [timeNumFinal, timeVecFinal, tFormattedTable, T_filtered(:, 15:37)];

                        i2 = i2 + 1;
                        while(i2 <= ResultSubFolderDirInfoLength ...
                              && isletter(resultSubFolderDirInfo(i2).name(end-4:end-4)) ...
                              && ~(strcmp(resultSubFolderDirInfo(i2).name(end-4:end-4), 'a')))
                            %Data
                            loading_incomplete = 1;
                            retryCounter = 0;
                            while(loading_incomplete)
                                try
                                    T_filtered = load(resultSubFolderDirInfo(i2).name); %, 'T_filtered');
                                    loading_incomplete = 0;
                                catch
                                    loading_incomplete = 1;
                                    retryCounter = retryCounter + 1
                                    disp('RETRY:  "Error using load!!! Bad version or endian-key"')
                                end
                            end    
                            T_filtered = T_filtered.T_filtered;

                            %Formatting time
                            formatIn = 'yyyy-mm-dd HH:MM:SS:FFF';
                            tTimeVec = datevec(T_filtered.Timestamp, formatIn);
                            tTimeNum = datenum(T_filtered.Timestamp, formatIn);
                            %baseline = tTimeNum(1,1); continue to use 'old' baseline
                            tTimeNum = (tTimeNum - baseline) * 24 * 60 * 60;
                            timeVecFinal = array2table(tTimeVec, 'VariableNames',{'Year','Month','Day', 'Hours', 'Minutes', 'Seconds'});
                            timeNumFinal = array2table(tTimeNum, 'VariableNames',{'ElapsedTime'});

                            %Formatting rest
                            tic
                            tFormattedTable = T_filtered(:, 2:14);
                            func = @str2double;
                            tFormattedTable = varfun(func, tFormattedTable);
                            toc
                            tFormattedTable.Properties.VariableNames = {'EngineSpeed' 'VehicleSpeed' 'Lat' 'Lon' 'Heading' 'Altitude' ...
                                'VehicleSpeedGPS' 'LonAcc' 'LatAcc' 'SteeringWheelAngle' 'ObjectDetected' 'ObjectRelSpeed' 'ObjectDist'};
                            data_temp = [timeNumFinal, timeVecFinal, tFormattedTable,T_filtered(:, 15:37)];
                            [tFormattedTableSize j3] = size(tFormattedTable);
                            %empty last tables
                            if(tFormattedTableSize > 0)
                                data = vertcat(data, data_temp);
                            end
                            i2 = i2 + 1;
                        end
                        currentDir = pwd;
                        mkdir(resultFolderCleandedPath, resultFolderDirInfo(i).name);
                        resultFolderCleaned = strcat(resultFolderCleandedPath, '\', resultFolderDirInfo(i).name);
                        cd(resultFolderCleaned);
                        saveFilename = strcat(resultSubFolderDirInfo(i2-1).name(1 : end-6), '.mat');
                        save(saveFilename, 'data');
                        cd(currentDir);
                    else
                        %Only one table to clean
                        loading_incomplete = 1;
                        retryCounter = 0;
                        while(loading_incomplete)
                            try
                                T_filtered = load(resultSubFolderDirInfo(i2).name); %, 'T_filtered');
                                loading_incomplete = 0;
                            catch
                                loading_incomplete = 1;
                                retryCounter = retryCounter + 1
                                disp('RETRY:  "Error using load!!! Bad version or endian-key"')
                            end
                        end    
                        T_filtered = T_filtered.T_filtered;

                        %Formatting time
                        formatIn = 'yyyy-mm-dd HH:MM:SS:FFF';
                        tTimeVec = datevec(T_filtered.Timestamp, formatIn);
                        tTimeNum = datenum(T_filtered.Timestamp, formatIn);
                        baseline = tTimeNum(1,1);
                        tTimeNum = (tTimeNum - baseline) * 24 * 60 * 60;
                        timeVecFinal = array2table(tTimeVec, 'VariableNames',{'Year','Month','Day', 'Hours', 'Minutes', 'Seconds'});
                        timeNumFinal = array2table(tTimeNum, 'VariableNames',{'ElapsedTime'});

                        %Formatting rest
                        tic
                        tFormattedTable = T_filtered(:, 2:14);
                        func = @str2double;
                        tFormattedTable = varfun(func, tFormattedTable);
                        toc
                        tFormattedTable.Properties.VariableNames = {'EngineSpeed' 'VehicleSpeed' 'Lat' 'Lon' 'Heading' 'Altitude' ...
                            'VehicleSpeedGPS' 'LonAcc' 'LatAcc' 'SteeringWheelAngle' 'ObjectDetected' 'ObjectRelSpeed' 'ObjectDist'};

                        data = [timeNumFinal, timeVecFinal, tFormattedTable,T_filtered(:, 15:37)];

                        %save cleaned / edited data 
                        currentDir = pwd;
                        mkdir(resultFolderCleandedPath, resultFolderDirInfo(i).name);
                        resultFolderCleaned = strcat(resultFolderCleandedPath, '\', resultFolderDirInfo(i).name);
                        cd(resultFolderCleaned);
                        saveFilename = strcat(resultSubFolderDirInfo(i2).name(:)); %may need editing
                        save(saveFilename, 'data');
                        cd(currentDir);
                        i2 = i2 + 1;
                    end
                else
                    % file has already been joined 
                    i2 = i2 + 1;
                end
            end           
        end
    end
end







