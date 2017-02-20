clear;

%filenameCurrent = 'ILOG_IVS506_2012-08-28-13-37-43-89.decoded.txt';
%filenameCurrent = 'ILOG_IVS005_2012-08-08-10-53-45-236.decoded.txt';
%filenameCurrent = 'ILOG_IVS023_2012-08-03-11-18-06-896.decoded.txt';
%filenameCurrent = 'ILOG_IVS025_2012-08-09-08-48-21-557.decoded.txt';
%filenameCurrent = 'ILOG_IVS322_2012-08-09-07-06-03-451.decoded.txt';
%filenameCurrent = 'ILOG_IVS355_2012-08-02-07-17-07-831.decoded.txt';
%filenameCurrent = 'ILOG_IVS355_2012-08-07-09-52-30-84.decoded.txt';
filenameCurrent = 'ILOG_IVS506_2012-08-28-13-37-43-89.decoded.txt';






fileID = fopen(filenameCurrent);
chunkSize = 1500000;
dataChunk = textscan(fileID, '%s', chunkSize, 'CommentStyle', '##', 'delimiter', ',');
dataChunk = dataChunk{1, 1};

checkWord = dataChunk{1, 1};

[sizeDataChunk, j1] = size(dataChunk);

dataCellArray = cell(ceil(sizeDataChunk / 5), 100);
                            
entryCounterI = 0;
entryCounterJ = 1;

startIndex = 1;
while(~strcmp(dataChunk{startIndex, 1}, checkWord))
    startIndex = startIndex + 1; 
end

dataChunk = dataChunk(startIndex:sizeDataChunk, : );   

enabled = 2;

tic
if(enabled == 1)
    iArray = 1;
    while(iArray < sizeDataChunk)
        compareElement = dataChunk{iArray, 1};
        if(strcmp(compareElement, 'm_IVS_AU_VAPIClient_EngineSpeed'))
            entryCounterI = entryCounterI + 1;
            dataCellArray{entryCounterI, 1} = dataChunk(iArray - 1, 1);
            dataCellArray{entryCounterI, 2} = dataChunk(iArray + 2, 1);
            iArray = iArray + 1;
        elseif(strcmp(compareElement, 'm_IVS_AU_VAPIClient_SimTD_FilteredPosition'))
            entryCounterI = entryCounterI + 1;
            dataCellArray{entryCounterI, 1} = dataChunk(iArray - 1, 1);
            dataCellArray{entryCounterI, 3} = dataChunk(iArray + 2, 1);
            dataCellArray{entryCounterI, 4} = dataChunk(iArray + 4, 1);
            dataCellArray{entryCounterI, 5} = dataChunk(iArray + 8, 1);
            dataCellArray{entryCounterI, 6} = dataChunk(iArray +10, 1);
            dataCellArray{entryCounterI, 7} = dataChunk(iArray +18, 1);
            iArray = iArray + 1;
        elseif(strcmp(compareElement, 'm_IVS_AU_VAPIClient_LongitudinalAcceleration'))
            
            iArray = iArray + 1;
        elseif(strcmp(compareElement, 'm_IVS_AU_HMI_HMIParameter'))
            
            iArray = iArray + 4;
        elseif(strcmp(compareElement(1, 1:2), 'm_'))
            
            iArray = iArray + 4;
        else
            iArray = iArray + 1;
        end
    end
end

parametersKeyword = 'm_IVS_AU_VA';
if(enabled == 2)
    for iArray = 1 : 1 : sizeDataChunk
        if(strcmp(dataChunk{iArray,1}, checkWord))% && strcmp(dataChunk{iArray+2,1}(1,1:11), 'm_IVS_AU_VA'))
            try
                keyword = dataChunk{iArray+2,1}(1,1:11);    %%%%%% CATCH SHORTER ONES
                if(strcmp(keyword, parametersKeyword))
                    entryCounterI = entryCounterI + 1;
                    entryCounterJ = 1;
                    dataCellArray{entryCounterI, entryCounterJ} = dataChunk(iArray, 1);
                else 

                end
            catch
                %didnt work
            end
            
            
            
        else
            entryCounterJ = entryCounterJ + 1;
            dataCellArray{entryCounterI, entryCounterJ} = dataChunk(iArray, 1);
        end
    end
end
toc






clearvars dataChunk;

dataCellArray = dataCellArray(1 : entryCounterI-1, 2 : 100);
                       
[sizeDataCellArray, j2] = size(dataCellArray);

tic
test = dataCellArray(:,2);
toc

tic
data = cell2table(dataCellArray);
toc

[C,ia,ic] = unique(data(:, 2));

[length, j2] = size(C);

C2 = zeros(length, 1);

C2T = table(C2);

CTOT = [C C2T];

j1 = 3;

count = {3}; %%%%%%%%%?????????????

for i1 = 1 : 1 : length
    while(~isempty(data{ia(i1), j1}{1,1}) && j1 < 98)
        count{1,1} = count{1,1} + 1;
        j1 = j1 + 1;
    end
    if(i1 == 161)
        check = 1
    end
    CTOT(i1, 2) = count;
    j1 = 3;
    count{1,1} = 3;
end

CTOT.Properties.VariableNames = {'keyword' 'misc'};

cd('C:\UNPACK');

save('table8.mat', 'CTOT');

clearvars dataCellArray;


tic

%Engine Speed
index = ismember(data.dataCellArray2, 'm_IVS_AU_VAPIClient_EngineSpeed');
vars = {'dataCellArray1', 'dataCellArray4'};
T_Temp1 = data(index, vars);
T_Temp1.Properties.VariableNames = {'Timestamp' 'EngineSpeed'};
[C,ia,ic] = unique(T_Temp1(:,1), 'stable');
T_Temp1 = T_Temp1(ia, :);

%Object Detection
index = ismember(data.dataCellArray2, 'm_IVS_AU_VAPIClient_SimTD_ObjectDetection');
vars = {'dataCellArray1', 'dataCellArray4', 'dataCellArray6', 'dataCellArray8'};
T_Temp2 = data(index, vars);
T_Temp2.Properties.VariableNames = {'Timestamp' 'Obj_detected' 'Obj_rel_speed' 'Obj_rel_dist'};
[C,ia,ic] = unique(T_Temp2(:,1), 'stable');
T_Temp2 = T_Temp2(ia, :);

%T_final = outerjoin(T_Temp1, T_Temp2, 'MergeKeys',true);
toc

 test = 3;


















