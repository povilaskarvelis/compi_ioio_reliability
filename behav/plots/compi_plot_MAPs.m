function COMPI_plot_MAPs(options)

% load data
[MAPs,~,txt] = xlsread(options.model.winningMAPs.interactions,'all_MAP_estimates_winning_model');

% Independent Variables
group      = txt(2:152,2);
condition  = txt(2:152,3);

% Dependent Variables: MAP Parameters
mu2_0      = tapas_sgm(MAPs(:,4),1);
mu3_0      = MAPs(:,5); % condition
ka         = MAPs(:,6); % condition
om2        = MAPs(:,7); % condition, interaction
om3        = MAPs(:,8);
zeta1      = MAPs(:,9); % condition, interaction
beta       = MAPs(:,10);

% Dependent Variables: Nonmodel-based variables
score           = MAPs(:,11);
accuracy        = MAPs(:,12);
helpful         = MAPs(:,13); % condition, interaction
misleading      = MAPs(:,14); % condition, interaction
choice_with     = MAPs(:,15);
choice_against  = MAPs(:,16);
choice_chance   = MAPs(:,17); % condition
stable_helpful  = MAPs(:,18); % condition, interaction
stable_helpful1 = MAPs(:,19); % condition
stable_helpful2 = MAPs(:,20); % condition, interaction
misleading_stab = MAPs(:,21); % condition
with_volatile   = MAPs(:,22);
advice_overall  = MAPs(:,23); % condition, interaction
against_volatile= MAPs(:,24);
switch_mislead  = MAPs(:,25); % condition
switch_helpful  = MAPs(:,26); 

against_advice_overall = ones(size(MAPs(:,15)))-advice_overall;

current_var = against_advice_overall;

[vs] = COMPI_violinplot(current_var,condition,group);







