
function RSK = coef2cal(RSK)

% COEF2CAL - Combines the coefficients structure to the calibrations structure.
%
% Syntax: [RSK] = coef2cal(RSK)
%
% Coef2cal adds the coefficients structure to the calibrations structure to
% be consistent with the structure schema pre RSK v1.13.4. It will only
% store the coefficients that have non-Null values as a field in the calibrations
% structure.
%
% Inputs:
%    RSK - Structure containing the logger metadata created with versions
%    RSK v1.13.4 or newer.
%
% Outputs:
%    RSK - Structure containing the logger metadata and thumbnails
%
% Author: RBR Ltd. Ottawa ON, Canada
% email: support@rbr-global.com
% Website: www.rbr-global.com
% Last revision: 2016-10-03

%Isolate each coefficient of each Id in order to assign the value at the
%right place.
for Id = 1:max([RSK.coefficients.calibrationID])
    IDind = find([RSK.coefficients.('calibrationID')] == Id);
    for i = IDind
        %Find which key and value is associated with the index and insert
        %into structure.
        key = RSK.coefficients(i).key; 
        RSK.calibrations(Id).(key)= str2double(RSK.coefficients(i).value);
    end
end
end

