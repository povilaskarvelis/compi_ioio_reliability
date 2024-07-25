function plot_C (C, model_names, plot_title, visibility)
%--------------------------------------------------------------------------
% Function to plot a confunsion matrix.
%--------------------------------------------------------------------------


%% Defauls
if nargin < 4
    visibility = 'on';
end


%% Plot
fh = figure('Position',  [100, 100, 540, 500], 'Visible', visibility);
imagesc(C)
colormap(flipud(gray))
colorbar
caxis([0 1])
xticks(1:length(model_names))
yticks(1:length(model_names))
%if ~isempty(model_names); xticklabels(model_names); end
%if ~isempty(model_names); yticklabels(model_names); end
add_values_to_imagesc(C);  % Add values onto imagesc
set(findall(gcf,'-property','FontSize'),'FontWeight','bold','FontSize',20)
%title(plot_title,'FontWeight','bold','FontSize',20);

xlabel('Inferred model', 'Color','k','FontWeight','bold','FontSize',32)
ylabel('True model', 'Color','k','FontWeight','bold','FontSize',32)
