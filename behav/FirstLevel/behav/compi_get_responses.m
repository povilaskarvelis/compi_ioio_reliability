function [behavior, codes, timing] = compi_get_responses(raw_data, options)
%--------------------------------------------------------------------------
% Function that organizes raw data from IOIO task into three tables
% containing behavioral variables, stimulus codes, and timing information.
% Important: This function transforms both cue and choice into advice 
% space.
%
% IN:
%   raw_data                -> Raw data matrix
%   options                 -> Analysis options obtained by running
%                              compi_ioio_options
%
% OUT:
%   behavior                -> Summary table of behavior
%   codes                   -> Summary table of stimulus codes
%   timing                  -> Summary table of timing information
%
%--------------------------------------------------------------------------



%% Get stimulus codes
stimulus = raw_data(:,4);
video    = raw_data(:,5);
outcome  = raw_data(:,14);

codes = table(stimulus, video, outcome);


%% Get timing
time_cue      = raw_data(:,6);
time_response = raw_data(:,11);
time_target   = raw_data(:,15);

timing = table(time_cue, time_response, time_target);


%% Get behavior
% Transform cue into advice space 
% Convert cue codes to cue probabilities (encoded for blue color)
prob_cue_blue     = interp1(options.task.cueCodes, options.task.cueProbs, stimulus);
cue               = prob_cue_blue;                   % Write out cue probabilities
advice_green      = logical(~mod(video,2));          % Find out when advice was green
cue(advice_green) = 1 - prob_cue_blue(advice_green); % Transform p(blue) to p(green)

% Transform choice to advice space
raw_choice = raw_data(:,10); % 1: blue 2: green
choice     = double(mod(video,2) == mod(raw_choice,2)); % Choice in advice space

advice  = double(mod(video,2) == mod(outcome,2)); % Advice correct?
RT      = raw_data(:,12); % Reaction time
correct = raw_data(:,16); % Subject's prediction correct?
CS      = raw_data(:,17); % Cumulative score
probe   = raw_data(:,8);  % Selected response to MC question
valid   = raw_choice > 0; % Valid response?

behavior = table(advice, cue, choice, RT, correct, CS, probe, valid, prob_cue_blue);
  


