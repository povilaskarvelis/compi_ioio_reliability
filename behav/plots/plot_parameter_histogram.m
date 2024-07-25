function plot_parameter_histogram(params, param_overview, save_path)
% -------------------------------------------------------------------------
% Function that plots paramater histograms.
%
% IN:
%   params          -> matrix with subjects by parameter dimensions
%   param_overview  -> Table
%       param_overview.space: cell array with space in which parameters are 
%                             specified, either 'log', 'logit', or 'nat'
%       param_overview.names: cell array with parameter names
%   save_path   -   > path to location, where figure should be saved
% -------------------------------------------------------------------------


%% Plot parameter histograms
prior = param_overview.prior_summary;
space = param_overview.space;
names = param_overview.names;

for i = 1:size(params,2)
    
    fh = figure('Visible', 'off');
    yyaxis left
    histogram(params(:,i))
    title(names{i},...
        'FontWeight','bold','FontSize',20);
    xlabel(names{i},'FontWeight','bold','FontSize',18);
    ylabel('Counts','FontWeight','bold','FontSize',18);
    ylimits = ylim;
    ylim([ylimits(1) ylimits(2)+1]);
    
    % Use unit sigmoid function, if upper bound is not specified
    switch space{i}
        case 'logit'
            if isnan(prior{i}(3))
                prior{i}(3) = 1; 
            end
    end
    
    yyaxis right
    plot_parameter_prior(prior{i}(1),prior{i}(2),prior{i}(3),space{i})
    ylabel('Prior Density','FontWeight','bold','FontSize',18);
    
    yyaxis left
    switch space {i}
        case 'logit'
            xlim([0 prior{i}(3)]);
        case 'log'
            xlim([0 max(params(:,i))+3*std(params(:,i))]);
        otherwise
            xlim([min(params(:,i))-3*std(params(:,i)) max(params(:,i))+3*std(params(:,i))]);
    end
    
    saveas(fh,...
        fullfile(save_path,...
        ['hist_' names{i} '.png']));
end