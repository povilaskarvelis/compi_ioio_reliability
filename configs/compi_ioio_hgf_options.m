function [options] = compi_ioio_hgf_options(options, ms)
% -------------------------------------------------------------------------
% Function that appends option structure with all options relevant to HGF
% analysis.
% -------------------------------------------------------------------------

% Select HGF model space
options.hgf.model_space = ms;
lt = options.behav.last_trial;

% Simulation options
%options.hgf.sim_noise = [0 1 2]; % (Additive) noise for confusion matrix
options.hgf.sim_noise = [0]; % (Additive) noise for confusion matrix

% Simulation seed (set to NaN if not seed should be used)
% Note: For estimating model performance only first seed will be used, the
% other seeds are used for the simulation pipeline (e.g. computing
% parameter recoveribility and confusion matrices (averaged across seeds)
%options.hgf.seeds = [10 11 12 13 14 15 16 17 18 19];
options.hgf.seeds = [10 11 12 13 14 15 16 17 18 19 20 21 22 23 24 25 26 27 28 29];
%options.hgf.seeds = NaN;


%% Return model space
switch options.hgf.model_space
        
    case 1
        %------------------------------------------------------------------
        % Model space 9: Model space that was identifiable in DMPAD data
        % with multiple random seeds. Try to see how much C and
        % recoveribiluty varies, for different seeds.
        % Changes with respect to MS1:
        % => theta and sigma20 fixed.
        % => sigma30 set to 1 for both models (previously set to 4 for
        % vanilla hgf, but to 1 for AR1)
        %------------------------------------------------------------------
        % Make sure, that we use the correct HGF version (3.0)
        addpath(genpath(fullfile(options.roots.toolboxes, 'HGF_3.0')));
        
        options.hgf.models = 1:4;
        options.hgf.model_names = {'HGF','HGFBO', 'HGFmr', 'HGFmrBO'};%,'HGFmr1','HGFmr2','HGFmr3','HGFmr4'};
        
        options.hgf.prc_models = {...
            'MS9_dmpad_hgf_config',...                                  % 1
            ['MS9_dmpad_hgf_BO_lt' num2str(lt) '_config'],...           % 2
            'MS9_dmpad_hgf_ar1_lvl3_config',...      
            ['MS9_dmpad_hgf_ar1_lvl3_BO_lt' num2str(lt) '_config'],...  % 4
            % 'MS9_dmpad_hgf_ar1_lvl3_1_config',... % 5
            % 'MS9_dmpad_hgf_ar1_lvl3_2_config',... % 6
            % 'MS9_dmpad_hgf_ar1_lvl3_3_config',... % 7
            % 'MS9_dmpad_hgf_ar1_lvl3_4_config',... % 8
            };
        
        options.hgf.obs_models = {...
            'MS9_dmpad_constant_voltemp_exp_config',...                 % 1
            };
        
        options.hgf.combinations = [...
            1     1    %  1: MS9_dmpad_hgf_config & MS9_dmpad_constant_voltemp_exp_config
            2     1    %  2: MS9_dmpad_hgf_BO_config & MS9_dmpad_constant_voltemp_exp_config
            3     1    %  3: MS9_dmpad_hgf_ar1_lvl3_config & MS9_dmpad_constant_voltemp_exp_config
            4     1    %  4: MS9_dmpad_hgf_ar1_lvl3_BO_config & MS9_dmpad_constant_voltemp_exp_config
            % 5     1
            % 6     1
            % 7     1 
            % 8     1
            ];
              
        
end

%% Create Results folder
% HGF
options.roots.results_hgf = fullfile(options.roots.results,...
    'results_hgf',['ms' num2str(ms)]);
mkdir(options.roots.results_hgf);


%% Create diagnostic roots and folders
options.roots.diag_hgf = fullfile(options.roots.results,...
    'diag_hgf',['ms' num2str(ms)]);
mkdir(options.roots.diag_hgf);

for i_m = 1:length(options.hgf.models)
    mkdir(fullfile(options.roots.diag_hgf,['m' num2str(i_m)],'traj'));
    mkdir(fullfile(options.roots.diag_hgf,['m' num2str(i_m)],'corr'));
