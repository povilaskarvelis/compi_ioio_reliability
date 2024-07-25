function [param_overview] = get_hgf_param_overview(est)
% -------------------------------------------------------------------------
% Function that creates table with information on all paramters that are
% estimated in a given HGF model.
% -------------------------------------------------------------------------


hgf_mod_fnames = {'prc','obs'};
i = 1;

for i_hgf_mod = 1:length(hgf_mod_fnames)
    
    % Get prior structure
    prior = getfield(est, ['c_' hgf_mod_fnames{i_hgf_mod}]);
    
    % Get posterior structure
    post  = getfield(est, ['p_' hgf_mod_fnames{i_hgf_mod}]);
    post = rmfield(post,{'p','ptrans'});
    
    % Get index for parameters that were estimated
    idx = (~isnan(prior.priorsas)) & (prior.priorsas ~= 0);
    
    % Get parameter field names
    fnames = fieldnames(post); % posterior parameter field names
    p_fnames = fieldnames(prior); % prior parameter field names
    
    % Cycle through posterior parameters
    j = 1;
    for i_field = 1:length(fnames)
        n_lvls = length(getfield(post,fnames{i_field}));
        
        % Cycle through HGF levels
        for i_lvl = 1:n_lvls
            if idx(j) == 1 % On first iteration write out parameter details
                
                % Write parameter description
                if n_lvls ==1
                    names{i,1} = fnames{i_field};
                else
                    names{i,1} = [fnames{i_field} '_' num2str(i_lvl)];
                end
                hgf_names{i,1} = fnames{i_field};
                hgf_models{i,1} = hgf_mod_fnames{i_hgf_mod};
                hgf_idx(i,1) = i_lvl;
                
                % Write prior description (mus)
                % FIXME: might not work if there are 2 parameters in log or
                % logit space that contain partially the same letters
                try % look for exact match
                    prior_mus_names{i,1} = p_fnames{strcmp(p_fnames, [fnames{i_field} 'mu'])};
                catch % look for partial match
                    prior_mus_names{i,1} = p_fnames{contains(p_fnames,[fnames{i_field} 'mu'])};
                end
                prior_field = getfield(prior, prior_mus_names{i,1});
                prior_mus(i,1) = prior_field(i_lvl);  % prior mu value
                clear prior_field
                
                % Write prior description (sas)
                % FIXME: might not work if there are 2 parameters in log or
                % logit space that contain partially the same letters
                try % look for exact match
                    prior_sas_names{i,1} = p_fnames{strcmp(p_fnames, [fnames{i_field} 'sa'])};
                catch % look for partial match
                    prior_sas_names{i,1} = p_fnames{contains(p_fnames,[fnames{i_field} 'sa'])};
                end
                prior_field = getfield(prior, prior_sas_names{i,1});
                prior_sas(i,1) = prior_field(i_lvl);  % prior sa value
                clear prior_field
                
                % Write space in which priors are specified
                if contains(prior_mus_names{i},'logit')
                    space{i,1} = 'logit';
                elseif contains(prior_mus_names{i},'log')
                    space{i,1} = 'log';
                else
                    space{i,1} = 'nat';
                end
                
                % Get upper bound for paramters in logit space
                if any(contains(p_fnames,[fnames{i_field} 'ub']))
                    ub_f_idx = contains(p_fnames,[fnames{i_field} 'ub']);
                    prior_ubs{i,1} = getfield(prior,p_fnames{ub_f_idx});
                else
                    prior_ubs{i,1} = NaN;
                end
                
                % Summarize relevant prior parameters for compact pass to
                % plotting functions
                prior_summary{i,1} = [prior_mus(i,1) prior_sas(i,1)  prior_ubs{i,1}(end)];
                
                i = i + 1;
            end
            j = j + 1;
        end
    end
end

param_overview = table(names, hgf_names, hgf_models, hgf_idx,...
    prior_mus_names, prior_sas_names, prior_mus, prior_sas, prior_ubs,...
    space, prior_summary);




