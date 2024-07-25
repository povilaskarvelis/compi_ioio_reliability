function [params, grand_cor] = collect_all_estimated_hgf_params(files)
% -------------------------------------------------------------------------
% Function that collects parameters from all files passed to function and
% computes grand correlation across all files.
% -------------------------------------------------------------------------


%% Collect parameters and compute parameter correlation
% Get parameter overview for this model
load(files{1});
param_overview = get_hgf_param_overview(est);

% Initialize
n_params = length(param_overview.names);
params = NaN(length(files),n_params);
z_cor  = NaN(n_params,n_params,length(files));

% Cycle through subjects
for i_file = 1:length(files)
    % Get model parameters and parameter correlation
    [params(i_file,:), cor] = get_estimated_hgf_params(files{i_file}, param_overview);
    
    % Z-transform correlation
    cor(logical(eye(size(cor)))) = 1; % make sure diagonal is exactly 1
    z_cor(:,:,i_file) = fisher_z(cor); % Z transformation
    clear cor
end

% Compute grand parameter correlation
z_grand_cor = mean(z_cor,3);
grand_cor = inv_fisher_z(z_grand_cor);
grand_cor(logical(eye(size(grand_cor)))) = 1;


