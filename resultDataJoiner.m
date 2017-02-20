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
        for i2 = 1 : 1 : ResultSubFolderDirInfoLength
            if(strcmp(resultSubFolderDirInfo(i2).name, '.') || strcmp(resultSubFolderDirInfo(i2).name, '..' ))
                %do nothing       
            else 
                if(strcmp(resultSubFolderDirInfo(i2).name(end-4:end-4), 'a'))
                    currrDIRR = pwd;
                    TempTable1 = load(resultSubFolderDirInfo(i2).name, 'T_filtered');
                    TempTable1 = TempTable1.T_filtered;
                    i2Temp = i2 + 1;
                    while(i2Temp < ResultSubFolderDirInfoLength ...
                          && isletter(resultSubFolderDirInfo(i2Temp).name(end-4:end-4)) ...
                          && ~(strcmp(resultSubFolderDirInfo(i2Temp).name(end-4:end-4), 'a')))
                        TempTable2 = load(resultSubFolderDirInfo(i2Temp).name, 'T_filtered');
                        TempTable2 = TempTable2.T_filtered;
                        TempTable1 = vertcat(TempTable1, TempTable2);
                        i2Temp = i2Temp + 1;
                    end
                    currentDir = pwd;
                    mkdir(resultFolderCleandedPath, resultFolderDirInfo(i).name);
                    resultFolderCleaned = strcat(resultFolderCleandedPath, '\', resultFolderDirInfo(i).name);
                    cd(resultFolderCleaned);
                    saveFilename = strcat(resultSubFolderDirInfo(i2).name(1 : end-6), '.mat');
                    save(saveFilename, 'TempTable1');
                    cd(currentDir);
                else
                    %do nothing
                end
            end           
        end
    end
end





msg = done;