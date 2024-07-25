

#---------------------------------------
# Load Packages
#---------------------------------------
pacman::p_load(xlsx, 
               reshape2,
               ggplot2,
               plyr,
               gridExtra,
               lme4,
               car,
               lsmeans)


#---------------------------------------
# Load data
#---------------------------------------
root_save = 'E:/COMPI/results/ioio/hgf_comp_SIRS/results_hgf/ms9/m3'

root_hgf_parameters = 'E:/COMPI/results/ioio/hgf_comp_SIRS/diag_hgf/ms9/m3/'
fname_hgf_parameters = 'hgf_parameters'

root_F = 'E:/COMPI/results/ioio/hgf_comp_SIRS/results_hgf/ms9/'
fname_F = 'F_hgf'

root_clinical_data = 'E:/COMPI/data/clinical/'
fname_clinical_data = 'input_mask_DH'

# Load parameter data
param_data = read.xlsx(paste0(root_hgf_parameters, fname_hgf_parameters,'.xlsx'),
                     as.data.frame = T, 
                     header = T,
                     sheetIndex = 1)

# Load clinical data
clinical_data = read.xlsx(paste0(root_clinical_data, fname_clinical_data,'.xlsx'),
                       as.data.frame = T, 
                       header = T,
                       sheetIndex = 1)
clinical_data = as.data.frame(clinical_data[match(param_data$subject,clinical_data$id),]) # Select specified subjects
clinical_data[clinical_data == 'NA'] = NA # Set NA's to NA

# Load parameter data
F_data = read.xlsx(paste0(root_F, fname_F,'.xlsx'),
                       as.data.frame = T, 
                       header = T,
                       sheetIndex = 1)




#---------------------------------------
# Prepare data
#---------------------------------------
# Get subject ids and group
subjects = factor(param_data$subject, levels = param_data$subject)
group = factor(param_data$group,
               levels = c('HC','CHR','FEP'))

# covariates
age = param_data$age
age_z = (age-mean(age))/sd(age)
wm = param_data$wm
wm_z = (wm-mean(wm))/sd(wm)
antipsych = factor(param_data$antipsych, 
                   levels = c(0,1), 
                   labels = c('no','yes'))
antidep = factor(param_data$antidep, 
                 levels = c(0,1), 
                 labels = c('no','yes'))
IQ = as.numeric(as.character(clinical_data$MWT_IQ))


# parameters
params_of_interest = 'ka|m_3'
params = as.matrix(param_data[,grepl(params_of_interest,colnames(param_data))])
n.params = dim(params)[2]
param.names = colnames(params)
m_3 = param_data$m_3
ka  = param_data$ka_2



#---------------------------------------
# Test for WM and IQ differences
#---------------------------------------
Anova(lm(wm ~ group), type = 3)
Anova(lm(IQ[!is.na(IQ)] ~ group[!is.na(IQ)]), type = 3)


#---------------------------------------
# Prepare PCL data
#---------------------------------------
# PCL frequency
PCL_freq = data.matrix(clinical_data[,grepl("PCL_freq_.*_T0", colnames(clinical_data))])
miss = which(is.na(PCL_freq), arr.ind=T)
# Median imputation (1 missing value) within group
PCL_freq[miss[1],miss[2]] = median(PCL_freq[group == group[miss[1]], miss[2]], na.rm = T)

# PCL distress
PCL_dist = data.matrix(clinical_data[grepl("PCL_dist_.*_T0", colnames(clinical_data))])
miss = which(is.na(PCL_dist), arr.ind=T)
# Median imputation (1 missing value) within group
PCL_dist[miss[1],miss[2]] = median(PCL_dist[group == group[miss[1]], miss[2]], na.rm = T)


PCL_conv = data.matrix(clinical_data[grepl("PCL_conv_.*_T0", colnames(clinical_data))])
miss = which(is.na(PCL_conv), arr.ind=T)
miss
# no missing here


# Compute total scores
PCL_freq_total = rowSums(PCL_freq)
PCL_conv_total = rowSums(PCL_conv)
PCL_dist_total = rowSums(PCL_dist)
PCL_total = PCL_freq_total + PCL_dist_total + PCL_conv_total

