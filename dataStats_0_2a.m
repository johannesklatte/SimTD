clear;

resultFolderCleandedPath = 'D:\SimTD\results_joined';

cd(resultFolderCleandedPath);

resultFolderCleandedDirInfo = dir;

[resultFolderCleandedDirInfoLength , j1] = size(resultFolderCleandedDirInfo);

for i1 = 4 : 1 : resultFolderCleandedDirInfoLength
    FolderCount = i1
    if(strcmp(resultFolderCleandedDirInfo(i1).name, '.') || strcmp(resultFolderCleandedDirInfo(i1).name, '..' ))
        %do nothing       
    elseif(resultFolderCleandedDirInfo(i1).isdir == 1)
        SubFolderPath = strcat(resultFolderCleandedPath, '\', resultFolderCleandedDirInfo(i1).name);        
        cd(SubFolderPath);
        subFolderDirInfo = dir;
        [subFolderDirInfoLength, j2] = size(subFolderDirInfo);
        for i2 = 1 : 1 : subFolderDirInfoLength
            tic
            if(strcmp(subFolderDirInfo(i2).name, '.') || strcmp(subFolderDirInfo(i2).name, '..' ))
                %do nothing       
            else
                T_filtered = load(subFolderDirInfo(i2).name, 'T_filtered');
                T_filtered = T_filtered.T_filtered;
                parameterIndices = [1,2,3,4,5,9,12];
                [i3b, parameterIndicesSize] = size(parameterIndices);
                
                
                %TEST TEST TEST  %TEST TEST TEST
                tic
                testData = T_filtered{: , 12};
                index = find(strcmp(testData, '1'));
                indexDiff = diff(index);
                regionsTemp = find(indexDiff > 100);
                regions = zeros(2*length(regionsTemp) + 2, 1);
                for rTemp = 1 : 1 : length(regionsTemp)
                    regions(2*rTemp,   1) = regionsTemp(rTemp,1);
                    regions(2*rTemp+1, 1) = regionsTemp(rTemp,1)+1;
                end
                regions(1,  1) = 1;
                regions(length(regions), 1) = length(index);
                
                for r1 = 1 : 2 : length(regions)
                    dataTest_0 = T_filtered{index(regions(r1,1),1) : index(regions(r1+1,1) ,1), 3};
                    dataTest_0 = str2double(dataTest_0);
                    
                    dataTest_0b = T_filtered{index(regions(r1,1),1) : index(regions(r1+1,1) ,1), 8};
                    dataTest_0b = str2double(dataTest_0b);
                    
                    speedIndex = find(isnan(dataTest_0));
                    dataTest_0(speedIndex) = dataTest_0b(speedIndex);
                    %dataTest_0(dataTest_0 == 0) = NaN;
                    
                    dataTest_1 = T_filtered{index(regions(r1,1),1) : index(regions(r1+1,1) ,1), 14};
                    dataTest_2 = T_filtered{index(regions(r1,1),1) : index(regions(r1+1,1) ,1), 13};
                    
                    x = find(~strcmp(dataTest_1, ''));
                    oDist = str2double(dataTest_1(x));

                    o_vRel = str2double(dataTest_2(x));
                    
                    method = 'linear'; % spline , 

                    xq = transpose(1:1:length(dataTest_1));
                    oDistq = interp1(x, oDist, xq, method);

                    vRelq = interp1(x, o_vRel, xq, method);

                    %x = x+100;
                    %xq = xq + 100;

                    xSpeed = find(~isnan(dataTest_0));
                    vSpeed = dataTest_0(xSpeed);
                
                    figure
                    plot(x,oDist,'o', xq,oDistq,':.', x,o_vRel,'o', xq,vRelq,':.', xSpeed, vSpeed,'x');
                    
                end
                
                
                %padding = NaN(100,1);
                %x = vertcat(padding, x, padding);
                %v = vertcat(padding, v, padding);
                %vq = [padding; vq; padding];
                %xq = 1:1:length(dataTest_1)+2*length(padding);

                
                
                dataTest_1 = str2double(dataTest_1);
                %testData = str2double(testData);
                %found = find(testData > 0.5);
                %logicalTemp2 = ~ismissing(testData);
                toc
                
                
                %testDataDobule = find(testData);
                %testDataDiff = diff(testDataDobule);
                %testCurrDir = pwd;
                %saveFile = strcat(testCurrDir, '\', 'test.dat');
                %save (saveFile, 'testData');
                %testLoad = load('test.dat');
                %findcluster(test.dat);
                
                
                
                
                
                %TEST TEST TEST  %TEST TEST TEST
                
                
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
            end
            toc
        end
    end
end

% for i1 = 1 : 1 :37
%     driveStatsCellArray(2, i1) = num2cell(cell2mat(driveStatsCellArray(1, i1)) / cell2mat(driveStatsCellArray(1, 1)) * 100);
% end
% 
% driveStats = cell2table(driveStatsCellArray);
% 
% driveStats.Properties.VariableNames = {'Timestamp' 'Rpm' 'Vehicle_speed' 'Long_acceleration' 'Lat_acceleration' ...
%                             'Gear_selection' 'Current_gear' 'Steeringwheel_angle' 'Steeringwheel_velocity' 'Odometer' ...
%                             'Trip_odometer' 'Latitude_GPS' 'Longitude_GPS' 'Heading_GPS' 'Altitude_GPS' ...
%                             'Vehicle_speed_GPS' 'Brake_actuation' 'Pedal_force' 'Object_detected' 'Relative_speed_to_object' ...
%                             'Distance_to_object' 'cruise_control' 'clutch' 'ABS' 'Exterior_temperature' ...
%                             'Hazard_ligths' 'Daytime_running_lights' 'Front_light_low_beam' 'Front_light_high_beam' 'Fog_light' ...
%                             'Turn_signal_front_left' 'Turn_signal_front_right' 'Turn_signal_rear_left' 'Turn_signal_rear_right' ...
%                             'Emergency_Light' 'Wiper_front' 'Wiper_rear'};
%                     
% driveStats.Properties.RowNames = {'Total', 'Percentage'};%, '3', '4'};

% cd(resultFolderCleandedPath);



save('EngineSpeed.mat', 'engineSpeed');
save('VehicleSpeed.mat', 'vehicleSpeed');
save('GPSData.mat', 'gpsData');
save('Acceleration.mat', 'acceleration');
save('ObjectDetection.mat', 'objectDetection');
