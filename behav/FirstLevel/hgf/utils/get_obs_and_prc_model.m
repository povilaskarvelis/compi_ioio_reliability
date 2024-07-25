function [prc_model, obs_model] = get_obs_and_prc_model(model,options)

combs     = options.hgf.combinations;
prc_model = options.hgf.prc_models{combs(model,1)};
obs_model = options.hgf.obs_models{combs(model,2)};


