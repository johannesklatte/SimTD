table1 = load('table1.mat', 'CTOT');
table1 = table1.CTOT;

table2 = load('table2.mat', 'CTOT');
table2 = table2.CTOT;

table3 = load('table3.mat', 'CTOT');
table3 = table3.CTOT;

table4 = load('table4.mat', 'CTOT');
table4 = table4.CTOT;

table5 = load('table5.mat', 'CTOT');
table5 = table5.CTOT;

table6 = load('table6.mat', 'CTOT');
table6 = table6.CTOT;

table7 = load('table7.mat', 'CTOT');
table7 = table7.CTOT;

table8 = load('table8.mat', 'CTOT');
table8 = table8.CTOT;



T_final1 = outerjoin(table1, table2, 'MergeKeys',true);
T_final2 = outerjoin(T_final1, table3, 'MergeKeys',true);
T_final3 = outerjoin(T_final2, table4, 'MergeKeys',true);
T_final4 = outerjoin(T_final3, table5, 'MergeKeys',true);
T_final5 = outerjoin(T_final4, table6, 'MergeKeys',true);
T_final6 = outerjoin(T_final5, table7, 'MergeKeys',true);
T_final7 = outerjoin(T_final6, table8, 'MergeKeys',true);
cd('C:\UNPACK');
%save('finalTable.mat', 'T_final7');

fileID = fopen('exp.txt','w');

[length, j2] = size(T_final7);

fprintf(fileID, '%s\n', 'Hello World');

stringgg = 'Hello World!!!!!';

fprintf(fileID, '%s\n\r', stringgg);

fprintf(fileID, '%s\n', 'Hello MATLAB!');

fclose(fileID);

for i = 1 : 1 : length
    
    
end


test1 = 0;












