function [model_posterior,xp, protected_xp] = COMPI_behav_plot_model_selection(options,models)
% Runs and plots model selection results
% IN
%   options     general analysis options%
%               options = COMPI_options;

% OUT
% Model posterior probabilities & (Protected) exceedance probabilities

if options.model.modelling_bias == true
    nModels = 18;
else
    nModels = 9;
end
%% Model Selection
[~,model_posterior,xp,protected_xp,~]=spm_BMS(models);
H=model_posterior;
P = protected_xp;
N=numel(H);
colorsProb=jet(numel(H));
colorsExceedance = bone(numel(P));

% Plot results
figure;
for i=1:N
    h=bar(i,H(i));
    
    if i==1, hold on, end
    set(h,'FaceColor',colorsProb(i,:))
    
end
set(gca,'XTick',1:nModels)
set(gca,'XTickLabel',options.model.labels);
ylabel('p(r|y)');

figure;
for i=1:N
    
    j=bar(i,P(i));
    if i==1, hold on, end
    
    set(j,'FaceColor',colorsExceedance(i,:))
end
set(gca,'XTick',1:nModels)
set(gca,'XTickLabel',options.model.labels);
ylabel('Protected Exceedance Probabilities');
disp(['Best model: ', num2str(find(model_posterior==max(model_posterior)))]);

%% Family Inference
load(options.family.template);
perceptual_family=family_allmodels;
perceptual_family.alpha0=[];
perceptual_family.s_samp= [];
perceptual_family.exp_r=[];
perceptual_family.xp=[];
perceptual_family.names=options.family.perceptual.labels;
perceptual_family.partition = options.family.perceptual.partition;
[family_models1,~] = spm_compare_families(models,perceptual_family);

% Plot family-level inference results
figure;
H=family_models1.exp_r;
N=numel(H);
colors=jet(numel(H));
for i=1:N
    h=bar(i,H(i));
    if i==1, hold on, end
    set(h,'FaceColor',colors(i,:))
end
set(gca,'XTick',1:numel(perceptual_family.names))
set(gca,'XTickLabel',options.family.perceptual.labels);
ylabel('p(r|y)');

responsemodelfamily1=perceptual_family;
responsemodelfamily1=family_models1;
responsemodelfamily1.alpha0=[];
responsemodelfamily1.s_samp= [];
responsemodelfamily1.exp_r=[];
responsemodelfamily1.xp=[];
responsemodelfamily1.names=options.family.responsemodels1.labels;
responsemodelfamily1.partition = options.family.responsemodels1.partition;
[family_models2,~] = spm_compare_families(models,responsemodelfamily1);

figure;
H=family_models2.exp_r;
N=numel(H);
colors=jet(numel(H));
for i=1:N
    h=bar(i,H(i));
    if i==1, hold on, end
    set(h,'FaceColor',colors(i,:))
end
set(gca,'XTick',1:numel(options.family.responsemodels1.labels))
set(gca,'XTickLabel',options.family.responsemodels1.labels);
ylabel('p(r|y)');

if options.model.modelling_bias == true
    responsemodelfamily2=perceptual_family;
    responsemodelfamily2=family_models1;
    responsemodelfamily2.alpha0=[];
    responsemodelfamily2.s_samp= [];
    responsemodelfamily2.exp_r=[];
    responsemodelfamily2.xp=[];
    responsemodelfamily2.names=options.family.responsemodels2.labels;
    responsemodelfamily2.partition = options.family.responsemodels2.partition;
    [family_models3,~] = spm_compare_families(models,responsemodelfamily2);
    
    figure;
    H=family_models3.exp_r;
    N=numel(H);
    colors=jet(numel(H));
    for i=1:N
        h=bar(i,H(i));
        if i==1, hold on, end
        set(h,'FaceColor',colors(i,:))
    end
    set(gca,'XTick',1:numel(options.family.responsemodels2.labels))
    set(gca,'XTickLabel',options.family.responsemodels2.labels);
    ylabel('p(r|y)');
    
else
    return
end


return
end



