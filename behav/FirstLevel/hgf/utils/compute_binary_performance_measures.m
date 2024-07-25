function [bac, acc, auc, perf] = compute_binary_performance_measures(class, pred_class, prob)
% -------------------------------------------------------------------------
% Function that computes a range of binary performance measures.
%
% IN:
%  class       =>  Numeric vector containing true class labels encoded in 0
%                  and 1 (for example choices in social learning task).
%  pred_class  =>  Numeric vector containing predicted class labels.
%  prob        =>  Numeric vector containing probabilities for class 1
%                  (positive class).
%
% OUT:
%  bac         =>  Balanced accuracy
%  acc         =>  Accuracy
%  auc         =>  Area under the receiver-operator curve
%  perf        =>  Structure with additional performance measures, like
%                  true positive predictions, etc. 
% -------------------------------------------------------------------------



%% Check for NaNs in probabilities
if sum(isnan(prob)) > 0
    message = sprintf(['Encountered NaN''s in predicted choice probabilities.\n',...
        'Model inversion may have gone wrong!']);
    warning(message)
end


%% Drop NaNs
irreg = isnan(class);
class(irreg) = [];
pred_class(irreg) = [];
prob(irreg) = [];


%% Compute performance
perf.tp  = sum((class == 1) & (pred_class == 1));
perf.tn  = sum((class == 0) & (pred_class == 0));
perf.fn  = sum((class == 1) & (pred_class == 0));
perf.fp  = sum((class == 0) & (pred_class == 1));
perf.acc = sum(class == pred_class)/length(class);
perf.bac = 0.5 * (perf.tp/(perf.tp+perf.fn)+perf.tn/(perf.tn+perf.fp));
perf.C   = [perf.tp perf.fp;
    perf.fn perf.tn];

try
    % AUC & optimal threshold
    [x,y,thresholds,perf.auc,optrocpt] = perfcurve(class,prob,1);
    perf.opt.th = thresholds((x == optrocpt(1)) & (y == optrocpt(2)));
    
    %
    perf.opt.pred_class = prob > perf.opt.th;
    perf.opt.tp  = sum((class == 1) & (perf.opt.pred_class == 1));
    perf.opt.tn  = sum((class == 0) & (perf.opt.pred_class == 0));
    perf.opt.fn  = sum((class == 1) & (perf.opt.pred_class == 0));
    perf.opt.fp  = sum((class == 0) & (perf.opt.pred_class == 1));
    perf.opt.acc = sum(class == perf.opt.pred_class)/length(class);
    perf.opt.bac = 0.5 * (perf.opt.tp / (perf.opt.tp + perf.opt.fn) +...
        perf.opt.tn/(perf.opt.tn + perf.opt.fp));
    perf.opt.C   = [perf.opt.tp perf.opt.fp;
        perf.opt.fn perf.opt.tn];
    
catch
    warning('Could not compute optimized performance measures.')
end


% Prepare output
bac = perf.bac;
acc = perf.acc;
auc = perf.auc;

       