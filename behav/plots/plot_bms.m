function [fh] = plot_bms(VBA_out, model_names)


set(0,'DefaultAxesFontSize',12);

ep = VBA_out.pxp
ef = VBA_out.Ef
vf = VBA_out.Vf;
n_mod = length(ep);

fh = figure('name', 'Bayesian Model Comparison',...
    'Position',  [100, 100, 900, 400]);
% fh = figure('name', 'Bayesian Model Comparison',...
%     'Position',  [100, 100, 400, 400]);
hold on
subplot(1,2,1)
bar(ep, 'FaceColor', [.8 .8 .8]);
line([0,n_mod+1], [.95,.95], 'Color','red', 'LineStyle', ':');
xlabel('Models', 'FontSize', 16, 'FontWeight', 'bold', 'Color','k');
ylabel('Protected Exceedance Probability', 'FontSize', 16, 'FontWeight', 'bold', 'Color','k');
xticks(1:n_mod);
if ~isempty(model_names); xticklabels(model_names); end
ylim([0 1.05])
xlim([0 n_mod+1])
xtickangle(45)
box on;
hold off

subplot(1,2,2)
hold on
bar(ef, 'FaceColor', [.8 .8 .8]);
errorbar(1:n_mod,ef,sqrt(vf),'.k')
line([0, n_mod+1],[1, 1]/n_mod,'Color','red','LineStyle',':');
xlabel('Models', 'FontSize', 16, 'FontWeight', 'bold', 'Color','k');
ylabel('Expected Frequency', 'FontSize', 16, 'FontWeight', 'bold', 'Color','k');
xticks(1:n_mod);
if ~isempty(model_names); xticklabels(model_names); end
ylim([0 1.05])
xlim([0 n_mod+1])
xtickangle(45)
box on;
hold off

set(findall(gcf,'-property','FontSize'),'FontWeight','bold','FontSize',12)
