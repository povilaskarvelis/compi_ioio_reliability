function plot_IRLS(x,y,xname,yname)

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

    % rank correlation
    %[R,P] = corr(x,y,'Type','Kendall','rows','complete');
    
    % robust regression
    [b, ~] = robustfit(x,y,'huber');
%     [be, ~] = robustfit(y,x,'huber');
%     r = sign(b(2))*sqrt(abs(b(2))*abs(be(2))); % approximation of r   

    % Pearson correlation
    [r,p] = corr(x,y,'Type','Pearson','rows','complete');
    
    c = get(gca,'colororder');
    
    % scatter(x,y,30,'MarkerEdgeColor','k', 'MarkerFaceColor', 'k'); hold on;
    
    scatter(x,y,40,'MarkerEdgeColor','w', 'MarkerFaceColor', 'k',...
        'MarkerFaceAlpha',0.7); hold on;
    
    plot(x,b(1)+b(2)*x,'color',c(1,:),'LineWidth',3); 
    
    xlabel(xname, 'Fontsize', 14); ylabel(yname, 'Fontsize', 13)
    % title(sprintf(\\tau_b = %.3f; p = %.3f', R, P)); %Kendall's tau
    title(sprintf('r = %.2f; p = %.3f', r, p));
    
    set(gca, 'linewidth', 1);
end