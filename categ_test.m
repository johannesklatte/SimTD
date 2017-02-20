clear;

symbols = ['a':'z' 'A':'Z' '0':'9'];
MAX_ST_LENGTH = 50;

stringArray = cell(1, 10000);

for i = 1 : 1 : 10000    
    stLength = randi(MAX_ST_LENGTH);
    nums = randi(numel(symbols),[1 stLength]);
    st = symbols (nums);
    stringArray(1, i) = cellstr(st);
end

compareElement = stringArray(1, 1);

tic 
for i = 1 : 1 : 10000
    a = strcmp(compareElement, stringArray(1, i));
end
toc


categoricalArray = categorical(stringArray);
compareElementCategorical = categoricalArray(1, 1);

tic 
for i = 1 : 1 : 10000
    a = (compareElementCategorical == categoricalArray(1, i));
end
toc

test = 3;