function [group, group_num] = compi_get_group_labels(options,IDs)


T = readtable(fullfile(options.roots.data,'clinical','input_mask_LM.xlsx'));

group = cell(length(IDs),1);
group_num = NaN(length(IDs),1);

for idx = 1:length(IDs)
    row = strcmp(T.id, ['COMPI_' IDs{idx}]);
    
    group{idx} = T.group_verb{row};
    
    switch group{idx}
        case 'HC'
            group_num(idx) = 0;
        case 'CHR'
            group_num(idx) = 1;
        case 'FEP'
            group_num(idx) = 2;
        otherwise
            group_num(idx)= NaN;
    end
end

