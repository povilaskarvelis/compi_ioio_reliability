function compi_write_behav_summary_table(options)


%% Get important parameters
subjects = options.subjects.all;
group = compi_get_group_labels(options, subjects);
nt = options.behav.last_trial;
covars = compi_get_covariates(options, subjects);
details = compi_get_subject_details(subjects{1}, options);
files = details.files.hgf_data;


%% Get choices
% Loop through HGF files
for i_file = 1:length(files)
    
    % Loop through subjects and extract advice taking
    choices = NaN(length(subjects), nt);
    for idx_subject = 1:length(subjects)
        % Get details
        id = options.subjects.all{idx_subject};
        details = compi_get_subject_details(id, options);
        
        % Load data
        load(details.files.hgf_data{i_file});

        % Store choices
        choices(idx_subject,:) = data.y(:,1);
    end
    
    % Write out table with all choices
    IDs = cellfun(@(c)['COMPI_' c], subjects, 'uni', false);
    T1 = array2table([IDs' group],'VariableNames', {'IDs' 'group'});
    trial_index = cellfun(@(c)['t' num2str(c)], num2cell(1:nt), 'uni', false);
    T2 = array2table(choices, 'VariableNames', trial_index);
    T  = [T1 covars T2];
    writetable(T,fullfile(options.roots.results_behav,...
        ['compi_choices_f' num2str(i_file) '.xlsx']));
    
    % Write out input
    input = array2table(data.input_u, 'VariableNames', {'advice','piechart'});
    writetable(input, fullfile(options.roots.results_behav,...
        ['compi_input_f' num2str(i_file) '.xlsx']));
    
end
