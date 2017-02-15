clear;

resultFolderCleandedPath = 'D:\SimTD\TEST\results_joined';

resultFolderDrivesPath = 'D:\SimTD\TEST\results_drives';

cd(resultFolderCleandedPath);

resultFolderCleandedDirInfo = dir;

[resultFolderCleandedDirInfoLength , j1] = size(resultFolderCleandedDirInfo);

overallTable = cell2table({});

sectionTable = cell2table({});

for i1 = 1 : 1 : resultFolderCleandedDirInfoLength
    FolderCount = i1
    if(strcmp(resultFolderCleandedDirInfo(i1).name, '.') || strcmp(resultFolderCleandedDirInfo(i1).name, '..' ))
        %do nothing       
    elseif(resultFolderCleandedDirInfo(i1).isdir == 1)
        SubFolderPath = strcat(resultFolderCleandedPath, '\', resultFolderCleandedDirInfo(i1).name);        
        cd(SubFolderPath);
        subFolderDirInfo = dir;
        [subFolderDirInfoLength, j2] = size(subFolderDirInfo);
        for i2 = 1 : 1 : subFolderDirInfoLength
            if(strcmp(subFolderDirInfo(i2).name, '.') || strcmp(subFolderDirInfo(i2).name, '..' ))
                %do nothing       
            else
                data = load(subFolderDirInfo(i2).name, 'data');
                data = data.data;
                
                obj_detection_data = data{: , 18};
                index = find(obj_detection_data == 1);
                % Overall cell array
                overallCellArray = cell(height(data) / 10, 26);
                if(length(index) > 10)
                    indexDiff = diff(index);
                    regionsTemp = find(indexDiff > 100);
                    regions = zeros(2*length(regionsTemp) + 2, 1);
                    for rTemp = 1 : 1 : length(regionsTemp)
                        regions(2*rTemp,   1) = regionsTemp(rTemp,1);
                        regions(2*rTemp+1, 1) = regionsTemp(rTemp,1)+1;
                    end
                    regions(1,  1) = 1;
                    regions(length(regions), 1) = length(index);
                    % Sections
                    sectionId = 1;
                    sectionArray = zeros(height(data), 13);
                    sectionLength = 0;
                    startIndex = 1;
                    for r1 = 1 : 2 : length(regions)
                        %Check if valid region (=enough detection data available)
                        data_vehicleDetection = data{index(regions(r1,1),1) : index(regions(r1+1,1) ,1), 18};
                        data_vehicleDetection_idx = ~isnan(data_vehicleDetection);
                        data_vehicleDetection_temp = data_vehicleDetection(data_vehicleDetection_idx);
                        % Set threshold/minimum of number of measuring points for data to be valid
                        measurePointThresh = 10;
                        if(length(data_vehicleDetection_temp) < measurePointThresh)
                            
                            vehicleSpeedStart = NaN;
                            vehicleSpeedEnd = NaN;  
                            data_vehicleSpeed_mean = NaN;
                            data_vehicleSpeed_std = NaN;
                            data_vehicleSpeed_fit_p1 = NaN;
                            data_vehicleSpeed_fit_p2 = NaN;                          
                            
                            data_vehicleRelativeSpeedStart = NaN;
                            data_vehicleRelativeSpeedEnd = NaN; 
                            data_vehicleRelativeSpeed_mean = NaN;
                            data_vehicleRelativeSpeed_std = NaN; 
                            data_vehicleRelativeSpeed_fit_p1 = NaN;
                            data_vehicleRelativeSpeed_fit_p2 = NaN;
                            
                            data_vehicleDistanceToObjectStart = NaN;
                            data_vehicleDistanceToObjectEnd = NaN; 
                            data_vehicleDistanceToObject_mean = NaN;
                            data_vehicleDistanceToObject_std = NaN;
                            data_vehicleDistanceToObject_fit_p1 = NaN;
                            data_vehicleDistanceToObject_fit_p2 = NaN;


                            % Time
                            data_time = data{index(regions(r1,1),1) : index(regions(r1+1,1) ,1), 1};

                            % Section time
                            section_time = data_time - data_time(1,1);

                            % Row index
                            rowId = index(regions(r1,1),1) : index(regions(r1+1,1) ,1);
                            row_index = transpose(rowId);
                            
                            % Engine Speed
                            data_engineSpeed = data{index(regions(r1,1),1) : index(regions(r1+1,1) ,1), 8};

                            % Vehicle Speed
                            data_vehicleSpeed = data{index(regions(r1,1),1) : index(regions(r1+1,1) ,1), 9};
                            data_vehicleSpeed_GPS = data{index(regions(r1,1),1) : index(regions(r1+1,1) ,1), 14};
                            data_vehicleSpeed_idx = ~isnan(data_vehicleSpeed);
                            data_vehicleSpeed_temp = data_vehicleSpeed(data_vehicleSpeed_idx);
                            if(length(data_vehicleSpeed_temp) < 2)
                                % 
                            else
                                data_time_temp = data_time(data_vehicleSpeed_idx);
                                data_time_temp = data_time_temp - min(data_time_temp);
                                fittype = 'poly1';
                                data_vehicleSpeed_fit = fit(data_time_temp, data_vehicleSpeed_temp, fittype);
                                data_vehicleSpeed_fit_p1 = data_vehicleSpeed_fit.p1;
                                data_vehicleSpeed_fit_p2 = data_vehicleSpeed_fit.p2;
                                plot(data_vehicleSpeed_fit, data_time_temp, data_vehicleSpeed_temp)
                                data_vehicleSpeed_mean = mean(data_vehicleSpeed_temp);
                                data_vehicleSpeed_std = std(data_vehicleSpeed_temp);
                                vehicleSpeedStart = data_vehicleSpeed_temp(1);
                                vehicleSpeedEnd = data_vehicleSpeed_temp(end);
                            end

                            % Vehicle detection: relative speed
                            data_vehicleRelativeSpeed = data{index(regions(r1,1),1) : index(regions(r1+1,1) ,1), 19};
                            data_vehicleRelativeSpeed_idx = ~isnan(data_vehicleRelativeSpeed);
                            data_vehicleRelativeSpeed_temp = data_vehicleRelativeSpeed(data_vehicleRelativeSpeed_idx);
                            if(length(data_vehicleRelativeSpeed_temp) < 2)
                                %
                            else
                                data_time_temp = data_time(data_vehicleRelativeSpeed_idx);
                                data_time_temp = data_time_temp - min(data_time_temp);
                                fittype = 'poly1';
                                data_vehicleRelativeSpeed_fit = fit(data_time_temp, data_vehicleRelativeSpeed_temp, fittype);
                                data_vehicleRelativeSpeed_fit_p1 = data_vehicleRelativeSpeed_fit.p1;
                                data_vehicleRelativeSpeed_fit_p2 = data_vehicleRelativeSpeed_fit.p2;
                                plot(data_vehicleRelativeSpeed_fit, data_time_temp, data_vehicleRelativeSpeed_temp)
                                data_vehicleRelativeSpeed_mean = mean(data_vehicleRelativeSpeed_temp);
                                data_vehicleRelativeSpeed_std = std(data_vehicleRelativeSpeed_temp);
                                data_vehicleRelativeSpeedStart = data_vehicleRelativeSpeed_temp(1);
                                data_vehicleRelativeSpeedEnd = data_vehicleRelativeSpeed_temp(end);                                
                            end

                            % Vehicle detection: distance to object
                            data_vehicleDistanceToObject = data{index(regions(r1,1),1) : index(regions(r1+1,1) ,1), 20};
                            data_vehicleDistanceToObject_idx = ~isnan(data_vehicleDistanceToObject);
                            data_vehicleDistanceToObject_temp = data_vehicleDistanceToObject(data_vehicleDistanceToObject_idx);
                            if(length(data_vehicleDistanceToObject_temp) < 2)
                                %
                            else
                                data_time_temp = data_time(data_vehicleDistanceToObject_idx);
                                data_time_temp = data_time_temp - min(data_time_temp);
                                fittype = 'poly1';
                                data_vehicleDistanceToObject_fit = fit(data_time_temp, data_vehicleDistanceToObject_temp, fittype);
                                data_vehicleDistanceToObject_fit_p1 = data_vehicleDistanceToObject_fit.p1;
                                data_vehicleDistanceToObject_fit_p2 = data_vehicleDistanceToObject_fit.p2;
                                plot(data_vehicleDistanceToObject_fit, data_time_temp, data_vehicleDistanceToObject_temp)
                                data_vehicleDistanceToObject_mean = mean(data_vehicleDistanceToObject_temp);
                                data_vehicleDistanceToObject_std = std(data_vehicleDistanceToObject_temp);
                                data_vehicleDistanceToObjectStart = data_vehicleDistanceToObject_temp(1);
                                data_vehicleDistanceToObjectEnd = data_vehicleDistanceToObject_temp(end);                                
                            end                                
                           
                            % GPS data
                            data_GPS_Lat = data{index(regions(r1,1),1) : index(regions(r1+1,1) ,1), 10};                            
                            data_GPS_Lat_idx = ~isnan(data_GPS_Lat);
                            data_GPS_Lat_clean = data_GPS_Lat(data_GPS_Lat_idx);
                            
                            data_GPS_Lon = data{index(regions(r1,1),1) : index(regions(r1+1,1) ,1), 11};
                            data_GPS_Lon_idx = ~isnan(data_GPS_Lon);
                            data_GPS_Lon_clean = data_GPS_Lon(data_GPS_Lon_idx);
                            data_GPS_Heading = data{index(regions(r1,1),1) : index(regions(r1+1,1) ,1), 12};
                            
                            % Acceleration data
                            Lon_acc = data{index(regions(r1,1),1) : index(regions(r1+1,1) ,1), 15};
                            Lat_acc = data{index(regions(r1,1),1) : index(regions(r1+1,1) ,1), 16};

                            % Write data into the section array
                            endIndex = startIndex + length(data_time) - 1;
                            % Section Id
                            sectionArray(startIndex : endIndex, 1) = sectionId;                     % Section ID
                            sectionArray(startIndex : endIndex, 2) = rowId;                         % Row ID
                            sectionArray(startIndex : endIndex, 3) = section_time;                  % Section time 
                            sectionArray(startIndex : endIndex, 4) = data_engineSpeed;              %
                            sectionArray(startIndex : endIndex, 5) = data_vehicleSpeed; 
                            sectionArray(startIndex : endIndex, 6) = data_vehicleSpeed_GPS; 
                            sectionArray(startIndex : endIndex, 7) = data_vehicleRelativeSpeed; 
                            sectionArray(startIndex : endIndex, 8) = data_vehicleDistanceToObject;
                            sectionArray(startIndex : endIndex, 9) = data_GPS_Lat;
                            sectionArray(startIndex : endIndex, 10) = data_GPS_Lon;
                            sectionArray(startIndex : endIndex, 11) = data_GPS_Heading;
                            sectionArray(startIndex : endIndex, 12) = Lon_acc;
                            sectionArray(startIndex : endIndex, 13) = Lat_acc;                            


                            % Write data into the overall array
                            overallCellArray{sectionId, 1} = {resultFolderCleandedDirInfo(i1).name};
                            overallCellArray{sectionId, 2} = {subFolderDirInfo(i2).name};
                            overallCellArray{sectionId, 3} = sectionId;
                            overallCellArray{sectionId, 4} = section_time(end)-section_time(1);
                            overallCellArray{sectionId, 5} = vehicleSpeedStart;                            
                            overallCellArray{sectionId, 6} = vehicleSpeedEnd;
                            overallCellArray{sectionId, 7} = data_vehicleSpeed_mean;
                            overallCellArray{sectionId, 8} = data_vehicleSpeed_std;
                            overallCellArray{sectionId, 9} = data_vehicleSpeed_fit_p1;
                            overallCellArray{sectionId, 10} = data_vehicleSpeed_fit_p2;
                            overallCellArray{sectionId, 11} = data_vehicleRelativeSpeedStart;
                            overallCellArray{sectionId, 12} = data_vehicleRelativeSpeedEnd;
                            overallCellArray{sectionId, 13} = data_vehicleRelativeSpeed_mean;
                            overallCellArray{sectionId, 14} = data_vehicleRelativeSpeed_std;
                            overallCellArray{sectionId, 15} = data_vehicleRelativeSpeed_fit_p1;
                            overallCellArray{sectionId, 16} = data_vehicleRelativeSpeed_fit_p2;
                            overallCellArray{sectionId, 17} = data_vehicleDistanceToObjectStart;
                            overallCellArray{sectionId, 18} = data_vehicleDistanceToObjectEnd;
                            overallCellArray{sectionId, 19} = data_vehicleDistanceToObject_mean;                            
                            overallCellArray{sectionId, 20} = data_vehicleDistanceToObject_std;                            
                            overallCellArray{sectionId, 21} = data_vehicleDistanceToObject_fit_p1;                            
                            overallCellArray{sectionId, 22} = data_vehicleDistanceToObject_fit_p2;                            
                            overallCellArray{sectionId, 23} = min(data_GPS_Lat_clean);                            
                            overallCellArray{sectionId, 24} = max(data_GPS_Lat_clean);                            
                            overallCellArray{sectionId, 25} = min(data_GPS_Lon_clean);                            
                            overallCellArray{sectionId, 26} = max(data_GPS_Lon_clean);

                            startIndex = endIndex + 1;
                            sectionId  = sectionId +1; 
                        end
                        %%% TODO
                        %cut sizes
                        %arrayToTable(sectionarray)
                        %sectionTable.append()                      
                    end                    
                end
                % Save section table
                if(sectionArray(1, 1) ~= 0)
                    sectionArray = sectionArray(1:endIndex, : );
                    sectionTable = array2table(sectionArray, 'VariableNames', ...
                        {'SectionID' 'RowID' 'SectionTime' 'EngineSpeed' 'VehicleSpeed' ...
                        'VehicleSpeedGPS' 'VehicleRelativeSpeed' 'VehicleDistanceToObject' 'GPSLat' 'GPSLon' ...
                        'GPSHeading' 'LonAcc' 'LatAcc'});
                    currentDir = pwd;
                    mkdir(resultFolderDrivesPath, resultFolderCleandedDirInfo(i1).name);
                    resultFolderDrives = strcat(resultFolderDrivesPath, '\', resultFolderCleandedDirInfo(i1).name);
                    cd(resultFolderDrives);
                    saveFilename = strcat(subFolderDirInfo(i2).name(1 : end-4), '-DRIVE', '.mat');
                    save(saveFilename, 'sectionTable');
                    cd(currentDir);
                else
                    %
                end
                
                % Save overall table
                if(~isempty(overallCellArray{1,1}))
                    overallCellArray = overallCellArray(1:sectionId - 1, :);
                    overallTable_temp = cell2table(overallCellArray, 'VariableNames', ...
                        {'Date' 'DriveID' 'SectionID' 'SectionLength' 'vehicleSpeedStart' ... 
                        'VehicleSpeedEnd' 'VehicleSpeedMean' 'VehicleSpeedStd' 'VehicleSpeedP1' 'VehicleSpeedP2' ...
                        'VehicleRelativeSpeedStart' 'VehicleRelativeSpeedEnd' 'VehicleRelativeSpeedMean' 'VehicleRelativeSpeedStd' 'VehicleRelativeSpeedP1' ...
                        'VehicleRelativeSpeedP2' 'VehicleDistanceToObjectStart' 'VehicleDistanceToObjectEnd' 'VehicleDistanceToObjectMean' 'VehicleDistanceToObjectStd' ...
                        'VehicleDistanceToObjectP1' 'VehicleDistanceToObjectP2' 'GPSLatMin' 'GPSLatMax' 'GPSLonMin' 'GPSLonMax'});
                else
                    %
                end
                if(height(overallTable) ~= 0)
                    overallTable = [overallTable; overallTable_temp];
                    currentDir = pwd;
                    cd(resultFolderDrivesPath);
                    save(saveFilename, 'overallTable');
                    cd(currentDir);
                else
                    overallTable = overallTable_temp;
                end
            end
        end
    end
end



















