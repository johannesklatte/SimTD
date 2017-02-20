% Clear Workplace
clear;

[num,txt,raw] = xlsread('links_gps.xls');

autobahnNamesTable = table(linksLoad.A661);

[numberOfEntries, j1] = size(autobahnNamesTable);

autobahnNamesTableUnique = unique(autobahnNamesTable);

[numberOfNames, j2] = size(autobahnNamesTableUnique);

autobahnListCleaned = cell(2*numberOfEntries,3);
 
newEntry = 1;

for i1 = 1 : 1 : numberOfNames
    stringAutobahn_1 = table2array(autobahnNamesTableUnique(i1,:));
    for i2 = 1 : 1 : numberOfEntries
        stringAutobahn_2 = table2array(autobahnNamesTable(i2,:));
        if('A3 | E35       ' == stringAutobahn_2)     
        %if(stringAutobahn_1 == stringAutobahn_2)
            % NAME
            entry = table2cell(autobahnNamesTableUnique(i1, :));
            autobahnListCleaned(newEntry,1) = entry;
            
            % LONGITUDE 1
            testNum = linksLoad.x80x2C65696(i2, 2);
            
            
            entry = strcat(num2str(linksLoad.x80x2C65696(i2, 1)), '.', num2str(linksLoad.x80x2C65696(i2, 2)));
            entry = str2double(entry);
            if(entry > 8.46179)
                testNum = linksLoad.x80x2C65696(i2, 2);
                szopp = 1;   
            end
            entry = num2cell(entry);
           
            autobahnListCleaned(newEntry, 2) = entry;
            
            % LATITUDE 1
            entry = linksLoad.x500x2C1844(i2, :);
            entry = strrep(entry, ',', '.');
            entry = num2cell(str2double(entry));
            autobahnListCleaned(newEntry, 3) = entry;
            
            %
            newEntry = newEntry + 1;
            
            %NAME
            entry = table2cell(autobahnNamesTableUnique(i1, :));
            autobahnListCleaned(newEntry,1) = entry;
            
            % LONGITUDE 2
            entry = strcat(num2str(linksLoad.x80x2C65792(i2, 1)), '.', num2str(linksLoad.x80x2C65792(i2, 2)));
            entry = num2cell(str2double(entry));
            autobahnListCleaned(newEntry, 2) = entry;
            
            % LATITUDE 2
            entry = linksLoad.x500x2C1862(i2, :);
            entry = strrep(entry, ',', '.');
            entry = num2cell(str2double(entry));
            autobahnListCleaned(newEntry, 3) = entry;
            
            %
            newEntry = newEntry + 1;
        end
    end
end

autobahnTableCleaned = cell2table(autobahnListCleaned);
autobahnTableCleaned.Properties.VariableNames = {'Autobahnabschnitt', 'Longitude', 'Latitude'};

cd('C:\Users\Johannes_Work\Downloads\Studium\HIWI');

currentFolder = pwd;

saveFileName = 'AutobahnLiksTable.mat';
save(saveFileName, 'autobahnTableCleaned');






