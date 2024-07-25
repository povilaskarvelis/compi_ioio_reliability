% -------------------------------------------------------------------------
% Function that tests HGF implementation.
% -------------------------------------------------------------------------


%% Specify subject and model
options = compi_ioio_options('ioio','eeg','all');
%subjects = {'0063', '0052', '0116'};
%subjects = {'0067', '0116'};
subjects = {'0068'};
model = 3;


%% Remove other versions of the HGF
%rmpath(genpath(fullfile(options.roots.code, 'toolboxes', 'HGF_3.0')));
%rmpath(genpath(fullfile(options.coderoot, 'Toolboxes', 'BehavioralModeling')));


for idx_s = 1:length(subjects)
    % Get subject
    subject = subjects{idx_s};
    
    % Get models
    [prc_model, obs_model] = get_obs_and_prc_model(model,options);
    
    
    % Get subject specific paths
    details = compi_get_subject_details(subject, options);
    files = details.files.behav{1};
    
    % Get data
    data = compi_ioio_get_data(files, details, options);
    
    
    % Invert
    [est, perf] = train_hgf(data, prc_model, obs_model);
    
    % Plot
    fh = plot_hgf_binary_traj(est, perf, 'on');
    set(fh,'Name',['Suject: ' subject]);
end


