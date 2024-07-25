function [warnings, errors] = compi_invert_on_simulated_hgf_data(model, true_model, options)






%% Get variables
subjects = options.subjects.all;
noise    = options.hgf.sim_noise;
[prc_model, obs_model] = get_obs_and_prc_model(model, options);


%% Initalize
errors = cell(0);
warnings = cell(0);
i_err  = 1;
i_warn = 1;


%% Invert model
% Cycle through seeds
for idx_seed = 1:length(options.hgf.seeds)
    seed = options.hgf.seeds(idx_seed);
    fprintf('\n-------------------\nSeed: %d\n-------------------\n', seed);
    
    % Cycle through noise levels
    for n = noise
        fprintf('\n-------------------\nNoise level: \x03B7 = %d\n-------------------\n',n);
        
        % Cycle over all subjects
        for idx_s = 1:length(subjects)
            fprintf('\n\n-------------------\n');
            fprintf('True model: %02d\nInverted model: %02d\n', true_model, model);
            fprintf('Perceptual Model: %s\nObservational Model: %s\n', prc_model, obs_model);
            
            % Get subject details
            details = compi_get_subject_details(subjects{idx_s},options);
            fprintf('Inverting model: %02d for subject: %s...\n\n', model, subjects{idx_s});
            
            % Load simulated data from true model
            [~ , true_model_file] = fileparts(details.files.hgf_models{true_model});
            if isnan(seed)
                sim_data_file = [true_model_file '_sim_n' num2str(n) '_noseed'];
            else
                sim_data_file = [true_model_file '_sim_n' num2str(n) '_s' num2str(seed)];
            end
            load(fullfile(details.dirs.sim_hgf_data, sim_data_file));
            
            % Prepare data
            data.input_u = sim.u;
            data.y = sim.y;
            
            try
                % Invert model
                [est, perf] = train_hgf(data, prc_model, obs_model, seed);
                
                % Test for NaN in probabilities
                if any(isnan(perf.prob))
                    warnings{i_warn} = sprintf(...
                        'Found NaN probabilities in Subject %s m%d tm%d n%d',...
                        subjects{idx_s}, model, true_model,n);
                    i_warn = i_warn +1;
                end
                
                % Save models
                [~ , model_file] = fileparts(details.files.hgf_models{model});
                if isnan(seed)
                    save_name = [model_file '_sim_n' num2str(n) '_m' num2str(model)...
                        '_tm' num2str(true_model) '_noseed'];
                else
                    save_name = [model_file '_sim_n' num2str(n) '_m' num2str(model)...
                        '_tm' num2str(true_model) '_s' num2str(seed)];
                end
                save(fullfile(details.dirs.sim_hgf_results, save_name),'est','perf');
                
                % Clean up
                clear est perf
                
            catch err
                errors{i_err} = err;
                i_err = i_err +1;
                disp(err)
            end
            clear sim data
        end
    end
end


%% Display warnings
if ~isempty(warnings)
    fprintf('\n\n-------------------\nSummary warnings\n-------------------\n');
    fprintf('True model: %02d\nInverted model: %02d\n', true_model, model);
    for i = 1:length(warnings); warning(warnings{i}); end 
else
    fprintf('Processing ended without warnings.')
end
