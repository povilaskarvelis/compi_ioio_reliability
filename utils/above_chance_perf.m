function threshold = above_chance_perf(n_trials,p_cutoff)
%% this function determines better than chance performance threshold (frac)

n_perm = 100000; % number of permutations

% Correct responses for each permutation
correct_resp = repmat(randi([0 1],[1 n_trials]),[n_perm 1]);

% Random responses for each permutation
random_resp = randi([0 1],[n_perm n_trials]);

% The percent correct for each permutation
percent_correct = sum(correct_resp==random_resp,2)/n_trials;

% The threshold that meets p_cutoff of being better than chance
threshold = quantile(percent_correct,1-p_cutoff);

end