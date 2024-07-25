function COMPI_plot_parameter_estimate_results(options,comparisonType)
% Runs and plots model selection results
% IN
%   options     general analysis options%
%               options = COMPI_options;

% OUT
% Winning model MAPs & behavioural statistics

if nargin < 2
    comparisonType = 'all';
end

switch comparisonType
    case 'all'
        subjects = [options.subjectIDsSession1 ...
            options.subjectIDsSession2 options.subjectIDsSession3 options.subjectIDsSession4];
    case 'highDelusion'
        subjects = [options.subjectIDshighDispositional options.subjectIDshighSituational];
    case 'lowDelusion'
        subjects = [options.subjectIDslowDispositional options.subjectIDslowSituational];
    case 'Situational'
        subjects = [options.subjectIDshighSituational options.subjectIDslowSituational];
    case 'Dispositional'
        subjects = [options.subjectIDshighDispositional options.subjectIDslowDispositional];
end

[parameters] = loadCOMPIMAPs(options,subjects,comparisonType);
[behaviour_COMPI] = loadCOMPIBehaviourStats(options,subjects);

%% Take Advice
design_matrix = [parameters(:,[1 3 4 5 6]) ones(size(parameters,1),1)];
[B,BINT,R,RINT,stats.regression_takeadvice] = regress(behaviour_COMPI(:,1),design_matrix);
disp(['GLM with taking advice as the dependent variable:'...
    ' the R-square statistic, the F statistic and p value  ' ...
    num2str(stats.regression_takeadvice(1:3))]);

if options.model.modelling_bias == true
    [R,P]=corrcoef(parameters(:,3),behaviour_COMPI(:,1));
    disp(['Correlation between zeta1 and taking advice? Pvalue: ' num2str(P(1,2))]);
    stats.correlation_advicexzeta = R(1,2);
    stats.correlationp_advicexzeta = P(1,2);
    
    [R,P]=corrcoef(parameters(:,5),behaviour_COMPI(:,1));
    disp(['Correlation between bias and taking advice? Pvalue: ' num2str(P(1,2))]);
    stats.correlation_advicexzeta2 = R(1,2);
    stats.correlationp_advicexzeta2 = P(1,2);
else
    
    [R,P]=corrcoef(parameters(:,6),behaviour_COMPI(:,1));
    disp(['Correlation between zeta1 and taking advice? Pvalue: ' num2str(P(1,2))]);
    stats.correlation_advicexzeta = R(1,2);
    stats.correlationp_advicexzeta = P(1,2);
    
    COMPI_plot_regression(behaviour_COMPI(:,1),parameters(:,6));
    
    
    [R,P]=corrcoef(parameters(:,7),behaviour_COMPI(:,1));
    disp(['Correlation between decision noise and taking advice? Pvalue: ' num2str(P(1,2))]);
    stats.correlation_advicexzeta2 = R(1,2);
    stats.correlationp_advicexzeta2 = P(1,2);
    
    COMPI_plot_regression(parameters(:,7),behaviour_COMPI(:,1));
end

%% Take helpful advice
[B,BINT,R,RINT,stats.regression_take_helpfuladvice] = regress(behaviour_COMPI(:,2),design_matrix);
disp(['GLM with taking helpful advice as the dependent variable:'...
    'the R-square statistic, the F statistic and p value  ' ...
    num2str(stats.regression_take_helpfuladvice(1:3))]);

if options.model.modelling_bias == true
    [R,P]=corrcoef(parameters(:,3),behaviour_COMPI(:,2));
    disp(['Correlation between zeta1 and taking helpful advice? Pvalue: ' num2str(P(1,2))]);
    stats.correlation_helpful_advicexzeta = R(1,2);
    stats.correlationp_helpful_advicexzeta = P(1,2);
else
    
    [R,P]=corrcoef(parameters(:,6),behaviour_COMPI(:,2));
    disp(['Correlation between zeta1 and taking helpful advice? Pvalue: ' num2str(P(1,2))]);
    stats.correlation_helpful_advicexzeta = R(1,2);
    stats.correlationp_helpful_advicexzeta = P(1,2);
    
    COMPI_plot_regression(parameters(:,6),behaviour_COMPI(:,2));
    
end

%% Go against misleading advice
[B,BINT,R,RINT,stats.regression_againstmisleading] = regress(behaviour_COMPI(:,3),design_matrix);
disp(['GLM with going against misleading advice as the dependent variable:'...
    'the R-square statistic, the F statistic and p value  ' ...
    num2str(stats.regression_againstmisleading(1:3))]);

if options.model.modelling_bias == true
    [R,P]=corrcoef(parameters(:,3),behaviour_COMPI(:,3));
    disp(['Correlation between zeta1 and going against advice? Pvalue: ' num2str(P(1,2))]);
    stats.correlation_againstadvicexzeta = R(1,2);
    stats.correlationp_againstadvicexzeta = P(1,2);
    
    [R,P]=corrcoef(parameters(:,5),behaviour_COMPI(:,3));
    disp(['Correlation between bias and going against advice? Pvalue: ' num2str(P(1,2))]);
    stats.correlation_againstadvicexzeta2 = R(1,2);
    stats.correlationp_againstadvicexzeta2 = P(1,2);
else
    [R,P]=corrcoef(parameters(:,6),behaviour_COMPI(:,3));
    disp(['Correlation between zeta1 and going against advice? Pvalue: ' num2str(P(1,2))]);
    stats.correlation_againstadvicexzeta = R(1,2);
    stats.correlationp_againstadvicexzeta = P(1,2);
    COMPI_plot_regression(parameters(:,6),behaviour_COMPI(:,3));
    
    [R,P]=corrcoef(parameters(:,7),behaviour_COMPI(:,3));
    disp(['Correlation between decision noise and going against advice? Pvalue: ' num2str(P(1,2))]);
    stats.correlation_againstadvicexzeta2 = R(1,2);
    stats.correlationp_againstadvicexzeta2 = P(1,2);
    COMPI_plot_regression(parameters(:,7),behaviour_COMPI(:,3));
end

if options.model.modelling_bias == true
    save(fullfile(options.resultroot, [comparisonType, '_competing_model_parameter_behaviour_stats.mat']), ...
    'stats', '-mat');
else
    save(fullfile(options.resultroot, [comparisonType, '_parameter_behaviour_stats.mat']), ...
    'stats', '-mat');
end

end

