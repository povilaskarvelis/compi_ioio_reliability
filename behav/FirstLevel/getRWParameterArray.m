function [ parArray ] =  getRWParameterArray(nParameter,bopars)

mu     = bopars.p_prc.v_0;
al     = bopars.p_prc.al;

switch nParameter
    case 'mu'
        parArray=[0:mu/4:1];
    case 'al'
        parArray=[0.1:al/3.5:0.5];
end

end

