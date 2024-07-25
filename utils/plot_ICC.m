function plot_ICC(x,y,xname,yname)

    % make sure the inputs are column vectors
    if size(x,2) > 1
        x = x';
    end
    
    if size(y,2) > 1
        y = y';
    end

    if nargin < 3
        xname = '';
        yname = '';
    end
      
    % robust regression
    [b, ~] = robustfit(x,y,'huber');

    % Pearson's correlation
    [r,p] = corr(x,y,'Type','Pearson','rows','complete');
    
    % Intraclass correlation coeff
    [icc, LB, UB, ~, ~, ~, ip] = ICC([x,y], 'A-1');
    
    c = get(gca,'colororder');
    
	% scatter 
    scatter(x,y,40,'MarkerEdgeColor','w', 'MarkerFaceColor', 'k',...
        'MarkerFaceAlpha',0.7); hold on;
     
    Xlim = get(gca, 'Xlim'); Ylim = get(gca, 'Ylim'); 

    % adjust axes limits by computing min max and range values
    p1 = min([x;y]);
    p2 = max([x;y]);
    ra = abs(p2 - p1);

    p1 = p1 - ra/10;
    p2 = p2 + ra/10;

    ylim([p1 p2]);
    xlim([p1 p2]);
    
	% robust regression line 
    plot([p1, p2],b(1)+b(2)*([p1 p2]),'color',c(1,:),'LineWidth',2);
	
	% perfect correlation line 
    plot([p1 p2], [p1 p2], 'k--', 'LineWidth', 1.5)
    
    set(gca,'FontSize',10, 'linewidth', 1);    
    xlabel(xname, 'Fontsize', 13); ylabel(yname, 'Fontsize', 13)
      
    % title(sprintf('r = %.2f; p = %.3f\n ICC = %.2f; p = %.3f', r, p,...
    %     icc, ip));

    title(sprintf('ICC = %.2f [%.2f %.2f]',icc, LB, UB),...
        'FontSize',13);

    
end