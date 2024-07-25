function loadCOMPIStates(options,subjects,comparisonType)
%IN
% analysis options
% OUT
% parameters of the winning model
options.subjectIDs = subjects;

perceptual_model = options.model.winningPerceptual;
response_model   = options.model.winningResponse;

% Critical phases when we want to compare values of states
% delta1, delta2, precisionAdvice(pi2hat), precisionVolatility(pi3hat),
% EstimatedVolatility(mu3hat), EstimatedValidity(Mu1hat)

nParameters = [8*2+5]; % 8 critical phases for 2 precisions, 5 critical phases for delta1
nSubjects = numel(options.subjectIDs);
states_COMPI = cell(nSubjects, numel(nParameters));

for iSubject = 1:nSubjects
    id = char(options.subjectIDs(iSubject));
    details = COMPI_subject_details(id, options);
    tmp = load(fullfile(details.behav.pathResults,...
        [details.dirSubject, perceptual_model...
        response_model,'.mat']));
    [binary_lottery_hiprob,binary_lottery_lowprob,binary_lottery_chance,stable_helpful_adviceIDs,...
        stable_misleading_adviceIDs,volatile_adviceIDs,stable_helpful_advice1IDs,stable_helpful_advice2IDs] ...
        = getCOMPIPhases(tmp.est_COMPI.u);
    % precision2
    precision1                           = tmp.est_COMPI.traj.muhat(:,1).*...
                                           (1-tmp.est_COMPI.traj.muhat(:,1));
    precision2_all                       = [mean(1./tmp.est_COMPI.traj.sahat(stable_helpful_advice1IDs,2)), ...
                                            mean(1./tmp.est_COMPI.traj.sahat(volatile_adviceIDs,2)) ...
                                            mean(1./tmp.est_COMPI.traj.sahat(stable_helpful_advice2IDs,2))];
    sigma2_all                           = [mean(tmp.est_COMPI.traj.sahat(stable_helpful_advice1IDs,2)), ...
                                            mean(tmp.est_COMPI.traj.sahat(volatile_adviceIDs,2)) ...
                                            mean(tmp.est_COMPI.traj.sahat(stable_helpful_advice2IDs,2))];                                    
    learningRate2                        = tmp.est_COMPI.traj.sahat(:,2).*tmp.est_COMPI.traj.muhat(:,1).*...
                                           (1-tmp.est_COMPI.traj.muhat(:,1));
    learningRate2_all                    = [mean(learningRate2(stable_helpful_advice1IDs,1)), ...
                                            mean(learningRate2(volatile_adviceIDs,1)) ...
                                            mean(learningRate2(stable_helpful_advice2IDs,1))];    
    precision1_all                       = [mean(precision1(stable_helpful_advice1IDs,1)), ...
                                            mean(precision1(volatile_adviceIDs,1)) ...
                                            mean(precision1(stable_helpful_advice2IDs,1))];                                     
    binary_lottery_hiprob_Precision2     = mean(1./tmp.est_COMPI.traj.sahat(binary_lottery_hiprob,2));
    binary_lottery_lowprob_Precision2    = mean(1./tmp.est_COMPI.traj.sahat(binary_lottery_lowprob,2));
    binary_lottery_chance_Precision2     = mean(1./tmp.est_COMPI.traj.sahat(binary_lottery_chance,2));
    stable_helpful_advice_Precision2     = mean(1./tmp.est_COMPI.traj.sahat(stable_helpful_adviceIDs,2));
    stable_misleading_advice_Precision2  = mean(1./tmp.est_COMPI.traj.sahat(stable_misleading_adviceIDs,2));
    volatile_advice_Precision2           = mean(1./tmp.est_COMPI.traj.sahat(volatile_adviceIDs,2));
    stable_helpful_advice1_Precision2    = mean(1./tmp.est_COMPI.traj.sahat(stable_helpful_advice1IDs,2));
    stable_helpful_advice2_Precision2    = mean(1./tmp.est_COMPI.traj.sahat(stable_helpful_advice2IDs,2));
    
    % precision 3
    precision3_all                       = [mean(1./tmp.est_COMPI.traj.sahat(stable_helpful_advice1IDs,3)), ...
                                            mean(1./tmp.est_COMPI.traj.sahat(volatile_adviceIDs,3)) ...
                                            mean(1./tmp.est_COMPI.traj.sahat(stable_helpful_advice2IDs,3))];
    learningRate3                        = tmp.est_COMPI.traj.sahat(:,3).*1/2.*tmp.est_COMPI.p_prc.ka(2).*...
                                           tmp.est_COMPI.traj.w(:,2);
    learningRate3_all                    = [mean(learningRate3(stable_helpful_advice1IDs,1)), ...
                                            mean(learningRate3(volatile_adviceIDs,1)) ...
                                            mean(learningRate3(stable_helpful_advice2IDs,1))];                                     
    binary_lottery_hiprob_Precision3     = mean(1./tmp.est_COMPI.traj.sahat(binary_lottery_hiprob,3));
    binary_lottery_lowprob_Precision3    = mean(1./tmp.est_COMPI.traj.sahat(binary_lottery_lowprob,3));
    binary_lottery_chance_Precision3     = mean(1./tmp.est_COMPI.traj.sahat(binary_lottery_chance,3));
    stable_helpful_advice_Precision3     = mean(1./tmp.est_COMPI.traj.sahat(stable_helpful_adviceIDs,3));
    stable_misleading_advice_Precision3  = mean(1./tmp.est_COMPI.traj.sahat(stable_misleading_adviceIDs,3));
    volatile_advice_Precision3           = mean(1./tmp.est_COMPI.traj.sahat(volatile_adviceIDs,3));
    stable_helpful_advice1_Precision3    = mean(1./tmp.est_COMPI.traj.sahat(stable_helpful_advice1IDs,3));
    stable_helpful_advice2_Precision3    = mean(1./tmp.est_COMPI.traj.sahat(stable_helpful_advice2IDs,3));
    
    % delta1 
    stable_helpful_advice1                = tmp.est_COMPI.traj.da(stable_helpful_advice1IDs,1);
    positive_stable_helpful_advice1IDs    = stable_helpful_advice1(:)>0;
    
    volatility_advice                    = tmp.est_COMPI.traj.da(volatile_adviceIDs,1);
    positive_volatilityIDs               = volatility_advice(:)>0;
    
    stable_helpful_advice2               = tmp.est_COMPI.traj.da(stable_helpful_advice2IDs,1);
    positive_stable_helpful_advice2IDs   = stable_helpful_advice2(:)>0;
    delta1_all                           = [mean(stable_helpful_advice1(positive_stable_helpful_advice1IDs)), ...
                                            mean(volatility_advice(positive_volatilityIDs)) ...
                                            mean(stable_helpful_advice2(positive_stable_helpful_advice2IDs))];

    negative_stable_helpful_advice1IDs    = stable_helpful_advice1(:)<0;
    negative_volatilityIDs               = volatility_advice(:)<0;
    negative_stable_helpful_advice2IDs   = stable_helpful_advice2(:)<0;
    ndelta1_all                           = [mean(stable_helpful_advice1(negative_stable_helpful_advice1IDs)), ...
                                            mean(volatility_advice(negative_volatilityIDs)) ...
                                            mean(stable_helpful_advice2(negative_stable_helpful_advice2IDs))];
                                        
    delta1_stable_helpful                = tmp.est_COMPI.traj.da(stable_helpful_adviceIDs,1);
    negative_delta1_stable_helpfulIDs    = delta1_stable_helpful(:)<0;
    stable_helpful_nDelta1        = mean(delta1_stable_helpful(negative_delta1_stable_helpfulIDs));
     
    delta1_stable_misleading                = tmp.est_COMPI.traj.da(stable_misleading_adviceIDs,1);
    negative_delta1_stable_misleadingIDs    = delta1_stable_misleading(:)<0;
    stable_misleading_nDelta1        = mean(delta1_stable_misleading(negative_delta1_stable_misleadingIDs));
    
    delta1_volatile_advice                  = tmp.est_COMPI.traj.da(volatile_adviceIDs,1);
    negative_delta1_volatile_adviceIDs      = delta1_volatile_advice(:)<0;
    volatile_advice_nDelta1        = mean(delta1_volatile_advice(negative_delta1_volatile_adviceIDs));
    
    delta1_stable_helpful_advice1           = tmp.est_COMPI.traj.da(stable_helpful_advice1IDs,1);
    negative_delta1_stable_helpful_advice1IDs      = delta1_stable_helpful_advice1(:)<0;
    stable_helpful_advice1_nDelta1        = mean(delta1_stable_helpful_advice1(negative_delta1_stable_helpful_advice1IDs));
    
    delta1_stable_helpful_advice2           = tmp.est_COMPI.traj.da(stable_helpful_advice2IDs,1);
    negative_delta1_stable_helpful_advice2IDs      = delta1_stable_helpful_advice2(:)<0;
    stable_helpful_advice2_nDelta1        = mean(delta1_stable_helpful_advice2(negative_delta1_stable_helpful_advice2IDs));
    
     % prediction
    prediction_all                       = [mean(tmp.est_COMPI.traj.muhat(stable_helpful_advice1IDs,1)), ...
                                            mean(tmp.est_COMPI.traj.muhat(volatile_adviceIDs,1)) ...
                                            mean(tmp.est_COMPI.traj.muhat(stable_helpful_advice2IDs,1))];
    stable_helpful_advice_Prediction     = mean(tmp.est_COMPI.traj.muhat(stable_helpful_adviceIDs,1));
    stable_misleading_advice_Prediction  = mean(tmp.est_COMPI.traj.muhat(stable_misleading_adviceIDs,1));
    volatile_advice_Prediction           = mean(tmp.est_COMPI.traj.muhat(volatile_adviceIDs,1));
    stable_helpful_advice1_Prediction    = mean(tmp.est_COMPI.traj.muhat(stable_helpful_advice1IDs,1));
    stable_helpful_advice2_Prediction    = mean(tmp.est_COMPI.traj.muhat(stable_helpful_advice2IDs,1));
    
    % volatility
    volatility_all                       = [mean(tmp.est_COMPI.traj.muhat(stable_helpful_advice1IDs,3)), ...
                                            mean(tmp.est_COMPI.traj.muhat(volatile_adviceIDs,3)) ...
                                            mean(tmp.est_COMPI.traj.muhat(stable_helpful_advice2IDs,3))];

    stable_helpful_advice_Volatility     = mean(tmp.est_COMPI.traj.muhat(stable_helpful_adviceIDs,3));
    stable_misleading_advice_Volatility  = mean(tmp.est_COMPI.traj.muhat(stable_misleading_adviceIDs,3));
    volatile_advice_Volatility           = mean(tmp.est_COMPI.traj.muhat(volatile_adviceIDs,3));
    stable_helpful_advice1_Volatility    = mean(tmp.est_COMPI.traj.muhat(stable_helpful_advice1IDs,3));
    stable_helpful_advice2_Volatility    = mean(tmp.est_COMPI.traj.muhat(stable_helpful_advice2IDs,3));
    
    % delta2
    stable_helpful_advice_Delta2     = mean(abs(tmp.est_COMPI.traj.da(stable_helpful_adviceIDs,2)));
    stable_misleading_advice_Delta2  = mean(abs(tmp.est_COMPI.traj.da(stable_misleading_adviceIDs,2)));
    volatile_advice_Delta2           = mean(abs(tmp.est_COMPI.traj.da(volatile_adviceIDs,2)));
    stable_helpful_advice1_Delta2    = mean(abs(tmp.est_COMPI.traj.da(stable_helpful_advice1IDs,2)));
    stable_helpful_advice2_Delta2    = mean(abs(tmp.est_COMPI.traj.da(stable_helpful_advice2IDs,2)));
    
    % delta1 (only helpful)
    delta1_stable_helpful                = tmp.est_COMPI.traj.da(stable_helpful_adviceIDs,1);
    positive_delta1_stable_helpfulIDs    = delta1_stable_helpful(:)>0;
    stable_helpful_pDelta1        = mean(delta1_stable_helpful(positive_delta1_stable_helpfulIDs));
     
    delta1_stable_misleading                = tmp.est_COMPI.traj.da(stable_misleading_adviceIDs,1);
    positive_delta1_stable_misleadingIDs    = delta1_stable_misleading(:)>0;
    stable_misleading_pDelta1        = mean(delta1_stable_misleading(positive_delta1_stable_misleadingIDs));
    
    delta1_volatile_advice                  = tmp.est_COMPI.traj.da(volatile_adviceIDs,1);
    positive_delta1_volatile_adviceIDs      = delta1_volatile_advice(:)>0;
    volatile_advice_pDelta1        = mean(delta1_volatile_advice(positive_delta1_volatile_adviceIDs));
    
    delta1_stable_helpful_advice1           = tmp.est_COMPI.traj.da(stable_helpful_advice1IDs,1);
    positive_delta1_stable_helpful_advice1IDs      = delta1_stable_helpful_advice1(:)>0;
    stable_helpful_advice1_pDelta1        = mean(delta1_stable_helpful_advice1(positive_delta1_stable_helpful_advice1IDs));
    
    delta1_stable_helpful_advice2           = tmp.est_COMPI.traj.da(stable_helpful_advice2IDs,1);
    positive_delta1_stable_helpful_advice2IDs      = delta1_stable_helpful_advice2(:)>0;
    stable_helpful_advice2_pDelta1        = mean(delta1_stable_helpful_advice2(positive_delta1_stable_helpful_advice2IDs));
    
    states_COMPI{iSubject,1} = binary_lottery_hiprob_Precision2;
    states_COMPI{iSubject,2} = binary_lottery_lowprob_Precision2;
    states_COMPI{iSubject,3} = binary_lottery_chance_Precision2;
    states_COMPI{iSubject,4} = stable_helpful_advice_Precision2;
    states_COMPI{iSubject,5} = stable_misleading_advice_Precision2;
    states_COMPI{iSubject,6} = volatile_advice_Precision2;
    states_COMPI{iSubject,7} = stable_helpful_advice1_Precision2;
    states_COMPI{iSubject,8} = stable_helpful_advice2_Precision2;
    states_COMPI{iSubject,9} = binary_lottery_hiprob_Precision3;
    states_COMPI{iSubject,10}= binary_lottery_lowprob_Precision3;
    
    states_COMPI{iSubject,11} = binary_lottery_chance_Precision3;
    states_COMPI{iSubject,12} = stable_helpful_advice_Precision3;
    states_COMPI{iSubject,13} = stable_misleading_advice_Precision3;
    states_COMPI{iSubject,14} = volatile_advice_Precision3;
    states_COMPI{iSubject,15} = stable_helpful_advice1_Precision3;
    states_COMPI{iSubject,16} = stable_helpful_advice2_Precision3;
    
    states_COMPI{iSubject,17} = stable_helpful_nDelta1;
    states_COMPI{iSubject,18} = stable_misleading_nDelta1;
    states_COMPI{iSubject,19} = volatile_advice_nDelta1;
    states_COMPI{iSubject,20} = stable_helpful_advice1_nDelta1;
    states_COMPI{iSubject,21} = stable_helpful_advice2_nDelta1;
    
    states_COMPI{iSubject,22} = stable_helpful_advice_Prediction;
    states_COMPI{iSubject,23} = stable_misleading_advice_Prediction;
    states_COMPI{iSubject,24} = volatile_advice_Prediction;
    states_COMPI{iSubject,25} = stable_helpful_advice1_Prediction;
    states_COMPI{iSubject,26} = stable_helpful_advice2_Prediction;
    
    states_COMPI{iSubject,27} = stable_helpful_advice_Volatility;
    states_COMPI{iSubject,28} = stable_misleading_advice_Volatility;
    states_COMPI{iSubject,29} = volatile_advice_Volatility;
    states_COMPI{iSubject,30} = stable_helpful_advice1_Volatility;
    states_COMPI{iSubject,31} = stable_helpful_advice2_Volatility;
    
    states_COMPI{iSubject,32} = stable_helpful_pDelta1;
    states_COMPI{iSubject,33} = stable_misleading_pDelta1;
    states_COMPI{iSubject,34} = volatile_advice_pDelta1;
    states_COMPI{iSubject,35} = stable_helpful_advice1_pDelta1;
    states_COMPI{iSubject,36} = stable_helpful_advice2_pDelta1;
    
    states_COMPI{iSubject,37} = stable_helpful_advice_Delta2;
    states_COMPI{iSubject,38} = stable_misleading_advice_Delta2;
    states_COMPI{iSubject,39} = volatile_advice_Delta2;
    states_COMPI{iSubject,40} = stable_helpful_advice1_Delta2;
    states_COMPI{iSubject,41} = stable_helpful_advice2_Delta2;
    
    states_all{iSubject,3,1}   = precision2_all; % group
    states_all{iSubject,3,2}   = precision3_all;
    states_all{iSubject,3,3}   = delta1_all;     % phase
    states_all{iSubject,3,4}   = prediction_all; % phase
    states_all{iSubject,3,5}   = volatility_all;
    states_all{iSubject,3,6}   = learningRate2_all; % group
    states_all{iSubject,3,7}   = learningRate3_all;
    states_all{iSubject,3,8}   = sigma2_all;
    states_all{iSubject,3,9}   = precision1_all;
    states_all{iSubject,3,10}   = ndelta1_all;
    
end
states_COMPI = cell2mat(states_COMPI);
temp         = reshape(states_all,151,3*10);
states_all   = cell2mat(temp);
save(fullfile(options.resultroot, [comparisonType '_States_estimates_winning_model.mat']), ...
    'states_COMPI', '-mat');
ofile=fullfile(options.resultroot,[comparisonType '_States_estimates_winning_model.xlsx']);
xlswrite(ofile, [str2num(cell2mat(options.subjectIDs')) states_COMPI]);

save(fullfile(options.resultroot, [comparisonType '_States_phases_winning_model.mat']), ...
    'states_all', '-mat');
ofile=fullfile(options.resultroot,[comparisonType '_States_phases_winning_model.xlsx']);
xlswrite(ofile, [str2num(cell2mat(options.subjectIDs')) states_all]);
end


