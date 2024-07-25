function [post,out] = compi_hgf_bms(options, load_F)
%--------------------------------------------------------------------------
% Function that computes Bayesian model selection for HGF model space
% specified in compi_ioio_hgf_options.
%--------------------------------------------------------------------------


%% Defaults
if nargin < 2
   load_F  = 0;  % Load F (1) or compute F from scratch (0) 
end


%% Paths
addpath(genpath(fullfile(options.roots.toolboxes, 'VBA')));


%% Get free energy
subjects   = options.subjects.all;
models     = options.hgf.models;
n_models   = length(options.hgf.models);
n_subjects = length(subjects);
group = compi_get_group_labels(options, subjects);
covars = compi_get_covariates(options, subjects);

if load_F
    load(fullfile(options.roots.results_hgf, 'F_hgf.mat'));
else
    % Write cell array with model files
    files = cell(n_subjects, n_models);
    for idx_s = 1:n_subjects
        % Get subject details
        details = compi_get_subject_details(subjects{idx_s},options);
        % Write out model file path
        if size(details.files.hgf_models,1) == 2
            if details.eeg_first==1
                files1(idx_s,:) = details.files.hgf_models(1,:);
                files2(idx_s,:) = details.files.hgf_models(2,:);
            else
                files1(idx_s,:) = details.files.hgf_models(2,:);
                files2(idx_s,:) = details.files.hgf_models(1,:);
            end
        else
            files(idx_s,:) = details.files.hgf_models;
        end
    end

    % Get F
    if size(details.files.hgf_models,1) == 2
        F1 = compi_get_F_hgf(files1);
        F2 = compi_get_F_hgf(files2);

        % Save F
        save(fullfile(options.roots.results_hgf, 'F_hgf.mat'),'F1','F2')
        
        % Save F as table
        IDs = cellfun(@(c)['COMPI_' c], subjects, 'uni', false);
        T1 = array2table([IDs' group],'VariableNames', {'subject' 'group'});
        T2 = [covars array2table(F1) array2table(F2)];
        T  = [T1 T2];
        writetable(T,fullfile(options.roots.results_hgf, 'F_hgf.xlsx'));

    else
        F = compi_get_F_hgf(files);

        % Save F
        save(fullfile(options.roots.results_hgf, 'F_hgf.mat'),'F');

        % Save F as table
        IDs = cellfun(@(c)['COMPI_' c], subjects, 'uni', false);
        T1 = array2table([IDs' group],'VariableNames', {'subject' 'group'});
        T2 = [covars array2table(F)];
        T  = [T1 T2];
        writetable(T,fullfile(options.roots.results_hgf, 'F_hgf.xlsx'));
    end
end


%% BMS
model_names = options.hgf.model_names(models);

if size(details.files.hgf_models,1) == 2

    [post1,out1]= compi_VBA_groupBMC(F1');
    
    save_name = fullfile(options.roots.results_hgf,'hgf_bms');
    saveas(gcf,[save_name '_vba_fig_session1.fig']);
    saveas(gcf,[save_name '_vba_fig_session1.png']);

    [post2,out2]= compi_VBA_groupBMC(F2');

    saveas(gcf,[save_name '_vba_fig_session2.fig']);
    saveas(gcf,[save_name '_vba_fig_session2.png']);

    F = F1 + F2;
    
    [post,out]= compi_VBA_groupBMC(F');

    saveas(gcf,[save_name '_vba_fig_combined.fig']);
    saveas(gcf,[save_name '_vba_fig_combined.png']);

    % Save
    
    save([save_name '_results.mat'],'post1','out1','post2','out2');
    
    % Summary figure
    fh1 = plot_bms(out1, model_names);
    save_name = fullfile(options.roots.results_hgf, 'hgf_summary_bms');
    saveas(fh1,[save_name '_sesison1.png']);

    fh2 = plot_bms(out2, model_names);
    save_name = fullfile(options.roots.results_hgf, 'hgf_summary_bms');
    saveas(fh2,[save_name '_sesison2.png']);
    
    fh = plot_bms(out, model_names);
    save_name = fullfile(options.roots.results_hgf, 'hgf_summary_bms');
    saveas(fh,[save_name '_combined.png']);

else
    [post,out]= compi_VBA_groupBMC(F');

    % Save
    save_name = fullfile(options.roots.results_hgf,'hgf_bms');
    save([save_name '_results.mat'],'post','out');
    saveas(gcf,[save_name '_vba_fig.fig']);
    saveas(gcf,[save_name '_vba_fig.png']);
    
    % Summary figure
    fh = plot_bms(out, model_names);
    save_name = fullfile(options.roots.results_hgf, 'hgf_summary_bms');
    saveas(fh,[save_name '.png']);
end



rmpath(genpath(fullfile(options.roots.toolboxes, 'VBA')));

