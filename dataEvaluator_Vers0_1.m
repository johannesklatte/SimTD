%% TODOLIST
%% 
%% --> schleife über alle files
%% --> gpx format mit höhe + timestamp erzeugen
%% --> gefilterte daten speichern in *.decoded.FILTERED.txt
%% --> abstandsensordaten finden
%% --> restliche daten erkennen und einfügen
%% --> Fortschrittsanzeige x/y files done!
%% --> speichern der daten als matlabfile, csvfile, txtfile, ....
%% 
%%
%%
%%
%%

clear;

% Set current folder to scripts location (path)
cd(fileparts(mfilename('fullpath')))

% Get all folders of the current scripts location (path)
MyDirInfo = dir;
fileNameList = {};
[dirLength, j] = size(MyDirInfo);
pattern = 'decoded.txt';
fileNameCounter = 1;

for i = 1 : 1 : dirLength
    index = strfind(MyDirInfo(i).name, pattern);
    if(index > 0)
        fileNameList{fileNameCounter, 1} = MyDirInfo(i).name; 
        fileNameCounter = fileNameCounter + 1; 
    end
end

filename  = fileNameList(1);

% Create new files to save the results in
fileNameGPX = strcat(filename, '.GPS_DATA.gpx');
fid0 = fopen(fileNameGPX{1,1}, 'wt');
fprintf(fid0,'<?xml version="1.0" encoding="UTF-8"?>\n');
fprintf(fid0,'<gpx version="1.0">\n');
fprintf(fid0,'	<name>');
fprintf(fid0, fileNameGPX{1,1});
fprintf(fid0,'</name>\n');

fprintf(fid0,'	<trk><name>');
fprintf(fid0, fileNameGPX{1,1});
fprintf(fid0,'</name><number>1</number><trkseg>\n');


delimiter1 = ' ';

%data = importdata(filename, delimiter1);
data = importdata('ILOG_IVS325_2012-08-27-08-53-09-195.decoded.txt', delimiter1);
[fileLength, j] = size(data);

filteredResult = cell((fileLength+1), 10);              %
filteredResult{1, 1} = 'Timestamp[Y-M-D h:m:s:ms]';     %
filteredResult{1, 2} = 'Engine Speed [U/min]';          %
filteredResult{1, 3} = 'Vehicle Spped [km/h]';          %
filteredResult{1, 4} = 'Current Gear';                  %
filteredResult{1, 5} = 'Lateral Acceleration';          %
filteredResult{1, 6} = 'Longitudinal Acceleration';     %
filteredResult{1, 7} = 'Position: Latitude';            %
filteredResult{1, 8} = 'Position: Longitude';           %
filteredResult{1, 9} = '';                              %
filteredResult{1,10} = '';                              %


%==========================================================================
% Write all Timestamps into the filtered result List
pattern      = 'IVS';
patternIndex = 1;       % Index of Time Stamp
delimiter2   = ',';     % Data per row is delimited by ','
fileLength   = 500;

for i = 1 : 1 : (fileLength)
    stringToSplit  = data{i,j};
	splittedString = strsplit(stringToSplit, delimiter2);
	filteredResult{(i+1), patternIndex} = splittedString(1,2);
    i = i
end


%==========================================================================
% Write all logged engine speeds into the filtered result list
pattern      = 'm_IVS_AU_VAPIClient_EngineSpeed';
patternIndex = 2;       % Index of Engine Speed
delimiter2   = ',';     % Data per row is delimited by ','

for i = 1 : 1 : fileLength
    index = strfind(data(i,j), pattern);
    if(index{1,1} > 0)
        stringToSplit  = data{i,j};
        splittedString = strsplit(stringToSplit, delimiter2);
        filteredResult{(i+1),patternIndex}=str2double(splittedString{1,5});        
    end
end


%==========================================================================
% Write all logged Long./Lat.-positions into the filtered result list
% m_IVS_AU_VAPIClient_SimTD_FilteredPosition

% LAT
extraGPSData = cell(1,2);
extraGPSDataCounter = 1;
pattern      = 'm_IVS_AU_VAPIClient_SimTD_FilteredPosition';
patternIndex = 7;       % Index of Engine Speed
delimiter2   = ',';     % Data per row is delimited by ','

for i = 1 : 1 : fileLength
    index = strfind(data(i,j), pattern);
    if(index{1,1} > 0)
        stringToSplit  = data{i,j};
        splittedString = strsplit(stringToSplit, delimiter2);
        temp = str2double(splittedString{1,5});
        if(temp > 0)
            filteredResult{(i+1),patternIndex} = temp;
            extraGPSData{extraGPSDataCounter,1} = temp;
            extraGPSDataCounter = extraGPSDataCounter + 1;
        end
    end
end

% LONG
pattern      = 'm_IVS_AU_VAPIClient_SimTD_FilteredPosition';
extraGPSDataCounter = 1;
patternIndex = 8;       % Index of Engine Speed
delimiter2   = ',';     % Data per row is delimited by ','

for i = 1 : 1 : fileLength
    index = strfind(data(i,j), pattern);
    if(index{1,1} > 0)
        stringToSplit  = data{i,j};
        splittedString = strsplit(stringToSplit, delimiter2);
        temp = str2double(splittedString{1,7});
        if(temp > 0)
            filteredResult{(i+1),patternIndex} = temp;
            extraGPSData{extraGPSDataCounter,2} = temp;
            fprintf(fid0,'		<trkpt lat="');
            fprintf(fid0, num2str(extraGPSData{extraGPSDataCounter,1}));
            fprintf(fid0,'" lon="');
            fprintf(fid0,num2str(extraGPSData{extraGPSDataCounter,2}));
            fprintf(fid0,'"><ele>1000</ele><time>2007-10-14T10:10:52Z</time></trkpt>\n');
            extraGPSDataCounter = extraGPSDataCounter + 1;
        end
    end
end


fprintf(fid0,'	</trkseg></trk>\n');
fprintf(fid0,'</gpx>');

fclose(fid0);

close('all');








