x = randn(1000,1);
x = x*100;
edges = [0.1:10:100.1 100.1:100:1000.1 1000.1 1000000];
[N1, edges] = histcounts(x, edges);
names = [100,300,500]
N1 = N1(1,1:3)
bar(N1)
set(gca,'XTickLabel',{'apples', 'oranges', 'strawberries'})
%x = x/10;
%[N2, edges] = histcounts(x, edges);

histogram(N1, edges)

h3 = h1 + h2;


X = [2 3 5 7 11 13 17 19 23 29];
[N,edges] = histcounts(X,6)


for i = [3,6,30]
   check = i; 
end



A = [4,4,4,4,4,4,2,2,2,2,2,2,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3];
histogram(A, 2);


test = 1;