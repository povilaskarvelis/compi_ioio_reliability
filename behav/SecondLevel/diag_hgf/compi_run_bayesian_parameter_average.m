function compi_run_bayesian_parameter_average(options)
%--------------------------------------------------------------------------
% Function that runs Bayesian parameter average and repeats HGF diagnostic 
% (including paramter histograms, grouped parameter histograms, a grand 
% correlation plot, and preliminary statistical analysis on this averages. 
% Also writes out averaged model parameters and parameter correlations.
%--------------------------------------------------------------------------


%% Get subjects, group labels, covariates etc.
subjects = options.subjects.all;
models = options.hgf.models;
groups = compi_get_group_labels(options,subjects);
covars = compi_get_covariates(options,subjects);
n_subjects = length(subjects);
n_models = length(models);


%% Cycle through models
for idx_m = 1:n_models
    fprintf('\n-------------------\nModel: %02d', models(idx_m));
    save_path = fullfile(options.roots.diag_hgf,['m' num2str(models(idx_m))]);
    
    %% Write cell array with model files
    files = cell(n_subjects,1);
    for idx_s = 1:n_subjects
        % Get subject details
        details = compi_get_subject_details(subjects{idx_s},options);
        % Write out model file path
        files(idx_s, 1) = details.files.hgf_models(models(idx_m));
    end
    
    
    %% Get parameters for this model
    % Get parameter overview
    load(files{1});
    param_overview = get_hgf_param_overview(est);
    
    % Get parameters
    fprintf('\n Collecting parameters...');
    [params, grand_cor] = collect_all_estimated_hgf_params(files);
    
    
    %% Generate diagnostic plots
    fprintf('\n Plotting histograms...');
    % Histograms for all subjects together including prior
    plot_parameter_histogram(params, param_overview, save_path);
    
    % Histograms sorted by group
    plot_grouped_parameter_histogram(params, param_overview.names, groups, save_path)
    
    % Plot grand parameter correlation
    plot_grand_corr(grand_cor, param_overview.names, save_path);
    
    
    %% Run preliminary statistics
    fprintf('\n Running stats...');
    run_group_comparison_on_parameters(params, param_overview.names,...
        groups, save_path, covars)
    
    
    %% Save parameters
    fprintf('\n Saving parameters...');
    IDs = cellfun(@(c)['COMPI_' c], subjects, 'uni', false);
    T1 = array2table([IDs' groups],'VariableNames', {'subject' 'group'});    
    T2 = [covars array2table(params, 'VariableNames', param_overview.names')];
    T = [T1 T2];
    writetable(T, fullfile(save_path, 'hgf_parameters.xlsx'));
    clear T1 T2 T
    
    
    %% Save correlations
    T = array2table(grand_cor);
    T.Properties.VariableNames = param_overview.names;
    writetable(T, fullfile(save_path, 'hgf_parameter_grand_cor.xlsx'));
    clear T
    
    
end

fprintf('\n-------------------\nComplete.\n-------------------\n');


