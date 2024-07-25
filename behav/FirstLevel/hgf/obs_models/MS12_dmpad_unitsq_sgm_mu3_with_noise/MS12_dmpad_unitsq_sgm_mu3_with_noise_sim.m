function [y, prob, y_ch]  = MS12_dmpad_unitsq_sgm_mu3_with_noise_sim(r, infStates, p)
% Simulates observations from a Bernoulli distribution
%
% --------------------------------------------------------------------------------------------------
% Copyright (C) 2012-2013 Christoph Mathys, TNU, UZH & ETHZ
%
% This file is part of the HGF toolbox, which is released under the terms of the GNU General Public
% Licence (GPL), version 3. You can redistribute it and/or modify it under the terms of the GPL
% (either version 3 or, at your option, any later version). For further details, see the file
% COPYING or <http://www.gnu.org/licenses/>.

mu1hat = infStates(:,1,1);
mu3hat = infStates(:,3,1);
c = r.u(:,2);

ze1 = p(1);
ze2 = p(2);

% Belief vector
b = ze1.*mu1hat + (1-ze1).*c;

% additional decision noise injected?
if length(p)<3
    eta = 0;
else
    eta = p(3);
end

beta = exp(-mu3hat) + exp(log(ze2) - eta);

% Apply the unit-square sigmoid to the inferred states
prob = b.^(beta)./(b.^(beta)+...
    (1-b).^(beta));

% Initialize random number generator
rng(0);
%rng('shuffle');

% Simulate
y = binornd(1, prob);

% Predicted choice
y_ch = single(prob >.5);

return;







