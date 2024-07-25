function [covars] = compi_get_covariates(options,IDs)


T = readtable(fullfile(options.roots.data, 'clinical', 'input_mask_LM.xlsx'));

age = NaN(length(IDs),1);
wm = NaN(length(IDs),1);
antipsych = NaN(length(IDs),1);
antidep =  NaN(length(IDs),1);

for idx = 1:length(IDs)
    row = strcmp(T.id, ['COMPI_' IDs{idx}]);
    
    age(idx) = T.SocDem_age(row);
    wm(idx) = T.DS_backward(row);
    antipsych(idx) = T.medication_antipsych_T0(row);
    antidep(idx) = T.medication_antidep_T0(row);
end

covars = array2table([age wm antipsych antidep]);
covars.Properties.VariableNames = {'age', 'wm', 'antipsych', 'antidep'};