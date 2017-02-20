%
%
%
%
%
%
%
%
%
%



% Clear all workplace data
clear;
% Set current folder to scripts location/path)
cd(fileparts(mfilename('fullpath')))
% Start parallel pool
numberOfCores = feature('numcores');
poolJob = parpool('local', numberOfCores);

% Get all filenames of the current scripts location/path
MyDirInfo = dir;
fileNameList = {};                      % List of all filenames in the dir
[dirLength, j] = size(MyDirInfo);
patternTextFiles = 'decoded.txt';       % Naming pattern for the *.txt files
excludedPatternGPX = 'GPS_DATA.gpx';
excludedPatternFilteredData = '';
fileNameCounter = 1;
for i = 1 : 1 : dirLength
    indexTextFiles = strfind(MyDirInfo(i).name, patternTextFiles);
    indexGPXFiles = strfind(MyDirInfo(i).name, excludedPatternGPX);
    indexFilteredFiles = strfind(MyDirInfo(i).name, excludedPatternFilteredData);
    if(indexTextFiles > 0)
        if(isempty(indexGPXFiles)) 
            if (isempty(indexFilteredFiles))
                fileNameList{fileNameCounter, 1} = MyDirInfo(i).name; 
                fileNameCounter = fileNameCounter + 1;
            end
        end
    end
end
fileNameCounter = fileNameCounter - 1;

% If no files were found (fileNameCounter == 0), exit script and display error message
if (fileNameCounter == 0)
    errorMessage = strcat('No files found matching the given pattern : ',' ', patternTextFiles);
    errorWindow = msgbox(errorMessage, 'Error!', 'error');
    return;
end

% Loop over all files in the current dir and create a new FilteredData and a GPX file for each
for iFile = 1 : 1 : 1 %fileNameCounter
    filenameCurrent = fileNameList(iFile);
    delimiterTXT = ' ';
    data = importdata(filenameCurrent{1,1}, delimiterTXT);
    [fileLength, j] = size(data);
    
    % Create boundary array to split data for parallel processing
    [numberOfRows, numberOfColumns] = size(data);
    boundaryArray = zeros(1, 2*numberOfCores);
    boundaryArray(1) = 1;
    for i = 2 : 2 : 2*numberOfCores
        boundaryArray(i) = (i/2) * (numberOfRows / numberOfCores);
    end
    boundaryArray = int64(boundaryArray);

    % Check boundaries (to make sure, that there is no change in timestamps at a boundary)
    patternDelimiter = ',';
    timestampPosition = 2;
    for iOut = 2 : 2 : ((2*numberOfCores) - 2)
        index = boundaryArray(iOut);
        splittedString = strsplit(data{index, 1}, patternDelimiter);
        oldTimestamp = splittedString{1, timestampPosition};
        for iIn = 1 : 1 : 10000
            splittedString = strsplit(data{(index+1), 1}, patternDelimiter);
            newTimestamp = splittedString{1, timestampPosition};
            if(strcmp(newTimestamp, oldTimestamp)) 
                oldTimestamp = newTimestamp;
                index = index + 1;
            else
                boundaryArray(iOut + 0) = index + 0;
                boundaryArray(iOut + 1) = index + 1;
                break
            end   
        end
    end

    % Parallel loop to extract particular data
    parfor i = 1 : 1 : numberOfCores
        indices = 1 : 2 : (2 * numberOfCores);
        loopBoundaryArray = boundaryArray;
        loopData = data(boundaryArray(indices(i+0)): boundaryArray(indices(i+1)), 1)
        
    end    
    
end


%shut down pool
delete(poolJob);
a = 4;
