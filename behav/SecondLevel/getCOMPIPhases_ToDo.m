function [binary_lottery_hiprob,binary_lottery_lowprob,binary_lottery_chance,stable_helpful_adviceIDs,...
    stable_misleading_adviceIDs,volatile_adviceIDs,stable_helpful_advice1IDs,stable_helpful_advice2IDs] ...
    = getSIBAKPhases(input_u)
% Get responses, performance accuracy, cumulative score
% Behaviour statistics collected here

% Get the pie chart probabilities
cue = input_u(:,2);

binary_lottery_hiprob  = (cue == max(cue)); % Select trials when the cue probability is maximum
binary_lottery_lowprob = (cue == min(cue)); % Select trials when the cue probability is minimum
binary_lottery_chance  = (cue==0.55|cue==0.50); % Select trials when the cue probability is around 50%

stable_helpful_adviceIDs     = [1:42,168:210]; % Select stable, helpful advice trials
stable_misleading_adviceIDs  = [43:62,148:167]; % Select stable, misleading advice trials
volatile_adviceIDs           = [43:167]; % Select volatile advice trials
stable_helpful_advice1IDs    = [1:42];
stable_helpful_advice2IDs    = [168:210]; % Select stable, helpful advice trials
end
