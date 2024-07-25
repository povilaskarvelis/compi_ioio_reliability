function COMPI_summary_table_states(options,comparisonType)
% Runs and plots model selection results
% IN
%   options     general analysis options%
%               options = COMPI_options;

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

loadCOMPIStates(options,subjects,comparisonType);

% Independent Variables
[~,~,txt] = xlsread(options.model.winningPhases,'phases');
group      = txt(2:end,2);
condition  = txt(2:end,3);


% Dependent Variables
[MAPs,~] = xlsread(options.model.winningPhases,'phases');
precision2 = MAPs(:,[4 5 6]);
precision3 = MAPs(:,[7 8 9]);
pdelta1     = MAPs(:,[10 11 12]);
prediction = MAPs(:,[13 14 15]);
volatility = MAPs(:,[16 17 18]);
lr2        = MAPs(:,[19 20 21]);
lr3        = MAPs(:,[22 23 24]);
sigma2     = MAPs(:,[25 26 27]);
precision1 = MAPs(:,[28 29 30]);
ndelta1    = MAPs(:,[31 32 33]);

variable = precision2;

[P,T,STATS,TERMS,ranovatbl] = COMPI_anovan(variable,condition,group);
ranovatbl
end


