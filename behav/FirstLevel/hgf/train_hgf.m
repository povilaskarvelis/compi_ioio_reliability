function [est, perf] = train_hgf(train_data, prc_model, obs_model, seeds)
%--------------------------------------------------------------------------
% Function that trains HGF model on training data and computes performance.
%
% IN:
%   train_data (struct)
%   train_data.y            -> Responses of participant
%   train_data.input_u      -> Inputs that participant observes
%
%   prc_model               -> String containing configfile for HGF
%                              perceptual model
%
%   obs_model               -> String containing configfile for HGF
%                              observer model
%
%--------------------------------------------------------------------------



%% Defaults
if nargin < 4
    seed = [];
end


%% Fit model
est = tapas_fitModel(train_data.y, train_data.input_u, ...
    prc_model, ...
    obs_model);


%% Get model parameters
p_prc       = est.p_prc.p;   % get params from perceptual model
p_obs       = est.p_obs.p;   % get params from response model
input       = est.u;         % get inputs


%% Compute train performance
% get MAP response predictions
sim  = sim_resp_hgf(input,...
    prc_model, p_prc,...
    obs_model, p_obs,...
    est, seeds(1));             % will only use first seed

% Get true and predicted responses
perf.ch      = train_data.y(:,1); % save true choices
perf.pred_ch = sim.y;             % save predicted choices (prob > 0.5)
perf.samp_ch = sim.ch_sampled;    % save sampled choice
perf.prob    = sim.prob;          % save sampled choice

% Compute performance measures
[perf.bac, perf.acc, perf.auc, perf.all_measures] = ...
    compute_binary_performance_measures(perf.ch, perf.pred_ch, perf.prob);



