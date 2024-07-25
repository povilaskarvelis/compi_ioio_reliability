

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
root_data = 'E:/COMPI/results/ioio/hgf_comp_SIRS/diag_hgf/ms9/m3/'
fname_data = 'hgf_parameters'


# Load choice data
data = read.xlsx(paste0(root_data, fname_data,'.xlsx'),
                     as.data.frame = T, 
                     header = T,
                     sheetIndex = 1)

# Get other variables
subjects = factor(data$subject)
group = factor(data$group,
               levels = c('HC','CHR','FEP'))

# covariates
age = data$age
age_z = (age-mean(age))/sd(age)
wm = data$wm
wm_z = (wm-mean(wm))/sd(wm)
antipsych = factor(data$antipsych, 
                   levels = c(0,1), 
                   labels = c('no','yes'))
antidep = factor(data$antidep, 
                 levels = c(0,1), 
                 labels = c('no','yes'))


# Response variables (i.e., parameters)
params_of_interest = 'ka|om|m_3|mu_0_3'
params_of_interest = 'ka|om|m_3|mu_0_3|mu_0_2|ze1'
Y = as.matrix(data[,grepl(params_of_interest,colnames(data))])
n.params = dim(Y)[2]
param.names = colnames(Y)

#---------------------------------------
# Histograms
#---------------------------------------
for (i in 1:n.params){
        hist(Y[,i], 
             main = param.names[i],
             xlab = param.names[i])
}



#---------------------------------------
# MANOVA
#---------------------------------------
mod = lm(Y ~ group + age_z + wm_z + antipsych + antidep, data)
Manova(mod, type = 'II')




#---------------------------------------
# Follow-up ANOVAs
#---------------------------------------
for (i in 1:n.params){
        cat(paste0('\n----------\n ',param.names[i]), '\n----------\n')
        an = lm(Y[,i] ~ group + age_z + wm_z + antipsych + antidep, data)
        print(Anova(an, type = 'III'))
        print(shapiro.test(an$residuals))
}




#---------------------------------------
# Follow-up T-tests
#---------------------------------------
for (i in 1:length(an)){
        p = an[[i]]$`Pr(>F)`[1]
        if (p<0.05){
                cat(paste0('\n----------\n ',param.names[i]), '\n----------\n')
                res = pairwise.t.test(Y[,i],group,p.adjust.method = 'bonferroni', paired = F, pool.sd = F)
                print(res)
        }
}



#---------------------------------------
# Follow-up Krushkal-Wallis
#---------------------------------------
p = vector(mode = 'numeric', length=n.params)
eta_squared = vector(mode = 'numeric', length=n.params)

for (i in 1:n.params){
        cat(paste0('\n----------\n ',param.names[i]), '\n----------\n')
        res = kruskal.test(Y[,i] ~ group)
        p[i]= res$p.value
        eta_squared[i] = res$statistic/(dim(Y)[1]-1)
        print(param.names[i])
        print(res)
}


# bonferroni correction
p.bf = p.adjust(p,method = 'bonferroni', n = length(p))
p.fdr = p.adjust(p,method = 'fdr', n = length(p))
sign.uncorr = as.numeric(p < 0.05)
sign.fdr = as.numeric(p.fdr < 0.05)
sign.bf = as.numeric(p.bf < 0.05)
parameter = param.names
options(scipen=999)
print(data.frame(parameter, eta_squared, p, p.fdr, p.bf, sign.uncorr, sign.fdr, sign.bf), row.names = F)
options(scipen=0)
cat('>0.02 small, >.13 medium, >.26 large')





#------------------------------------------
# Plots
#------------------------------------------
#-------------------------------
# m3
#-------------------------------
# Get data for specific parameter
i = 3 # idx for significant parameter
data = data.frame(Y[,i], group)
colnames(data) = c('param', 'group')


# Plot parameter effect
range.param = range(data[,1]) # Get range of parameter
range.dif = range.param[2]-range.param[1]

