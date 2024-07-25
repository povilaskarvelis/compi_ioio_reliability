function run_group_comparison_on_parameters(params, param_names, groups, save_path, covars)





%% Defaults
if nargin < 5
    do_ANCOVA = 0;
else
    do_ANCOVA = 1;
end


%% Get parameter number
n_params = size(params,2);


%% ANCOVA
if do_ANCOVA
    % Prepare model data
    data{1} = groups;
    for i_cov = 1:size(covars,2)
        data{i_cov + 1} = table2array(covars(:,i_cov));
    end
    
    % Initialize
    p = NaN(n_params,1);
    F = NaN(n_params,1);
    h1 = NaN(n_params,1);
    
    for i_param = 1:n_params
        [p_temp, tbl]= anovan(params(:,i_param),data,'Continuous',[2 3],...
            'varnames',[{'group'}, covars.Properties.VariableNames],'display','off');
        p(i_param)    = p_temp(1);
        F(i_param) = tbl{2,6};
        h1(i_param)   =  p(i_param) < 0.05;
        clear tbl p_temp
    end
    
    % Write results table
    stats = table(param_names, h1, p, F);
    stats.Properties.VariableNames = {'parameter', 'H1', 'p', 'F'};
    writetable(stats,fullfile(save_path,'ANCOVA_group_comparison.xlsx'));
end

%% ANOVA
p = NaN(n_params,1);
F = NaN(n_params,1);
h1 = NaN(n_params,1);

for i_param = 1:n_params
    [p(i_param), tbl] = anova1(params(:,i_param), groups, 'off');
    F(i_param) = tbl{2,5};
    h1(i_param)   =  p(i_param) < 0.05;
    clear tbl
end

% Write results table
stats = table(param_names, h1, p, F);
stats.Properties.VariableNames = {'parameter', 'H1', 'p', 'F'};
writetable(stats,fullfile(save_path,'ANOVA_group_comparison.xlsx'));


%% Non-parametric group comparison
p = NaN(n_params,1);
chi2 = NaN(n_params,1);
h1 = NaN(n_params,1);

for i_param = 1:n_params
    [p(i_param), tbl] = kruskalwallis(params(:,i_param), groups, 'off');
    chi2(i_param)     = tbl{2,5};
    h1(i_param)       =  p(i_param) < 0.05;
    clear tbl
end

% Write results table
stats = table(param_names, h1, p, chi2);
stats.Properties.VariableNames = {'parameter', 'H1', 'p', 'chi2'};
writetable(stats,fullfile(save_path,'krushkalwallis_group_comparison.xlsx'));