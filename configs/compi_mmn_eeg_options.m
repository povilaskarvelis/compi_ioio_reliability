function [options] = compi_mmn_eeg_options(options)



options.eeg.mmn.preproc.rereferencing       = 'avref'; % avref, noref
options.eeg.mmn.preproc.trialdef            = 'tone'; % tone, oddball
options.eeg.mmn.preproc.trlshift            = 25; % set to 125 for pilots in anta?
options.eeg.mmn.preproc.epochwin            = [-100 450];

options.eeg.mmn.preproc.eyeblinkdetection   = 'sdThresholding';
options.eeg.mmn.preproc.eyeblinkthreshold   = 3; % for SD thresholding: in standard deviations, for amp in uV
options.eeg.mmn.preproc.eyeblinkmode        = 'eventbased'; % uses EEG triggers for trial onsets
options.eeg.mmn.preproc.eyeblinkwindow      = 0.5; % in s around blink events
options.eeg.mmn.preproc.eyeblinktrialoffset = 0.1; % in s: EBs won't hurt <100ms after tone onset
options.eeg.mmn.preproc.eyeblinkEOGchannel  = 'EOG'; % EOG channel (name/idx) to plot
options.eeg.mmn.preproc.eyebadchanthresh    = 0.4; % prop of bad trials due to EBs
options.eeg.mmn.preproc.badtrialthresh      = 75; % in microVolt
options.eeg.mmn.preproc.badchanthresh       = 0.2; % prop of bad trials (artefacts)
options.eeg.mmn.preproc.eyeconfoundcomps    = 1;

%-- erp ------------------------------------------------------------------%

options.eeg.mmn.erp.type        = 'phases_oddball'; % roving, phases_oddball,
% phases_roving, split_phases
switch options.eeg.mmn.erp.type
    case 'roving'
        options.eeg.mmn.erp.conditions = {'standard', 'deviant'};
    case {'phases_oddball', 'phases_roving'}
        options.eeg.mmn.erp.conditions = {'volDev', 'stabDev', ...
            'volStan', 'stabStan'};
end
options.eeg.mmn.erp.electrode   = 'Fz';
options.eeg.mmn.erp.averaging   = 's'; % s (standard), r (robust)
switch options.eeg.mmn.erp.averaging
    case 'r'
        options.eeg.mmn.erp.addfilter = 'f';
    case 's'
        options.eeg.mmn.erp.addfilter = '';
end

options.eeg.mmn.erp.contrastWeighting   = 1;
options.eeg.mmn.erp.contrastPrefix      = 'diff_';
options.eeg.mmn.erp.contrastName        = 'mmn';

%-- conversion2images ----------------------------------------------------%
options.eeg.mmn.conversion.mode             = 'modelbased'; %'ERPs', 'modelbased',
%'mERPs', 'diffWaves'
options.eeg.mmn.conversion.space            = 'sensor';
options.eeg.mmn.conversion.convPrefix       = 'whole'; % whole, early, late, ERP
options.eeg.mmn.conversion.convTimeWindow   = [100 450];
options.eeg.mmn.conversion.smooKernel       = [16 16 0];

%-- stats ----------------------------------------------------------------%
options.eeg.mmn.stats.mode          = 'ERP';        % 'modelbased', 'ERP'
options.eeg.mmn.stats.priors        = 'volTrace';   % omega35, default, mypriors,
% kappa2, peIncrease, volTrace
options.eeg.mmn.stats.design        = 'epsilon';    % 'sepsilon', 'PEs', 'HGF',
%'epsilon', 'prediction'
switch options.eeg.mmn.stats.design
    case 'epsilon'
        options.eeg.mmn.stats.regressors = {'epsi2', 'epsi3'};
end
options.eeg.mmn.stats.pValueMode    = 'clusterFWE';
options.eeg.mmn.stats.exampleID     = '0001';