# Z- scoring
PCL_freq_total_z = (PCL_freq_total-mean(PCL_freq_total))/sd(PCL_freq_total)
PCL_conv_total_z = (PCL_conv_total-mean(PCL_conv_total))/sd(PCL_conv_total)
PCL_dist_total_z = (PCL_dist_total-mean(PCL_dist_total))/sd(PCL_dist_total)
PCL_total_z = (PCL_total-mean(PCL_total))/sd(PCL_total)



#---------------------------------------
# Prepare PANSS data
#---------------------------------------
PANSS_P = data.matrix(clinical_data[,grepl("PANSS_P.*_T0", colnames(clinical_data))])
rownames(PANSS_P) = subjects
PANSS_N = data.matrix(clinical_data[,grepl("PANSS_N.*_T0", colnames(clinical_data))])
rownames(PANSS_N) = subjects
PANSS_G = data.matrix(clinical_data[,grepl("PANSS_G.*_T0", colnames(clinical_data))])
rownames(PANSS_G) = subjects

# Set PANSS_G12 to 1 for HC (deficits of insight into the disease; 1 = no deficits)
PANSS_G[group =='HC', grepl('PANSS_G12_T0', colnames(PANSS_G))] = 1
# Median imputation within group for miss G12 in 1 CHR
row = match('COMPI_0059', rownames(PANSS_G))
col = match('PANSS_G12_T0', colnames(PANSS_G))
PANSS_G[row, col] = median(PANSS_G[group == 'CHR', col], na.rm = T)
# Median imputation within group for miss G12 in 1 FEP
row = match('COMPI_0012', rownames(PANSS_G))
col = match('PANSS_G12_T0', colnames(PANSS_G))
PANSS_G[row, col] = median(PANSS_G[group == 'FEP', col], na.rm = T)
# One FEP has no PANSS at all, we will remove that from the analysis later

# Compute total scores
PANSS_P_total = rowSums(PANSS_P)
PANSS_N_total = rowSums(PANSS_N)
PANSS_G_total = rowSums(PANSS_G)
PANSS_total = PANSS_P_total + PANSS_N_total + PANSS_G_total

# Z- scoring
PANSS_P_total_z = (PANSS_P_total-mean(PANSS_P_total, na.rm = T))/sd(PANSS_P_total, na.rm = T)
PANSS_N_total_z = (PANSS_N_total-mean(PANSS_N_total, na.rm = T))/sd(PANSS_N_total, na.rm = T)
PANSS_G_total_z = (PANSS_G_total-mean(PANSS_G_total, na.rm = T))/sd(PANSS_G_total, na.rm = T)
PANSS_total_z = (PANSS_total-mean(PANSS_total, na.rm = T))/sd(PANSS_total, na.rm = T)



#---------------------------------------
# Prepare Bayes Factors
#---------------------------------------
bf = F_data$F3 - F_data$F1

# Plot Bayes factors
windowsFonts(Calibri = windowsFont("Calibri"))
bf_data = data.frame(bf, group, subjects)
ggplot(data = bf_data, aes(x = subjects, y = bf, fill = group)) +
        geom_bar(stat="identity") +
        scale_y_continuous(name="Log Bayes Factor") +
        scale_x_discrete(name="Subject") +
        theme_classic() +
        theme(axis.text.x = element_blank(),
              axis.ticks = element_blank(),
              text = element_text (family = "Calibri", size = 18, face = 'bold'))




#---------------------------------------
# Correlating Parameters with Symptoms 
#---------------------------------------
data = data.frame(m_3, ka, PCL_total_z, PCL_conv_total_z, PCL_dist_total_z, PCL_freq_total_z)
# PCL & Mu
Anova(lm(m_3 ~ PCL_total_z, data = data), type = 3)
Anova(lm(m_3 ~ PCL_freq_total_z + PCL_conv_total_z + PCL_dist_total_z, data = data), type = 3)
# cor.test(params$m_3,PCL_total)
# cor.test(params$m_3,PCL_freq_total)
# cor.test(params$m_3,PCL_conv_total)
# cor.test(params$m_3,PCL_dist_total)

