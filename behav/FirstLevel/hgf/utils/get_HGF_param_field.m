function param = get_HGF_param_field(est)
%--------------------------------------------------------------------------
% Function that extracts table with parameter descriptions from HGF model
% structure.
%
% IN:
%   est                     -> Output from model inversion using
%                              tapas_fitModel
%
% OUT:
%   param(table)            -> Table containing detailed information
%                              required to extract and visualize HGF model 
%                              parameters that were estimated during 
%                              inversion.
%
%--------------------------------------------------------------------------



%% Main function
hgf_mod_fnames = {'prc','obs'};

i = 1;
for i_hgf_mod = 1:length(hgf_mod_fnames)
    
    % Get relevant fields from est structure
    post  = getfield(est, ['p_' hgf_mod_fnames{i_hgf_mod}]);
    prior = getfield(est, ['c_' hgf_mod_fnames{i_hgf_mod}]); 
    post = rmfield(post,{'p','ptrans'});
    idx = (~isnan(prior.priorsas)) & (prior.priorsas ~= 0);
    fnames = fieldnames(post);
    p_fnames = fieldnames(prior);

    j = 1;
    
    for i_field = 1:length(fnames)
        n_lvls = length(getfield(post,fnames{i_field}));
        
        for i_lvl = 1:n_lvls
            if idx(j) == 1
                % Write parameter description
                if n_lvls ==1
                    names{i} = fnames{i_field};
                else
                    names{i} = [fnames{i_field} '_' num2str(i_lvl)];
                end
                hgf_names{i} = fnames{i_field};
                hgf_models{i} = hgf_mod_fnames{i_hgf_mod};
                hgf_idx{i} = i_lvl;
                
                % Write prior description
                temp = p_fnames(contains(p_fnames,[fnames{i_field} 'mu']));
                try
                    prior_mus{i} = temp{1};
                catch
                    prior_mus{i} = temp;
                end
                temp = p_fnames(contains(p_fnames,[fnames{i_field} 'sa']));
                try
                    prior_sas{i} = temp{1};
                catch
                    prior_sas{i} = temp;
                end
                clear temp
                
                % Specify parameter space
                if contains(prior_mus{i},'logit')
                    space{i} = 'logit';
                elseif contains(prior_mus{i},'log')
                    space{i} = 'log';
                else
                    space{i} = 'nat';
                end
                
                % Collect bounds if applicable
                if any(contains(p_fnames,[fnames{i_field} 'ub']))
                    ub_f_idx = contains(p_fnames,[fnames{i_field} 'ub']);
                    prior_ubs{i} = getfield(prior,p_fnames{ub_f_idx});
                else
                    prior_ubs{i} = [];
                end
                
                i = i+1;
            end
            j = j + 1;
        end
    end
end

% Create parameter description table
param = table(names',hgf_names', hgf_models', cell2mat(hgf_idx'), space',...
    prior_mus', prior_sas', prior_ubs');
param.Properties.VariableNames = {'names','hgf_names', 'hgf_models',...
    'hgf_idx','space','prior_mus','prior_sas','prior_ubs'};



