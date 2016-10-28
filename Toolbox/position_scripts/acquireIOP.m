function gps_iop=acquireIOP;
    s=urlread('http://iop.apl.washington.edu/ice/txt/300034013757350_GP01.txt');
    c=textscan(s,'%s','delimiter',' ');
    c=c{1};
    cc=c(4:4:end);

   clear gps_iop; k=1;
    for i=1:length(cc)
        com=strfind(cc{i},',');
        if strcmp(cc{i}(com(6)+1:com(7)-1),'256')==1
            disp('bad')
            continue
        end
        gps_iop.time(k)=str2double(cc{i}(com(4)+1:com(5)-1))+datenum([2000 01 01 00 00 00])+str2double(cc{i}(com(5)+1:com(6)-1))/24;
        gps_iop.lat(k)=str2double(cc{i}(1:com(1)-1))+str2double(cc{i}(com(1)+1:com(2)-1))/60;
        gps_iop.lon(k)=str2double(cc{i}(com(2)+1:com(3)-1))+str2double(cc{i}(com(3)+1:com(4)-1))/60;

        k=k+1; 
    end
    
gps_iop.time=gps_iop.time(:);
gps_iop.lat=gps_iop.lat(:);
gps_iop.lon=gps_iop.lon(:);
end
