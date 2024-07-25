function plot_parameter_prior(mu, sigma, upperbound, space)
% -------------------------------------------------------------------------
% Function that overlays parameter prior over plot.
%
% IN:
%   mu          -> prior mean
%   sigma       -> prior variance
%   upperbound  -> uper bound for logit priors (otherwise NaN)
%   space       -> space of prior, either: 'log', 'logit',or 'nat'
% -------------------------------------------------------------------------


%% Determine x-values of interest and stepsize
xmax = 100;
dx   = .001;


%% Transformation functions
switch space
    case 'nat'
        trafo = @(x) x;
        invtrafo = @(x)  x;
        ddy_invtrafo = @(y) 1;
    case 'logit'
        trafo = @(x) tapas_sgm(x,upperbound);
        invtrafo = @(y) tapas_logit(y, upperbound);
        ddy_invtrafo = @(y) 1./(y.*(1-y));
    case 'log'
        trafo = @(x) exp(x);
        invtrafo = @(y) log(y);
        ddy_invtrafo = @(y) 1./y;
end


%% Compute PDFs before/after trafo
x = -xmax:dx:xmax;
y = trafo(x);

% remove boundary y's of 0,1 for logit:
switch space
    case 'nat'
        y = y(y>mu-30 & y < mu+30); 
    case 'logit'
        y = y(y>0 & y<upperbound);
    case 'log'
        y = y(y>0 & y < mu+100); % up to + infinity, but hard to see :-)
end
px = normpdf(x, mu, sqrt(sigma));

% using trafo of random variables: p_Y(y) = p_X(g^-1(y))*abs(( d/dy g^-1(y)))
py = normpdf(invtrafo(y), mu, sqrt(sigma)).*abs(ddy_invtrafo(y));


%% Add transformed variable to plot
hold on
ylimits = ylim;
py = py.*ylimits(2); % rescale for visualization purposes

plot(y,py, 'LineWidth', 2,'Color','red');

switch space
    case {'nat','log'}
        stringLegend = sprintf('\\mu  = %.2f\n\\mu_t = %.2f\n\\sigma^2 = %.2f', ...
            mu, trafo(mu),sigma);
    case 'logit'
        stringLegend = sprintf('\\mu  = %.2f\n\\mu_t = %.2f\n\\sigma^2 = %.2f\nb = %.1f', ...
            mu, trafo(mu),sigma, upperbound);
end

TextLocation(stringLegend,'Location','best');
% annotation('textbox',dim,'String',stringLegend,'FitBoxToText','on');
% legend({'Counts' stringLegend});
ylabel('Density','FontWeight','bold','FontSize',18);
hold off



