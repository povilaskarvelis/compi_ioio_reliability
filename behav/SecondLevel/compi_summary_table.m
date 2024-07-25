function compi_summary_table(options,comparisonType)
% Runs and plots model selection results
% IN
%   options     general analysis options%
%               options = compi_ioio_options;

% OUT
% Winning model MAPs & behavioural statistics

if nargin < 2
    comparisonType = 'all';
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

COMPI_extract_parameters_create_table(options,subjects,comparisonType);