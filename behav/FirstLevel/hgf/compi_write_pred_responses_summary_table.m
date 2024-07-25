function compi_write_pred_responses_summary_table(options)



%% Get important parameters
subjects = options.subjects.all;
group = compi_get_group_labels(options, subjects);
nt = options.behav.last_trial;
covars = compi_get_covariates(options, subjects);
details = compi_get_subject_details(subjects{1}, options);
files = details.files.hgf_models;


%% Get choices
% Loop through HGF files
for i_model = 1:length(files)
    
    % Loop through subjects and extract advice taking
    predictions = NaN(length(subjects), nt);
    choices = NaN(length(subjects), nt);
    for idx_subject = 1:length(subjects)
        % Get details
        id = options.subjects.all{idx_subject};
        details = compi_get_subject_details(id, options);
        
        % Load data
        load(details.files.hgf_models{i_model});

        % Store choices
        predictions(idx_subject,:) = perf.prob;
        choices(idx_subject,:) = est.y(:,1);
    end
    
    % Write out table with all choices
    IDs = cellfun(@(c)['COMPI_' c], subjects, 'uni', false);
    T1 = array2table([IDs' group],'VariableNames', {'IDs' 'group'});
    trial_index = cellfun(@(c)['t' num2str(c)], num2cell(1:nt), 'uni', false);
    T2 = array2table(predictions, 'VariableNames', trial_index);
    T  = [T1 covars T2];
    writetable(T,fullfile(options.roots.diag_hgf,['m' num2str(i_model)],...
        'pred_responses.xlsx'));
    T3 = array2table(predictions, 'VariableNames', trial_index);
    T  = [T1 covars T3];
    writetable(T,fullfile(options.roots.results_behav,...
        'compi_choices.xlsx'));
end
