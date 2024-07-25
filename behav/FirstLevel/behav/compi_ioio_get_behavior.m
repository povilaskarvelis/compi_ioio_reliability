function full_behavior = compi_ioio_get_behavior(id, options)


%% Get subject details
details = compi_get_subject_details(id, options);


%% Collect files depending on currently chosen modality
files = details.files.behav;


for i_file = 1:length(files)
    %% Get data and behavioral measures
    [data, behav_measures, trial_data] = compi_ioio_get_data(files{i_file}, details, options);    

    %% Save
    mkdir(details.dirs.results_behav);
    
    % Data
    save(details.files.hgf_data{i_file}, 'data');
    
    % Behavioral measures
    save(details.files.behav_measures{i_file}, 'behav_measures');
   
    % Trial data for neuroimaging analysis
    save(details.files.trial_data{i_file}, 'trial_data');

    % Store to have long format for other analyses
    behavior{i_file} = trial_data; 
end

%% Reorganize full behavioral data

if numel(files) > 1
        % add session number
        behavior{1}.session = ones(size(behavior{1},1),1);
        behavior{2}.session = ones(size(behavior{1},1),1)*2;
        
        % concatenate
        full_behavior = [behavior{1}; behavior{2}];
        
        % rearrange
        full_behavior = full_behavior(:,[end, 1:end-1]);
else
        full_behavior = behavior{1};
end

end

