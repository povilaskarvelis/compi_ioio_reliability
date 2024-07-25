function [parameters_COMPI] = loadCOMPIMAPs(options,subjects,comparisonType)
%IN
% analysis options
% OUT
% parameters of the winning model
options.subjectIDs = subjects;

if options.model.modelling_bias == true
    % pairs of perceptual and response model
    PerceptualModel_Parameters = options.model.rw;
    ResponseModel_Parameters = options.model.bias;
    
    perceptual_model = options.model.competingPerceptual;
    response_model   = options.model.competingResponse;
else
    % pairs of perceptual and response model
    PerceptualModel_Parameters = options.model.hgf;
    ResponseModel_Parameters = options.model.sgm;
    
    perceptual_model = options.model.winningPerceptual;
    response_model   = options.model.winningResponse;
    
end

nParameters = [PerceptualModel_Parameters';ResponseModel_Parameters'];
nSubjects = numel(options.subjectIDs);
parameters_COMPI = cell(nSubjects, numel(nParameters));

if options.model.modelling_bias == true
    
    for iSubject = 1:nSubjects
        id = char(options.subjectIDs(iSubject));
        details = COMPI_subject_details(id, options);
        tmp = load(fullfile(details.behav.pathResults,...
            [details.dirSubject, perceptual_model...
            response_model,'.mat']));
        parameters_COMPI{iSubject,1} = tmp.est_COMPI.p_prc.v_0;
        parameters_COMPI{iSubject,2} = tmp.est_COMPI.p_prc.al;
        parameters_COMPI{iSubject,3} = tmp.est_COMPI.p_obs.ze1;
        parameters_COMPI{iSubject,4} = tmp.est_COMPI.p_obs.ze2;
        parameters_COMPI{iSubject,5} = tmp.est_COMPI.p_obs.nu;
    end
    
   parameters_COMPI = cell2mat(parameters_COMPI);
    figure; scatter(parameters_COMPI(:,2),parameters_COMPI(:,3));
    xlabel(['\' options.model.rw{2}]);
    ylabel(['\' options.model.bias{1}]);
    [R,P]=corrcoef(parameters_COMPI(:,1),parameters_COMPI(:,2));
    disp(['Correlation between al and zeta? Pvalue: ' num2str(P(1,2))]);
    figure; scatter(parameters_COMPI(:,3),parameters_COMPI(:,5));
    xlabel(['\' options.model.bias{1}]);
    ylabel(['\' options.model.bias{3}]);
    [R,P]=corrcoef(parameters_COMPI(:,3),parameters_COMPI(:,5));
    disp(['Correlation between zeta and psi? Pvalue: ' num2str(P(1,2))]);
    save(fullfile(options.resultroot, [comparisonType '_MAP_estimates_competing_model.mat']), ...
        'parameters_COMPI', '-mat');
    ofile=fullfile(options.resultroot, [comparisonType '_MAP_estimates_competing_model.xlsx']);
    xlswrite(ofile, [str2num(cell2mat(options.subjectIDs')) parameters_COMPI]);
    
else
    
    for iSubject = 1:nSubjects
        id = char(options.subjectIDs(iSubject));
        details = COMPI_subject_details(id, options);
        tmp = load(fullfile(details.behav.pathResults,...
            [details.dirSubject, perceptual_model...
            response_model,'.mat']));
        parameters_COMPI{iSubject,1} = tmp.est_COMPI.p_prc.mu_0(2);
        parameters_COMPI{iSubject,2} = tmp.est_COMPI.p_prc.mu_0(3);
        parameters_COMPI{iSubject,3} = tmp.est_COMPI.p_prc.ka(2);
        parameters_COMPI{iSubject,4} = tmp.est_COMPI.p_prc.om(2);
        parameters_COMPI{iSubject,5} = tmp.est_COMPI.p_prc.om(3);
        parameters_COMPI{iSubject,6} = tmp.est_COMPI.p_obs.ze1;
        parameters_COMPI{iSubject,7} = tmp.est_COMPI.p_obs.ze2;
        parameters_COMPI{iSubject,8} = tmp.est_COMPI.go_against_adv_misleading(1);
        parameters_COMPI{iSubject,9} = tmp.est_COMPI.take_adv_helpful(1);
        parameters_COMPI{iSubject,10}= tmp.est_COMPI.take_adv_overall;
        if options.model.modelling_bias == true
            parameters_COMPI{iSubject,11} = tmp.est_COMPI.p_obs.nu;
        else
            parameters_COMPI{iSubject,11} = [];
        end
    end
    parameters_COMPI = cell2mat(parameters_COMPI);
    figure; scatter(parameters_COMPI(:,1),parameters_COMPI(:,2));
    xlabel(['\' options.model.hgf{1}]);
    ylabel(['\' options.model.hgf{2}]);
    [R,P]=corrcoef(parameters_COMPI(:,1),parameters_COMPI(:,2));
    disp(['Correlation between mu2 and mu3? Pvalue: ' num2str(P(1,2))]);
    figure; scatter3(parameters_COMPI(:,3),parameters_COMPI(:,4),parameters_COMPI(:,5),'filled');
    xlabel(['\' options.model.hgf{3}]);
    ylabel(['\' options.model.hgf{4}]);
    zlabel(['\' options.model.hgf{5}]);
    [R,P]=corrcoef(parameters_COMPI(:,3),parameters_COMPI(:,4));
    disp(['Correlation between kappa and omega? Pvalue: ' num2str(P(1,2))]);
    save(fullfile(options.resultroot, [comparisonType '_MAP_estimates_winning_model.mat']), ...
        'parameters_COMPI', '-mat');
    ofile=fullfile(options.resultroot,[comparisonType '_MAP_estimates_winning_model.xlsx']);
    xlswrite(ofile, [str2num(cell2mat(options.subjectIDs')) parameters_COMPI]);
end
end


