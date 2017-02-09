%
clear all;
setenv('TEMP', 'C:\Temp');% TEMP for Windows
clear;

% Start parallel pool
numberOfCores = feature('numcores');


resultFolderPath = 'D:\SimTD\results';

resultFolderCleandedPath = 'D:\SimTD\results_joined';

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
                    %tic
                    %t1 =  T_filtered(:,2:5);
                    %func = @str2double;
                    %t2 = varfun(func, t1);
                    %toc
                    
                    tic
                    parfor iCore = 1 : 1 : 4
                        T_inner = T_filtered;
                        switch i 
                            case 1
                                t1 =  T_inner(:,2);
                                func = @str2double;
                                t2 = varfun(func, t1);
                                
                            case 2
                                t1 =  T_inner(:,3);
                                func = @str2double;
                                t2 = varfun(func, t1);
                                
                            case 3
                                t1 =  T_inner(:,4);
                                func = @str2double;
                                t2 = varfun(func, t1);
                                
                            otherwise
                                t1 =  T_inner(:,5);
                                func = @str2double;
                                t2 = varfun(func, t1);
                        
                        end
                    end
                    toc
                    
                    
                    
                    
                    
                    testTime = T_filtered.Timestamp;
                    formatIn = 'dd-mmm-yyyy HH:MM:SS:FFF';
                    testTime = datenum(testTime, formatIn);
                    baseline = testTime(1,1);
                    testTime = (testTime - baseline) * 24 * 60 * 60;
                    toc
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







