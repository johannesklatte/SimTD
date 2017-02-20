

% Open file
fid = fopen('mydata.txt','rt')

% Read header line
header = fgetl(fid);
% Read data IN THE LINE 4
q=textscan(fid,'%s %s %f %f %f %f','delimiter',',');

fclose(fid);

c = {};
for i = 3:6
    % concatenate the elements in fourth row  of each cell column in 'q'
    c = vertcat(c, q{i}(4));
end
num_from_line = cell2mat(c)