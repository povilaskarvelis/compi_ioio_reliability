%% Test-retest reliability (and EEG-fMRI reliability)
function compi_ioio_plot_test_retest(options,saved_behav_results,saved_hgf_results)

%% load behvioral data table
Tb = readtable(fullfile(options.roots.results_behav,saved_behav_results));

% bnames = {'Total score','Total AT','AT Acc','Stable AT','Volatile AT',...
%     'Helpful AT', 'Unhelpful AT', 'win-stay','lose-switch'};
% 
% bt1 = [Tb.CS_t1, Tb.AT_total_t1, Tb.AT_acc_t1, Tb.AT_stable_t1,...
%     Tb.AT_volatile_t1, Tb.AT_helpful_t1, Tb.AT_unhelpful_t1,...
%     Tb.win_stay_t1, Tb.lose_switch_t1];
% 
% bt2 = [Tb.CS_t2, Tb.AT_total_t2, Tb.AT_acc_t2, Tb.AT_stable_t2,...
%     Tb.AT_volatile_t2, Tb.AT_helpful_t2, Tb.AT_unhelpful_t2,...
%     Tb.win_stay_t2, Tb.lose_switch_t2];

bnames = {'Total Acc','Total AT','Stable AT','Volatile AT',...
    'win-stay','lose-switch'};

bt1 = [Tb.AT_acc_t1, Tb.AT_total_t1, Tb.AT_stable_t1,...
    Tb.AT_volatile_t1, Tb.win_stay_t1, Tb.lose_switch_t1];

bt2 = [Tb.AT_acc_t2, Tb.AT_total_t2, Tb.AT_stable_t2,...
    Tb.AT_volatile_t2, Tb.win_stay_t2, Tb.lose_switch_t2];

% difference between the sessions
btd = bt2-bt1;

% calculate better than chance performance
threshold = above_chance_perf(options.behav.last_trial,0.20);

% participants to include
inc = Tb.AT_acc_t1 > threshold & Tb.AT_acc_t2 > threshold;

%% reliability and practice effects on model params
Tm = readtable(fullfile(options.roots.results_hgf, saved_hgf_results));

%Tm = Tm(inc,:); % include only participants that perform above chance

mnames = {'\mu_2^{(0)}','\mu_3^{(0)}','m_3','\kappa_2','\omega_2',...
    '\zeta','\nu'};

mt1 = [Tm.mu0_2_t1, Tm.mu0_3_t1, Tm.m_3_t1, Tm.ka_2_t1, Tm.om_2_t1,...
    Tm.ze_t1, Tm.nu_t1];

mt2 = [Tm.mu0_2_t2, Tm.mu0_3_t2, Tm.m_3_t2, Tm.ka_2_t2, Tm.om_2_t2,...
    Tm.ze_t2, Tm.nu_t2];

% difference between the sessions
mtd = mt2 - mt1;

% color scheme for some plots
c =  [0.45, 0.80, 0.69;...
      0.98, 0.40, 0.35;...
      0.55, 0.60, 0.79;...
      0.90, 0.70, 0.30]; 
  
  
% figure('WindowStyle','docked')
% for i = 1:numel(bnames)    
%     subplot(2,3,i)
%     plot_ICC(bt1(:,i),bt2(:,i),[bnames{i} ' T_1'],[bnames{i} ' T_2'])
% end
% suptitle('t1 vs t2')

figure('WindowStyle','docked')
for i = 1:numel(bnames)
   
    subplot(2,3,i)
    h = daboxplot({[bt1(:,i),bt2(:,i)]},'xtlabels',{'T1','T2'},...
        'whiskers',0,'boxalpha',0.7,'scatter',2, 'colors', [0.5 0.5 0.5],...
        'outfactor',3); 
    [~,p] = ttest(bt1(:,i) - bt2(:,i));
    bf10  = BFttest(bt1(:,i) - bt2(:,i));    
    title(sprintf('p = %.3f; BF_{01} = %.1f',p,1/bf10));
    ylabel(bnames(i));
end

%d = cohensd(mt2(:,6),mt1(:,6),'paired-sample');

% figure('WindowStyle','docked')
% 
% for i = 1:numel(mnames)    
%     subplot(3,3,i)
%     plot_ICC(mt1(:,i),mt2(:,i),[mnames{i} ' T_1'],[mnames{i} ' T_2'])
% 
%     M = [mt1(:,i),mt2(:,i)];
% 
%     [n, k] = size(M);
%     SStotal = var(M(:)) *(n*k - 1);
%     MSR = var(mean(M, 2)) * k;
%     MSW = sum(var(M,0, 2)) / n;
%     MSC = var(mean(M, 1)) * n;
%     MSE = (SStotal - MSR *(n - 1) - MSC * (k -1))/ ((n - 1) * (k - 1));
% 
%     % sompute standard deviations 
% 
%     % se = sqrt(MSE)
%     % sb = sqrt((MSR-MSE)/k)
%     % sw = sqrt(k*(MSW-MSE))
% 
% end
% 
% suptitle('t1 vs t2')

