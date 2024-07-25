% -------------------------------------------------------------------------
% Function that tests HGF implementation.
% -------------------------------------------------------------------------


%% Specify subject and model
options = compi_ioio_options;
subject = '0070';
model   = 3;


%% Remove other versions of the HGF
addpath(genpath(fullfile(options.roots.toolboxes, 'HGF_3.0')));
%rmpath(genpath(fullfile(options.coderoot, 'Toolboxes', 'BehavioralModeling')));


%% Get models
[prc_model, obs_model] = get_obs_and_prc_model(model,options);


%% Get subject specific paths
details = compi_get_subject_details(subject, options);


%% Get data
data = compi_ioio_get_data(details.files.behav{1}, details, options);


%% Invert
[est, perf] = train_hgf(data, prc_model, obs_model, 10);

%% Plot
tapas_hgf_binary_plotTraj(est);


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



