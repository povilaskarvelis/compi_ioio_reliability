%% Test-retest reliability (and EEG-fMRI reliability)
function compi_ioio_plot_validity(options,saved_full_behav_results)

probe_trials = [1 14, 49, 73, 99, 134];
design = load(options.task.design);
prob_struct = design(1:options.behav.last_trial,end);

% % plot task structure
% figure('WindowStyle','docked'); hold on
% patch([0 0 35 35], [0 1 1 0], [0.92,0.95,0.97])
% patch([35 35 options.behav.last_trial options.behav.last_trial],...
%     [0 1 1 0], [0.94,0.90,0.90])
% plot(prob_struct,'k-','LineWidth',2)
% xlim([0 options.behav.last_trial])
% xlabel('Trial'); ylabel('Advice helpfulness')
% xticks([0:20:153])


%% load behvioral and model data
Tb = readtable(fullfile(options.roots.results_behav,saved_full_behav_results));

load(fullfile(options.roots.results_hgf,'hgf_est'))

mnames = {'\mu_2^{(0)}','\mu_3^{(0)}','m_3','\kappa_2','\omega_2',...
    '\zeta','\nu'};

% loop over subjects
for i = 1:size(all_est,1)

    Tbs1 = Tb(Tb.subID==i & Tb.session==1,:);
    Tbs2 = Tb(Tb.subID==i & Tb.session==2,:); 
    
    probe(i,:,:) = [Tbs1.probe(probe_trials), ...
                Tbs2.probe(probe_trials)];
    
    mu2h_p(i,:,:) = [all_est{i,1}.traj.muhat(probe_trials,2),...
                 all_est{i,2}.traj.muhat(probe_trials,2)];

    mu2h_s(i,:,:) = [all_est{i,1}.traj.muhat(probe_trials,2),...
                 all_est{i,2}.traj.muhat(probe_trials,2)];

    mu2h_all(i,:,:) = [all_est{i,1}.traj.muhat(:,2),...
                 all_est{i,2}.traj.muhat(:,2)];

    % choices
    ch(i,:,:) = [all_est{i,1}.y, all_est{i,2}.y];
    ad(i,:,:) = [all_est{i,1}.u(:,1), all_est{i,2}.u(:,1)];


end

probe = probe(2:end,:,:); % remove subject 1 that has invalid responses

for j = 1:numel(probe_trials)
    gc = groupcounts(probe(:,j,1));
    P1(j,:) = gc/sum(gc);

    gc = groupcounts(probe(:,j,2));
    P2(j,:) = gc/sum(gc);
end

% rearrange this to be 1-helpful, 2-random, 3-misleading
P1 = P1(:,[1,3,2]);
P2 = P2(:,[1,3,2]);


figure('WindowStyle','docked')

subplot(2,1,1)
bar(probe_trials,P1,'stacked'); hold on
plot(prob_struct,'k--','LineWidth',2)
legend({'Helpful','Random','Misleading','Adviser''s fidelity'})  
title('Session 1')

subplot(2,1,2)
bar(probe_trials,P2,'stacked'); hold on
plot(prob_struct,'k--','LineWidth',2)
legend({'Helpful','Random','Misleading','Adviser''s fidelity'})  
title('Session 2')

figure('WindowStyle','docked')


subplot(2,1,1)
mur = mu2h_all(:,:,1)/8 +0.5; % rescale
plot(1:length(prob_struct), mur); hold on
plot(1:length(prob_struct), mean(mur),'c-', 'LineWidth',2);
plot(prob_struct,'k--','LineWidth',2);
scatter(1:length(prob_struct),ad(1,:,1),'.','r')
ylabel('$$\hat{\mu_2}$$','interpreter','latex')
title('Session 1'); ylim([-0.1 1.1])

subplot(2,1,2)
mur = mu2h_all(:,:,2)/8 +0.5; % rescale
plot(1:length(prob_struct), mur); hold on
plot(1:length(prob_struct), mean(mur),'c-', 'LineWidth',2);
plot(prob_struct,'k--','LineWidth',2);
scatter(1:length(prob_struct),ad(1,:,1),'.','r')
ylabel('$$\hat{\mu_2}$$','interpreter','latex')
title('Session 2'); ylim([-0.1 1.1])


% mu2h1 = reshape(mu2h_p(:,:,1),1,[]);
% mu2h2 = reshape(mu2h_p(:,:,2),1,[]);
% 
% prb1 = reshape(probe(:,:,1),1,[]);
% prb2 = reshape(probe(:,:,2),1,[]);


% within-individual model validity
figure('WindowStyle','docked')

for i = 1:size(probe,1)
    for j = 1:3
        mu2ha1(i,j) = mean(mu2h_p(i,probe(i,:,1)==j,1));
        mu2ha2(i,j) = mean(mu2h_p(i,probe(i,:,1)==j,2));
    end
end

% rearrange this to be 1-helpful, 2-random, 3-misleading
mu2ha1 = mu2ha1(:,[1,3,2]);
mu2ha2 = mu2ha2(:,[1,3,2]);

subplot(2,1,1)
dv = daviolinplot([{mu2ha1(:,1)},{mu2ha1(:,2)},{mu2ha1(:,3)}],...
        'legend',{'Helpful','Random','Misleading'},...
        'boxcolors','same','scatter',1,'jitter',1);
ylabel('$$\hat{\mu_2}$$','interpreter','latex')
title('Session 1'); xlim([0 4])
grid on

[~,p3] = ttest(mu2ha1(:,1)-mu2ha1(:,3));
%d3 = meanEffectSize(mu2ha1(:,1)-mu2ha1(:,2));
sigstar5({[1,3]},p3)


subplot(2,1,2)
dv = daviolinplot([{mu2ha2(:,1)},{mu2ha2(:,2)},{mu2ha2(:,3)}],...
        'boxcolors','same','scatter',1,'jitter',1);
ylabel('$$\hat{\mu_2}$$','interpreter','latex')
title('Session 2'); xlim([0 4])

[~,p3] = ttest(mu2ha2(:,1)-mu2ha2(:,3));
%d3 = meanEffectSize(mu2ha2(:,1)-mu2ha2(:,2));
sigstar5({[1,3]},p3)


% for k = 1:6
%     subplot(2,6,6+k);
%     if k==1
%         daboxplot(mu2h_p(:,k,1),'groups',probe(:,k,1),...
%         'legend',{'Helpful','Misleading','Random'},...
%         'whiskers',0,'boxalpha',0.9,...
%         'scatter',1);
%     else
%         daboxplot(mu2h_p(:,k,1),'groups',probe(:,k,1),...
%         'whiskers',0,'boxalpha',0.9,...
%         'scatter',1);
%     end
% 
%     ylabel('$$\hat{\mu_2}$$','interpreter','latex')
%     ylim([-2 2.1])
%     title(sprintf('Trial: %d',probe_trials(k)))
% end
% 
% figure('WindowStyle','docked')
% 
% title('Session 1')



end
