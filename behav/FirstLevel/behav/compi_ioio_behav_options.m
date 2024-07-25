function [options] = compi_ioio_behav_options(options)
% -------------------------------------------------------------------------
% Function that appends option structure with all options relevant to
% behavioral analysis.
% -------------------------------------------------------------------------



%% Analysis options
% Select analysis steps
options.behav.pipe.executeStepsPerSubject = {
    'behaviour',
    'writeATSummaryTable',
    'writeBehavSummaryTable'};

% Last trial
switch options.task.modality
    case 'eeg'
        options.behav.last_trial = 170;
    case {'fmri', 'test_retest'}
        options.behav.last_trial = 153;
    case 'test_retest_136'
        options.behav.last_trial = 136;
    case {'phase','hgf_comp'}
        options.behav.last_trial = 153;
end

% Create ouput directory
options.roots.results_behav = fullfile(options.roots.results,'results_behav');
mkdir(options.roots.results_behav);
