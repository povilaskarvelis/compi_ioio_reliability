function [params, cor] = get_estimated_hgf_params(file, param_overview)
% -------------------------------------------------------------------------
% Function that returns parameter estimates and their posterior correlation
% specified in 'param_overview' (can be computed with
% get_hgf_param_overview function) from the HGF specified in 'file'.
% -------------------------------------------------------------------------


%% Load HGF file
load(file);


%% Initialize
n_pars = length(param_overview.names);
params = NaN(1,n_pars);

for i_par = 1:n_pars
    % Get level index in HGF for ith parameter
    hgf_idx = param_overview.hgf_idx(i_par);
    
    % Get data from correct model (perceptual or observation model)
    field = getfield(est, ['p_' param_overview.hgf_models{i_par}]);
    
    % Get parameter of interest
    temp = getfield(field, param_overview.hgf_names{i_par});
    params(i_par) = temp(hgf_idx);
end

cor = est.optim.Corr;


