function [errorIds, errorSubjects, errorFile] = ...
    loop_analyze_behaviour_thesis(options)
% Loops over subjects in COMPI study with a local loop and executes all analysis steps %%
%
% USAGE
%        [errorIds, errorSubjects, errorFile] = loop_analyze_subject_local(options);
%
% IN
%   options         (subject-independent) analysis pipeline options,
%                   retrieve via options = dmpad_set_analysis_options
%
% OUT
%   errorIds
%   errorSubjects
%   errorFile
%
% See also compi_ioio_options

old_dir = cd;

errorSubjects = {};
errorIds = {};
errorFile = 'errorBehavVariables.mat'; % TODO: time stamp? own sub-folder?

now = datestr(datetime,'ddmmyy_HHMM');
cd(fullfile(options.roots.log));
diary(['logfile_extract_behav_measures_' now '.log'])


for idCell = options.subjects.all
    id = char(idCell);
    compi_analyze_behaviour(id,options);
end


save(fullfile(options.roots.err,...
    ['errors_hgf_inversion_' now '.mat']),'errorSubjects', 'errorIds');
diary off


cd(old_dir)
