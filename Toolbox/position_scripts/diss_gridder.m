load mr_d2_diss

mr_grid.P=[1:2:25];
mr_grid.time=[];

k=1;
for ii=1:length(mr_d2_diss)
    ii
    if length(mr_d2_diss(ii).P) < 15
        disp('bad'); continue
    end
    mr_grid.e1(:,k)=interp1(mr_d2_diss(ii).P,mr_d2_diss(ii).e1(:,1),mr_grid.P)';
    mr_grid.time(k)=mr_d2_diss(ii).time;
    k=k+1;
end






































