function [p_prc,p_obs,lgstr] =  getAR1SpecificParameterArray(bopars,nParameter,s)

% Priors
averagemu2_0    = 0;
averageka       = 1.00;
averageom2      = -5;
averageTh       = -6;
averageZe       = 0.5;
averageBeta     = log(48);

switch nParameter
    case 'ka'
        ka=s;
        p_prc=[bopars.p_prc.p(1:10) averagemu2_0 bopars.p_prc.p(12:13) ...
            ka NaN averageom2 averageTh];
        p_obs=[averageZe averageBeta];
        lgstr = sprintf('/kappa = %3.1f', ka);
    case 'om'
        om=s;
        p_prc=[bopars.p_prc.p(1:10) averagemu2_0 bopars.p_prc.p(12:13) ...
            averageka NaN om averageTh];
        p_obs=[averageZe averageBeta];
        lgstr = sprintf('/omega = %3.1f', om);
    case 'th'
        th=s;
        p_prc=[bopars.p_prc.p(1:10) averagemu2_0 bopars.p_prc.p(12:13) ...
            averageka NaN averageom2 th];
        p_obs=[averageZe averageBeta];
        lgstr = sprintf('/theta = %3.1f', th);
    case 'm2'
        m2=s;
        p_prc=[bopars.p_prc.p(1) m2 bopars.p_prc.p(3:10) averagemu2_0 bopars.p_prc.p(12:13) ...
            averageka NaN averageom2 averageTh];
        p_obs=[averageZe averageBeta];
        lgstr = sprintf('/m2 = %3.1f', m2);        
    case 'ze'
        ze=s;
        p_prc=[bopars.p_prc.p(1:10) averagemu2_0 bopars.p_prc.p(12:13) ...
            averageka NaN averageom2 averageTh];
        p_obs=[ze averageBeta];
        lgstr = sprintf('/zeta = %3.1f', ze);
end
end

