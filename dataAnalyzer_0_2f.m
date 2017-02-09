clear;

resultFolderCleandedPath = 'D:\SimTD\results_joined';

cd(resultFolderCleandedPath);

% resultFolderCleandedDirInfo = dir;
% 
% [resultFolderCleandedDirInfoLength , j1] = size(resultFolderCleandedDirInfo);
% 
% engineSpeed = zeros(1,21);    
% vehicleSpeed = zeros(1,21);    
% gpsData = zeros(1,21);    
% acceleration = zeros(1,21);    
% objectDetection = zeros(1,21);                     
% 
% for i1 = 4 : 1 : resultFolderCleandedDirInfoLength
%     FolderCount = i1
%     if(strcmp(resultFolderCleandedDirInfo(i1).name, '.') || strcmp(resultFolderCleandedDirInfo(i1).name, '..' ))
%         %do nothing       
%     else
%         SubFolderPath = strcat(resultFolderCleandedPath, '\', resultFolderCleandedDirInfo(i1).name);        
%         cd(SubFolderPath);
%         subFolderDirInfo = dir;
%         [subFolderDirInfoLength, j2] = size(subFolderDirInfo);
%         for i2 = 1 : 1 : subFolderDirInfoLength
%             tic
%             if(strcmp(subFolderDirInfo(i2).name, '.') || strcmp(subFolderDirInfo(i2).name, '..' ))
%                 %do nothing       
%             else
%                 T_filtered = load(subFolderDirInfo(i2).name, 'T_filtered');
%                 T_filtered = T_filtered.T_filtered;
%                 parameterIndices = [2,3,4,9,12];
%                 [i3b, parameterIndicesSize] = size(parameterIndices);
%                 for i3 = 1 : 1 : parameterIndicesSize
%                     i3Inner = parameterIndices(1, i3);
%                     tempTable = T_filtered(: , i3Inner);
%                     logicalTemp2 = ~ismissing(tempTable);
%                     indices = find(logicalTemp2);
%                     [indicesLength , j4] = size(indices);
%                     differenceTemp = zeros(1,1);
%                     if(indicesLength > 1)
%                         differenceTemp = zeros(indicesLength-1, 1);
%                         for i4 = 2 : 1 : indicesLength
%                             differenceTemp(i4-1,1) = indices(i4, 1) - indices(i4-1, 1);
%                         end
%                         edges = [0.1 1.1 2.1 3.1 4.1 5.1 6.1 7.1 8.1 9.1 10.1 20.1 30.1 40.1 50.1 ...
%                             100.1 200.1 300.1 400.1 500.1 1000.1 1000000000.1];
%                         [N1, edges] = histcounts(differenceTemp, edges);
%                         switch i3
%                             case 1
%                                 engineSpeed = engineSpeed + N1;
%                             case 2
%                                 vehicleSpeed = vehicleSpeed + N1;
%                             case 3
%                                 gpsData = gpsData + N1;
%                             case 4
%                                 acceleration = acceleration + N1;
%                             case 5
%                                 objectDetection = objectDetection + N1;
%                             otherwise
%                                 %should never happen
%                                 error = 1;
%                         end
%                     end
%                 end
%             end
%             toc
%         end
%     end
% end
% 
% % for i1 = 1 : 1 :37
% %     driveStatsCellArray(2, i1) = num2cell(cell2mat(driveStatsCellArray(1, i1)) / cell2mat(driveStatsCellArray(1, 1)) * 100);
% % end
% % 
% % driveStats = cell2table(driveStatsCellArray);
% % 
% % driveStats.Properties.VariableNames = {'Timestamp' 'Rpm' 'Vehicle_speed' 'Long_acceleration' 'Lat_acceleration' ...
% %                             'Gear_selection' 'Current_gear' 'Steeringwheel_angle' 'Steeringwheel_velocity' 'Odometer' ...
% %                             'Trip_odometer' 'Latitude_GPS' 'Longitude_GPS' 'Heading_GPS' 'Altitude_GPS' ...
% %                             'Vehicle_speed_GPS' 'Brake_actuation' 'Pedal_force' 'Object_detected' 'Relative_speed_to_object' ...
% %                             'Distance_to_object' 'cruise_control' 'clutch' 'ABS' 'Exterior_temperature' ...
% %                             'Hazard_ligths' 'Daytime_running_lights' 'Front_light_low_beam' 'Front_light_high_beam' 'Fog_light' ...
% %                             'Turn_signal_front_left' 'Turn_signal_front_right' 'Turn_signal_rear_left' 'Turn_signal_rear_right' ...
% %                             'Emergency_Light' 'Wiper_front' 'Wiper_rear'};
% %                     
% % driveStats.Properties.RowNames = {'Total', 'Percentage'};%, '3', '4'};
% 
% % cd(resultFolderCleandedPath);
% 
% 
% 
% save('EngineSpeed.mat', 'engineSpeed');
% save('VehicleSpeed.mat', 'vehicleSpeed');
% save('GPSData.mat', 'gpsData');
% save('Acceleration.mat', 'acceleration');
% save('ObjectDetection.mat', 'objectDetection');