figure('WindowStyle','docked')
for i = 1:numel(mnames)
   
    subplot(3,3,i)
    h = daboxplot({[mt1(:,i),mt2(:,i)]},'xtlabels',{'T1','T2'},...
        'whiskers',0,'boxalpha',0.7,'scatter',2,'colors', [1 0.6 0],'outfactor',3); 
    [~,p] = ttest(mt1(:,i) - mt2(:,i));
    bf10  = BFttest(mt1(:,i) - mt2(:,i));   
    title(sprintf('p = %.3f; BF_{01} = %.1f',p,1/bf10));
    ylabel(mnames(i));
end


% eeg vs fMRI
m_eeg  = [mt1(logical(Tm.eeg_1st),:); mt2(logical(1-Tm.eeg_1st),:)];
m_fmri = [mt2(logical(Tm.eeg_1st),:); mt1(logical(1-Tm.eeg_1st),:); ];

% figure('WindowStyle','docked')
% 
% for i = 1:numel(mnames)
%     subplot(3,3,i)
%     plot_ICC(m_eeg(:,i),m_fmri(:,i),...
%         [mnames{i} ' eeg'],[mnames{i} ' fmri'])
% end
% suptitle('eeg vs fmri')


figure('WindowStyle','docked')
for i = 1:numel(mnames)
   
    subplot(3,3,i)
    h = daboxplot({[m_eeg(:,i),m_fmri(:,i)]},...
        'xtlabels',{'EEG','fMRI'},'whiskers',0,'boxalpha',0.7,...
        'scatter',2, 'colors', [1 0.6 0], 'outfactor',3); 
    [~,p] = ttest(m_eeg(:,i) - m_fmri(:,i));
    bf10  = BFttest(m_eeg(:,i) - m_fmri(:,i));   
    title(sprintf('p = %.3f; BF_{01} = %.1f',p,1/bf10));
    ylabel(mnames(i));
end

% % internal longitudinal 'validity'
% figure('WindowStyle','docked')
% 
% for i = 1:6    
%     switch i
%         case 1
%             x = mtd(:,1); y = btd(:,2); 
%             xl = '\Delta \mu_2^{(0)}'; yl = '\Delta Total AT';
%         case 2
%             x = mtd(:,1); y = btd(:,3); 
%             xl = '\Delta \mu_2^{(0)}'; yl = '\Delta Stable AT';
%         case 3
%             x = mtd(:,1); y = btd(:,5); 
%             xl = '\Delta \mu_2^{(0)}'; yl = '\Delta Win-stay';
% 
%         case 4
%             x = mtd(:,6); y = btd(:,2); 
%             xl = '\Delta \zeta'; yl = '\Delta Total AT';
%         case 5
%             x = mtd(:,6); y = btd(:,3); 
%             xl = '\Delta \zeta'; yl = '\Delta Stable AT';
%         case 6
%             x = mtd(:,6); y = btd(:,5); 
%             xl = '\Delta \zeta'; yl = '\Delta Win-stay';
%     end            
% 
% subplot(2,3,i)
% plot_IRLS(x,y,xl,yl)
% end
% 
% % cross-sectional 'validity'
% figure('WindowStyle','docked')
% 
% for i = 1:6    
%     switch i
%         case 1
%             x = mt1(:,1); y = bt1(:,2); 
%             xl = '\mu_2^{(0)}'; yl = 'Total AT';
%         case 2
%             x = mt1(:,1); y = bt1(:,3); 
%             xl = '\mu_2^{(0)}'; yl = 'Stable AT';
%         case 3
%             x = mt1(:,1); y = bt1(:,5); 
%             xl = '\mu_2^{(0)}'; yl = 'Win-stay';
% 
%         case 4
%             x = mt1(:,6); y = bt1(:,2); 
%             xl = '\zeta'; yl = 'Total AT';
%         case 5
%             x = mt1(:,6); y = bt1(:,3); 
%             xl = '\zeta'; yl = 'Stable AT';
%         case 6
%             x = mt1(:,6); y = bt1(:,5); 
%             xl = '\zeta'; yl = 'Win-stay';
%     end            
% 
% subplot(2,3,i)
% plot_IRLS(x,y,xl,yl)
% 
% end



% multiple regression
% for i = 1:numel(pnames)
%     fprintf('\n\n %s \n',pnames{i});
%     [b,bint,~,~,stats] = regress(xt1(:,i),[ones(size(xt2,1),1),xt2(:,i), 1-T.eeg_1st]);
% end


end
