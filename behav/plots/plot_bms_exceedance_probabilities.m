function[fh] = plot_bms_exceedance_probabilities(VBA_out, model_names)


set(0,'DefaultAxesFontSize',12);

ep = VBA_out.pxp;
n_mod = length(ep);

fh = figure('name', 'Bayesian Model Comparison',...
    'Position',  [100, 100, 400, 400]);
hold on
bar(ep, 'FaceColor', [.8 .8 .8]);
line([0,n_mod+1], [.95,.95], 'Color','red', 'LineStyle', ':');
%xlabel('Models', 'FontSize', 16, 'FontWeight', 'bold', 'Color','k');
%ylabel('Protected Exceedance Probability', 'FontSize', 16, 'FontWeight', 'bold', 'Color','k');
xticks(1:n_mod);
if ~isempty(model_names); xticklabels(model_names); end
ylim([0 1.05])
xlim([0 n_mod+1])
%xtickangle(45)
box on;
hold off

set(findall(gcf,'-property','FontSize'),'FontWeight','bold','FontSize',12)