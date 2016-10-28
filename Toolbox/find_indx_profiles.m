function indx=find_indx_profiles(P,depth)


up_dif=abs(diff(P));

pp=find(up_dif>depth);
endd=pp;
startt=ones(size(endd));
startt(2:end)=endd(1:end-1)+1;
indx=[startt,endd];
%% add a condition when profiles are not linear
%  like stair case profil
indx=indx(startt~=endd,:);


