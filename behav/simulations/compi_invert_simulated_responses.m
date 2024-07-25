function [F, p_prc, p_obs, estArray] = ...
    COMPI_invert_simulated_responses(iSim, s, input_y, iInversionModelArray, ...
    doSave,input_u,ModelName,parameterName,options)
% inverts models for a given set of simulated responses and several
% selection models for inversion
%
% if doSave, saves free energy (F) and parameter estimates (p_prc and
% p_obs) of all models (cell array) to F_allModels_iSim%05d.mat in
% paths.save directory specified in get_names_paths_subjects_models

paths.save   = options.simroot;

nInversionModels = length(iInversionModelArray);
F = NaN(1, nInversionModels);
p_prc = cell(1, nInversionModels);
p_obs = cell(1, nInversionModels);
estArray = cell(1, nInversionModels);
for m = 1:nInversionModels
    fprintf('\tInverting Model %d/%d\n', m, nInversionModels);
    
    iInversionModel = iInversionModelArray(m);
    try
        switch ModelName
            case {'HGF','AR1'}
                est = tapas_fitModel(input_y, input_u, ...
                    [options.model.perceptualModels '_config'], ...
                    [options.model.responseModels{iInversionModel} '_config']);
                F(1, m) = est.optim.LME;
            case 'HGF_v1'
                est = tapas_fitModel_v1(input_y, input_u, ...
                    [options.model.perceptualModels '_config'], ...
                    [options.model.responseModels{iInversionModel} '_config']);
                F(1, m) = est.F;
        end
        p_prc{1,m} = est.p_prc;
        p_obs{1,m} = est.p_obs;
    catch err
        % warning instead of error to continue
        warning(err.message);
        p_prc{1,m} = NaN;
        p_obs{1,m} = NaN;
        F(1, m) = NaN;
    end
end

if doSave
    filenameSave = fullfile(paths.save, sprintf('F_allModels_iSim%05d_Parameter%s_Value%05d.mat',...
        iSim,parameterName,s));
    save(filenameSave, 'F', 'p_prc', 'p_obs');
end