function compi_compute_hgf_confusion_matrix(options, load_F)




%% Defaults
if nargin < 2
    load_F = 0;
end


%% Get variables
models   = options.hgf.models;
subjects = options.subjects.all;
noise    = options.hgf.sim_noise;
n_seeds  = length(options.hgf.seeds);


%% Get F if it should not be loaded
if ~load_F
    
    % Cycle through simulation seeds
    for idx_seed = 1:n_seeds
        seed = options.hgf.seeds(idx_seed);
        fprintf('\n-------------------\n Seed: %d', seed);
        
        % Cycle through noise levels
        for n = noise
            fprintf('\n Noise level: \x03B7 = %d',n);
            % Initialize file cell array
            files = cell(length(subjects),length(models),length(models));
            
            % Cycle through models, true models, and subjects
            for idx_tm = models
                for idx_m = models
                    for idx_s = 1:length(subjects)
                        % Get subject details
                        details = compi_get_subject_details(subjects{idx_s},options);
                        % Get model file name
                        [~ , model_file] = fileparts(details.files.hgf_models{idx_m});
                        if isnan(seed)
                            file_name = [model_file '_sim_n' num2str(n) ...
                                '_m' num2str(idx_m) '_tm' num2str(idx_tm) '_noseed'];
                        else
                            file_name = [model_file '_sim_n' num2str(n) ...
                                '_m' num2str(idx_m) '_tm' num2str(idx_tm) '_s' num2str(seed)];
                        end
                        files{idx_s,idx_m,idx_tm} = ...
                            fullfile(details.dirs.sim_hgf_results, file_name);
                    end
                end
            end
            
            F = compi_get_F_hgf(files);
            
            % Save
            if isnan(seed)
                save_name = ['F_sim_n' num2str(n) '_noseed.mat'];
            else
                save_name = ['F_sim_n' num2str(n) '_s' num2str(seed) '.mat'];
            end
            save(fullfile(options.roots.results_hgf,...
                save_name),'F');
            clear save_name F files
        end
    end
end


%% Compute Confusion matrix
% Specify models
selected_models = models; % This is useful for manually running other comparisons
% selected_models = [1 3 4];
n_models = length(selected_models);

% Cycle through noise levels
for n = noise
    % Initialize C
    C = NaN(n_models, n_models, n_seeds);
    
    % Cycle through simulation seeds
    for idx_seed = 1:n_seeds
        seed = options.hgf.seeds(idx_seed);
        
        %% Load F
        if isnan(seed)
            load_name = ['F_sim_n' num2str(n) '_noseed.mat'];
        else
            load_name = ['F_sim_n' num2str(n) '_s' num2str(seed) '.mat'];
        end
        load(fullfile(options.roots.results_hgf,load_name));
        
        
        %% Compute confusion matrix
        options.DisplayWin = 0;
        options.verbose = 0;
        
        if ~any(any(isnan(F(:,selected_models,selected_models))))
            for idx_tm = 1:length(selected_models)
                [~, out]= compi_VBA_groupBMC(F(:,selected_models,selected_models(idx_tm))',options);
                C(idx_tm,:,idx_seed) = out.pxp;
            end
        else
            warning(sprintf('NaN found in free energy matrix for \x03B7 = %d Seed = %d', n, seed));
            warning('Skipping this seed.');
        end
        
        
        %% Plot confusion matrix for single seed
        plot_title = sprintf('HGF Confusion Matrix \x03B7 = %d Seed = %d', n, seed);
        plot_C(C(:,:,idx_seed), {options.hgf.model_names{selected_models}}, plot_title, 'on');
        
        % Create model naming string for figure
        if isequal(selected_models, models)
            m_string = '';
        else
            m_string = '_';
            for i = 1:n_models
                m_string = [m_string 'm' num2str(selected_models(i))];
            end
        end
        % Add seed to save name
        if isnan(seed)
            save_name = ['C_n' num2str(n) '_noseed' m_string];
        else
            save_name = ['C_n' num2str(n) '_s' num2str(seed) m_string];
        end
        saveas(gcf,fullfile(options.roots.diag_hgf, 'C', [save_name '.png']));
        clear F out save_name
        
        
    end
    
    
    %% Plot confusion matrix averaged over simulation seeds
    av_C = mean(C,3,'omitnan');
    plot_title = sprintf('HGF Av. Confusion Matrix \x03B7 = %d', n);
    plot_C(av_C, {options.hgf.model_names{selected_models}}, plot_title);
    
    % Create model naming string for figure
    if isequal(selected_models, models)
        m_string = '';
    else
        m_string = '_';
        for i = 1:n_models
            m_string = [m_string 'm' num2str(selected_models(i))];
        end
    end
    save_name = ['C_n' num2str(n) m_string];
    saveas(gcf,fullfile(options.roots.diag_hgf, [save_name '_av.png']));
    save(fullfile(options.roots.diag_hgf, 'C', [save_name '.mat']), 'C');
end
