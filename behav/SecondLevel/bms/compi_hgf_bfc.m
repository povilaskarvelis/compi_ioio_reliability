function [post,out] = compi_hgf_bfc(options, load_F)
%--------------------------------------------------------------------------
% Function that computes Bayesian family comparison for HGF model space
% specified in compi_ioio_hgf_options.
%--------------------------------------------------------------------------


%% Defaults
if nargin < 2
   load_F  = 0;  % Load F (1) or compute F from scratch (0) 
end


%% Paths
% Add VBA toolbox to path
addpath(genpath(fullfile(options.roots.code, 'toolboxes', 'VBA')));


%% Get free energy
% Write out model files
subjects   = options.subjects.all;
models     = options.hgf.models;
n_models   = length(options.hgf.models);
n_subjects = length(subjects);

if load_F
    load(fullfile(options.roots.results_hgf, 'F_hgf.mat'));
else
    % Write cell array with model files
    files = cell(n_subjects, n_models);
        for idx_s = 1:n_subjects
            % Get subject details
            details = compi_get_subject_details(subjects{idx_s},options);
            % Write out model file path
            files(idx_s,:) = details.files.hgf_models;
        end

    % Get F
    F = compi_get_F_hgf(files);
    
    % Save F
    save(fullfile(options.roots.results_hgf, 'F_hgf.mat'),'F');
end


%% Bayesian family comparison
for i_fam = 1:length(options.hgf.families)
    vba_options.families = options.hgf.families{i_fam};
    [post,out]= VBA_groupBMC(F', vba_options);
    
    family_names = options.hgf.family_names{i_fam};
    family_title = options.hgf.family_titles{i_fam};
    fh = plot_bfc(out, family_names, family_title);
       
    % Save
    save_name = fullfile(options.roots.results_hgf,...
        ['hgf_summary_bfc_fam' num2str(i_fam)]);
    
    save([save_name '.mat'],'post','out');
    saveas(fh,[save_name '.fig']);
    saveas(fh,[save_name '.png']);
    
    rmpath(genpath(fullfile(options.roots.code, 'toolboxes', 'VBA')));
end


