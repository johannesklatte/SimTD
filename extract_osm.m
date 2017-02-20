clear;

fileID = fopen('highways_germay.xml');
dataChunk = textscan(fileID, '%s');

dataChunk = dataChunk{1, 1};

[sizeDataChunk, j1] = size(dataChunk);

filteredResults = zeros(sizeDataChunk, 5);

entryCounter = 0;
LocalCounter = 0;

offset = 0.002;

threshold = 0.05;

LATOld = 0.0;
LONOld = 0.0;

first = 1;

LocalData = cell(35, 11);

totalCount = 0;

highwayData = cell(200000,1);

for i = 1 : 1 : sizeDataChunk
    if(strcmp(dataChunk(i, 1), '<node'))
        %ID
        tempString = strrep(dataChunk{i+1, 1}, 'id="', '');
        tempString = strrep(tempString, '"', '');
        IDString   = str2double(tempString);
        
        %LAT
        tempString = strrep(dataChunk{i+2, 1}, 'lat="', '');
        tempString = strrep(tempString, '"', '');
        LATnew = str2double(tempString);
          
        %LON
        tempString = strrep(dataChunk{i+3, 1}, 'lon="', '');
        tempString = strrep(tempString, '"', '');
        LONnew = str2double(tempString);
        
        
        
        if(abs(LATnew-LATOld)<threshold && abs(LONnew-LONOld)<threshold && LocalCounter < 31)
           LocalCounter = LocalCounter + 1;
           LocalData{LocalCounter,2} = LATnew-offset;
           LocalData{LocalCounter,3} = LONnew-offset;
           LocalData{LocalCounter,4} = LATnew+offset;
           LocalData{LocalCounter,5} = LONnew-offset;
           LocalData{LocalCounter,6} = LATnew-offset;
           LocalData{LocalCounter,7} = LONnew+offset;
           LocalData{LocalCounter,8} = LATnew+offset;
           LocalData{LocalCounter,9} = LONnew+offset;
           LATOld = LATnew;
           LONOld = LONnew;
           
        else
            if(first==1)
                first = 0;
                LocalCounter = LocalCounter + 1;
                LocalData{LocalCounter,2} = LATnew-offset;
                LocalData{LocalCounter,3} = LONnew-offset;
                LocalData{LocalCounter,4} = LATnew+offset;
                LocalData{LocalCounter,5} = LONnew-offset;
                LocalData{LocalCounter,6} = LATnew-offset;
                LocalData{LocalCounter,7} = LONnew+offset;
                LocalData{LocalCounter,8} = LATnew+offset;
               LocalData{LocalCounter,9} = LONnew+offset;
                LATOld = LATnew;
                LONOld = LONnew;
            else
                entryCounter = entryCounter + 1;
                LocalData{1,1} = min(cell2mat(LocalData(1:LocalCounter,2))); %minX
                LocalData{2,1} = min(cell2mat(LocalData(1:LocalCounter,3))); %minY
                LocalData{3,1} = max(cell2mat(LocalData(1:LocalCounter,2))); %maxX
                LocalData{4,1} = max(cell2mat(LocalData(1:LocalCounter,3))); %maxY
                LocalCounter = max(5, LocalCounter);
                highwayData{entryCounter,1} = LocalData(1:LocalCounter,:);
                LATOld = LATnew;
                LONOld = LONnew;
                                
                LocalCounter = 0;
                LocalCounter = LocalCounter + 1;
                LocalData = cell(35, 11);
                LocalData{LocalCounter,2} = LATnew-offset;
               LocalData{LocalCounter,3} = LONnew-offset;
               LocalData{LocalCounter,4} = LATnew+offset;
               LocalData{LocalCounter,5} = LONnew-offset;
               LocalData{LocalCounter,6} = LATnew-offset;
               LocalData{LocalCounter,7} = LONnew+offset;
               LocalData{LocalCounter,8} = LATnew+offset;
               LocalData{LocalCounter,9} = LONnew+offset;
                totalCount = totalCount + 1;
            end
        end
    end
    if(i == sizeDataChunk-1)
        entryCounter = entryCounter + 1;
      	LocalData{1,1} = min(cell2mat(LocalData(1:LocalCounter,2))); %minX
      	LocalData{2,1} = min(cell2mat(LocalData(1:LocalCounter,3))); %minY
     	LocalData{3,1} = max(cell2mat(LocalData(1:LocalCounter,2))); %maxX
      	LocalData{4,1} = max(cell2mat(LocalData(1:LocalCounter,3))); %maxY
       	LocalCounter = max(5, LocalCounter);
      	highwayData{entryCounter,1} = LocalData(1:LocalCounter,:);
        totalCount = totalCount + 1;
    end
end

highwayData = highwayData(1:totalCount, 1);

for i = 1 : 1 : totalCount
    xNormal = cell2mat(highwayData{i,1}(:,2));
    xNormal = xNormal + offset;
    x1 = cell2mat(highwayData{i,1}(:,2));
    x2 = cell2mat(highwayData{i,1}(:,4));
    x3 = cell2mat(highwayData{i,1}(:,6));
    x4 = cell2mat(highwayData{i,1}(:,8));
    
    yNormal = cell2mat(highwayData{i,1}(:,3));
    yNormal = yNormal + offset;
    y1 = cell2mat(highwayData{i,1}(:,3));
    y2 = cell2mat(highwayData{i,1}(:,5));
    y3 = cell2mat(highwayData{i,1}(:,7));
    y4 = cell2mat(highwayData{i,1}(:,9));
    x = vertcat(x1,x2,x3,x4);
    y = vertcat(y1,y2,y3,y4);
    
    k = boundary(x, y, 0.30);
    xx = x(k);
    [lengthXX, jXX] = size(xx);
    yy = y(k);
    [lengthYY, jYY] = size(yy);
    
    %fig = figure;
    %plot(yNormal, xNormal, '.b', 'MarkerSize', 20)
    %plot_google_map
    %plot(y, x, '.r', 'MarkerSize', 20)
    %plot(yy, xx, '.g', 'MarkerSize', 20)
    
    %plot(yy, xx, 'b-');
    
    highwayData{i,1}(1:lengthXX, 10) = num2cell(xx);
    highwayData{i,1}(1:lengthYY, 11) = num2cell(yy);  
end

saveFilename = 'highwaysGermanyPieces.mat';
save(saveFilename, 'highwayData');






filteredResults = filteredResults(1:entryCounter, 1:5);

filteredResultsTable = array2table(filteredResults);

highwayNames = cell(entryCounter, 1);

[highwayNames{:}] = deal('unknown');

highwayNamesTable = cell2table(highwayNames);

filteredResultsTableFinal = [filteredResultsTable highwayNamesTable];

filteredResultsTableFinal.Properties.VariableNames = {'ID' 'LAT_under' 'LON_under' 'LAT_over' 'LON_over' 'Highway_Name'};

tic
rows1 = ismember(filteredResultsTableFinal.Highway_Name, 'unknown');
toc

tic 
rows2 = filteredResultsTableFinal.ID<122464;
toc

tic
rows3 = filteredResultsTableFinal.LAT_over<53.15;
toc

tic
rowFinal = or(rows1, rows2);
toc

finale = cell(5,30);

test321 = filteredResultsTableFinal.ID(rows3, 1); 


test = 10;















