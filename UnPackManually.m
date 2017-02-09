%
clear all;
setenv('TEMP', 'D:\SimTD\temp');% TEMP for Windows
tempdir
clear;

[tarfilename, folderPath] = uigetfile('D:\SimTD\data', 'Select folder that contains all *.tar files');
untarFolderPath= 'D:\SimTD\unpack';

cd(folderPath);
untar(tarfilename, untarFolderPath);


msg = 'done';