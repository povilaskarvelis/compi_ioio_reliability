function [pathAnalysisArray,regressor] = getDesign(design)

switch design
    case 'AllParams'
        pathAnalysisArray = {
            'AllParams_CuePE',...
            'AllParams_SignedDelta1',...
            'AllParams_OutcomePE',...
            'AllParams_Sigma2',...
            'AllParams_Delta2',...
            'AllParams_Sigma3'};
        regressor = {
            'CuePE','SignedDelta1','OutcomePE','Sigma2','Delta2',...
            'Sigma3'};
    case 'FullDesignMatrix'
        pathAnalysisArray = {
            'FullDesignMatrix_Main',...
            'FullDesignMatrix_CuePE',...
            'FullDesignMatrix_SignedDelta1_Pos',...
            'FullDesignMatrix_OutcomePE',...
            'FullDesignMatrix_Sigma2',...
            'FullDesignMatrix_Delta2',...
            'FullDesignMatrix_Sigma3',...
            'FullDesignMatrix_Delta3'};
        regressor = {'Main', 'CuePE','SignedDelta1','OutcomePE','Sigma2','Delta2',...
            'Sigma3','Delta3'};
    case 'FullDesignMatrix_Pruned'
        pathAnalysisArray = {
            'FullDesignMatrix_Main',...
            'FullDesignMatrix_CuePE',...
            'FullDesignMatrix_SignedDelta1_Pos',...
            'FullDesignMatrix_OutcomePE',...
            'FullDesignMatrix_Sigma2',...
            'FullDesignMatrix_Delta2',...
            'FullDesignMatrix_Sigma3',...
            'FullDesignMatrix_Delta3'};
        regressor = {'Main', 'CuePE','SignedDelta1','OutcomePE','Sigma2','Delta2',...
            'Sigma3','Delta3'};
    case 'FullDesignMatrixUncertainty'
        pathAnalysisArray = {
            'FullDesignMatrixUncertainty_Main',...
            'FullDesignMatrixUncertainty_CuePE',...
            'FullDesignMatrixUncertainty_SignedDelta1',...
            'FullDesignMatrixUncertainty_OutcomePE',...
            'FullDesignMatrixUncertainty_Sigma2',...
            'FullDesignMatrixUncertainty_Delta2',...
            'FullDesignMatrixUncertainty_Sigma3',...
            'FullDesignMatrixUncertainty_Delta3'};
        regressor = {'Main', 'CuePE','SignedDelta1','OutcomePE','Sigma2','Delta2',...
            'Sigma3','Delta3'};
    case 'DesignMatrix'
        pathAnalysisArray = {
            'FullDesignMatrix_Main',...
            'FullDesignMatrix_CuePE',...
            'FullDesignMatrix_SignedDelta1_Pos',...
            'FullDesignMatrix_OutcomePE',...
            'FullDesignMatrix_Sigma2',...
            'FullDesignMatrix_Delta2',...
            'FullDesignMatrix_Sigma3',...
            'FullDesignMatrix_Delta3'};
        regressor = {'Main', 'CuePE','SignedDelta1','OutcomePE','Sigma2','Delta2',...
            'Sigma3','Delta3'};
        
    case 'DesignMatrix_Pruned'
        pathAnalysisArray = {
            'FullDesignMatrix_Main',...
            'FullDesignMatrix_CuePE',...
            'FullDesignMatrix_PositiveDelta1',...
            'FullDesignMatrix_NegativeDelta1',...
            'FullDesignMatrix_OutcomePE',...
            'FullDesignMatrix_Precision2',...
            'FullDesignMatrix_Delta2',...
            'FullDesignMatrix_Precision3'};
        
        regressor = ...
            {'Main', 'CuePE','PositiveDelta1','NegativeDelta1','OutcomePE','Precision2','Delta2',...
            'Precision3'};
        
end
end