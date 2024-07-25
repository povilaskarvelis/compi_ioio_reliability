function [sum_behav_measures] = compi_create_phase_table(options)
%--------------------------------------------------------------------------
% Function that writes out relevant behavioral measures for master thesis
% of Michelle Wobmann.
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
    if details.eeg_first
        load(fullfile(details.files.behav_measures_eeg));
    else
        load(fullfile(details.files.behav_measures_fmri));
    end
    
    % Collect advice taking
    ID{idx_subject}            = details.id;
    AT_total(idx_subject,1)    = behav_measures.AT_total;
    AT_stable_I(idx_subject,1) = behav_measures.AT_stable_I;
    AT_volatile(idx_subject,1) = behav_measures.AT_volatile;
end


sum_behav_measures = table(ID, AT_total, AT_stable_I, AT_volatile);

ofile = fullfile(options.roots.results,'sum_behav_measures.xlsx');
writetable(sum_behav_measures, ofile);



