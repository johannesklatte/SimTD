% Clear Workplace
clear;

cd('C:\Users\Johannes_Work\Downloads\Studium\HIWI');

autobahnTable = open('AutobahnLiksTable.mat');

names = table2array(autobahnTable.cleanedAutobahnTable(:,1));

[length, j1] = size(names);

gpsData = table2array(autobahnTable.cleanedAutobahnTable(:,2:5));

gpsResults = {};

entryCounter = 1;

for i = 1 : 1 : length
    if(strcmp(names(i,1), 'A3 | E35'))
        gpsResults{entryCounter,1} = gpsData(i, 1);
        gpsResults{entryCounter,2} = gpsData(i, 2);
        entryCounter = entryCounter + 1;
        
        gpsResults{entryCounter,1} = gpsData(i, 3);
        gpsResults{entryCounter,2} = gpsData(i, 4);
        entryCounter = entryCounter + 1;
    else
        
    end
end

[length2, j2] = size(gpsResults);

gpsDataResults = zeros(length2,2);

for i2 = 1 : 1 : length2
    gpsDataResults(i2,1) = gpsResults{i2,1};
    gpsDataResults(i2,2) = gpsResults{i2,2};
end

fig = figure;
plot(gpsDataResults(:,1),gpsDataResults(:,2), '.r', 'MarkerSize', 20)
plot_google_map

lon = gpsDataResults(:,1);

lat = gpsDataResults(:,2);

% offset set to +/-30m = 0.000027° 
offset = 0.001075;

lonExtended = zeros(2*length2, 1);
lonExtended(1,1) = lon(1,1) + offset; 
lonExtended(2,1) = lon(1,1) - offset;

latExtended = zeros(2*length2, 1);
latExtended(1,1) = lat(1,1) + offset; 
latExtended(2,1) = lat(1,1) - offset;


for i = 1 : 1 : length2-1
    %lon
    lonExtended(i*2+1,1) = lon(i+1) + offset;
    lonExtended(i*2+2,1) = lon(i+1) - offset;
    %lat
    latExtended(i*2+1,1) = lat(i+1) + offset;
    latExtended(i*2+2,1) = lat(i+1) - offset;
end


%fig = figure;

plot(lonExtended(:,1),latExtended(:,1), '.y', 'MarkerSize', 20)

compactBoundary = boundary(lonExtended, latExtended, 1);
plot(lonExtended(compactBoundary), latExtended(compactBoundary), 'b-');




a = 4;