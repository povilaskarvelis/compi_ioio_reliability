function fh = plotDMPADRegressors(design, sub)
% Plots DMPAD Regressors from HGF for design matrix
% 
% different options depending on design (and existing regressors, i.e.,
% field names) for plotting are used
%
% See also getDMPADRegressors


% compatibility for some different naming
if ~isfield(design, 'Precision3')
    design.Precision3 = 1./design.Sigma3;
end

if ~isfield(design, 'Precision2')
    design.Precision2 = 1./design.Sigma2;
end

%% Plot
fh = figure;

if isfield(design, 'SignedDelta2')
    % Plot Signed Delta2
    % Subplots
    subplot(7,1,1);
    plot(design.Precision3, 'm', 'LineWidth', 4);
    hold all;
    ylabel('\pi_3');
    plot(ones(153,1).*0,'k','LineWidth', 1,'LineStyle','-.');
    subplot(7,1,2);
    plot(design.SignedDelta2, 'r', 'LineWidth', 4);
    ylabel('\delta_2');
    hold on;
    plot(ones(153,1).*0,'k','LineWidth', 1,'LineStyle','-.');
    subplot(7,1,3);
    plot(design.Precision2, 'c', 'LineWidth', 4);
    ylabel('\pi_2');
    hold on;
    plot(ones(153,1).*0,'k','LineWidth', 1,'LineStyle','-.');
    subplot(7,1,4);
    plot(design.BeliefPrecision, 'Color', [0.5 0.5 0.5], 'LineWidth', 4);
    hold all;
    ylim([3.8 12])
    ylabel('\pi_b');
    plot(ones(153,1).*mean(design.BeliefPrecision,1),'k','LineWidth', 1,'LineStyle','-.');
    subplot(7,1,5);
    plot(design.CuePE, 'g', 'LineWidth', 4);
    ylabel('\delta_3');
    hold on;
    plot(ones(153,1).*0,'k','LineWidth', 1,'LineStyle','-.');
    subplot(7,1,6);
    plot(design.Delta1, 'b', 'LineWidth', 4);
    ylabel('\delta_1');
    hold on;
    plot(ones(153,1).*0.5,'k','LineWidth', 1,'LineStyle','-.');
    subplot(7,1,7);
    plot(design.CueTransformedPE, 'k', 'LineWidth', 4);
    ylabel('\delta_c');
    hold on;
    plot(ones(153,1).*0.5,'k','LineWidth', 1,'LineStyle','-.');
    xlabel('Trial number');
    subplot(7,1,1);
    hold on;
    title([sprintf('Subject ID = %d', sub)], ...
        'FontWeight', 'bold');
else % Plot Signed Delta 1
    figure;
    % Subplots
    subplot(6,1,1);
    plot(design.Precision3([1:153],:), 'm', 'LineWidth', 4);
    hold all;
    ylabel('\pi_3');
    plot(ones(153,1).*mean(design.Precision3,1),'k','LineWidth', 1,'LineStyle','-.');
    subplot(6,1,2);
    plot(design.Delta2([1:153],:), 'r', 'LineWidth', 4);
    ylabel('\delta_2');
    hold on;
    plot(ones(153,1).*0,'k','LineWidth', 1,'LineStyle','-.');
    subplot(6,1,3);
    plot(design.Precision2([1:153],:), 'c', 'LineWidth', 4);
    ylabel('\pi_2');
    hold on;
    plot(ones(153,1).*mean(design.Precision2,1),'k','LineWidth', 1,'LineStyle','-.');
    subplot(6,1,4);
    plot(design.OutcomePE([1:153],:), 'g', 'LineWidth', 4);
    ylabel('\delta_o');
    hold on;
    plot(ones(153,1).*0.5,'k','LineWidth', 1,'LineStyle','-.');
    subplot(6,1,5);
    plot(design.SignedDelta1([1:153],:), 'b', 'LineWidth', 4);
    ylabel('\delta_1');
    hold on;
    plot(ones(153,1).*0,'k','LineWidth', 1,'LineStyle','-.');
    subplot(6,1,6);
    plot(design.CuePE([1:153],:), 'y', 'LineWidth', 4);
    ylabel('\delta_c');
    hold on;
    plot(ones(153,1).*0.5,'k','LineWidth', 1,'LineStyle','-.');
    xlabel('Trial number');
    subplot(6,1,1);
    hold on;
    title([sprintf('Subject ID = %s', sub)], ...
        'FontWeight', 'bold');
end