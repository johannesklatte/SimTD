% Clear Workplace
clear;

%resultsFolderName = uigetdir('C:\', 'Select folder where filtered data has been saved in');
resultsFolderName = 'C:\Users\Johannes_Work\Downloads\Studium\HIWI\RESULTS';

% load gps autobahn data
cd('C:\Users\Johannes_Work\Downloads\Studium\HIWI');
MyDirInfo = dir('*_cut.xml');
[length, j1] = size(MyDirInfo);

currentFolder = pwd

matFile = load('ILOG_IVS023_2012-08-02-09-18-31-57_GPSData');

% Autobahn coverage, read gpx-xml files
lat = zeros(0);
lon = zeros(0);
for i = 1 : 1 : 1 %length
	% Get Filename
	filename = MyDirInfo(i).name;
	% Read xml file
	x_doc = xmlread(filename);
	x_root = x_doc.getFirstChild;
	trkpt_nodes = x_root.getElementsByTagName('trkpt'); 
	% Get lat / lon data from xml file
	latTemp = zeros(trkpt_nodes.getLength,1);
	lonTemp = zeros(trkpt_nodes.getLength,1); 
	for i1 = 1 : 1 : trkpt_nodes.getLength-1
        trkpt_element = trkpt_nodes.item(i1);
    	latTemp(i1, 1) = str2double(trkpt_element.getAttribute('lat'));
    	lonTemp(i1, 1) = str2double(trkpt_element.getAttribute('lon'));
    end
	lat = vertcat(lat, latTemp);
	lon = vertcat(lon, lonTemp);
end

%Remove NaN and '0' entries from lat and lon
lat = lat(~any(isnan(lat), 2),:);
lon = lon(~any(isnan(lon), 2),:);
lat = lat(any(lat, 2),:);
lon = lon(any(lon, 2),:);

% plot Autobahn coverage

%lat = lat(3:10,1);
%lon = lon(3:10,1);

%create surrounding point tube

[lengthLat, j2] = size(lat);
latExtended = zeros(lengthLat*3, 1);
lonExtended = zeros(lengthLat*3, 1);

% offset set to +/-30m = 0.000027° 
offset = 0.000027;
latExtended(1,1) = lat(1,1);
latExtended(2,1) = lat(1,1) + offset; 
latExtended(3,1) = lat(1,1) - offset;

lonExtended(1,1) = lon(1,1);
lonExtended(2,1) = lon(1,1) + offset; 
lonExtended(3,1) = lon(1,1) - offset;

for i = 1 : 1 : lengthLat
    % lat
    latExtended(i*3+1,1) = lat(i);
    latExtended(i*3+2,1) = lat(i) + offset;
    latExtended(i*3+3,1) = lat(i) - offset;
    %lon
    lonExtended(i*3+1,1) = lon(i);
    lonExtended(i*3+2,1) = lon(i) + offset;
    lonExtended(i*3+3,1) = lon(i) - offset;
end

lat = matFile.gpsData(:, 1);
lon = matFile.gpsData(:, 2);

%fig = figure;
%plot(lon,lat, '.r', 'MarkerSize', 20)
%plot_google_map

% boundary
[compactBoundary, volume] = boundary(latExtended, lonExtended);

compactBoundaryLat = latExtended(compactBoundary);
compactBoundaryLon = lonExtended(compactBoundary);

% check if route is in or out of A5
[in,on] = inpolygon(lon, lat, compactBoundaryLon, compactBoundaryLat);

%plot(lon, lat, '.')
hold on;

compactBoundaryT = boundary(lat, lon);
%plot(lon(compactBoundaryT), lat(compactBoundaryT));


plot(lonExtended, latExtended, '.');
plot(lonExtended(compactBoundary), latExtended(compactBoundary));


% Read result files (=filtered tables) and merge them into one large file
[FileNameXLSX, PathName] = uigetfile('*.xlsx','Select the MATLAB code file');
cd(PathName);
joinedData = readtable(FileNameXLSX);

lat = joinedData(:, 17);
lon = joinedData(:, 18);

% Convert lan and lon tables to arrays 
lon = table2array(lon);
lat = table2array(lat);

%Remove NaN and '0' entries from lat and lon
lat = lat(~any(isnan(lat), 2),:);
lon = lon(~any(isnan(lon), 2),:);
lat = lat(any(lat, 2),:);
lon = lon(any(lon, 2),:);

% plot driven miles of joined day
fig = figure;
plot(lon,lat, '.r', 'MarkerSize', 20)
plot_google_map















filename = 'ILOG_IVS613_2012-08-27-08-52-25-980.decoded.txt_Filtered_Data_Table.xlsx';

A = xlsread(filename);

distace = A(:, 26);

distace = distace(~any(isnan(distace), 2),:);
 
distace = distace(any(distace, 2),:);

numberOfValues = size(distace);

x = [1:numberOfValues(1,1)];

fig = figure;
plot(x, distace)


% GPS = A(:, 17:18);
% 
% GPS = GPS(~any(isnan(GPS), 2),:);
% 
% GPS = GPS(any(GPS, 2),:);
% 
% lat = GPS(:, 1);
% 
% lon = GPS(:, 2);
% 
% fig = figure;
% plot(lon,lat,'.r','MarkerSize',20)
% plot_google_map
% print(fig, 'MySavedPlot', '-dpng')

a = 1;