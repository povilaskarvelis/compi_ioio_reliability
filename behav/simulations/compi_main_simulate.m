%% Simulate responses for all subjects with their estimated parameters
%       => add another parameter eta (0, 0.1, 0.5, 3) to subjects'
%       parameter vector
%       => 4 runs for each parameter/subject pair
%
% - for all models:
%       - 3 perceptual models
%       - 3 belief integrations
% - 20 instances of each model_params/subject pair
%
%   IN
%       options
function compi_main_simulate(iParameterArray)

%% MOD - Simulation parameters / Inversion Parameters
iInstanceArray          = 1:20;
noiseLevelArray         = [0, 0.5, 1, 3];
noiseLevelStringArray   = {'none', 'low', 'medium', 'high'};
iResponseModelArray     = 1:3; % total number of response models
iInversionModelArray    = iResponseModelArray; % models for data inversion

doSimulateData          = 1;
doInvertModels          = 1;
doCompareParameters     = 1;
doParallelizeArton      = 1;
doSaveInversionInOneFile= 1; % true = 1 file for all iSims; false = 1 file per iSim
doSaveFigures           = 1; % save sim output figures as png

ModelName        = 'AR1';
options          = compi_ioio_options(ModelName);
responseModels   = options.model.responseModels;
perceptualModels = options.model.perceptualModels;
ParameterArray   = options.model.simulationsParameterArray;
input_u          = load(options.input);
paths.save       = options.simroot;
nInversionModels = numel(responseModels);
nTrials          = 210;
nParameters      = numel(ParameterArray);

if nargin < 1
    iParameterArray = 1:nParameters;
end

%% cluster setup
if doParallelizeArton && isempty(gcp('nocreate')) ...
        && (doSimulateData || doInvertModels)
    if options.doRunOnArton
        parpool('local', 16);
    else
        parpool('SGEMatlab', 20); % max 32, try 24, then 20, then 16, if stuck at "Starting parallel pool"
    end
end


nNoiseLevels = numel(noiseLevelArray);
nSimulatedResponseModels = numel(iResponseModelArray);
nInstances = numel(iInstanceArray);

