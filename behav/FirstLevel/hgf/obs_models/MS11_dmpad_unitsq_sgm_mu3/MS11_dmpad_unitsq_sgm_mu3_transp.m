function [pvec, pstruct] = MS11_dmpad_unitsq_sgm_mu3_transp(r, ptrans)
% --------------------------------------------------------------------------------------------------
% Copyright (C) 2012-2013 Christoph Mathys, TNU, UZH & ETHZ
%
% This file is part of the HGF toolboMS11_dmpad_unitsq_sgm_mu3, which is released under the terms of the GNU General Public
% Licence (GPL), version 3. You can redistribute it and/or modify it under the terms of the GPL
% (either version 3 or, at your option, any later version). For further details, see the file
% COPYING or <http://www.gnu.org/licenses/>.

pvec    = [];
pstruct = struct;

pvec(1)     = tapas_sgm(ptrans(1),1);       % ze1
pstruct.ze1 = pvec(1);

return;