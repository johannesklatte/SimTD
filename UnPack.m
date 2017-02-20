%
clear all
setenv('TEMP', 'C:\Users\Johannes_Work\Downloads\Studium\HIWI\TEST');% TEMP for Windows
tempdir
clear;

[tarfilename, folderPath] = uigetfile('C:\Users\Johannes_Work\Downloads\Studium\HIWI\TEST\DATA', 'Select folder that contains all *.tar files');
untarFolderPath= 'C:\Users\Johannes_Work\Downloads\Studium\HIWI\TEST\UNPACK';

cd(folderPath);
untar(tarfilename, untarFolderPath);


test= 1;