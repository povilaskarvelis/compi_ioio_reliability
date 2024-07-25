function [models_COMPI] = loadCOMPIModelEvidence(options,subjects)

perceptual_models = {'tapas_hgf_binary','tapas_hgf_ar1_binary','tapas_rw_binary'};
response_models  = options.model.allresponseModels';

if options.model.modelling_bias == true
    % pairs of perceptual and response model
    iCombPercResp = zeros(18,2);
    iCombPercResp(1:6,1) = 1;
    iCombPercResp(7:12,1) = 2;
    iCombPercResp(13:18,1) = 3;
    
    iCombPercResp(1:6,2) = 1:6;
    iCombPercResp(7:12,2) = 7:12;
    iCombPercResp(13:18,2) = 7:12;    
else 
    % pairs of perceptual and response model
    iCombPercResp = zeros(9,2);
    iCombPercResp(1:3,1) = 1;
    iCombPercResp(4:6,1) = 2;
    iCombPercResp(7:9,1) = 3;
    
    iCombPercResp(1:3,2) = 1:3;
    iCombPercResp(4:6,2) = 4:6;
    iCombPercResp(7:9,2) = 4:6;
    
end

nModels = size(iCombPercResp,1);

nSubjects = numel(subjects);
models_COMPI = cell(nSubjects, nModels);

for iSubject = 1:nSubjects
    
    id = char(subjects(iSubject));
    details = COMPI_subject_details(id, options);
    
    % loop over perceptual and response models
    for iModel = 1:nModels
        
        tmp = load(fullfile(details.behav.pathResults,...
            [details.dirSubject, perceptual_models{iCombPercResp(iModel,1)}...
            response_models{iCombPercResp(iModel,2)},'.mat']));
        models_COMPI{iSubject,iModel} = tmp.est_COMPI.optim.LME;
    end
end
models_COMPI = cell2mat(models_COMPI);
end