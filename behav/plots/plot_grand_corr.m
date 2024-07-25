function [fh] = plot_grand_corr(grand_cor, param_names, save_path)
%--------------------------------------------------------------------------
% Function that plots grand correlation and saves figure in save_path.
%--------------------------------------------------------------------------


%% Plot Correlation
fh = figure('Visible', 'off');
imagesc(grand_cor)
colormap(flipud(gray))
colorbar
caxis([-1 1])
xticks(1:length(param_names))
yticks(1:length(param_names))
xticklabels(param_names)
yticklabels(param_names)
add_values_to_imagesc(grand_cor);  % Add values onto imagesc
set(findall(gcf,'-property','FontSize'),'FontWeight','bold','FontSize',12)
title('Hessian-based parameter correlations','FontWeight','bold','FontSize',16)

saveas(fh, fullfile(save_path,'grand_parameter_corr.png'));