% Clear Workplace
clear;

[num,txt,raw] = xlsread('links_gps.xls');

autobahnName = raw(:,5);

autobahnName(cellfun(@(autobahnName) any(isnan(autobahnName)),autobahnName)) = [];

autobahnNamesUnique = unique(autobahnName);

[numberOfEntries, j1] = size(autobahnName);

[numberOfNames, j2] = size(autobahnNamesUnique);

tempcell = cell(numberOfEntries, 5);

tempcell(:,1) = autobahnName;

tempcell(:,2) = raw(1:numberOfEntries, 6);

tempcell(:,3) = raw(1:numberOfEntries, 7);

tempcell(:,4) = raw(1:numberOfEntries, 8);

tempcell(:,5) = raw(1:numberOfEntries, 9);

cleanedAutobahnTable = cell2table(tempcell);

cleanedAutobahnTable.Properties.VariableNames = {'Autobahnname' 'Longitude_start' 'Latitude_start' ...
    'Longitude_end' 'Latitude_end'};

cd('C:\Users\Johannes_Work\Downloads\Studium\HIWI');

currentFolder = pwd;

saveFileName = 'AutobahnLiksTable.mat';
save(saveFileName, 'cleanedAutobahnTable');



