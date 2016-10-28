function df=onedgrad(f,dx);
index=find(~isnan(f));
% preserve NaNs where they belong
df=f;
if(length(index)==0)
return
end
if(length(index)==1)
     df(index(1))=0;
end
if(length(index)==2)
df(index(1))=(f(index(2))-f(index(1)))/dx;
df(index(2))=(f(index(2))-f(index(1)))/dx;
end
if(length(index)>2)
df(index(1))=(f(index(2))-f(index(1)))/dx;
df(index(end))=(f(index(end))-f(index(end-1)))/dx;
for n=index(2):index(end-1)
     df(n)=(f(n+1)-f(n-1))/2/dx;
end
end
