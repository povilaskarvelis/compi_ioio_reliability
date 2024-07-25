function compi_simulate_hgf_data(options)
%--------------------------------------------------------------------------
% Function that runs simulates new data from inverted HGFs under noise
% levels specified in in compi_ioio_hgf_options.
%--------------------------------------------------------------------------


%% Get subjects
subjects   = options.subjects.all;
noise      = options.hgf.sim_noise;
models     = options.hgf.models;

n_subjects = length(subjects);
n_models   = length(models);
n_seeds    = length(options.hgf.seeds);

%% Create single HGF seeds
% Creating different seeds based on the seeds set in hgf_options to ensure
% that the generated data is not identical.
all_sim_seeds = NaN(n_subjects, n_models,  n_seeds);
for idx_seed = 1:n_seeds
    if ~isnan(options.hgf.seeds(idx_seed)) % check if meta-seeds are specified
        rng(options.hgf.seeds(idx_seed)) % use meta-seed to define all seeds
    end
    all_sim_seeds(:,:,idx_seed) = randi(999999, n_subjects, n_models);
end
save(fullfile(options.roots.diag_hgf, 'all_sim_seeds.mat'), 'all_sim_seeds');


%% Simulate
for n = noise
    fprintf('\n\n-------------------\nNoise level: \x03B7 = %d\n-------------------\n',n);
    for idx_m = 8%models        
        fprintf('\n-------------------\nModel: %02d', idx_m);
        
        % Get model name
        [prc_model, obs_model] = get_obs_and_prc_model(idx_m,options);
        
        for idx_s = 1:length(subjects)
            
            % Get subject details
            details = compi_get_subject_details(subjects{idx_s},options);
            fprintf('\n Simulating data for subject: %s...\n', details.id);
            
            % Load model
            if strcmp(options.task.modality,'test_retest')   
                load(details.files.hgf_models{1,idx_m});
                [~ , model_file] = fileparts(details.files.hgf_models{1,idx_m});            
            else
                load(details.files.hgf_models{idx_m});
                [~ , model_file] = fileparts(details.files.hgf_models{idx_m});
            end
            
            % Cycle through simulation seeds and simulate data
            for idx_seed = 1:length(options.hgf.seeds)
                meta_seed = options.hgf.seeds(idx_seed);
                seed = all_sim_seeds(idx_s, models(idx_m), idx_seed);
                
                % Simulate
                sim = tapas_simModel(est.u,...
                    erase(prc_model,'_config'), est.p_prc.p,...
                    erase(obs_model,'_config'), [est.p_obs.p n],...
                    seed);
                
                % Save
                if isnan(isnan(options.hgf.seeds(1)))
                    save_name = [model_file '_sim_n' num2str(n) '_noseed'];
                else
                    save_name = [model_file '_sim_n' num2str(n) '_s' num2str(meta_seed)];
                end
                save(fullfile(details.dirs.sim_hgf_data, save_name),'sim');
                
                % Clean up
                clear sim
            end
            
            % Clean up
            clear est
        end
    end
end
fprintf('\n-------------------\nComplete.\n-------------------\n');


