function [z] = fisher_z(r)

%FISHERZ Fisher's Z-transform.
% Z = FISHERZ(R) returns the Fisher's Z-transform of the correlation
% coefficient R.

% Save size
dims = size(r);

% Fisher transform
r = r(:);
z = .5.*log((1+r)./(1-r));

% Reshape
z = reshape(z,dims);

end