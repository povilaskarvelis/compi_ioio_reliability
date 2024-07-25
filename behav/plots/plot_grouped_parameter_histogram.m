function plot_grouped_parameter_histogram(params, param_names, groups, save_path)
% -------------------------------------------------------------------------
% Function that plots paramater histograms per group.
%
% IN:
%   params      -> matrix with subjects by parameter dimensions
%   param_names -> cell array with parameter names
%   groups      -> cell array or numeric array with group indicators
%   save_path   -> path to location, where figure should be saved
% -------------------------------------------------------------------------


%% Plot group histograms
group_labels = unique(groups);
n_groups = length(group_labels);


for i_param = 1:size(params,2)
    min_param = min(params(:,i_param));
    max_param = max(params(:,i_param));
    
    fh = figure('Visible', 'off');
    for i_group = 1:n_groups
        h(i_group) = subplot(n_groups,1,i_group);
        
        % Get index for instances of group i
        if iscell(groups)
            idx = contains(groups,group_labels{i_group});
        else
            idx = groups == group_labels(i_group);
        end
        
        histogram(params(idx,i_param), 20,...
            'FaceColor', 'black','BinLimits',[min_param, max_param]);
        
        if iscell(groups)
            title(group_labels{i_group},'FontWeight','bold','FontSize',18);
        else
            title(num2str(group_labels(i_group)),'FontWeight','bold','FontSize',18);
        end
        
        if i_group == round(n_groups/2)
            ylabel('Counts','FontWeight','bold','FontSize',18)
        end
    end
    
    linkaxes(h)
    xlabel(param_names{i_param},'FontWeight','bold','FontSize',18)
    
    saveas(fh,...
        fullfile(save_path,...
        ['hist_grouped_' param_names{i_param} '.png']));
end

