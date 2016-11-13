function std=std_median(x)
% x is matrice (D1,D2,D3) 
% std on dimension 3
    N=size(x,3);
    mu=nanmean(x,3);
    std=sqrt(1/(N-1)*nansum((x-repmat(mu,[1 1 N])).^2,3));
end