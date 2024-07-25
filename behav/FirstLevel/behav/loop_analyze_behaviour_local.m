function [errorIds, errorSubjects, errorFile] = loop_analyze_behaviour_local(options)
% -------------------------------------------------------------------------
% Loops over subjects in COMPI study with a local loop and executes all 
% analysis steps.
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
% -------------------------------------------------------------------------



%% Analyze behavior
errorSubjects = {};
errorIds = {};
errorFile = 'errorBehavVariables.mat'; % TODO: time stamp? own sub-folder?

subjects = options.subjects.all;
for idx_s = 1:length(subjects)
    full_behavior{idx_s} = compi_analyze_behaviour(subjects{idx_s},options);
    
    % add ID
    full_behavior{idx_s}.subID = idx_s.*ones(size(full_behavior{idx_s},1),1);
end

% concatenate
full_behav = vertcat(full_behavior{:});
    
% rearrange
full_behav = full_behav(:,[end,1:end-1]);  

% leave only valid trials
%full_behav = full_behav(full_behav.valid==1,:);

%% save behavioral data
ofile = fullfile(options.roots.results_behav, 'full_behav_measures.txt');
writetable(full_behav, ofile);


%% Save errors
save(fullfile(options.roots.err, errorFile), 'errorSubjects', 'errorIds');

