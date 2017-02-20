test = load('ILOG_IVS346_2012-10-22-08-08-13-554_a.mat');
test = test.T_filtered;
whos test


alphaLetters = ('a':'z');
alphaLetters2 = ['a', 'b', 'c']; 


saveCouunter = 5;
letter1 = alphaLetters(1, saveCouunter);


driveData = load('ILOG_IVS426_2012-08-27-08-56-03-462.mat');
driveData = driveData.T_filtered;


lat = driveData{:,14};

lat = lat(~cellfun('isempty',lat)); 

lat = str2double(lat);

lat = lat(lat~=0);









x = gallery('uniformdata',30,1,1);
y = gallery('uniformdata',30,1,10);
plot(x,y,'.')
xlim([-0.2 1.2])
ylim([-0.2 1.2])

k = boundary(x,y);
hold on;
plot(x(k),y(k));

j = boundary(x,y,0.1);
hold on;
plot(x(j),y(j));


test = 1;