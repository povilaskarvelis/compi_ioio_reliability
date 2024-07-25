function [perf_acc,cScore,take_adv_helpful,go_against_adv_misleading,choice_with, ...
                choice_against,choice_with_chance,go_with_stable_helpful_advice,choice_against_stable_misleading_advice,...
                go_with_volatile_advice, go_against_volatile_advice,go_with_stable_helpful_advice1,go_with_stable_helpful_advice2,...
                take_adv_overall,take_adv_in_switch_to_misleading,take_adv_in_switch_to_helpful] = getNonModelStatsCOMPI(input_u,y)
% Get responses, performance accuracy, cumulative score
% Behaviour statistics collected here

acc                     = sum(y==input_u(:,1));
perf_acc                = (sum(nansum(acc)))/size(y,1);
remove_zeros            = (input_u(:,1)+ones(size(y)).*5)./6;
take_adv_helpful        = sum((y==remove_zeros))./sum(input_u(:,1));
remove_ones_input       = (input_u(:,1)+ones(size(y)).*6)./6;
remove_ones_y           = (y(:,1)+ones(size(y)).*5)./5;
go_against_adv_misleading= sum((remove_ones_y==remove_ones_input))./(size(y,1)-sum(input_u(:,1)));


temp1    = (y==input_u(:,1)).*2; % Code correct responses with 1 and incorrect ones with -1 for cumulative score
cScore   = sum((temp1+(ones(size(y)).*-1)));
% Get the pie chart probabilities
cue = input_u(:,2);

binary_lottery_hiprob  = (cue == max(cue)); % Select trials when the cue probability is maximum
go_against_advice      = ((binary_lottery_hiprob+(ones(size(binary_lottery_hiprob)).*-1)) == y);
% Set the trials with highest cue probability to zero
% if cue = 0.65, then go against advice
choice_against         = sum(go_against_advice)./sum(binary_lottery_hiprob); % Calculate percentage of going against the advice when cue is 65%
binary_lottery_lowprob = (cue == min(cue)); % Select trials when the cue probability is minimum
go_with_advice         = ((binary_lottery_lowprob+(ones(size(binary_lottery_lowprob)).*5))./6 == y);
% Set the trials with lowest cue probability to one
% if cue = 0.35, then go with advice
choice_with            = sum(go_with_advice)./sum(binary_lottery_lowprob);% Calculate percentage of going with the advice when cue is 35%

binary_lottery_chance  = (cue==0.55|cue==0.50); % Select trials when the cue probability is around 50%
go_with_advice_chance  = ((binary_lottery_chance+(ones(size(binary_lottery_chance)).*5))./6 == y);
% Set the trials with close to chance probability to one
% if cue = 0.55 or 0.50, then go with advice
choice_with_chance     = sum(go_with_advice_chance)./sum(binary_lottery_chance);% Calculate percentage of going with the advice when cue is 35%

stable_helpful_advice         = input_u([1:42,168:210],1); % Select stable, helpful advice trials
go_with_stable_helpful_advice = sum((y([1:42,168:210],1)==stable_helpful_advice))./size(stable_helpful_advice,1);

stable_misleading_advice                = input_u([43:62,148:167],1); % Select stable, misleading advice trials
choice_against_stable_misleading_advice = sum((y([43:62,148:167],1)==stable_misleading_advice))./size(stable_misleading_advice,1);

volatile_advice         = input_u([43:167],1); % Select volatile advice trials
go_with_volatile_advice = sum((y([43:167],1)==volatile_advice))./size(volatile_advice,1);

go_against_volatile_advice = 1 - go_with_volatile_advice;

%new
stable_helpful_advice1         = input_u([1:42],1);
go_with_stable_helpful_advice1 = sum((y([1:42],1)==stable_helpful_advice1))./size(stable_helpful_advice1,1);

%new2
stable_helpful_advice2         = input_u([168:210],1); % Select stable, helpful advice trials
go_with_stable_helpful_advice2 = sum((y([168:210],1)==stable_helpful_advice2))./size(stable_helpful_advice2,1);

%new3
take_adv_overall = sum(y)./210;

%switch1
switch_to_misleading_pre           = input_u([38:42],1);
switch_to_misleading_post          = input_u([42:46],1);
take_adv_in_switch_to_misleading_pre = sum((y([38:42],1)==switch_to_misleading_pre))./size(switch_to_misleading_pre,1);
take_adv_in_switch_to_misleading_post = sum((y([42:46],1)==switch_to_misleading_post))./size(switch_to_misleading_post,1);
take_adv_in_switch_to_misleading = take_adv_in_switch_to_misleading_post - take_adv_in_switch_to_misleading_pre;

%switch2
switch_to_helpful_pre             = input_u([164:168],1);
switch_to_helpful_post            = input_u([168:172],1);
take_adv_in_switch_to_helpful_pre     = sum((y([164:168],1)==switch_to_helpful_pre))./size(switch_to_helpful_pre,1);
take_adv_in_switch_to_helpful_post     = sum((y([168:172],1)==switch_to_helpful_post))./size(switch_to_helpful_post,1);
take_adv_in_switch_to_helpful     = take_adv_in_switch_to_helpful_post - take_adv_in_switch_to_helpful_pre;
end
