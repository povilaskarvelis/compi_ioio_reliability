function [behaviour_compi] = loadCOMPIBehaviourStats(options,subjects)
%IN
% analysis options
% OUT
% behavioural_statistics

options.subjectIDs = subjects;

if options.model.modelling_bias == true
    perceptual_model = options.model.competingPerceptual;
    response_model   = options.model.competingResponse;
    
else
    perceptual_model = options.model.winningPerceptual;
    response_model   = options.model.winningResponse;
    
    
end


nBehaviourReadouts = 6;
nSubjects = numel(options.subjectIDs);
behaviour_compi = cell(nSubjects, nBehaviourReadouts);

for iSubject = 1:nSubjects
    id = char(options.subjectIDs(iSubject));
    details = compi_subject_details(id, options);
    tmp = load(fullfile(details.behav.pathResults,...
        [details.dirSubject, perceptual_model...
        response_model,'.mat']));
    behaviour_compi{iSubject,1} = tmp.est_compi.take_adv_overall;
    behaviour_compi{iSubject,2} = tmp.est_compi.take_adv_helpful(1);
    behaviour_compi{iSubject,3} = tmp.est_compi.go_against_adv_misleading(1);
    behaviour_compi{iSubject,4} = tmp.est_compi.choice_against;
    behaviour_compi{iSubject,5} = tmp.est_compi.choice_with_chance;
end
behaviour_compi = cell2mat(behaviour_compi);

figure; scatter(behaviour_compi(:,2),behaviour_compi(:,5));
xlabel('take_helpfulAdvice');
ylabel('percentage_with_advice_lowprob');
[R,P]=corrcoef(behaviour_compi(:,2),behaviour_compi(:,5));
disp(['Correlation between taking helpful advice &  going with advice low probability? Pvalue: ' num2str(P(1,2))]);

figure; scatter(behaviour_compi(:,3),behaviour_compi(:,4));
xlabel('against_misleadingAdvice');
ylabel('percentage_against_advice_hiprob');
[R,P]=corrcoef(behaviour_compi(:,3),behaviour_compi(:,4));
disp(['Correlation between going against advice &  going against advice high probability? Pvalue: ' num2str(P(1,2))]);

end

