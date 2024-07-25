function [options] = compi_ioio_task_options(options)


options.task.design = fullfile(options.roots.config,'COMPI.txt');
design = load(options.task.design);

tpb = 17;
%prob = prob;

options.task.cueCodes = 9:14;
options.task.cueProbs = 0.75:-0.10:0.25;

prob = [design(1,end),...
    design(1+tpb,end),...
    design(1+2*tpb,end),...
    design(1+3*tpb,end),...
    design(1+4*tpb,end),...
    design(1+5*tpb,end),...
    design(1+6*tpb,end),...
    design(1+7*tpb,end),...
    design(1+8*tpb,end),...
    design(1+9*tpb,end)];
options.task.TrialbyTrialprob       = ...
    [ones(tpb,1).*prob(1);ones(tpb,1).*prob(2);...
    ones(tpb,1).*prob(3);ones(tpb,1).*prob(4);...
    ones(tpb,1).*prob(5);ones(tpb,1).*prob(6);...
    ones(tpb,1).*prob(7);ones(tpb,1).*prob(8);...
    ones(tpb,1).*prob(9);ones(tpb,1).*prob(10)];

% options.task.helpful1 = zeros(size(design,1),1);
% options.task.helpful1(1:2*tpb,1) = 1; % first 2 blocks are helpful
% options.task.stable   = zeros(size(design,1),1);
% options.task.stable(1:2*tpb,1) = 1;
% options.task.stable(1+8*tpb:end,1) = 1;
% options.task.volatile   = zeros(size(design,1),1);
% options.task.volatile(1+2*tpb:8*tpb,1) = 1;
% options.task.helpful2 = zeros(size(design,1),1);
% options.task.helpful2(1+8*tpb:end,1) = 1;


% helpful advice during phase I
options.task.helpful1 = zeros(size(design,1),1);
options.task.helpful1(1:2*tpb,1) = 1; 

% helpful advice during phases II ('volatile') and III ('stable')
options.task.helpful2 = zeros(size(design,1),1);
options.task.helpful2([1+4*tpb:5*tpb,1+6*tpb:7*tpb,1+8*tpb:10*tpb],1) = 1; 

% stable: the first two blocks and the last block
options.task.stable = zeros(size(design,1),1);
options.task.stable([1:2*tpb,1+9*tpb:10*tpb],1) = 1;

% volatile: 3-9 blocks
options.task.volatile = zeros(size(design,1),1);
options.task.volatile(1+2*tpb:9*tpb,1) = 1;

options.task.TrialsperBlock = tpb;

configs = load(fullfile(options.roots.config,'COMPI.txt'));
options.task.vol_struct = configs(:,end);

