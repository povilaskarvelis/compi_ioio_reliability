function c = MS6_dmpad_unitsq_sgm_mu3_with_noise_config
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% Contains the configuration for the unit square sigmoid observation model for binary responses
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% The unit square sigmoid (ussgm) is the function
%
% f(x) = x^zeta/(x^zeta + (1-x)^zeta) = ustapas_sgm(x; zeta),
%
% where x is in the unit interval, and zeta > 0 is a parameter that determines the shape of the
% sigmoid. Since both its argument and value are always in the unit interval, its graph is
% restricted to the unit square, hence the name unit square sigmoid.
%
% In the application here, the ussgm is the probability of observing a decision y=1 (rather than
% the only alternative y=0) given the current probability mu1hat (or value) of input u=1:
%
% p(y=1|mu1hat) = tapas_sgm(mu1hat; zeta)
%
% The parameter zeta regulates the steepness of the sigmoid such that it forms the diagonal of
% the unit square for zeta=1 and approaches a step function at 0.5 as zeta approaches infinity.
% Values of 0 < zeta < 1 lead to sigmoids with reverse concavity than usual, but they still
% represent valid observation models.
%
% Zeta can be interpreted as inverse decision noise. To have a shrinkage prior on this, choose a
% high value. It is estimated log-space since it has a natural lower bound at zero.
%
% --------------------------------------------------------------------------------------------------
% Copyright (C) 2012-2013 Christoph Mathys, TNU, UZH & ETHZ
%
% This file is part of the HGF toolbox, which is released under the terms of the GNU General Public
% Licence (GPL), version 3. You can redistribute it and/or modify it under the terms of the GPL
% (either version 3 or, at your option, any later version). For further details, see the file
% COPYING or <http://www.gnu.org/licenses/>.

% Config structure
c = struct;

% Model name
c.model = 'MS6_dmpad_unitsq_sgm_mu3_with_noise';

% Sufficient statistics of Gaussian parameter priors

% Zeta_1
c.logitze1mu = tapas_logit(0.5,1); % 0;
c.logitze1sa = 1;

% Zeta_2
c.logze2mu = log(48);
c.logze2sa = 1;

% Gather prior settings in vectors
c.priormus = [
    c.logitze1mu,...
    c.logze2mu,...
    ];

c.priorsas = [
    c.logitze1sa,...
    c.logze2sa,...
    ];

% Model filehandle
c.obs_fun = @MS6_dmpad_unitsq_sgm_mu3_with_noise;

% Handle to function that transforms observation parameters to their native space
% from the space they are estimated in
c.transp_obs_fun = @MS6_dmpad_unitsq_sgm_mu3_with_noise_transp;

return;
