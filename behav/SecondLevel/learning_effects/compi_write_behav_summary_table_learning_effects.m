function [sum_behav_measures] = compi_write_behav_summary_table_learning_effects(options)
%--------------------------------------------------------------------------
% Function that writes out relevant behavioral measures.
%
% IN:
%   options                 -> Analysis options obtained by running
%                              compi_ioio_options
%
% OUT:
%   sum_behav_measures      -> Summary table of behavior
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
            load(details.files.behav_measures{1});
            
            eeg_1st(idx_subject,1)         = 1;
            ID{idx_subject}                = details.id;
            
            % Collect performance measures
            AT_acc_t1(idx_subject,1)       = behav_measures.AT_acc;
            CS_t1(idx_subject,1)           = behav_measures.CS;
            
            % Collect advice taking
            AT_total_t1(idx_subject,1)     = behav_measures.AT_total;
            AT_stable_t1(idx_subject,1)    = behav_measures.AT_stable;
            AT_volatile_t1(idx_subject,1)  = behav_measures.AT_volatile;
            AT_helpful_t1(idx_subject,1)   = behav_measures.AT_helpful;
            AT_unhelpful_t1(idx_subject,1) = behav_measures.AT_unhelpful;
            
            % Collect other behavioral measures
            win_stay_t1(idx_subject,1)     = behav_measures.win_stay;
            lose_switch_t1(idx_subject,1)  = behav_measures.lose_switch;
            U_t1(idx_subject,1)            = behav_measures.U;
            
            
            % Load fMRI data
            clear behav_measures;
            load(details.files.behav_measures{2});
            
            % Collect performance measures
            AT_acc_t2(idx_subject,1)       = behav_measures.AT_acc;
            CS_t2(idx_subject,1)           = behav_measures.CS;
            
            % Collect advice taking
            AT_total_t2(idx_subject,1)     = behav_measures.AT_total;
            AT_stable_t2(idx_subject,1)    = behav_measures.AT_stable;
            AT_volatile_t2(idx_subject,1)  = behav_measures.AT_volatile;
            AT_helpful_t2(idx_subject,1)   = behav_measures.AT_helpful;
            AT_unhelpful_t2(idx_subject,1) = behav_measures.AT_unhelpful;
            
            % Collect other behavioral measures
            win_stay_t2(idx_subject,1)     = behav_measures.win_stay;
            lose_switch_t2(idx_subject,1)  = behav_measures.lose_switch;
            U_t2(idx_subject,1)            = behav_measures.U;  
            
            
        otherwise   
            % Load fMRI data
            load(details.files.behav_measures{2});
            
            eeg_1st(idx_subject,1)         = 0;
            ID{idx_subject}                = details.id;
            
            % Collect performance measures
            AT_acc_t1(idx_subject,1)       = behav_measures.AT_acc;
            CS_t1(idx_subject,1)           = behav_measures.CS;
            
            % Collect advice taking
            AT_total_t1(idx_subject,1)     = behav_measures.AT_total;
            AT_stable_t1(idx_subject,1)    = behav_measures.AT_stable;
            AT_volatile_t1(idx_subject,1)  = behav_measures.AT_volatile;
            AT_helpful_t1(idx_subject,1)   = behav_measures.AT_helpful;
            AT_unhelpful_t1(idx_subject,1) = behav_measures.AT_unhelpful;
            
            % Collect other behavioral measures
            win_stay_t1(idx_subject,1)     = behav_measures.win_stay;
            lose_switch_t1(idx_subject,1)  = behav_measures.lose_switch;
            U_t1(idx_subject,1)            = behav_measures.U;
            
            % Load EEG data
            clear behav_measures;
            load(details.files.behav_measures{1});
            
            % Collect performance measures
            AT_acc_t2(idx_subject,1)       = behav_measures.AT_acc;
            CS_t2(idx_subject,1)           = behav_measures.CS;
            
            % Collect advice taking
            AT_total_t2(idx_subject,1)     = behav_measures.AT_total;
            AT_stable_t2(idx_subject,1)    = behav_measures.AT_stable;
            AT_volatile_t2(idx_subject,1)  = behav_measures.AT_volatile;
            AT_helpful_t2(idx_subject,1)   = behav_measures.AT_helpful;
            AT_unhelpful_t2(idx_subject,1) = behav_measures.AT_unhelpful;
            
            % Collect other behavioral measures
            win_stay_t2(idx_subject,1)     = behav_measures.win_stay;
            lose_switch_t2(idx_subject,1)  = behav_measures.lose_switch;
            U_t2(idx_subject,1)            = behav_measures.U;           
    end
end


%% Write out table and save it
T = table(ID,eeg_1st,CS_t1, CS_t2, AT_total_t1, AT_total_t2, AT_acc_t1,...
    AT_acc_t2, AT_stable_t1, AT_stable_t2, AT_volatile_t1, AT_volatile_t2,...
    AT_helpful_t1, AT_helpful_t2, AT_unhelpful_t1, AT_unhelpful_t2,...
    win_stay_t1, win_stay_t2, lose_switch_t1, lose_switch_t2, U_t1, U_t2);

ofile = fullfile(options.roots.results_behav, 'sum_behav_measures.xlsx');
writetable(T, ofile);



