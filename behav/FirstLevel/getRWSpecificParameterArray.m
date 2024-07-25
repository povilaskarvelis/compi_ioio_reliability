function [p_prc,p_obs,lgstr] =  getRWSpecificParameterArray(nParameter,parArray,iParameter,lgstr)

switch nParameter
    case 'al'
        al=parArray(iParameter);
        p_prc=[0.5 al];
        p_obs=[0.5 log(48)];
        lgstr{iParameter} = sprintf('/alpha = %3.1f', al);
    case 'mu'
        mu=parArray(iParameter);
        p_prc=[mu 0.16];
        p_obs=[0.5 log(48)];
        lgstr{iParameter} = sprintf('/mu = %3.1f', mu);
end
end

