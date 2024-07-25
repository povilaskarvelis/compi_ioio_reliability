function [logp, yhat, res] = MS10_dmpad_unitsq_sgm_mu3_with_noise(r, infStates, ptrans)
% Calculates the log-probability of response y=1 under the unit-square sigmoid model
%
% --------------------------------------------------------------------------------------------------
% Copyright (C) 2012-2013 Christoph Mathys, TNU, UZH & ETHZ
% modified by Andreea Diaconescu for IOIO on 27/10/2017
%
% This file is part of the HGF toolbox, which is released under the terms of the GNU General Public
% Licence (GPL), version 3. You can redistribute it and/or modify it under the terms of the GPL
% (either version 3 or, at your option, any later version). For further details, see the file
% COPYING or <http://www.gnu.org/licenses/>.

% Initialize returned log-probabilities as NaNs so that NaN is
% returned for all irregualar trials
n = size(infStates,1);
logp = NaN(n,1);
yhat = NaN(n,1);
res  = NaN(n,1);

% Weed irregular trials out from inferred states and responses
mu1hat = infStates(:,1,1);
mu1hat(r.irr) = [];
mu3hat = infStates(:,3,1);
mu3hat(r.irr) = [];
c = r.u(:,2);
c(r.irr) = [];
y = r.y(:,1);
y(r.irr) = [];

% Social bias is ze1
% Decision temperature is a function of the decision temperature and the exponential of log-volatility
% (i.e., inverse decision temperature is exponential of negative log-volatility)
ze1 = tapas_sgm(ptrans(1),1);
ze2 = exp(ptrans(2));
ze = exp(-mu3hat) + exp(log(ze2));

% Avoid any numerical problems when taking logarithms close to 1
x = ze1.*mu1hat + (1-ze1).*c;
logx = log(x);
log1pxm1 = log1p(x-1);
logx(1-x<1e-4) = log1pxm1(1-x<1e-4);
log1mx = log(1-x);
log1pmx = log1p(-x);
log1mx(x<1e-4) = log1pmx(x<1e-4);

% Calculate log-probabilities for non-irregular trials
reg = ~ismember(1:n,r.irr);
logp(reg) = y.*ze.*(logx -log1mx) +ze.*log1mx -log((1-x).^ze +x.^ze);
yhat(reg) = x;
res(reg) = (y-x)./sqrt(x.*(1-x));


return;
