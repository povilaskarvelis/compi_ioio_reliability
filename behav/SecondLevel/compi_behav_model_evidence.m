function COMPI_behav_model_evidence(options,comparisonType)
%IN
% options
% Function saves model selection results

if nargin < 2
    comparisonType = 'highDelusion';
end

switch comparisonType
    case 'all'
        subjects = [options.subjectIDsSession1 ...
            options.subjectIDsSession2 options.subjectIDsSession3 options.subjectIDsSession4];
    case 'highDelusion'
        subjects = [options.subjectIDshighDispositional options.subjectIDshighSituational];
    case 'lowDelusion'
        subjects = [options.subjectIDslowDispositional options.subjectIDslowSituational];
    case 'Situational'
        subjects = [options.subjectIDshighSituational options.subjectIDslowSituational];
    case 'Dispositional'
        subjects = [options.subjectIDshighDispositional options.subjectIDslowDispositional];
end

[models_COMPI]                                       = loadCOMPIModelEvidence(options,subjects);
[COMPI_model_posterior,COMPI_xp, COMPI_protected_xp] = COMPI_behav_plot_model_selection(options,models_COMPI);

save(fullfile(options.resultroot ,[comparisonType '_model_selection_results.mat']), ...
    'COMPI_model_posterior','COMPI_xp', 'COMPI_protected_xp', '-mat');
end

