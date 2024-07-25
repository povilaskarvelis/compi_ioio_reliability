function design = getDMPADRegressors(...
    designName,details,est,cue,cue_new,input_u,doPlotRegressors)
% Computes regressors for design matrix from HGF model inversion results
% and behavioral data of subject

x=est.traj.muhat(:,1);
ze1=est.p_obs.ze1;
px = 1./(x.*(1-x));
pc = 1./(cue_new.*(1-cue_new));
wx = ze1.*px./(ze1.*px + pc);
wc = pc./(ze1.*px + pc);
b = wx.*x + wc.*cue_new;
outcomeP = ze1.*x + (1-ze1).*cue_new;
switch designName
    case 'Transformed_DesignMatrixPrediction'
        sigmaCue                  = std(cue);
        design.Cue                = cue./sigmaCue;
        sigmaMu1hat               = std(est.traj.muhat(:,1));
        design.Mu1hat             = (est.traj.muhat(:,1))./sigmaMu1hat;
        sigmaOutcomeProbability   = std(outcomeP);
        design.OutcomeProbability = outcomeP./sigmaOutcomeProbability;
        sigmaPi2hat               = std(1./est.traj.sahat(:,2));
        design.Pi2hat             = (1./est.traj.sahat(:,2))./sigmaPi2hat;
        sigmaMu3hat               = std(est.traj.muhat(:,3));
        design.Mu3hat             = (est.traj.muhat(:,3))./sigmaMu3hat;
        sigmaPi3hat               = std(1./est.traj.sahat(:,3));
        design.Pi3hat             = (1./est.traj.sahat(:,3))./sigmaPi3hat;
        design.Drift              = [1:210]';
    case 'FullDesignMatrix'
        design.CuePE        = abs(input_u(:,1) - cue);
        design.SignedDelta1 = est.traj.da(:,1);
        design.OutcomePE    = abs(input_u(:,1) - b);
        design.Precision2   = 1./est.traj.sa(:,2);
        design.Delta2       = est.traj.da(:,2);
        design.Precision3   = 1./est.traj.sa(:,3);
        design.Delta3       = abs(est.traj.mu(:,3) - est.traj.muhat(:,3));
    case 'Transformed_FullDesignMatrix'
        sigmaCuePE          = std(abs(input_u(:,1) - cue));
        design.CuePE        = (abs(input_u(:,1) - cue))./sigmaCuePE;
        sigmaSignedDelta1   = std(est.traj.da(:,1));
        design.SignedDelta1 = (est.traj.da(:,1))./sigmaSignedDelta1;
        sigmaOutcomePE      = std(abs(input_u(:,1) - b));
        design.OutcomePE    = (abs(input_u(:,1) - b))./sigmaOutcomePE;
        sigmaPrecision2     = std(1./est.traj.sa(:,2));
        design.Precision2   = (1./est.traj.sa(:,2))./sigmaPrecision2;
        sigmaDelta2         = std(est.traj.da(:,2));
        design.Delta2       = (est.traj.da(:,2))./sigmaDelta2;
        sigmaPrecision3     = std(1./est.traj.sa(:,3));
        design.Precision3   = (1./est.traj.sa(:,3))./sigmaPrecision3;
        sigmaDelta3         = std(abs(est.traj.mu(:,3) - est.traj.muhat(:,3)));
        design.Delta3       = (abs(est.traj.mu(:,3) - est.traj.muhat(:,3)))./sigmaDelta3;
    case 'PredictionwithBeliefUpdating'
        sigmaCuePE          = std(abs(input_u(:,1) - cue));
        design.CuePE        = (abs(input_u(:,1) - cue))./sigmaCuePE;
        sigmaSignedDelta1   = std(est.traj.da(:,1));
        design.SignedDelta1 = (est.traj.da(:,1))./sigmaSignedDelta1;
        sigmaOutcomePE      = std(abs(input_u(:,1) - b));
        design.OutcomePE    = (abs(input_u(:,1) - b))./sigmaOutcomePE;
        sigmaPrecision2     = std(1./est.traj.sa(:,2));
        design.Precision2   = (1./est.traj.sa(:,2))./sigmaPrecision2;
        sigmaDelta2         = std(est.traj.da(:,2));
        design.Delta2       = (est.traj.da(:,2))./sigmaDelta2;
        sigmaPrecision3     = std(1./est.traj.sa(:,3));
        design.Precision3   = (1./est.traj.sa(:,3))./sigmaPrecision3;
        sigmaDelta3         = std(abs(est.traj.mu(:,3) - est.traj.muhat(:,3)));
        design.Delta3       = (abs(est.traj.mu(:,3) - est.traj.muhat(:,3)))./sigmaDelta3;
        sigmaCue                  = std(cue);
        design.Cue                = cue./sigmaCue;
        sigmaMu1hat               = std(est.traj.muhat(:,1));
        design.Mu1hat             = (est.traj.muhat(:,1))./sigmaMu1hat;
        sigmaOutcomeProbability   = std(outcomeP);
        design.OutcomeProbability = outcomeP./sigmaOutcomeProbability;
        sigmaPi3hat               = std(1./est.traj.sahat(:,3));
        design.Pi3hat             = (1./est.traj.sahat(:,3))./sigmaPi3hat;
    case 'Control'
        sigmaCuePE          = std(abs(input_u(:,1) - cue));
        design.CuePE        = (abs(input_u(:,1) - cue))./sigmaCuePE;
        sigmaSignedDelta1   = std(est.traj.da(:,1));
        design.SignedDelta1 = (est.traj.da(:,1))./sigmaSignedDelta1;
        sigmaOutcomePE      = std(abs(input_u(:,1) - b));
        design.OutcomePE    = (abs(input_u(:,1) - b))./sigmaOutcomePE;
        sigmaPrecision2     = std(1./est.traj.sa(:,2));
        design.Precision2   = (1./est.traj.sa(:,2))./sigmaPrecision2;
        sigmaDelta2         = std(est.traj.da(:,2));
        design.Delta2       = (est.traj.da(:,2))./sigmaDelta2;
        sigmaPrecision3     = std(1./est.traj.sa(:,3));
        design.Precision3   = (1./est.traj.sa(:,3))./sigmaPrecision3;
        sigmaDelta3         = std(abs(est.traj.mu(:,3) - est.traj.muhat(:,3)));
        design.Delta3       = (abs(est.traj.mu(:,3) - est.traj.muhat(:,3)))./sigmaDelta3;
        design.Drift        = [1:170]';
    case 'HGF'
        sigmaSignedDelta1   = std(est.traj.da(:,1));
        design.SignedDelta1 = (est.traj.da(:,1))./sigmaSignedDelta1;
        sigmaPrecision2     = std(1./est.traj.sa(:,2));
        design.Precision2   = (1./est.traj.sa(:,2))./sigmaPrecision2;
        sigmaDelta2         = std(est.traj.da(:,2));
        design.Delta2       = (est.traj.da(:,2))./sigmaDelta2;
        sigmaPrecision3     = std(1./est.traj.sa(:,3));
        design.Precision3   = (1./est.traj.sa(:,3))./sigmaPrecision3;
        sigmaDelta3         = std(abs(est.traj.mu(:,3) - est.traj.muhat(:,3)));
        design.Delta3       = (abs(est.traj.mu(:,3) - est.traj.muhat(:,3)))./sigmaDelta3;
    case 'FullDesignMatrixUncertainty'
        sigmaCuePE          = std(abs(input_u(:,1) - cue));
        design.CuePE        = (abs(input_u(:,1) - cue))./sigmaCuePE;
        sigmaSignedDelta1   = std(est.traj.da(:,1));
        design.SignedDelta1 = (est.traj.da(:,1))./sigmaSignedDelta1;
        sigmaOutcomePE      = std(abs(input_u(:,1) - b));
        design.OutcomePE    = (abs(input_u(:,1) - b))./sigmaOutcomePE;
        sigmaSigma2     = std(est.traj.sa(:,2));
        design.Sigma2   = (est.traj.sa(:,2))./sigmaSigma2;
        sigmaDelta2         = std(est.traj.da(:,2));
        design.Delta2       = (est.traj.da(:,2))./sigmaDelta2;
        sigmaSigma3     = std(est.traj.sa(:,3));
        design.Sigma3   = (est.traj.sa(:,3))./sigmaSigma3;
        sigmaDelta3         = std(abs(est.traj.mu(:,3) - est.traj.muhat(:,3)));
        design.Delta3       = (abs(est.traj.mu(:,3) - est.traj.muhat(:,3)))./sigmaDelta3;     
    case 'DesignMatrix_ValencePE'
        design.CuePE          = abs(input_u(:,1) - cue);
        design.PositiveDelta1 = [];
        design.NegativeDelta1 = [];
        advPE = est.traj.da(:,1);
        for iCell = 1:210
            if advPE(iCell) > 0
                design.PositiveDelta1(iCell) = advPE(iCell);
            else
                design.PositiveDelta1(iCell) = 0;
            end
        end
        
        for iCell = 1:210
            if advPE(iCell) < 0
                design.NegativeDelta1(iCell) = advPE(iCell);
            else
                design.NegativeDelta1(iCell) = 0;
            end
        end
        
        design.PositiveDelta1 = design.PositiveDelta1';
        design.NegativeDelta1 = design.NegativeDelta1';
        design.OutcomePE    = abs(input_u(:,1) - b);
        design.Precision2   = 1./est.traj.sa(:,2);
        design.Delta2       = est.traj.da(:,2);
        design.Precision3   = 1./est.traj.sa(:,3);
        design.Delta3       = abs(est.traj.mu(:,3) - est.traj.muhat(:,3));
end

% FIXME: create folder in EEG output
%save(fullfile(details.dirs, [designName '.mat']),'design','-mat');

%if doPlotRegressors
    fh = plotDMPADRegressors(design, details.subproname);
%end