for iParameter = iParameterArray
    parameterName = ParameterArray{iParameter};
    
    %% Simulate Data
    if doSimulateData
        
        % Initialise optimal parameters
        bopars  = tapas_fitModel([], input_u(:,1), [perceptualModels '_config'], ...
            'tapas_bayes_optimal_binary_config', 'tapas_quasinewton_optim_config');
        
        switch ModelName
            case 'HGF'
                [iParameterInstanceArray] = getHGFParameterArray(parameterName,bopars);
            case 'HGF_v1'
                [iParameterInstanceArray] = getHGFv1ParameterArray(parameterName,bopars);
            case 'AR1'
                [iParameterInstanceArray] = getAR1ParameterArray(parameterName,bopars);
        end
        [iParameterGrid, iModelGrid, noiseLevelGrid, iInstanceGrid] = ndgrid( ...
            iParameterInstanceArray, iResponseModelArray, noiseLevelArray, iInstanceArray);
        
        nSims = numel(iInstanceGrid);
        simulatedResponses = NaN(nTrials, nSims);
        
        p_prc = cell(1, nSims);
        p_obs = cell(1, nSims);
        parfor iSim = 1:nSims
            % set different counters
            iInstance = iInstanceGrid(iSim);
            noiseLevel = noiseLevelGrid(iSim);
            iParameterInstance = iParameterGrid(iSim);
            iInversionModel = iModelGrid(iSim);
            fprintf(['Simulating responses %d/%d of subject %d, iModel %d, '...
                'noiseLevel %f, iInstance %d\n'],iSim, nSims, iParameterInstance, iInversionModel, ...
                noiseLevel, iInstance);
            
            switch ModelName
                case 'HGF'
                    [prcArray,rspArray,lgstr] =  getHGFSpecificParameterArray(bopars,parameterName,iParameterInstance);
                case 'HGF_v1'
                    [prcArray,rspArray,lgstr] =  getHGFv1SpecificParameterArray(bopars,parameterName,iParameterInstance);
                case 'AR1'
                    [prcArray,rspArray,lgstr] =  getAR1SpecificParameterArray(bopars,parameterName,iParameterInstance);
            end
            
            % Add noise
            responseArray=[rspArray noiseLevel];
            
            % Simulate
            sim = tapas_simModel(input_u, perceptualModels, prcArray, ...
                responseModels{iInversionModel}, responseArray);
            simulatedResponses(:,iSim)  = sim.y;
            p_prc{:,iSim} = sim.p_prc;
            p_obs{:,iSim} = sim.p_obs;
        end
        save(fullfile(paths.save, ['SimulationssimulatedResponses', ModelName,parameterName,'.mat']), ...
            'nSims', 'simulatedResponses','iParameterGrid','iModelGrid','noiseLevelGrid', 'iInstanceGrid',...
            'p_prc','p_obs');
        
    else % load previous simulations
        load(fullfile(paths.save, ['SimulationssimulatedResponses', ModelName,parameterName,'.mat']));
        nInversionModels = length(unique(iModelGrid(:)));
        nSims = size(simulatedResponses,2);
    end
    
    
    %% Invert Models
    if doInvertModels
        nInversionModels = numel(iInversionModelArray);
        F = NaN(nSims, nInversionModels);
        if doSaveInversionInOneFile
            p_prc = cell(nSims, nInversionModels);
            p_obs = cell(nSims, nInversionModels);
        end
        iSimArray = 1:nSims;
        parfor iSim = iSimArray
            % set different counters
            iInstance = iInstanceGrid(iSim);
            noiseLevel = noiseLevelGrid(iSim);
            iParameterInstance = iParameterGrid(iSim);
            iInversionModel = iModelGrid(iSim);
            fprintf(['Inverting model using simulated responses %d/%d of subject %d, iModel %d, '...
                'noiseLevel %f, iInstance %d\n'],iSim, nSims, iParameterInstance, iInversionModel, ...
                noiseLevel, iInstance);
            
            input_y = simulatedResponses(:,iSim);
            
            % perform inversion for all models
            if doSaveInversionInOneFile
                doSave = false;
                [F(iSim, iInversionModelArray), ...
                    p_prc(iSim, iInversionModelArray), ...
                    p_obs(iSim, iInversionModelArray)] = ...
                    COMPI_invert_simulated_responses(iSim, iParameterInstance, input_y, ...
                    iInversionModelArray, doSave, input_u, ...
                    ModelName,parameterName,options);
                fprintf('\n\n\n\n\n\niSim %d / %d, parameter %d/%d (%s)\n\n\n\n\n', iSim, nSims, ...
                    iParameter, nParameters, parameterName);
                % pause(1);
            else
                doSave = true;
                F(iSim, iInversionModelArray) = ...
                    COMPI_invert_simulated_responses(iSim, iParameterInstance, input_y, iInversionModelArray, ...
                    doSave, input_u,ModelName,parameterName,options);
            end
        end
        if doSaveInversionInOneFile
            save(...
                fullfile(paths.save, ['FittedParametersToSimulation_allModels_', ...
                ModelName,parameterName,'.mat']), ...
                'F', 'p_prc', 'p_obs');
        end
    end
end %% loop over parameters

