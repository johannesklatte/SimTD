%
clear all;
setenv('TEMP', 'C:\Temp');% TEMP for Windows
clear;


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