# PCL & kappa
Anova(lm(ka ~ PCL_total_z, data = data), type = 3)
Anova(lm(ka ~ PCL_freq_total_z + PCL_conv_total_z + PCL_dist_total_z, data = data), type = 3)
# cor.test(params$ka_2,PCL_total)
# cor.test(params$ka_2,PCL_freq_total)
# cor.test(params$ka_2,PCL_conv_total)
# cor.test(params$ka_2,PCL_dist_total)

# PANSS & Mu


data = data.frame(m_3, ka, PANSS_total_z, PANSS_P_total_z, PANSS_N_total_z, PANSS_G_total_z)
data = data[complete.cases(data),]

Anova(lm(formula = m_3 ~ PANSS_total_z, data = data), type = 3)
Anova(lm(m_3 ~ PANSS_P_total_z + PANSS_N_total_z + PANSS_G_total_z, data = data), type = 3)
# cor.test(params$m_3,PANSS_total, na.action = na.omit())
# cor.test(params$m_3,PANSS_P_total, na.action = na.omit())
# cor.test(params$m_3,PANSS_N_total, na.action = na.omit())
# cor.test(params$m_3,PANSS_G_total, na.action = na.omit())

# PANSS & kappa
Anova(lm(formula = ka ~ PANSS_total_z, data = data), type = 3)
Anova(lm(ka ~ PANSS_P_total_z + PANSS_N_total_z + PANSS_G_total_z, data = data), type = 3)
cor.test(ka,PANSS_total, na.action = na.omit())
cor.test(ka,PANSS_P_total, na.action = na.omit())
cor.test(ka,PANSS_N_total, na.action = na.omit())
cor.test(ka,PANSS_G_total, na.action = na.omit())

# PCL & BF
data = data.frame(bf, PCL_total_z, PCL_conv_total_z, PCL_dist_total_z, PCL_freq_total_z)
Anova(lm(bf ~ PCL_total_z, data = data), type = 3)
Anova(lm(bf ~ PCL_freq_total_z + PCL_conv_total_z + PCL_dist_total_z, data = data), type = 3)
cor.test(bf, PCL_total)



#---------------------------------------
# MANOVA PCL
#---------------------------------------
m_3_z = (m_3-mean(m_3))/sd(m_3)
ka_z = (ka-mean(ka))/sd(ka)

Y = as.matrix(data.frame(PCL_conv_total, PCL_dist_total, PCL_freq_total))
Anova(lm(PCL_total ~ m_3_z + ka_z), type = 3, p.adjust.methods = 'bonferroni')
Manova(lm(Y ~ m_3_z + ka_z), type = 3)

for (i in 1:dim(Y)[2]){
        cat(paste0('\n---------------------\n ',colnames(Y)[i], '\n---------------------\n'))
        an = lm(Y[,i] ~ m_3_z + ka_z)
        print(Anova(an, type = 'III'))
        cat('--------------------------\nTest for normality\n--------------------------')
        qqnorm(resid(an))
        qqline(resid(an))
        print(shapiro.test(an$residuals))
}

#---------------------------------------
# Spearman correlations with PCL
#---------------------------------------
n.comp = dim(Y)[2] # * n.params
p = vector(mode = 'numeric', length = n.comp)
rho = vector(mode = 'numeric', length = n.comp)
parameter = vector(mode = 'character', length = n.comp)
outcome = vector(mode = 'character', length = n.comp)

c = 1
for (i in 1:n.params){
         cat(paste0('\n---------------------\n ',param.names[i], '\n---------------------'))
        for (j in 1:dim(Y)[2]){
                cat(paste0('\n---------------------\n ',colnames(Y)[j], '\n---------------------\n'))
                res = cor.test(Y[,j], params[,i], method = 'spearman')
                # res = kruskal.test(Y[,j] ~ m_3)
                p[c] = res$p.value
                rho[c] = res$estimate
                parameter[c] = param.names[i]
                outcome[c] = colnames(Y)[j]
                print(res)
                c = c+1
        }
}

# bonferroni correction
p_bon = p.adjust(p,method = 'bonferroni', n = length(p))
p_fdr = p.adjust(p,method = 'fdr', n = length(p))
print(cbind(parameter, outcome, rho, p, p_bon, p_fdr))


