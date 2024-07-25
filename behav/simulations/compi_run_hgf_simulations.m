function compi_run_hgf_simulations(options)
%--------------------------------------------------------------------------
% Function that runs hgf simulations (also computes confusion matrix and
% parameter recoverability).
%--------------------------------------------------------------------------


%% Settings
offline = 1;

%% Get important variables
models = options.hgf.models;
subjects = options.subjects.all;
n_subjects = length(subjects);


%% Create directories
for idx_s = 1:n_subjects
    details = compi_get_subject_details(subjects{idx_s},options);
    mkdir(details.dirs.sim_hgf_data);
    mkdir(details.dirs.sim_hgf_results);
end


%% Simulate data
compi_simulate_hgf_data(options);


%% Invert on simulated data

% parameter recovery for each model
for idx_m = models
    w{idx_m,idx_m} = compi_invert_on_simulated_hgf_data(idx_m, idx_m, options);
end

% model recovery across all models
for idx_tm = models
    for idx_m = models
        w{idx_m,idx_tm} = compi_invert_on_simulated_hgf_data(idx_m, idx_tm, options);
    end
end


%% Compute confusion matrix
addpath(genpath(fullfile(options.roots.toolboxes, 'VBA')));
compi_compute_hgf_confusion_matrix(options);
rmpath(genpath(fullfile(options.roots.toolboxes, 'VBA')));


%% Compute parameter recoverability of all models
compi_compute_hgf_parameter_recoverability(options);


%% Print warning
% sprintf('\n\n-------------------\nSummary warnings\n-------------------\n');
% if offline 
%     for idx_m = models
%         for idx_tm = models 
%             fprintf('True model: %02d\nInverted model: %02d\n', idx_tm, idx_m);
%             for i = 1:length(w{idx_m,idx_tm}); warning(w{idx_m,idx_tm}{i}); end
%         end
%     end
% end

end

