function [fh] = plot_model_attributions(VBA_post, model_names)


set(0,'DefaultAxesFontSize',12);

n_mod = length(VBA_post.a);

% fh = figure('name', 'Bayesian Model Comparison',...
%     'Position',  [100, 100, 900, 400]);
fh = figure('name', 'Model attributions',...
    'Position',  [100, 100, 400, 400]);
imagesc(VBA_post.r');
%xlabel('Models', 'FontSize', 16, 'FontWeight', 'bold', 'Color','k');
%ylabel('Subjects', 'FontSize', 16, 'FontWeight', 'bold', 'Color','k');
xticks(1:n_mod);
if ~isempty(model_names); xticklabels(model_names); end
%xtickangle(45)
colormap(flipud(gray))
colorbar('northoutside')
xlim([0 5]);


set(findall(gcf,'-property','FontSize'),'FontWeight','bold')
