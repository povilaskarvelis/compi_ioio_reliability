function [ parArray ] =  getHGFv1ParameterArray(nParameter,bopars)

ka     = bopars.p_prc.ka(2);
om     = bopars.p_prc.om(2);
th     = bopars.p_prc.th;
mu2_0  = bopars.p_prc.mu_0(2);

switch nParameter
    case 'ka'
        parArray= [ka/3:ka/4:ka*2];
    case 'om'
        parArray= [om*3.8:0.8:om/2];
    case 'th'
        parArray= [th/1.8:th/4:th*3];
    case 'ze'
        parArray= [0:0.11:1];
    case 'mu2_0'
        parArray= [mu2_0/2.2:0.08:mu2_0*1.75];
end

end

