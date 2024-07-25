function compi_check_correlations_regressors(options)
subjects = [options.subjectIDsSession1 ...
options.subjectIDsSession2 options.subjectIDsSession3 options.subjectIDsSession4];    
        
for iSub = 1: numel(subjects)
    id = char(subjects{iSub});
    details = COMPI_subject_details(id,options);
    winningModel = load(fullfile(details.behav.pathResults,[details.behav.invertCOMPIName, ...
        options.model.winningResponse,'.mat']));
    corrMatrix    = winningModel.est_COMPI.optim.Corr;
    z_transformed = real(COMPI_fisherz(reshape(corrMatrix,size(corrMatrix,1)^2,1)));
    averageCorr{iSub,1}=reshape(z_transformed,size(corrMatrix,1),...
        size(corrMatrix,2));
end
save(fullfile(options.resultroot, 'COMPIsubjects_parameter_correlations.mat'), ...
    'averageCorr', '-mat');

averageZCorr = mean(cell2mat(permute(averageCorr,[2 3 1])),3);
averageGroupCorr = COMPI_ifisherz(reshape(averageZCorr,size(corrMatrix,1)^2,1));
finalCorr = reshape(averageGroupCorr,size(corrMatrix,1),...
        size(corrMatrix,2));
figure;imagesc(finalCorr);
caxis([-1 1]);
title('Correlation Matrix, averaged over subjects');
maximumCorr = max(max(finalCorr(~isinf(finalCorr))));
fprintf('\n\n----- Maximum correlation is %s -----\n\n', ...
    num2str(maximumCorr));
minimumCorr = min(min(finalCorr(~isinf(finalCorr))));
fprintf('\n\n----- Minimum correlation is %s -----\n\n', ...
    num2str(minimumCorr));
end