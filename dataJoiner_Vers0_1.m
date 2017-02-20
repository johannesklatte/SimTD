% Clear Workplace
clear;

%joinFolderName = uigetdir('C:\', 'Select folder of one day data to be joined');
joinFolderName = 'C:\Users\Johannes_Work\Downloads\Studium\HIWI\RESULTS\2012-08-27';
cd(joinFolderName);
MyDirInfo = dir('*.xlsx');
[dirLength, j1] = size(MyDirInfo);
variablesNames = {'Timestamp_1' 'Timestamp_2' 'Timestamp_3' 'Timestamp_4' 'Timestamp_5' ...
    'Timestamp_6' 'Rpm' 'Vehicle_speed' 'Long_acceleration' 'Lat_acceleration' ...
	'Gear_selection' 'Current_gear' 'Steeringwheel_angle' 'Steeringwheel_velocity' 'Odometer' ...
	'Trip_odometer' 'Latitude_GPS' 'Longitude_GPS' 'Heading_GPS' 'Altitude_GPS' ...
	'Vehicle_speed_GPS' 'Brake_actuation' 'Pedal_force' 'Object_detected' 'Relative_speed_to_object' ...
	'Distance_to_object' 'cruise_control' 'clutch' 'ABS' 'Exterior_temperature' ...
	'Hazard_ligths' 'Daytime_running_lights' 'Front_light_low_beam' 'Front_light_high_beam' 'Fog_light' ...
    'Turn_signal_front_left' 'Turn_signal_front_right' 'Turn_signal_rear_left' 'Turn_signal_rear_right' ...
	'Emergency_Light' 'Wiper_front' 'Wiper_rear'};
joinedFilteredDataTable = cell2table(cell(0,42));
joinedFilteredDataTable.Properties.VariableNames = variablesNames;

for i = 1 : 1 : dirLength
    currentFileName = MyDirInfo(i).name;
    filteredDataTable = readtable(currentFileName);
    [filteredDataLength, j2] = size(filteredDataTable);
    tStart = table2array([filteredDataTable(2,1), filteredDataTable(2,2), filteredDataTable(2,3), ...
        filteredDataTable(2,4), filteredDataTable(2,5), filteredDataTable(2,6)]);
    tEnd = table2array([filteredDataTable(filteredDataLength-1, 1), filteredDataTable(filteredDataLength-1, 2), ...
        filteredDataTable(filteredDataLength-1, 3), filteredDataTable(filteredDataLength-1, 4), ...
        filteredDataTable(filteredDataLength-1, 5), filteredDataTable(filteredDataLength-1, 6)]);
    timeElapsed = etime(tEnd, tStart);
    if(timeElapsed > 10*60)
        joinedFilteredDataTable = vertcat(joinedFilteredDataTable, filteredDataTable(2: (filteredDataLength), :));
    else
        % Drive was to short -> do not use this data
    end
end%for

% Save joined tables of filterd data in a new table
tableFilenameXLSX = 'joined_Table.xlsx';
writetable(joinedFilteredDataTable, tableFilenameXLSX);






