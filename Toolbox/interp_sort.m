function [out,I]=interp_sort(in)

% function interp_sort(in)
% call this function to make sure that your X-values are different prior to
% interpolation.  this solves finicky matlab bs that doesn't allow for
% repeated x values.

[presort,I] = sort(in);
trouble = find(diff(presort)==0);
out=in;

if ~isempty(trouble)
    for index2 = 1: length(trouble)
        out(I(trouble(index2)+1)) = in(I(trouble(index2)+1))+rand(1)/100000;
    end
end

