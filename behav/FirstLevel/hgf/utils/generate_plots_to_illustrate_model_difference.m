
%% Create Bayes optimal and random learner

% Set model
m_prc = 'MS9_dmpad_hgf_ar1_lvl3';
m_obs = 'MS9_dmpad_constant_voltemp_exp';

%compi_setup_paths();
options = compi_ioio_options('ioio','hgf_comp','all');
lt = options.behav.last_trial;
details = compi_get_subject_details('0126',options);
files = details.files.behav{1};


%% Load data
example_data = compi_ioio_get_data(files, details, options);


% Bayes optimal (subject code 1)
bopars = tapas_fitModel([], example_data.input_u(1:lt,:),...
        [m_prc '_config'],...
    'tapas_bayes_optimal_binary_config');

bopars.p_prc.p(12) = 4.5;

bopars.p_prc.p(9) = 0;

sim = tapas_simModel(example_data.input_u(1:lt,:),... 
    m_prc, bopars.p_prc.p,...
    m_obs, [tapas_logit(0.5,1) log(48)]);


% Plot trajectory
sim.c_prc.n_levels = 3;
sim.c_obs = struct();
plot_hgf_binary_traj(sim)
tapas_hgf_binary_plotTraj(bopars);
try
    MS10_dmpad_ehgf_plotTraj(bopars);
catch
    MS10_dmpad_ehgf_ar1_plotTraj(bopars);
end
hold on
plot(1:lt,options.task.vol_struct(1:lt))
movav = movmean(example_data.input_u(1:lt,1),17);
plot(1:lt,movav)
hold off



