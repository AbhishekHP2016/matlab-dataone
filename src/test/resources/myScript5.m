filename = 'durer.mat';
myVars = {'X','caption'};
S = load(filename,myVars{:})

p = rand(1,10);
q = ones(10);
save('pqfile.mat','p','q')