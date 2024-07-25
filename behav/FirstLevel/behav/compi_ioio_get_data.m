function [data, behav_measures, behavior] = compi_ioio_get_data(files, details, options)
%--------------------------------------------------------------------------
% Function that returns data for HGF inversion and computes relevant
% behavioral variables.
%
% IN:
%   details                 -> Subject specific details obtained by running
%                              compi_ioio_subjects(id, options)
%   options                 -> Analysis options obtained by running
%                              compi_ioio_options
%   files                   -> Cell array containing directories of
%                              behavioral raw files
%
% OUT:
%   data(struct)
%       data.y              -> Responses
%       data.input_u        -> Input
%
%   behav_measures          -> Summary table of different behavioral 
%                              measures
%
%--------------------------------------------------------------------------



%% Initialize
data = struct;


%% Check if files exist
if ~exist(files{1}, 'file') || ~exist(files{2}, 'file')
    warning('Behavioral files for subject %s not found', details.id)
    data.y         = [];
    data.input_u   = [];
    behav_measures = [];
    
    
else
    %% Load data
    % Load SOC structures
    temp1 = load(files{1});
    temp2 = load(files{2});
    
    % Concatenate runs
    raw_data = [temp1.SOC.Session(2).exp_data; temp2.SOC.Session(2).exp_data];
    
    [behavior, codes, timing] = compi_get_responses(raw_data,options);

    % Throw out trials that are not required in the analysis
    last_trial = options.behav.last_trial;
    behavior = behavior(1:last_trial,:);
    behavior.stable = options.task.stable(1:last_trial);
    codes = codes(1:last_trial,:);
    timing = timing(1:last_trial,:);
    
    % Get responses and input
    data.input_u = [behavior.advice behavior.cue];
    data.y       = behavior.choice;
    
    cue_advice_space = {behavior.cue};
    cue = {behavior.prob_cue_blue};
    
    % add onsets of different parts of each trial
    behavior = [behavior timing];
    
    
    %% Design checks
    design = load(options.task.design);
    
    % Throw out trials that are not required in the analysis
    design = design(1:last_trial,:);
    
    % Check, whether Stimulus/Outcome codes are the same as in the design
    diff_stimulus_codes = design(:,3) - codes.stimulus;
    diff_video_codes    = design(:,4) - codes.video;
    diff_outcome_codes  = design(:,6) - codes.outcome;
    if sum(diff_stimulus_codes)~=0 || sum(diff_video_codes)~=0 || sum(diff_outcome_codes)~=0
        warning('Codes do not match design for subject %s', details.dirSubject)
    end
    
    % Check, whether inputs differed from design
    diff_inputs = design(:,10) - data.input_u(:,1);
    if sum(diff_inputs)~=0
        warning('Inputs do not match Design for subject %s', details.dirSubject)
    end
    
    
    %% Compute behavioral statistics
    valid = behavior.valid;
       
    % Cumulative score
    CS = sum((data.y(valid) == data.input_u(valid,1)).*2-1);
    %behavior.CS(end)
    
    % Total advice taking
    AT_total = sum(data.y(valid))/sum(valid);
    
    % Compute performance accuracy (going with advice when it is helpful 
    % and against it, when it is misleading)
    AT_acc = sum(data.y(valid) == data.input_u(valid,1))/sum(valid);
    
    % Advice taking, when adviser is helpful/unhelpful
    AT_helpful = sum(data.y(valid) & data.input_u(valid,1))/sum(data.input_u(valid,1));
    AT_unhelpful = sum(data.y(valid) & ~data.input_u(valid,1))/sum(data.input_u(valid,1));
    
    % Advice taking in stable helpful phases
    idx = valid & options.task.stable(1:last_trial);
    AT_stable = sum(data.y(idx))/sum(idx); 
    
    % Advice taking in volatile phases
    idx = valid & options.task.volatile(1:last_trial);
    AT_volatile = sum(data.y(idx))/sum(idx); 
    
%     % Advice taking in stable helpful I
%     idx = valid & options.task.helpful1(1:last_trial);
%     AT_stable_I = sum(data.y(idx))/sum(idx); 
%     
%     % Advice taking in stable helpful II
%     idx = valid & options.task.helpful2(1:last_trial);
%     AT_stable_II = sum(data.y(idx))/sum(idx);   

    
    % Social win-stay
    % Trials when subject went against advice when it was helpful divided 
    % by trials when advice was helpful.
    n_stay = 0;
    
    n_helpful = sum(valid & data.input_u(:,1) == 1);
    for i_trial = 2:size(data.y,1)
        if valid(i_trial) && valid(i_trial-1)...       % if trials were valid trials
                && data.input_u(i_trial-1, 1) == 1 ... % if last advice was helpful
                && data.y(i_trial-1, 1) == 1 ...       % and subject took advice
                && data.y(i_trial, 1) == 1             % and stayed afterwards
            n_stay = n_stay + 1;
        end
    end
    win_stay = n_stay/n_helpful;

    % Social lose-switch
    % Trials when subject still went with advice when it was not helpful 
    % divided by trials when advice was not helpful.
    n_switch = 0;
    n_misleading = sum(valid & data.input_u(:,1) == 0);
    for i_trial = 2:size(data.y,1)
        if valid(i_trial) && valid(i_trial-1)...       % if trials were valid trials
                && data.input_u(i_trial-1, 1) == 0 ... % if last advice was not helpful
                && data.y(i_trial-1, 1) == 1 ...       % and subject took advice
                && data.y(i_trial, 1) == 0             % and switched afterwards
            n_switch = n_switch + 1;
        end
    end
    lose_switch = n_switch/n_misleading;
 
    % U-Values
    eps = 0.000000000001;
    alpha = sum(data.y(valid,1))/length(data.y(valid,1));
    U = -((alpha * log(alpha+eps)/log(2)) + ((1-alpha) * log(1-alpha+eps)/log(2)));
    
    
    %% Write output table and report
    behav_measures = table(CS, AT_total, AT_acc, AT_stable, AT_volatile,...
        AT_helpful, AT_unhelpful, lose_switch, win_stay, U, cue, cue_advice_space);
    
    [~, file1] = fileparts(files{1});
    [~, file2] = fileparts(files{2});
    
    fprintf('\nExtracting data...\n');
    fprintf('Files: %s, %s \n', file1, file2);
    fprintf('Subject took the advice: %.2f%%\n', AT_total);
    fprintf('Subject took advice when it was helpful: %.2f%%\n', AT_helpful);
    if AT_total <= 0.5
        warning('Advice taking below 50%, check responses...');
    end       
    
end







