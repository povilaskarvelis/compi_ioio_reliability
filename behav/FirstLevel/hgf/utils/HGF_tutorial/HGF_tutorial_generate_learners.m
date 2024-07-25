%--------------------------------------------------------------------------
% The purpose of this tutorial is to show you how you can understand 
% changes in parameters and simulate different artificial learners that 
% could correspond to different clinical phenotypes. Again, this tutorial
% consists of several parts:
%
% PART 1: Design your task (Repetition)
%   -> Generating a probability structure 
%   -> Generate corresponding experimental inputs
%
% PART 2: Simulating an ideal observer (Repetition)
%   -> Estimating Bayes-optimal parameters given the input structure 
%
% PART 3: Investigating parameter changes
%   -> Simulate under different parameters to understand how they impact
%   the ensuing belief trajectories
%
% PART 4: Simulating prototypical patients
%   -> Simulate two different learners and compare them
%
%--------------------------------------------------------------------------


%% Defaults
random_seed = 999; % Random seed for simulations
% Sets axis font size (this may depend on your screen size, you can
% increase it to 20, if the font is too small or decrease it).
set(0,'defaultAxesFontSize', 18); 


%% PART 1: Design your task
% Array that indicates the probability of the binary outcome = 1 for each
% experimental block
options = compi_ioio_options('ioio','hgf_comp','all');
lt = options.behav.last_trial;
vol_struct = options.task.vol_struct(1:lt);
details = compi_get_subject_details('0004',options);
files = details.files.behav{1};


%% Load data
example_data = compi_ioio_get_data(files, details, options);
u = example_data.input_u;


%% PART 2: Generate an ideal observer
% Now let's generate an ideal observer again. However, this time we will
% use a slightly more complex model in which we can also specify a drift 
% at the third level that formalizes the idea that participants may 
% experience the environment as increasingly volatile or increasingly 
% stable over time.

% Get Bayes optimal parameters given the input
bopars = tapas_fitModel([], u,...           % experimental input
    'MS9_dmpad_hgf_ar1_lvl3_config',...      % perceptual model function
    'tapas_bayes_optimal_binary_config',... % observational model function
    'tapas_quasinewton_optim_config');      % optimization function
% Simulate how this agent would respond to seeing this input.
sim = tapas_simModel(u,...
    'MS9_dmpad_hgf_ar1_lvl3', bopars.p_prc.p,...
    'MS9_dmpad_constant_voltemp_exp', [tapas_logit(0.5,1) log(48)],...
    random_seed);
sim.c_prc.n_levels = 3;
tapas_hgf_binary_plotTraj(sim)
hold on; plot(vol_struct, 'k:'); hold off; % Plot volatility structure 


%% PART 3: Investigate parameter changes
% To understand what the parameters do it is helpful to see how changes in
% the parameters affect the belief trajectories. 
% Choose a parameter to vary, possible options are:
% 'ka2'     -> Coupling between hierarchical levels (Phasic learning rate)
% 'om2'     -> Learning rate at second level (Tonic learning rate) 
% 'th'      -> Meta-volatility
% 'm3'      -> Equilibrium/Attractor point for drift at third level
% 'phi3'    -> Drift rate at third level

parameter = 'm3'; % Change the parameter you want to investigate
[parameter_idx, parameter_name, parameter_array] = get_hgf_parameter_index(parameter);

% Simulate trajectories for different parameter values, while keeping the
% other parameters fixed to the parameters of the ideal observer.
sims = cell(0);
for idx_sim = 1: length(parameter_array)
    sims{idx_sim} = tapas_simModel(u, ...
        'MS9_dmpad_hgf_ar1_lvl3',...
        [bopars.p_prc.p(1:parameter_idx-1) parameter_array(idx_sim) bopars.p_prc.p(parameter_idx+1:end)],...
        'MS9_dmpad_constant_voltemp_exp', [tapas_logit(0.5,1) log(48)],...
        random_seed);
    sims{idx_sim}.c_prc.n_levels = 3;
end

parameter_array = {'-2','-1',' 0',' 1',' 2',' 3'};
% And let's look at them
set(0,'DefaultAxesFontSize',18);
plot_multiple_hgf_traj(flip(sims), parameter_name, flip(parameter_array));
hold on;  h = plot(vol_struct, 'k:'); h.Annotation.LegendInformation.IconDisplayStyle = 'off'; hold off; % Plot volatility structure 

saveas(gcf,fullfile(options.roots.project,'figures','dissertation','simulations.png'));

% Feel free to try out different parameters to learn how they will affect
% the belief trajectories.


% %% PART 4: Simulate prototypical patients
% % Now, you can generate some prototypical patients by specifying which
% % parameter will be affected and by specifying a value for this parameter.
% % If you select a parameter value that is too high or too low the inversion
% % may not work. To be on the safe side, you can use parameters in the
% % range of PART 3 (you can also look at the ranges for all parameters in
% % the get_hgf_parameter_index() function. These are tested and should work.
% % Note, that the parameter range that is sensible may also vary with your
% % input structure.
% 
% % Let's give this simulation a name
% simulation_name = 'Early Psychosis';
% % What should we call our artifical agents?
% person1_name = 'Patient 1';
% person2_name = 'Patient 2';
% 
% % Simulate first person
% parameter = 'm3';       % You can also generate hypothesis using other parameters 
% parameter_value = -1;    % Or other parameter values
% parameter_idx = get_hgf_parameter_index(parameter);
% 
% person1 = tapas_simModel(u, ...
%         'kcni_hgf_ar1_lvl3' ,...
%         [bopars.p_prc.p(1:parameter_idx-1) parameter_value bopars.p_prc.p(parameter_idx+1:end)],...
%         'tapas_unitsq_sgm', 5,...
%         random_seed);
% 
% % Simulate second person
% parameter = 'm3';       % You can also generate hypothesis using other parameters 
% parameter_value = 3;   % Or other parameter values
% parameter_idx = get_hgf_parameter_index(parameter);
% 
% person2 = tapas_simModel(u, ...
%         'kcni_hgf_ar1_lvl3' ,...
%         [bopars.p_prc.p(1:parameter_idx-1) parameter_value bopars.p_prc.p(parameter_idx+1:end)],...
%         'tapas_unitsq_sgm', 5,...
%         random_seed);
% 
% % Plot the two artifical agents together 
% plot_multiple_hgf_traj({person1, person2}, simulation_name, {person1_name, person2_name});
% hold on;  h = plot(vol_struct, 'k:'); h.Annotation.LegendInformation.IconDisplayStyle = 'off'; hold off; % Plot volatility structure 
%  
% 
% 