end
mkdir(fullfile(options.roots.diag_hgf, 'C'));

% TODO: Check which options are needed (see below) and integrate them in function.


% options.model.winningPerceptual = 'tapas_hgf_binary';
% options.model.winningResponse   = 'tapas_ioio_unitsq_sgm_mu3';
%
% options.model.all               = {'HGF','HGF_v1','AR1','HGF_2Levels','Sutton','RW'};
% options.model.typeModel         = char(ModelName);
% options.errorfile               = [options.model.typeModel,'.mat'];
% options.model.modelling_bias    = false;
%
% %% Model Space
% switch options.model.typeModel
%     case 'HGF'
%         options.model.perceptualModels   = 'tapas_hgf_binary';
%         options.model.responseModels   = ...
%             {'tapas_ioio_unitsq_sgm_mu3', 'tapas_ioio_cue_unitsq_sgm_mu3',...
%             'tapas_ioio_advice_unitsq_sgm_mu3'};
%         options.model.simulationsParameterArray = {'ka','om','th','ze','mu2_0'};
%     case 'HGF_v1'
%         options.model.perceptualModels   = 'tapas_hgf_binary_v1';
%         options.model.responseModels   = ...
%             {'ioio_constant_voltemp_exp','ioio_constant_voltemp_exp_cue',...
%             'ioio_constant_voltemp_exp_adv'};
%         options.model.simulationsParameterArray = {'ka','om','th','ze','mu2_0'};
%     case 'AR1'
%         options.model.perceptualModels   = 'tapas_hgf_ar1_binary';
%         options.model.responseModels   = ...
%             {'tapas_ioio_unitsq_sgm','tapas_ioio_cue_unitsq_sgm',...
%             'tapas_ioio_advice_unitsq_sgm'};
%         options.model.simulationsParameterArray = {'ka','om','th','ze','m2'};
%     case 'HGF_2Levels'
%         options.model.perceptualModels   = 'tapas_hgf_binary_novol';
%         options.model.responseModels   = ...
%             {'tapas_ioio_unitsq_sgm','tapas_ioio_cue_unitsq_sgm',...
%             'tapas_ioio_advice_unitsq_sgm'};
%     case 'Sutton'
%         options.model.perceptualModels   = 'tapas_sutton_k1_binary';
%         options.model.responseModels   = ...
%             {'tapas_ioio_unitsq_sgm','tapas_ioio_cue_unitsq_sgm',...
%             'tapas_ioio_advice_unitsq_sgm'};
%     case 'RW'
%         options.model.perceptualModels   = 'tapas_rw_binary';
%         options.model.responseModels   = ...
%             {'tapas_ioio_unitsq_sgm','tapas_ioio_cue_unitsq_sgm',...
%             'tapas_ioio_advice_unitsq_sgm'};
% end
%
% options.model.allresponseModels = ...
%     {'tapas_ioio_unitsq_sgm_mu3','tapas_ioio_cue_unitsq_sgm_mu3',...
%     'tapas_ioio_advice_unitsq_sgm_mu3',...
%     'tapas_ioio_unitsq_sgm','tapas_ioio_cue_unitsq_sgm',...
%     'tapas_ioio_advice_unitsq_sgm'};
% options.model.labels = ...
%     {'HGF_Both', 'Cue','HGF_Advice','AR1_Both','Cue',...
%     'AR1_Advice','RW_Both','Cue','RW_Advice'};
% options.family.perceptual.labels = {'HGF','AR1','RW'};
% options.family.perceptual.partition = [1 1 1 2 2 2 3 3 3];
%
% options.family.responsemodels1.labels = {'Both','Cue','Advice'};
% options.family.responsemodels1.partition = [1 2 3 1 2 3 1 2 3];



% %% Model Parameters
% options.model.hgf   = {'mu2_0','mu3_0','kappa','omega_2','omega_3'};
% options.model.rw    = {'mu2_0','alpha'};
% options.model.ar1   = {'m3','phi3','kappa','omega_2','omega_3'};
%
% options.model.sgm   = {'zeta_1','zeta_2'};
% options.model.bias  = {'zeta_1','zeta_2','psi'};
