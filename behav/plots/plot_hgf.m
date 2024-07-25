function [fh_traj, fh_corr] = plot_hgf(est, perf, vol_struct, visibility)



%% Defaults
if nargin < 4
    visibility = 'on';    
elseif nargin < 3
    plot_vol = 0;
    visibility = 'on';  
else
    plot_vol = 1;
end


%% Plot trajectory
fh_traj = plot_hgf_binary_traj(est, perf, visibility);
if plot_vol; hold on; plot(vol_struct,'k:'); hold off; end

% Correlation plot
fh_corr = plot_corr(est, visibility);