%% Compare parameters
if doCompareParameters
    iInversionModel = 1; % response model
    colourArray = {'m', 'r', 'c',  'g', 'b'};
    
    % bayes optimal parameters to be plotted as well
    bopars  = tapas_fitModel([], input_u(:,1), [perceptualModels '_config'], ...
        'tapas_bayes_optimal_binary_config', 'tapas_quasinewton_optim_config');
    
    for iParameter = iParameterArray
        parameterName = ParameterArray{iParameter};
        
        switch ModelName
            case 'HGF'
                [iParameterInstanceArray] = getHGFParameterArray(parameterName,bopars);
            case 'HGF_v1'
                [iParameterInstanceArray] = getHGFv1ParameterArray(parameterName,bopars);
            case 'AR1'
                [iParameterInstanceArray] = getAR1ParameterArray(parameterName,bopars);
        end
        load(fullfile(paths.save, ['SimulationssimulatedResponses', ModelName,parameterName,'.mat']));
        
        % recreate
        [iParameterGrid, iModelGrid, noiseLevelGrid, iInstanceGrid] = ndgrid( ...
            iParameterInstanceArray, iResponseModelArray, noiseLevelArray, iInstanceArray);
        
        nParameterInstances = numel(iParameterInstanceArray);
        nSims = size(simulatedResponses,2);
        
        if doSaveInversionInOneFile
            load(...
                fullfile(paths.save, ['FittedParametersToSimulation_allModels_', ...
                ModelName,parameterName,'.mat']), ...
                'F', 'p_prc', 'p_obs');
        end
        
        titleString = sprintf('%s - Recoverability', parameterName);
        fh(iParameter) = figure('Name', titleString);
        
        %% Collect data for subplots per noise level
        
        % initialize data for collection
        fittedParametersPerNoiseLevel = cell(nNoiseLevels,1);
        for iNoise = 1:nNoiseLevels
            fittedParametersPerNoiseLevel{iNoise} = ones(nParameterInstances, nInstances);
        end
        
        iSimArray = 1:nSims;
        for iSim = iSimArray
            % set different counters
            iInstance = iInstanceGrid(iSim);
            iNoise = find(noiseLevelGrid(iSim)==noiseLevelArray);
            iParameterInstance = find(iParameterGrid(iSim)==iParameterInstanceArray);
            
            % catch NaNs in estimate, i.e. estimation did not finish
            if ~isstruct(p_prc{iSim, iInversionModel}) && isnan(p_prc{iSim, iInversionModel})
                currData = NaN;
            else % extract specific estimation struct component dependent on parameter
                switch ModelName
                    case {'HGF','HGF_v1'}
                        switch parameterName
                            case 'ka'
                                currData = p_prc{iSim, iInversionModel}.ka(2);
                            case 'om'
                                currData = p_prc{iSim, iInversionModel}.om(2);
                            case  'th'
                                currData = p_prc{iSim, iInversionModel}.om(3);
                            case 'ze'
                                currData = p_obs{iSim, iInversionModel}.ze1;
                            case 'mu2_0'
                                currData = p_prc{iSim, iInversionModel}.mu_0(2);
                        end
                    case {'AR1'}
                        switch parameterName
                            case 'ka'
                                currData = p_prc{iSim, iInversionModel}.ka(2);
                            case 'om'
                                currData = p_prc{iSim, iInversionModel}.om(2);
                            case  'th'
                                currData = p_prc{iSim, iInversionModel}.om(3);
                            case 'ze'
                                currData = p_obs{iSim, iInversionModel}.ze1;
                            case 'm2'
                                currData = p_prc{iSim, iInversionModel}.m(2);
                        end
                end
                
                fittedParametersPerNoiseLevel{iNoise}(iParameterInstance, iInstance) = currData;
                
            end
            
            %% subplots for noise levels
            for iNoise = 1:nNoiseLevels
                subplot(1, nNoiseLevels,iNoise);
                X = reshape(repmat(iParameterInstanceArray, nInstances, 1).', [], 1);
                Y = reshape(fittedParametersPerNoiseLevel{iNoise}, [], 1);
                scatter(X, Y, [],'MarkerEdgeColor',[0 .5 .5],...
                    'MarkerFaceColor',colourArray{iParameter},...
                    'LineWidth',1.5);
                axis square
                title({'Added Decision', sprintf('Noise +%.1f', noiseLevelArray(iNoise))});
            end % noise levels
            suptitle(regexprep(titleString, '_', '\\_'));
            
            if doSaveFigures
                % nicer figure name w/o white spaces and minus
                figFileString = regexprep(...
                    regexprep([titleString '.png'], '( |-)*', '_'), '(_)+', '_');
                saveas(fh(iParameter), fullfile(options.simfigureroot, figFileString));
            end
        end % parameters
    end % doCompareParameters
end