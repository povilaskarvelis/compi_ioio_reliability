function compi_compute_hgf_parameter_recoverability(options)
% computes and plots parameter recoverability based on files saved during
% the 


%% Get Settings
subjects = options.subjects.all;


%% Cycle through all models
for idx_m = 1:length(options.hgf.models)
    m = options.hgf.models(idx_m);
    
    seeds_rparams = []; seeds_rparams_sHGF = [];
    % Cycle through simulation seeds
    for idx_seed = 1:length(options.hgf.seeds)
        seed = options.hgf.seeds(idx_seed);
        
        %% Write out model files
        emp_files = cell(length(subjects),1); % empirical model files
        sim_files = cell(length(subjects),1); % simulated model files
        
        for idx_s = 1:length(subjects)
            % Get subject details
            details = compi_get_subject_details(subjects{idx_s},options);
            % Write out model file path
            if strcmp(options.task.modality,'test_retest') 
                [~ , model_file] = fileparts(details.files.hgf_models{1,idx_m});
            else
                [~ , model_file] = fileparts(details.files.hgf_models{idx_m});
            end
            
            if isnan(seed)
                sim_file_name = [model_file '_sim_n0' ...
                    '_m' num2str(m) '_tm' num2str(m) '_noseed'];
            else
                sim_file_name = [model_file '_sim_n0'...
                    '_m' num2str(m) '_tm' num2str(m) '_s' num2str(seed)];
            end
            emp_files{idx_s, 1} = fullfile(details.dirs.results_hgf, model_file);
            sim_files{idx_s, 1} = fullfile(details.dirs.sim_hgf_results, sim_file_name);
        end
        
        
        %% Collect parameters
        fprintf('\n Collecting estimated parameters from empirical model...');
        params = collect_all_estimated_hgf_params(emp_files);

        % Tr = array2table(params);
        % Tr.Properties.VariableNames(1:4) = param_overview.names;
        % writetable(Tr,'sim_params_hgfmr_4.csv')
        
        fprintf('\n Collecting estimated parameters from simulated model...');
        sim_params = collect_all_estimated_hgf_params(sim_files);
        
        
        %% Get parameter names
        load(emp_files{1});
        param_overview = get_hgf_param_overview(est);
        param_names = param_overview.names;
        n_params = length(param_names);
        
        
        %% Plot recoverability
        fprintf('\n Plotting parameter recoverability...');

        % Pretty parameter names
        if m == 3
            param_names = {'\mu_{2}^{(0)}','\mu_{3}^{(0)}','m_3',...
                '\kappa_{2}','\omega_{2}','\zeta','\nu'};

            seeds_rparams = [seeds_rparams; ...
                idx_seed*ones(size(sim_params,1),1), [1:size(sim_params,1)]', sim_params];
        else

            seeds_rparams_sHGF = [seeds_rparams_sHGF; ...
                idx_seed*ones(size(sim_params,1),1), [1:size(sim_params,1)]', sim_params];
        end
        

        % figure('name', options.hgf.model_names{idx_m},...
        %     'units', 'normalized', 'outerposition', [0 0 1 1], 'Visible', 'on');
        % 
        % for i_p = 1:n_params            
        %     subplot(2,4,i_p)
        %     plot_ICC(params(:,i_p), sim_params(:,i_p),...
        %         [param_names{i_p} ' true'],[param_names{i_p} ' recovered'])
        % end
        
        % Save
%         if isnan(seed)
%             save_name = ['m' num2str(m) '_noseed_parameter_recoverability.png'];
%         else
%             save_name = ['m' num2str(m) '_s' num2str(seed) '_parameter_recoverability.png'];
%         end
%         saveas(gcf, fullfile(options.roots.diag_hgf, ['m' num2str(m)], save_name));
    end
    
    % if m == 3
    %     pn = {'seed','subID','mu0_2', 'mu0_3', 'm_3', 'ka_2', 'om_2', 'ze', 'nu'};
    % 
    %     Tr = array2table(seeds_rparams);
    %     Tr.Properties.VariableNames(1:9) = pn;
    %     writetable(Tr,'rec_params_20seeds_sHGF.csv')
    % elseif m ==1
    %     pn = {'seed','subID','mu0_2', 'mu0_3', 'ka_2', 'om_2', 'ze', 'nu'};
    % 
    %     Tr = array2table(seeds_rparams_sHGF);
    %     Tr.Properties.VariableNames(1:8) = pn;
    %     writetable(Tr,'rec_params_20seeds_sHGF.csv')
    % elseif m == 5
    %     pn = {'seed','subID', 'mu0_3', 'm3', 'ka_2', 'om_2', 'ze', 'nu'};
    % 
    %     Tr = array2table(seeds_rparams_sHGF);
    %     Tr.Properties.VariableNames(1:8) = pn;
    %     writetable(Tr,'rec_params_20seeds_hgfmr_1.csv')
    % elseif m == 6
    %     pn = {'seed','subID', 'mu0_2', 'mu0_3', 'm3', 'om_2', 'ze', 'nu'};
    % 
    %     Tr = array2table(seeds_rparams_sHGF);
    %     Tr.Properties.VariableNames(1:8) = pn;
    %     writetable(Tr,'rec_params_20seeds_hgfmr_2.csv')
    % elseif m == 7
    %     pn = {'seed','subID', 'mu0_3', 'm3', 'om_2', 'ze', 'nu'};
    % 
    %     Tr = array2table(seeds_rparams_sHGF);
    %     Tr.Properties.VariableNames(1:7) = pn;
    %     writetable(Tr,'rec_params_20seeds_hgfmr_3.csv')
    % 
    % elseif m == 8
    %     pn = {'seed','subID', 'm3', 'om_2', 'ze', 'nu'};
    % 
    %     Tr = array2table(seeds_rparams_sHGF);
    %     Tr.Properties.VariableNames(1:6) = pn;
    %     writetable(Tr,'rec_params_20seeds_hgfmr_4.csv')
    % 
    % end
end

