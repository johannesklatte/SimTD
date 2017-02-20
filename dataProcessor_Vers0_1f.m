% Clear Workplace
clear;

%resultsFolderName = uigetdir('C:\', 'Select folder where filtered data has been saved in');
resultsFolderName = 'C:\Users\Johannes_Work\Downloads\Studium\HIWI\RESULTS\2012-07-25';
cd(resultsFolderName);
MyDirInfo = dir('*IVS*');
[length, j1] = size(MyDirInfo);
minLat = 200.0;
maxLat = 0.0;
minLon = 200.0;
maxLon = 0.0;

for i = 1 : 1 : length
    currentFileName = MyDirInfo(i).name;
    temp = load(currentFileName);
    filteredData = temp.filteredTable;
    lat = filteredData(:, 12);
    lon = filteredData(:, 13);
    
    lat = table2array(lat);
    lon = table2array(lon);
    
    % Convert to double and remove NaN entries from lat and lon
    lat = cell2mat(lat);
    lon = cell2mat(lon);
    
    %Remove '0' entries from lat and lon
    lat = lat(any(lat, 2),:);
    lon = lon(any(lon, 2),:);
    
    [lengthLat, j1] = size(lat);
    [lengthLon, j2] = size(lon);
    
    length = min([lengthLat lengthLon]);
    
    lat = lat(1:length, 1);
    lon = lon(1:length, 1);
    
    % Save GPS data
    gpsData = horzcat(lat, lon);
    saveFileNameTemp = strsplit(currentFileName, '.mat');
    saveFileName = saveFileNameTemp{1, 1};
    saveFileNameGPS = strcat(saveFileName, '_GPSData');
    %save(saveFileNameGPS, 'gpsData');
    
    % Calculate and Save convex hull (polygon)
    % boundary
    try
        driveLine = line(lon, lat);
        saveFileNameLine = strcat(saveFileName, '_Line');
        %save(saveFileNameLine, 'driveLine');
        %patch(lon, lat, 'red');
    catch   
    end
    
    try
        compactBoundary = boundary(lat, lon, 1.0);
        saveFileNameCompactBoundary = strcat(saveFileName, '_CompactBoundary');
        %save(saveFileNameCompactBoundary, 'compactBoundary');
        plot(lon(compactBoundary), lat(compactBoundary), 'r-');
    catch
    end
    fig = figure;
    plot(gpsData(:,2),gpsData(:,1), '.r', 'MarkerSize', 20)
    plot_google_map
    
    a= 1;
     
end