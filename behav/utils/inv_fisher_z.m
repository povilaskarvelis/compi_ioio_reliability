function [r] = inv_fisher_z(z)
%IFISHERZ Inverse Fisher's Z-transform.
%   R = IFISHERZ(Z) re-transforms Z into the correlation coefficient R.

%20080103, Thomas Zoeller (tzo@gmx.de)

% Save size
dims = size(z);

z = z(:);
r = (exp(2*z)-1)./(exp(2*z)+1);

% Reshape
r = reshape(r,dims);