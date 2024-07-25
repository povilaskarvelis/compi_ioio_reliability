function fh = plot_hgf_binary_traj(est, perf, visibility)
% Plots the estimated or generated trajectories for the binary HGF perceptual model
% Usage example:  est = tapas_fitModel(responses, inputs); tapas_hgf_binary_plotTraj(est);
%
% --------------------------------------------------------------------------------------------------
% Copyright (C) 2012-2013 Christoph Mathys, TNU, UZH & ETHZ
%
% This file is part of the HGF toolbox, which is released under the terms of the GNU General Public
% Licence (GPL), version 3. You can redistribute it and/or modify it under the terms of the GPL
% (either version 3 or, at your option, any later version). For further details, see the file
% COPYING or <http://www.gnu.org/licenses/>.

%% Defaults
if nargin < 2
    plot_pred_resp = 0;
    visibility = 'on';
elseif nargin <3
     plot_pred_resp = 1;
    visibility = 'on';
else
     plot_pred_resp = 1;
end


%% Options
plotsd = true; % Optional plotting of standard deviations (true or false)
ploty = true; % Optional plotting of responses (true or false)



%% Set up display
scrsz = get(0,'screenSize');
outerpos = [0.2*scrsz(3),0.2*scrsz(4),0.8*scrsz(3),0.8*scrsz(4)];
fh = figure(...
    'OuterPosition', outerpos,...
    'Name', 'HGF trajectories','Visible', visibility);

% Time axis
t = ones(1,size(est.u,1));
ts = cumsum(t);
ts = [0, ts];

% Number of levels
try
    l = est.c_prc.n_levels;
catch
    l = (length(est.p_prc.p)+1)/5;
end

% Upper levels
for j = 1:l-1

    % Subplots
    subplot(l,1,j);

    if plotsd == true
        upperprior = est.p_prc.mu_0(l-j+1) + sqrt(est.p_prc.sa_0(l-j+1));
        lowerprior = est.p_prc.mu_0(l-j+1) - sqrt(est.p_prc.sa_0(l-j+1));
        upper = [upperprior; est.traj.mu(:,l-j+1)+ sqrt(est.traj.sa(:,l-j+1))];
        lower = [lowerprior; est.traj.mu(:,l-j+1)- sqrt(est.traj.sa(:,l-j+1))];
    
        plot(0, upperprior, 'ob', 'LineWidth', 1);
        hold all;
        plot(0, lowerprior, 'ob', 'LineWidth', 1);
        fill([ts, fliplr(ts)], [(upper)', fliplr((lower)')], ...
             'b', 'EdgeAlpha', 0, 'FaceAlpha', 0.15);
    end
    plot(ts, [est.p_prc.mu_0(l-j+1); est.traj.mu(:,l-j+1)], 'b', 'LineWidth', 2);
    hold all;
    plot(0, est.p_prc.mu_0(l-j+1), 'ob', 'LineWidth', 2); % prior
    xlim([0 ts(end)]);
    title(['Posterior expectation of x_' num2str(l-j+1)], 'FontWeight', 'bold');
    ylabel(['\mu_', num2str(l-j+1)]);
end

% Input level
subplot(l,1,l);

plot(ts, [tapas_sgm(est.p_prc.mu_0(2), 1); tapas_sgm(est.traj.mu(:,2), 1)], 'r', 'LineWidth', 2);
hold all;
plot(0, tapas_sgm(est.p_prc.mu_0(2), 1), 'or','LineWidth', 2); % prior

input = est.u(:,1); % inputs
input(input == 1) = .92;
input(input == 0) = .08;
plot(ts(2:end), input, '.','Markersize', 8, 'Color', [0 0.6 0]);
if (ploty == true) && ~isempty(find(strcmp(fieldnames(est),'y'))) && ~isempty(est.y)
    if ~isempty(find(strcmp(fieldnames(est),'irr')))
        y(est.irr) = NaN; % weed out irregular responses
        plot(ts(est.irr),  ones([1 length(est.irr)]),... % irregular responses
            'x', 'Color', [1 0.7 0], 'Markersize', 11, 'LineWidth', 2); 
        plot(ts(est.irr), zeros([1 length(est.irr)]),... % irregular responses
            'x', 'Color', [1 0.7 0], 'Markersize', 11, 'LineWidth', 2); 
    end
    plot(ts(2:end), est.y(:,1), '.', 'Markersize', 8, 'Color',  [1 0.7 0]); % responses 
    ylabel('y, u, s(\mu_2)');
    axis([0 ts(end) -0.15 1.15]);
else
    ylabel('u, s(\mu_2)');
    axis([0 ts(end) -0.1 1.1]);
end
plot(ts(2:end), 0.5, 'k');
line([0 ts(end)],[.5 .5],'Color','k','LineStyle','--'); % reference line
xlabel('Trial number');


%% Format title
if ~any(strcmp(fieldnames(est.c_obs),'logze2mu'))
    est.p_obs.ze2 = NaN;
end

