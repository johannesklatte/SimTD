clear;

testPath = 'D:\SimTD\TEST\results_drives\2012-12-11\ILOG_IVS005_2012-12-11-10-23-55-441-OVERALL.mat';

sectionData = load(testPath);

sectionData = sectionData.overallTable;

% Loggic filters: filter out unrealistic data
minSectionLength = 0.1;             % Section length
%VehicleSpeedMean ~= NaN;           % Vehicle speed mean is not NaN

toDelete = sectionData.SectionLength < minSectionLength;
sectionData(toDelete, : ) = [];
toDelete = isnan(sectionData.VehicleSpeedMean);
sectionData(toDelete, : ) = [];

% Plot data
% Plot section length data 
nbinsSectionLength = 4;
h_SectionLength = histogram(sectionData.SectionLength, nbinsSectionLength)

x_VehicleSpeedMean = sectionData.VehicleSpeedMean;
[x_sorted_VehicleSpeedMean, sortIdx] = sort(x_VehicleSpeedMean);
y_sorted_VehicleDistanceToObjectMean = sectionData.VehicleDistanceToObjectMean(sortIdx);
y_sorted_VehicleDistanceToObjectInSecondsMean = sectionData.VehicleDistanceToObjectInSecondsMean(sortIdx);
[ax, y1, y2] = plotyy(x_sorted_VehicleSpeedMean, y_sorted_VehicleDistanceToObjectMean, x_sorted_VehicleSpeedMean, ...
    y_sorted_VehicleDistanceToObjectInSecondsMean);
title('Distance in meters and seconds to object in relation to velocity');
xlabel('velocity [km/h]')
set(get(ax(1),'Ylabel'),'String','distance to object [m]')
set(get(ax(2),'Ylabel'),'String','distance to object [sec]') 

%x_VehicleSpeedMean = [22.1 22.3 22.8 22.8 22.8 22.8 22.8 22.8 22.8 22.8 25];

x_VehicleSpeedMean_bin = cell(200,1);
y_VehicleDistanceToObjectMean_bin = cell(200,1);
y_VehicleDistanceToObjectInSecondsMean_bin = cell(200,1);
for iSpeed = 1 : 1 : length(x_VehicleSpeedMean)
    idx = ceil(x_VehicleSpeedMean(iSpeed));
    x_VehicleSpeedMean_bin{idx, 1} = horzcat(x_VehicleSpeedMean_bin{idx, 1}, x_VehicleSpeedMean(iSpeed));  
    y_VehicleDistanceToObjectMean_bin{idx, 1} = horzcat(y_VehicleDistanceToObjectMean_bin{idx, 1}, y_sorted_VehicleDistanceToObjectMean(iSpeed));
    y_VehicleDistanceToObjectInSecondsMean_bin{idx, 1} = horzcat(y_VehicleDistanceToObjectInSecondsMean_bin{idx, 1}, ...
        y_sorted_VehicleDistanceToObjectInSecondsMean(iSpeed));
end

for iSpeed = 1 : 1 : length(x_VehicleSpeedMean_bin)
    if(~isempty(x_VehicleSpeedMean_bin{iSpeed, 1}))
        x_VehicleSpeedMean_bin{iSpeed, 1} = mean(x_VehicleSpeedMean_bin{iSpeed, 1});
        y_VehicleDistanceToObjectMean_bin{iSpeed, 1} = mean(y_VehicleDistanceToObjectMean_bin{iSpeed, 1});
        y_VehicleDistanceToObjectInSecondsMean_bin{iSpeed, 1} = mean(y_VehicleDistanceToObjectInSecondsMean_bin{iSpeed, 1});
    end
end

x_VehicleSpeedMean = cell2mat(x_VehicleSpeedMean_bin);





numberOfBins = 1;