summary = data.frame(levels(group),
                     c(mean(data$param[data$group == 'HC']),
                       mean(data$param[data$group == 'CHR']),
                       mean(data$param[data$group == 'FEP'])))
colnames(summary) = c('group', 'param')

colors = c('HC' = 'green', 'CHR' = 'dodgerblue2', 'FEP' = 'firebrick2') 

windowsFonts(Calibri = windowsFont("Calibri"))

g.left = ggplot(data = data) +
        geom_density(aes(x = param, y=..density.., color = group),
                     alpha = .2,
                     size = 1) +
        scale_color_manual(values= colors) +
        scale_x_continuous(limits = c(min(data[,1])-0.1, max(data[,1])+0.1)) +
        # Axis
        ylab('Density') +
        xlab(expression(bold(m[bold("3")]))) +
        coord_flip() +
        theme_linedraw() +
        theme(text=element_text(family="Calibri"),
              legend.position="none",
              axis.title.y = element_text(colour="black",size=18,face="bold", margin = margin(t = 0, r = 20, b = 0, l = 0)),
              axis.title.x = element_text(colour="black",size=18,face="bold", margin = margin(t = 12, r = 0, b = 0, l = 0)),
              axis.text.y = element_text(colour="black",size=16),
              axis.text.x = element_blank(),
              panel.grid.major =  element_blank(),
              panel.grid.minor =  element_blank())
g.left

h1 = 2.93
g.middle = ggplot(data, aes(x = group, y = param, fill = group)) +
        geom_boxplot(outlier.shape = NA) +
        scale_fill_manual(values = colors) +
        geom_jitter(position = position_jitterdodge(dodge.width = 0.75), alpha = .3) +
        scale_y_continuous(limits = c(min(data[,1])-0.1, max(data[,1])) + 0.1, breaks = NULL) +
        geom_point(data = summary, size = 4, shape = 22, position = position_dodge(width=0.75), show.legend = F) +
        scale_shape_identity() +
        theme_linedraw() +
        theme(text=element_text(family="Calibri"),
              legend.position="none",
              axis.title.x=element_blank(),
              axis.title.y=element_blank(),
              axis.text.y = element_blank(),
              axis.text.x = element_text(colour="black", size=18,face="bold", margin = margin(t = 12, r = 0, b = 0, l = 0)),
              panel.grid.major.x =  element_blank()) +
        #Effects
        geom_segment(aes(x = 1.05, y = h1, xend = 2.95, yend = h1)) +
        annotate("text", x = 2, y = h1 + .01, label = "**", size = 7)

g.middle 


grid.arrange(g.left,g.middle, ncol = 2, widths = c(1/3, 2/3)) 
g <- arrangeGrob(g.left,g.middle, ncol = 2, widths = c(1/3, 2/3)) 
ggsave(paste0(root_save,'hgf_parameter_effect_m3.png'), g,
       dpi = 300)



#-------------------------------
# kappa
#-------------------------------
# Get data for specific parameter
i = 4 # idx for significant parameter
data = data.frame(Y[,i], group)
colnames(data) = c('param', 'group')


# Plot parameter effect
range.param = range(data[,1]) # Get range of parameter
range.dif = range.param[2]-range.param[1]

summary = data.frame(levels(group),
                     c(mean(data$param[data$group == 'HC']),
                       mean(data$param[data$group == 'CHR']),
                       mean(data$param[data$group == 'FEP'])))
colnames(summary) = c('group', 'param')

colors = c('HC' = 'green', 'CHR' = 'dodgerblue2', 'FEP' = 'firebrick2') 

windowsFonts(Calibri = windowsFont("Calibri"))