engineSpeed = load('EngineSpeed.mat');
engineSpeed = engineSpeed.engineSpeed;


figure('units','normalized','outerposition',[0 0 1 1])
bar(engineSpeed)
set(gca,'XTick',[1:21]);
set(gca,'XTickLabel',{'1', '2', '3', '4', '5', '6', '7', '8', '9', '10', '10-20', '20-30', '30-40',...
	'40-50', '50-100', '100-200', '200-300', '300-400', '400-500', '500-1000', '1000++'})
xlabel('distance between two consecutive occurrences');
ylabel('Observed frequency')
title('Engine speed (RPM)')
saveas(gcf, 'EngineSpeed_FrequencyOfOccurrence.fig')


figure('units','normalized','outerposition',[0 0 1 1])
bar(vehicleSpeed)
set(gca,'XTick',[1:21]);
set(gca,'XTickLabel',{'1', '2', '3', '4', '5', '6', '7', '8', '9', '10', '10-20', '20-30', '30-40',...
	'40-50', '50-100', '100-200', '200-300', '300-400', '400-500', '500-1000', '1000++'})
xlabel('distance between two consecutive occurrences');
ylabel('Observed frequency')
title('Vehicle speed (km/h)')
saveas(gcf, 'VehicleSpeed_FrequencyOfOccurrence.fig')


figure('units','normalized','outerposition',[0 0 1 1])
bar(gpsData)
set(gca,'XTick',[1:21]);
set(gca,'XTickLabel',{'1', '2', '3', '4', '5', '6', '7', '8', '9', '10', '10-20', '20-30', '30-40',...
	'40-50', '50-100', '100-200', '200-300', '300-400', '400-500', '500-1000', '1000++'})
xlabel('distance between two consecutive occurrences');
ylabel('Observed frequency')
title('GPS Data')
saveas(gcf, 'GPSData_FrequencyOfOccurrence.fig')


figure('units','normalized','outerposition',[0 0 1 1])
bar(acceleration)
set(gca,'XTick',[1:21]);
set(gca,'XTickLabel',{'1', '2', '3', '4', '5', '6', '7', '8', '9', '10', '10-20', '20-30', '30-40',...
	'40-50', '50-100', '100-200', '200-300', '300-400', '400-500', '500-1000', '1000++'})
xlabel('distance between two consecutive occurrences');
ylabel('Observed frequency')
title('Acceleration')
saveas(gcf, 'Acceleration_FrequencyOfOccurrence.fig')


figure('units','normalized','outerposition',[0 0 1 1])
bar(objectDetection)
set(gca,'XTick',[1:21]);
set(gca,'XTickLabel',{'1', '2', '3', '4', '5', '6', '7', '8', '9', '10', '10-20', '20-30', '30-40',...
	'40-50', '50-100', '100-200', '200-300', '300-400', '400-500', '500-1000', '1000++'})
xlabel('distance between two consecutive occurrences');
ylabel('Observed frequency')
title('Object Detection')
saveas(gcf, 'ObjectDetection_FrequencyOfOccurrence.fig')


msg = 'done';









