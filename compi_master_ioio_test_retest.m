function compi_master_ioio_test_retest
% -------------------------------------------------------------------------
% The master script for reproducing results in Karvelis et al. (2024) 
% "Test-retest reliability of behavioral and computational measures of 
% advice taking under volatility"
%
% Important: You need to have access to the raw data. The path should be 
% specified in compi_ioio_options()
% -------------------------------------------------------------------------


%% Set paths and analysis options

% initialize paths
COMPI_setup_paths;

% set options 
options = compi_ioio_options('ioio','test_retest','hc');

% options to match the number of trials in Hauke et al. 2024
%options = compi_ioio_options('ioio','test_retest_136','hc'); 

%% First-level analysis

% Analyze behavior
loop_analyze_behaviour_local(options);

% Fit HGF
loop_fit_hgf_local(options);

%% Perform Bayesian model selection
compi_hgf_bms(options);

% arrange individual behavioral measures and param estimates into tables
compi_write_behav_summary_table_learning_effects(options);
compi_write_hgf_summary_table_learning_effects(options,3); % model 2
compi_write_hgf_summary_table_learning_effects(options,1); % model 1

% additional models for the supplementary analysis
% compi_write_hgf_summary_table_learning_effects(options,5); % model hgfmr_1
% compi_write_hgf_summary_table_learning_effects(options,6); % model hgfmr_2
% compi_write_hgf_summary_table_learning_effects(options,7); % model hgfmr_3
% compi_write_hgf_summary_table_learning_effects(options,8); % model hgfmr_4


%% Plot test-retest results and practice effects
compi_ioio_plot_test_retest(options,'sum_behav_measures.xlsx',...
    'sum_hgf_params.xlsx')

%% Plot validity results 
compi_ioio_plot_validity(options,'full_behav_measures.xlsx')

%% Run HGF simulations and parameter recovery

% set the options for using only session 1 data
options = compi_ioio_options('ioio','hgf_comp','hc');
loop_fit_hgf_local(options);
compi_run_hgf_simulations(options)

% run some diagnostics (parameter distributions, collinearity, etc).
%compi_run_hgf_diagnostics(options)

end