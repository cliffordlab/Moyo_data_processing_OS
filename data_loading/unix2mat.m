function t_out = unix2mat(t_in)

% Convert unix timestamp to Matlab "datenum" format
%
% Input:  unix timestamp in int or double format
%         this is the number of seconds since 1 Jan 1970
%
% Output: matlab datenum format
%         this is the number of days since 1 Jan 0000 


% Calculate seconds to days
num_days = t_in / 86400;

% Add offset
t_out = num_days + datenum(1970,1,1);

end % end function