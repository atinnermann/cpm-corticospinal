function Y=meancor(X)
%normalise X to zero mean, std unity
Y = X - ones(size(X,1),1)*nanmean(X); %zero mean