if any(strcmp(fieldnames(est.c_prc),'logitthmu'))
    % Check for AR1 model (HGF version 3)
    if any(strcmp(fieldnames(est.c_prc),'logitphimu')) 
    text = ['Resp. (orange dot), pred. resp. (orange ast.), input (green), and post. expect. s(\\mu_2) (red) \n',...
        'for \\mu_0=%.2f %.2f | \\sigma_0=%.2f %.2f | '...
        'm=%.2f %.2f | \\phi=%.2f %.2f | '...
        '\\kappa=%.2f | ',...
        '\\theta=%.2f | ',...
        '\\omega=%.2f | \\zeta=%.2f %.2f'];
    title(sprintf(text,...
        est.p_prc.mu_0(2), est.p_prc.mu_0(3),...
        est.p_prc.sa_0(2), est.p_prc.sa_0(3),...
        est.p_prc.m(2), est.p_prc.m(3),...
        est.p_prc.phi(2),est.p_prc.phi(3),...
        est.p_prc.ka(2),...
        est.p_prc.th,...
        est.p_prc.om(2),...
        est.p_obs.ze1, est.p_obs.ze2),...
        'FontWeight', 'bold');
    
    % Check for regular HGF version 3
    else
    text = ['Resp. y (orange dot), pred. resp. (orange ast.), input u (green), and post. expectation s(\\mu_2) (red) \n',...
        'for \\mu_0=%.2f %.2f | \\sigma_0=%.2f %.2f | \\rho=%.2f %.2f | '...
        '\\kappa=%.2f | ',...
        '\\theta=%.2f | ',...
        '\\omega=%.2f | \\zeta=%.2f %.2f'];
    title(sprintf(text,...
        est.p_prc.mu_0(2), est.p_prc.mu_0(3),...
        est.p_prc.sa_0(2), est.p_prc.sa_0(3),...
        est.p_prc.rho(2),est.p_prc.rho(3),...
        est.p_prc.ka(2),...
        est.p_prc.th,...
        est.p_prc.om(2),...
        est.p_obs.ze1, est.p_obs.ze2),...
        'FontWeight', 'bold');
    end
% Assume its HGF version 5 or 6 (theta => omega 3)
else
    % Check for drift here
    if any(strcmp(fieldnames(est.c_prc),'logitphimu'))
        text = ['Resp. (orange dot), pred. resp. (orange ast.), input (green), and post. expect. s(\\mu_2) (red) \n',...
            'for \\mu_0=%.2f %.2f | \\sigma_0=%.2f %.2f | '...
            'm=%.2f %.2f | \\phi=%.2f %.2f | '...
            '\\kappa=%.2f | ',...
            '\\omega=%.2f %.2f | \\zeta=%.2f %.2f'];
        title(sprintf(text,...
            est.p_prc.mu_0(2), est.p_prc.mu_0(3),...
            est.p_prc.sa_0(2), est.p_prc.sa_0(3),...
            est.p_prc.m(2), est.p_prc.m(3),...
            est.p_prc.phi(2), est.p_prc.phi(3),...
            est.p_prc.ka(2),...
            est.p_prc.om(2), est.p_prc.om(3),...
            est.p_obs.ze1, est.p_obs.ze2),...
            'FontWeight', 'bold');
    % else it must be vanilla version
    else
        text = ['Resp. y (orange dot), pred. resp. (orange ast.), input u (green), and post. expectation s(\\mu_2) (red) \n',...
            'for \\mu_0=%.2f %.2f | \\sigma_0=%.2f %.2f | \\rho=%.2f %.2f | '...
            '\\kappa=%.2f | ',...
            '\\omega=%.2f %.2f | \\zeta=%.2f %.2f'];
        title(sprintf(text,...
            est.p_prc.mu_0(2), est.p_prc.mu_0(3),...
            est.p_prc.sa_0(2), est.p_prc.sa_0(3),...
            est.p_prc.rho(2),est.p_prc.rho(3),...
            est.p_prc.ka(2),...
            est.p_prc.om(2),est.p_prc.om(3),...
            est.p_obs.ze1, est.p_obs.ze2),...
            'FontWeight', 'bold');
    end
end


%% Build volatility structure
% vol = [0.70,0.80,0.50,0.30,0.20,0.30,0.50,0.70,0.8,0.8];
% nTrials = 21;
% all_trials = 210;
% vol_struct = repmat(vol(1),nTrials,1);
% for i = 2:length(vol)
%     vol_struct = [vol_struct; repmat(vol(i),nTrials,1)];
% end
% plot(ts(2:end),vol_struct,'k--')
% line([ts(1) ts(end)],[.5 .5],'Color','red');


%% Plot predicted responses
if plot_pred_resp   
    irr = isnan(perf.prob); % mark trials with NaN in probability as irregular
    pred_ch = perf.pred_ch;
    ts = ts(2:end);
    pred_ch(perf.pred_ch == 1) = 1.08;
    pred_ch(perf.pred_ch == 0) = -.08;
    plot(ts(~irr), pred_ch(~irr)', '*', 'Color', [1 0.7 0], 'Markersize', 4, 'LineWidth', .5);  
    plot(ts(irr), pred_ch(irr)', 'x', 'Color', [1 0.7 0], 'Markersize', 6, 'LineWidth', .5);  
    %plot(ts(2:end), perf.prob','k');
end

