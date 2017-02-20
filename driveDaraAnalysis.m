clear;

highwayData = load('highwaysGermanyPieces.mat');
highwayData = highwayData.highwayData;

driveData = load('ILOG_IVS426_2012-08-27-08-56-03-462.mat');
driveData = driveData.T_filtered;

lat = driveData{:,4};
lon = driveData{:,5};

lat = lat(~cellfun('isempty',lat));  
lon = lon(~cellfun('isempty',lon)); 

lat = str2double(lat);
lon = str2double(lon);

lat = lat(lat~=0);
lon = lon(lon~=0);

[HighwayDataLength, j2] = size(highwayData);

[driveDataLength, j2] = size(driveData);

tic
for i1 = 1708 : 1 : 22000%driveDataLength
    i1
    for i2 = 1 : 1 : HighwayDataLength
        if(lat(i1,1) > highwayData{i2,1}{1,1} && lat(i1,1) < highwayData{i2,1}{3,1} &&  ...
            lon(i1,1) > highwayData{i2,1}{2,1} && lon(i1,1) < highwayData{i2,1}{4,1})
            xq = lat(i1,1);
            yq = lon(i1,1);
            
            xv = highwayData{i2,1}(:,10);
            xv = xv(~cellfun('isempty',xv)); 
            xv = cell2mat(xv);
            
            yv = highwayData{i2,1}(:,11);
            yv = yv(~cellfun('isempty',yv));
            yv = cell2mat(yv);
            
            [in,on] = inpolygon(xq,yq,xv,yv);
            if(in ==1)
                check = 1;
            end
        end        
    end
end
toc


fig = figure;
plot(lon, lat, '.r', 'MarkerSize', 20)
plot_google_map


test = 1;