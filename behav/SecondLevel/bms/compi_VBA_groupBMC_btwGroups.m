function [res, fh, out, post] = compi_VBA_groupBMC_btwGroups(Ls, options)
% test for between-groups difference in model frequencies
% function [h,p] = VBA_groupBMC_btwGroups(Ls,options)
% IN:
%   - Ls: {nmXns_1, nmXns_2} array of log-model evidences matrices of each group (nm models; ns_g subjects in the group).
%   - options: a structure containing the following fields:
%       .DisplayWin: flag for display window
%       .verbose: flag for summary statistics display
%       .families: a cell array of size nf, which contains the indices of
%       the models that belong to each of the nf families.
% OUT:


if nargin < 2
    options = {};
end

%%
try
    gnames = options.subjects.group_labels;
catch
    gnames = {'G1', 'G2', 'G3'};
end
vba_options.DisplayWin = 0;


%% Compute evidence for all partitions
% --------------------------------------------------
% H0: All groups have the same winning model
% --------------------------------------------------
L = [Ls{1} Ls{2} Ls{3}];
[~,H0_out] = compi_VBA_groupBMC(L, vba_options);
%set(gcf, 'Name', 'BMC all Groups');
res.hypotheses{1} = [gnames{1} ' = ' gnames{2} ' = ' gnames{3}];
res.F(1) = H0_out.F(end);

% --------------------------------------------------
% H1: Groups 1 & 2 & 3 each have a different model
% --------------------------------------------------
[post{1}, H1_G1_out] = compi_VBA_groupBMC(Ls{1});
fh(1) = gcf;
set(fh(1),'Name',['BMC ' gnames{1}]);
[post{2},H1_G2_out] = compi_VBA_groupBMC(Ls{2});
fh(2) = gcf;
set(fh(2),'Name',['BMC ' gnames{2}]);
[post{3},H1_G3_out] = compi_VBA_groupBMC(Ls{3});
fh(3) = gcf;
set(fh(3),'Name',['BMC ' gnames{3}]);
res.hypotheses{2} = [gnames{1} ' \neq ' gnames{2} ' \neq ' gnames{3}];
res.F(2) = H1_G1_out.F(end) + H1_G2_out.F(end) + H1_G3_out.F(end);

out = {H1_G1_out, H1_G2_out, H1_G3_out};


% --------------------------------------------------
% H1: Groups 1 & 2 differ from group 3
% --------------------------------------------------
L = [Ls{1} Ls{2}];
[~,H1_G12_out] = compi_VBA_groupBMC(L, vba_options);
%set(gcf,'Name','BMC Groups 1 and 2');
res.hypotheses{3} = [gnames{1} ' = ' gnames{2} ' \neq ' gnames{3}];
res.F(3) = H1_G12_out.F(end) + H1_G3_out.F(end);

% --------------------------------------------------
% H1: Groups 1 & 3 differ from group 2
% --------------------------------------------------
L = [Ls{1} Ls{3}];
[~,H1_G13_out] = compi_VBA_groupBMC(L, vba_options);
%set(gcf,'Name','BMC Groups 1 and 3');
res.hypotheses{4} = [gnames{1} ' = ' gnames{3} ' \neq ' gnames{2}];
res.F(4) = H1_G13_out.F(end) + H1_G2_out.F(end);

% --------------------------------------------------
% H1: Groups 2 & 3 differ from group 1
% --------------------------------------------------
L = [Ls{2} Ls{3}];
[~,H1_G23_out] = compi_VBA_groupBMC(L, vba_options);
%set(gcf,'Name','BMC Groups 2 and 3');
res.hypotheses{5} = [gnames{1} ' \neq ' gnames{2} ' = ' gnames{3}];
res.F(5) = H1_G23_out.F(end) + H1_G1_out.F(end);


%% Compute posterior probabilities for each group partition
res.p = exp(res.F - VBA_logSumExp(res.F));
 

%% Plot
fh(4) = figure;
hold on
bar(res.p,'FaceColor',[.8 .8 .8]);
line([0 length(res.p)+.5], [.95 .95],...
    'Color','red','LineStyle','--');
hold off
xticks(1:length(res.p))
xticklabels(res.hypotheses)
xtickangle(45)
ylabel('p(m_i|y)')

set(findall(gcf,'-property','FontSize'),'FontWeight','bold','FontSize',12)
title('Between-group BMC','FontWeight','bold','FontSize',20)
end