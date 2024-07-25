function [sum_behav_measures] = compi_write_AT_summary_table(options)
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


n_subjects = length(options.subjects.all);
ID = cell(n_subjects,1);

for idx_subject = 1:n_subjects
    
    % Get subject details
    id = options.subjects.all{idx_subject};
    details = compi_get_subject_details(id, options);
    
    % Load data
    load(details.files.behav_measures{1});
    
    % Collect advice taking
    ID{idx_subject}             = details.id;
    AT_total(idx_subject,1)     = behav_measures.AT_total;
    AT_stable_I(idx_subject,1)  = behav_measures.AT_stable_I;
    AT_volatile(idx_subject,1)  = behav_measures.AT_volatile;
    AT_stable_II(idx_subject,1) = behav_measures.AT_stable_II;
    
    % Collect performance measures
    AT_acc(idx_subject,1)       = behav_measures.AT_acc;
    CS(idx_subject,1)           = behav_measures.CS;
    
    % Collect other behavioral measures
    win_switch(idx_subject,1)   = behav_measures.win_switch;
    lose_stay(idx_subject,1)    = behav_measures.lose_stay;
    U(idx_subject,1)            = behav_measures.U;
    
end

T = table(ID, AT_total, AT_stable_I, AT_volatile,...
    AT_stable_II, AT_acc, CS, win_switch, lose_stay, U);

ofile = fullfile(options.roots.results_behav, 'sum_behav_measures.xlsx');
writetable(T, ofile);



