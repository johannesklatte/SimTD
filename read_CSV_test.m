DateString = '2014-05-26 11:13:14:155';
formatIn = 'yyyy-mm-dd HH:MM:SS:FFF';
test = datevec(DateString, formatIn);






DateStrings = {'2014-05-26 11:13:14:111'; '2012-08-27 09:48:21:182'};
t = datetime(DateStrings, 'InputFormat', 'yyyy-MM-dd hh:mm:ss:SSS');




DateStrings1='2014-06-23 17:06:41:584';
t = datenum(DateStrings1, 'yyyy-mm-dd HH:MM:SS:FFF');
test = datestr(t, 'yyyy-mm-dd HH:MM:SS:FFF');



t = datetime('now');
str = date;
T = readtable('ILOG_IVS764_2012-08-27-09-48-11-714.decoded.txt_Filtered_Data_Table.xlsx');

test = T{2,1};
testCell = {'2012-08-27-09:48:21:182'};
t = datetime(testCell, 'InputFormat', 'yyyy-MM-dd-HH:mm:ss')

lat = [48.8708   51.5188   41.9260   40.4312   52.523   37.982];
lon = [2.4131    -0.1300    12.4951   -3.6788    13.415   23.715];
plot(lon,lat,'.r','MarkerSize',20)
plot_google_map

a = 4;