function [prc_model,rp_model] = getDMPADModelSpace(iModels)

switch iModels
    case 1
        rp_model = {'ioio_constant_weight_config','ioio_constant_weight_adv_config','ioio_constant_weight_cue_config'};
        prc_model = 'tapas_hgf_binary_config';
    case 2
        rp_model = {'ioio_constant_voltemp_exp_config','ioio_constant_voltemp_exp_adv_config','ioio_constant_voltemp_exp_cue_config'};
        prc_model = 'tapas_hgf_binary_allfree_config';
    case 3
        rp_model = {'ioio_constant_weight_config','ioio_constant_weight_adv_config','ioio_constant_weight_cue_config'};
        prc_model = 'tapas_hgf_binary_novol_config';
    case 4
        rp_model = {'rw_ioio_constant_weight_config','rw_ioio_constant_weight_adv_config','rw_ioio_constant_weight_cue_config'};
        prc_model = 'tapas_rw_binary_config';
    case 5
        rp_model = {'ioio_constant_weight_config','ioio_constant_weight_adv_config','ioio_constant_weight_cue_config'};
        prc_model = 'tapas_sutton_k1_binary_config';
    case 6
        rp_model = {'ioio_constant_voltemp_exp_config','ioio_constant_voltemp_exp_adv_config','ioio_constant_voltemp_exp_cue_config'};
        prc_model = 'tapas_hgf_binary_free_params_config';
        
end
end