g.left = ggplot(data = data) +
        geom_density(aes(x = param, y=..density.., color = group),
                     alpha = .2,
                     size = 1) +
        scale_color_manual(values= colors) +
        scale_x_continuous(limits = c(min(data[,1])-0.05, max(data[,1]))) +
        # Axis
        ylab('Density') +
        xlab(expression(bold(kappa))) +
        coord_flip() +
        theme_linedraw() +
        theme(text=element_text(family="Calibri"),
              legend.position="none",
              axis.title.y = element_text(colour="black",size=18,face="bold", margin = margin(t = 0, r = 20, b = 0, l = 0)),
              axis.title.x = element_text(colour="black",size=18,face="bold", margin = margin(t = 12, r = 0, b = 0, l = 0)),
              axis.text.y = element_text(colour="black",size=16),
              axis.text.x = element_blank(),
              panel.grid.major =  element_blank(),
              panel.grid.minor =  element_blank())
g.left

h1 = 0.54
g.middle = ggplot(data, aes(x = group, y = param, fill = group)) +
        geom_boxplot(outlier.shape = NA) +
        scale_fill_manual(values = colors) +
        geom_jitter(position = position_jitterdodge(dodge.width = 0.75), alpha = .3) +
        scale_y_continuous(limits = c(min(data[,1])-0.05, max(data[,1])), breaks = NULL) +
        geom_point(data = summary, size = 4, shape = 22, position = position_dodge(width=0.75), show.legend = F) +
        scale_shape_identity() +
        theme_linedraw() +
        theme(text=element_text(family="Calibri"),
              legend.position="none",
              axis.title.x=element_blank(),
              axis.title.y=element_blank(),
              axis.text.y = element_blank(),
              axis.text.x = element_text(colour="black", size=18,face="bold", margin = margin(t = 12, r = 0, b = 0, l = 0)),
              panel.grid.major.x =  element_blank()) +
        #Effects
        geom_segment(aes(x = 1.05, y = h1, xend = 2.95, yend = h1)) +
        annotate("text", x = 2, y = h1 + 0.003, label = "*", size = 7)

g.middle 


grid.arrange(g.left,g.middle, ncol = 2, widths = c(1/3, 2/3)) 
g <- arrangeGrob(g.left,g.middle, ncol = 2, widths = c(1/3, 2/3)) 
ggsave(paste0(root_save,'hgf_parameter_effect_kappa.png'), g,
       dpi = 300)




















#---------------------------------------
# Follow-up T-tests
#---------------------------------------
for (i in 1:n.params){
        if (p[i]<0.05)
                {
                cat(paste0('\n----------\n ',param.names[i]), '\n----------\n')
                res = pairwise.wilcox.test(Y[,i], group, p.adjust.method = 'none', paired = F)
                print(res)
                res = pairwise.wilcox.test(Y[,i], group, p.adjust.method = 'bonferroni', paired = F)
                print(res)
                }
}


# m3 effect size
m3 = Y[group == 'HC' | group == 'FEP',3]
g = group[group == 'HC' | group == 'FEP']

res = kruskal.test(m3 ~ g)
p = res$p.value
eta_squared = res$statistic/(length(m3)-1)

# kappa effect size
eta_squared = vector(mode = 'numeric', length=1)
ka = Y[group == 'HC' | group == 'FEP',4]
g = group[group == 'HC' | group == 'FEP']

res = kruskal.test(ka ~ g)
p = res$p.value
eta_squared = res$statistic[1]/(length(ka)-1)





#---------------------------------------
# Transforming parameters
#---------------------------------------
Y_temp = Y
Y_temp[,grepl('om',colnames(Y_temp))] = exp(Y_temp[,grepl('om',colnames(Y_temp))])
summary(p1 <- powerTransform(Y_temp ~ group, family = 'bcnPower'))
coef(p1, round=TRUE)
Y_transf = bcnPower(Y_temp, lambda = p1$lambda, gamma = p1$gamma)

for (i in 1:n.params){
        hist(Y_transf[,i],
             main = paste(param.names[i], 'transformed'),
             xlab = param.names[i])
}
