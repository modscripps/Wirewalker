function [rsk_struct,rsk_struct_raw]=RSK_wrapper(RSK,instr_type,P_range)

% function rsk_structure=RSK_wrapper(RSK,instr_type)
% instr type = 'c' or 'm' for Concerto or Maestro or 'c1' for the single
% channel Concerto or 'tp' for the RBR t/P wave dou instrument or c_DO if
% the concerto has a rinko on v2.
% function to take RBR data from the Concerto or Maestro and put it in a
% matlab structure that we have plotting and analysis tools for
if exist('temporary_rsk_struct.mat')
    load('temporary_rsk_struct.mat')
else
    RSKdb=RSKopen(RSK);


    RSKread=RSKreaddata(RSKdb);
    % keyboard
    if strcmp(instr_type,'quipp')==1
        rsk_struct_raw=RSK_structQ(RSKread);
    else    
        rsk_struct_raw=RSK_struct(RSKread);
    end
    
    % enable for WW, disable for bowchain
    if strcmp(instr_type,'c_4Hz')==1
        [rsk_struct_raw.up,rsk_struct_raw.down,rsk_struct]=get_upcastRBR_4hz(rsk_struct_raw);
    else
        [rsk_struct_raw.up,rsk_struct_raw.down,rsk_struct]=get_upcast(rsk_struct_raw);
    end
    
    
    
    if strcmp(instr_type,'tp')==1
        dirc=[];
        % while strcmp(dirc,'u')~=1||strcmp(dirc,'d')~=1
        dirc=input('Upward (u) or downward (d) mounted T/P? ');
        if strcmp(dirc,'u')==1;
            clear rsk_struct
            rsk_struct.time=rsk_struct_raw.time(rsk_struct_raw.up);
            rsk_struct.T=rsk_struct_raw.T(rsk_struct_raw.up);
            rsk_struct.P=rsk_struct_raw.P(rsk_struct_raw.up);
        end
        if strcmp(dirc,'d')==1;
            clear rsk_struct
            rsk_struct.time=rsk_struct_raw.time(rsk_struct_raw.down);
            rsk_struct.T=rsk_struct_raw.T(rsk_struct_raw.down);
            rsk_struct.P=rsk_struct_raw.P(rsk_struct_raw.down);
        end
        %end
    end
end
ii=find_indx_profiles(rsk_struct.P,abs(floor((P_range(end)-P_range(1))/2)));
%ii_correct=ii(ii(:,1)~=ii(:,2),:);
rsk_struct.std_profiles=make_standard_profilesRBR(rsk_struct,ii,P_range);
rsk_struct.idx=ii;