#---------------------------------------
# MANOVA PANSS
#---------------------------------------
Y = as.matrix(data.frame(PANSS_P_total, PANSS_N_total, PANSS_G_total))
Anova(lm(PANSS_total ~ m_3_z + ka_z), type = 3, p.adjust.methods = 'bonferroni')
Manova(lm(Y ~ m_3_z + ka_z), type = 3)

for (i in 1:dim(Y)[2]){
        cat(paste0('\n---------------------\n ',colnames(Y)[i], '\n---------------------\n'))
        an = lm(Y[,i] ~ m_3 + ka)
        print(Anova(an, type = 'III'))
        cat('--------------------------\nTest for normality\n--------------------------')
        qqnorm(resid(an))
        qqline(resid(an))
        print(shapiro.test(an$residuals))
}

#---------------------------------------
# Spearman correlations with PANSS
#---------------------------------------
Y = as.matrix(data.frame(PANSS_P_total, PANSS_N_total, PANSS_G_total))
n.comp = dim(Y)[2] * n.params
p = vector(mode = 'numeric', length = n.comp)
rho = vector(mode = 'numeric', length = n.comp)
parameter = vector(mode = 'character', length = n.comp)
outcome = vector(mode = 'character', length = n.comp)

c = 1
for (i in 1:n.params){
        cat(paste0('\n---------------------\n ',param.names[i], '\n---------------------'))
        for (j in 1:dim(Y)[2]){
                cat(paste0('\n---------------------\n ',colnames(Y)[j], '\n---------------------\n'))
                res = cor.test(Y[,j], params[,i], method = 'spearman')
                # res = kruskal.test(Y[,j] ~ m_3)
                p[c] = res$p.value
                rho[c] = res$estimate
                parameter[c] = param.names[i]
                outcome[c] = colnames(Y)[j]
                print(res)
                c = c+1
        }
}

# bonferroni correction
p_bon = p.adjust(p,method = 'bonferroni', n = length(p))
p_fdr = p.adjust(p,method = 'fdr', n = length(p))
print(cbind(parameter, outcome, rho, p, p_fdr, p_bon))


#-----------------
# Plot m3
#-----------------
rank_P = rank(Y[,2])
rank_m3 = rank(m_3)
data = data.frame(rank_m3,rank_P)
colnames(data) = c('param','symptom')


windowsFonts(Calibri = windowsFont("Calibri"))
ggplot(data = data, aes(x = param, y = symptom)) +
        geom_point() +
        geom_smooth(method = "lm") +
        ylab('Rank PANSS P') +
        xlab(expression(bold(m[bold("3")]))) +
        theme_classic() +
        theme(text = element_text (size = 18, family = "Calibri", face = 'bold'))
# 
# ggsave(paste0(root_save,'hgf_parameter_effect_m3.png'), g,
#        dpi = 300)
# 
# 
# library(ggpubr)
# p+stat_cor(method="pearson")
# 
# 
# ggplot(data = df, aes(x = mpg, y = hp)) + 
#         geom_point(color='blue') +
#         geom_smooth(method = "lm", se = FALSE)
# 
# 
# ggstatsplot::ggscatterstats(data = iris, x = data$param, y = data$symptom)



#---------------------------------------
# Spearman correlations with BF
#---------------------------------------
n.comp = n.params
p = vector(mode = 'numeric', length = n.comp)
rho = vector(mode = 'numeric', length = n.comp)
parameter = vector(mode = 'character', length = n.comp)
outcome = vector(mode = 'character', length = n.comp)

c = 1
for (i in 1:n.params){
        cat(paste0('\n---------------------\n ',param.names[i], '\n---------------------'))
        
        res = cor.test(bf, params[,i], method = 'spearman')
        # res = kruskal.test(Y[,j] ~ m_3)
        p[c] = res$p.value
        rho[c] = res$estimate
        parameter[c] = param.names[i]
        print(res)
        c = c+1
}

# bonferroni correction
p_bon = p.adjust(p,method = 'bonferroni', n = length(p))
p_fdr = p.adjust(p,method = 'fdr', n = length(p))
print(cbind(parameter, rho, p, p_bon, p_fdr))


