% -------------------------------------------------------------------------
% Function that tests HGF implementation.
% -------------------------------------------------------------------------


%% Specify subject and model
options = compi_ioio_options('ioio','hgf_comp','all');
subject = '0116';
model   = 1;


%% Get models
[prc_model, obs_model] = get_obs_and_prc_model(model,options);


%% Get subject specific paths
details = compi_get_subject_details(subject, options);
files = details.files.behav{1};

%% Get data
data = compi_ioio_get_data(files, details, options);


%% Invert
[est, perf] = train_hgf(data, prc_model, obs_model, options.hgf.seeds(1));

%% Plot
plot_hgf_binary_traj(est, perf, 'on');
%MS10_dmpad_ehgf_ar1_plotTraj(est);
%dmpad_hgf_binary_plotTraj(est,perf);

% configfile = 'C:\Users\danie\Dropbox\HGFRT\code\configs\configs_COMPI.txt';
% configs = load( configfile);
% probs = configs(:,end);
% nt = size(data.y,1);
% 
% hold on
% plot(1:nt,probs(1:nt))
% movav = movmean(data.input_u(:,1),17);
% plot(1:nt,movav)



%nt = size(data.y,1);

%hold on
%plot(1:nt,probs(1:nt))
%movav = movmean(data.input_u(:,1),17);
%plot(1:nt,movav)




% ylim([.48 .52])
% xlimits = xlim;
% hold on
% line(xlimits,[.5 .5])
% xlim([80 140])

%ylim([-.1 1.1])
%sum(est.y(:,1)



