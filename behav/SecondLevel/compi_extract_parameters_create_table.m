function [variables_COMPI] = compi_extract_parameters_create_table(options,subjects,comparisonType)
%IN
% analysis options, subjects
% OUT
% parameters of the winning model and all nonmodel-based parameters
options.subjectIDs = subjects;

% pairs of perceptual and response model
PerceptualModel_Parameters = options.model.hgf;
ResponseModel_Parameters = options.model.sgm;

perceptual_model = options.model.winningPerceptual;
response_model   = options.model.winningResponse;

nParameters = [PerceptualModel_Parameters';ResponseModel_Parameters'];
nSubjects = numel(options.subjectIDs);
variables_COMPI = cell(nSubjects, numel(nParameters)+16); % 16 is the number of nonmodel-based variables


for iSubject = 1:nSubjects
    id = char(options.subjectIDs(iSubject));
    details = COMPI_subject_details(id, options);
    tmp = load(fullfile(details.behav.pathResults,...
        [details.dirSubject, perceptual_model...
        response_model,'.mat']));
    variables_COMPI{iSubject,1} = tmp.est_COMPI.p_prc.mu_0(2);
    variables_COMPI{iSubject,2} = tmp.est_COMPI.p_prc.mu_0(3);
    variables_COMPI{iSubject,3} = tmp.est_COMPI.p_prc.ka(2);
    variables_COMPI{iSubject,4} = tmp.est_COMPI.p_prc.om(2);
    variables_COMPI{iSubject,5} = tmp.est_COMPI.p_prc.om(3);
    variables_COMPI{iSubject,6} = tmp.est_COMPI.p_obs.ze1;
    variables_COMPI{iSubject,7} = tmp.est_COMPI.p_obs.ze2;
    
    variables_COMPI{iSubject,8}   = tmp.est_COMPI.cScore;
    variables_COMPI{iSubject,9}   = tmp.est_COMPI.perf_acc;
    variables_COMPI{iSubject,10}  = tmp.est_COMPI.take_adv_helpful;
    variables_COMPI{iSubject,11}  = tmp.est_COMPI.go_against_adv_misleading;
    variables_COMPI{iSubject,12}  = tmp.est_COMPI.choice_with;
    variables_COMPI{iSubject,13}  = tmp.est_COMPI.choice_against;
    variables_COMPI{iSubject,14}  = tmp.est_COMPI.choice_with_chance;
    variables_COMPI{iSubject,15}  = tmp.est_COMPI.go_with_stable_helpful_advice;
    variables_COMPI{iSubject,16}  = tmp.est_COMPI.go_with_stable_helpful_advice1;
    variables_COMPI{iSubject,17}  = tmp.est_COMPI.go_with_stable_helpful_advice2;
    variables_COMPI{iSubject,18}  = tmp.est_COMPI.choice_against_stable_misleading_advice;
    variables_COMPI{iSubject,19}  = tmp.est_COMPI.go_with_volatile_advice;
    variables_COMPI{iSubject,20}  = tmp.est_COMPI.take_adv_overall;
    variables_COMPI{iSubject,21}  = tmp.est_COMPI.go_against_volatile_advice;
    variables_COMPI{iSubject,22}  = tmp.est_COMPI.take_adv_in_switch_to_misleading;
    variables_COMPI{iSubject,23}  = tmp.est_COMPI.take_adv_in_switch_to_helpful;
end
variables_COMPI = cell2mat(variables_COMPI);
save(fullfile(options.resultroot, [comparisonType '_MAP_estimates_winning_model_nonModelVariables.mat']), ...
    'variables_COMPI', '-mat');
ofile=fullfile(options.resultroot,[comparisonType '_MAP_estimates_winning_model_nonModelVariables.xlsx']);
xlswrite(ofile, [str2num(cell2mat(options.subjectIDs')) variables_COMPI]);
end



