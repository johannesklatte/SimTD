C = {'blue' 'red' 'green' 'blue'; 'blue' 'green' 'green' 'blue'};

colors = categorical(C)

colors(1,:) == colors(2,:)
