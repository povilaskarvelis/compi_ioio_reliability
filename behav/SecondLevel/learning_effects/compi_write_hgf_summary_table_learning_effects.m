function compi_write_hgf_summary_table_learning_effects(options,m)
%--------------------------------------------------------------------------
% Function that writes out relevant behavioral measures.
%
% IN:
%   options                 -> Analysis options obtained by running
%                              compi_ioio_options
%
%   m                       -> The number of the winning model
%
% OUT:
%   sum_behav_measures      -> Summary table of hgf parameters
%
%--------------------------------------------------------------------------


%% Extract behavior
n_subjects = length(options.subjects.all);
ID = cell(n_subjects,1);

for idx_subject = 1:n_subjects
    
    % Get subject details
    id = options.subjects.all{idx_subject};
    details = compi_get_subject_details(id, options);
    
    % Switch between files depending on measurement order
    switch id
        % Subjects that performed EEG first
        case options.subjects.eeg_1st
            % Load EEG data
            load(details.files.hgf_models{1,m});
            
            % Collect params
            eeg_1st(idx_subject,1)         = 1;
            ID{idx_subject}                = details.id;
            
            mu0_2_t1(idx_subject,1)        = est.p_prc.mu_0(2);
            mu0_3_t1(idx_subject,1)        = est.p_prc.mu_0(3);
            ka_2_t1(idx_subject,1)         = est.p_prc.ka(2);
            om_2_t1(idx_subject,1)         = est.p_prc.om(2);
            ze_t1(idx_subject,1)           = est.p_obs.ze1;
            nu_t1(idx_subject,1)           = est.p_obs.ze2;

            if m ~= 1
                m_3_t1(idx_subject,1)      = est.p_prc.m(3);
            end

            all_est{idx_subject,1} = est;
            
            % Load fMRI data
            clear est;
            load(details.files.hgf_models{2,m});
            
            % Collect params
            mu0_2_t2(idx_subject,1)        = est.p_prc.mu_0(2);
            mu0_3_t2(idx_subject,1)        = est.p_prc.mu_0(3);
            ka_2_t2(idx_subject,1)         = est.p_prc.ka(2);
            om_2_t2(idx_subject,1)         = est.p_prc.om(2);
            ze_t2(idx_subject,1)           = est.p_obs.ze1;
            nu_t2(idx_subject,1)           = est.p_obs.ze2;
            
            if m ~= 1
                m_3_t2(idx_subject,1)      = est.p_prc.m(3);
            end

            all_est{idx_subject,2} = est;

        otherwise   
             % Load fMRI data
            load(details.files.hgf_models{2,m});
            
            % Collect params
            eeg_1st(idx_subject,1)         = 0;
            ID{idx_subject}                = details.id;
            
            mu0_2_t1(idx_subject,1)        = est.p_prc.mu_0(2);
            mu0_3_t1(idx_subject,1)        = est.p_prc.mu_0(3);
            ka_2_t1(idx_subject,1)         = est.p_prc.ka(2);
            om_2_t1(idx_subject,1)         = est.p_prc.om(2);
            ze_t1(idx_subject,1)           = est.p_obs.ze1;
            nu_t1(idx_subject,1)           = est.p_obs.ze2;

            if m ~= 1
                m_3_t1(idx_subject,1)      = est.p_prc.m(3);
            end

            all_est{idx_subject,1} = est;
            
            % Load EEG data
            clear est;
            load(details.files.hgf_models{1,m});
            
            % Collect params
            mu0_2_t2(idx_subject,1)        = est.p_prc.mu_0(2);
            mu0_3_t2(idx_subject,1)        = est.p_prc.mu_0(3);
            ka_2_t2(idx_subject,1)         = est.p_prc.ka(2);
            om_2_t2(idx_subject,1)         = est.p_prc.om(2);
            ze_t2(idx_subject,1)           = est.p_obs.ze1;
            nu_t2(idx_subject,1)           = est.p_obs.ze2;

            if m ~= 1
                m_3_t2(idx_subject,1)      = est.p_prc.m(3);
            end

            all_est{idx_subject,2} = est;
            
    end
end


%% Write out table and save it
if m == 1

    T = table(ID,eeg_1st,mu0_2_t1,mu0_2_t2,mu0_3_t1,mu0_3_t2,...
        ka_2_t1,ka_2_t2,om_2_t1,om_2_t2,ze_t1,ze_t2,nu_t1,nu_t2);
else

    T = table(ID,eeg_1st,mu0_2_t1,mu0_2_t2,mu0_3_t1,mu0_3_t2,m_3_t1,m_3_t2,...
        ka_2_t1,ka_2_t2,om_2_t1,om_2_t2,ze_t1,ze_t2,nu_t1,nu_t2);
end

if m == 1
    ofile = fullfile(options.roots.results_hgf, 'sum_hgf_s_params.xlsx');
elseif m == 3
    ofile = fullfile(options.roots.results_hgf, 'sum_hgf_params.xlsx');
elseif m == 5
    ofile = fullfile(options.roots.results_hgf, 'sum_hgf_1_params.xlsx');
elseif m == 6
    ofile = fullfile(options.roots.results_hgf, 'sum_hgf_2_params.xlsx');
elseif m == 7
    ofile = fullfile(options.roots.results_hgf, 'sum_hgf_3_params.xlsx');
elseif m == 8
    ofile = fullfile(options.roots.results_hgf, 'sum_hgf_4_params.xlsx');
end


writetable(T, ofile);

% ofile = fullfile(options.roots.results_hgf, 'hgf_est.mat');
% save(ofile,'all_est')
