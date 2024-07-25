function [ parArray ] =  getAR1ParameterArray(nParameter,bopars)

ka     = 1;
om     = bopars.p_prc.om(2);
th     = bopars.p_prc.om(3);
m2     = 0;

switch nParameter
    case 'ka'
        parArray= [ka/1.8:ka/4:ka*3];
    case 'om'
        parArray= [om*2:0.8:om/2];
    case 'th'
        parArray= [th*1.5:0.65:th/1.5];
    case 'ze'
        parArray= [0:0.11:1];
    case 'm2'
        parArray= [-2:0.5:1];
end

end

