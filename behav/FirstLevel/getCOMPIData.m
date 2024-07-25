function [cue, cue_advice_space,y,input_u,takeAdv,take_helpfulAdvice, ...
    perf_acc,against_misleadingAdvice,percentage_against_advice_hiprob,...
    percentage_with_advice_lowprob,takeAdviceStable,takeAdviceVolatile,...
    takeAdviceHelpful1,takeAdviceHelpful2,takeAdvStable1Volatile,cScore,probeSelection] =  getCOMPIData(details,options,fileBehav)


sub = details.dirSubject;
subjectData = {};
finalBehavMatrix{2,1} = {};
finalCodeMatrix{2,1}     = {};
if ~exist(fileBehav{1}, 'file') || ~exist(fileBehav{2}, 'file')
    warning('Behavioral logfile for subject %s not found', sub)
    y = [];
    input_u = [];
    takeAdv = [];
    take_helpfulAdvice = [];
    acc = [];
    perf_acc = [];
    remove_zeros = [];
    against_misleadingAdvice = [];
else
    for iTask = 1:numel(details.behav.tasks)
        subjectData{iTask} = load(fileBehav{iTask});
        [behavMatrix,codeMatrix,~] = compi_get_responses(subjectData{iTask}.SOC.Session(2).exp_data,options);
        finalBehavMatrix{iTask} = behavMatrix;
        finalCodeMatrix{iTask}  = codeMatrix;
    end
    outputMatrix = cell2mat(finalBehavMatrix);
    outputCodes  = cell2mat(finalCodeMatrix);
    
    y       = outputMatrix(:,3);
    input_u = [outputMatrix(:,1) outputMatrix(:,2)];
    probeSelection  = outputMatrix(:,8);
    iValid  = logical(outputMatrix(:,9));
    lastTrial = size(iValid,1);
end



% Some checks are needed here:
design = load(options.task.design);
diffStimulusCodes = design(1:lastTrial,3)-outputCodes(:,1);
diffVideoCodes = design(1:lastTrial,4)-outputCodes(:,2);
diffOutcomeCodes = design(1:lastTrial,6)-outputCodes(:,3);
if sum(diffStimulusCodes)~=0 || sum(diffVideoCodes)~=0 || sum(diffOutcomeCodes)~=0
    warning('Codes do not match Design for subject %s', sub)
end

diffInputs = [design(1:lastTrial,10)] - input_u(:,1);

if sum(diffInputs(:,1))~=0 
    warning('Inputs do not match Design for subject %s', sub)
end

switch options.task.modality
    case 'eeg'
        save(fullfile(details.behav.eeg.pathResults,'behavMatrix.mat'), 'outputMatrix','-mat');
    case 'fmri'
        save(fullfile(details.behav.fmri.pathResults,'behavMatrix.mat'), 'outputMatrix','-mat');
end

%% Behaviour statistics collected here

% Get responses, performance accuracy, cumulative score
% Behaviour statistics collected here

remove_zeros_input        = (input_u(:,1)+ones(size(y)).*5)./6;
remove_ones_input         = (input_u(:,1)+ones(size(y)).*6)./6;
remove_ones_y             = (y(:,1)+ones(size(y)).*5)./5;

% iValid is the row of trials where a response was made; 1 = response made;
%                                                        0 = miss
% logical array
adviceCongruence          = input_u(iValid,1);
cue                       = input_u(iValid,2);
binaryLotteryMax          = double(cue == max(cue)); % Select trials when the cue probability is maximum
binaryLotteryMin          = double(cue == min(cue)); % Select trials when the cue probability is minimum

totalTrials               = size(y(iValid,1),1);
totalHelpfulTrials        = sum(adviceCongruence);
totalMisleadingTrials     = totalTrials-totalHelpfulTrials;

congruenceBehaviourAdvice          = double(y(iValid,1)==input_u(iValid,1));
adviceTakingBehaviour              = double(y(iValid,1)==remove_zeros_input(iValid,1));
adviceRefusalBehaviour             = double(remove_ones_y(iValid,1)==remove_ones_input(iValid,1));


perf_acc                 = sum(congruenceBehaviourAdvice)./totalTrials;
take_helpfulAdvice       = sum(adviceTakingBehaviour)./totalHelpfulTrials;
against_misleadingAdvice = sum(adviceRefusalBehaviour)./totalMisleadingTrials;
takeAdv                  = sum(y(iValid,1))./totalTrials;
go_against_advice        = ((binaryLotteryMax+(ones(size(binaryLotteryMax)).*-1)) == y(iValid,1)); % zeros will match zeros
go_with_advice           = ((binaryLotteryMin+(ones(size(binaryLotteryMin)).*5))./6 == y(iValid,1)); % ones will match ones
percentage_with_advice_lowprob             = sum(go_with_advice)./sum(binaryLotteryMin);% Calculate percentage of going with the advice when cue is 35%
percentage_against_advice_hiprob           = sum(go_against_advice)./sum(binaryLotteryMax); % Calculate percentage of going against the advice when cue is 75%

temp1    = (congruenceBehaviourAdvice).*2; % Code correct responses with 1 and incorrect ones with -1 for cumulative score
cScore   = sum((temp1+(ones(size(y(iValid,1),1),1).*-1)));


StableTrials         = logical(iValid.*logical(options.task.stable(1:lastTrial)));
takeAdviceStable     = sum(y(StableTrials))./sum(StableTrials); % go with advice in stable helpful phases

VolatileTrials       = logical(iValid.*logical(options.task.volatile(1:lastTrial)));
takeAdviceVolatile   = sum(y(VolatileTrials))./sum(VolatileTrials); % go with advice in volatile phases

StableH1Trials       = logical(iValid.*logical(options.task.helpful1(1:lastTrial)));
takeAdviceHelpful1   = sum(y(StableH1Trials))./sum(StableH1Trials); % go with advice in stable helpful 1

StableH2Trials       = logical(iValid.*logical(options.task.helpful2(1:lastTrial)));
takeAdviceHelpful2   = sum(y(StableH2Trials))./sum(StableH2Trials); % go with advice in stable helpful 2

takeAdvStable1Volatile              ...
                     = (sum(y(StableH1Trials))./sum(StableH1Trials) + sum(y(VolatileTrials))./sum(VolatileTrials))./2; % go with advice in stable helpful 1 and % go with advice in volatile phases

% Get the pie chart probabilities
cue                    = (outputMatrix(:,4));
cue_advice_space       = (outputMatrix(:,2));


[~, f1] = fileparts(fileBehav{1});
[~, f2] = fileparts(fileBehav{2});

fprintf('Files: %s, %s \n', f1, f2)
fprintf('Subject took the advice: %.2f%%\n', takeAdv);
fprintf('Subject took advice when it was helpful: %.2f%%\n', take_helpfulAdvice);
if takeAdv<=0.5
    warning('Advice taking below 50%, check responses...');
end
end

