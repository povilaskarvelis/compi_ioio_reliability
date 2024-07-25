function [p_prc,p_obs,lgstr] =  getHGFSpecificParameterArray(bopars,nParameter,s)

% Priors
averagemu2_0    = 0.5;
averageka       = 1.00;
averageom2      = -5;
averageTh       = -6;
averageZe       = 0.5;
averageBeta     = log(48);

switch nParameter
    case 'ka'
        ka=s;
        p_prc=[bopars.p_prc.p(1) averagemu2_0 bopars.p_prc.p(3:10) ka NaN averageom2 averageTh];
        p_obs=[averageZe averageBeta];
        lgstr = sprintf('/kappa = %3.1f', ka);
    case 'om'
        om=s;
        p_prc=[bopars.p_prc.p(1) averagemu2_0 bopars.p_prc.p(3:10) averageka NaN om averageTh];
        p_obs=[averageZe averageBeta];
        lgstr = sprintf('/omega = %3.1f', om);
    case 'th'
        th=s;
        p_prc=[bopars.p_prc.p(1) averagemu2_0 bopars.p_prc.p(3:10) averageka NaN averageom2 th];
        p_obs=[averageZe averageBeta];
        lgstr = sprintf('/theta = %3.1f', th);
    case 'mu2_0'
        mu2_0=s;
        p_prc=[bopars.p_prc.p(1) mu2_0 bopars.p_prc.p(3:10) averageka NaN averageom2 averageTh];
        p_obs=[averageZe averageBeta];
        lgstr = sprintf('/mu_2 = %3.1f', mu2_0);        
    case 'ze'
        ze=s;
        p_prc=[bopars.p_prc.p(1) averagemu2_0 bopars.p_prc.p(3:10) averageka NaN averageom2 averageTh];
        p_obs=[ze averageBeta];
        lgstr = sprintf('/zeta = %3.1f', ze);
end
end

