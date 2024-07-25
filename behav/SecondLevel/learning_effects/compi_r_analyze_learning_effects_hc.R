#---------------------------------------
# Load packages
#---------------------------------------
pacman::p_load(xlsx, 
               reshape2,
               ggplot2,
               plyr, 
               lme4,
               car,
               lsmeans,
               ggpubr)

#---------------------------------------
# Load data
#---------------------------------------
root_data = 'E:/COMPI/results/ioio/learning_effects/results_behav/'
root_save = root_data
# cov_file_name = 'compi_choices_f1'
behav_file_name = 'sum_behav_measures'
# cov_data = read.xlsx(paste0(root_data, cov_file_name,'.xlsx'),
#                      as.data.frame = T, 
#                      header = T,
#                      sheetIndex = 1)
behav = read.xlsx(paste0(root_data, behav_file_name,'.xlsx'),
                  as.data.frame = T, 
                  header = T,
                  sheetIndex = 1)

subjects = as.factor(behav [,1])


# # covariates
# age = cov_data[,3]
# age_z = (age-mean(age))/sd(age)
# wm = cov_data[,4]
# wm_z = (wm-mean(wm))/sd(wm)


#---------------------------------------
# Analyse performance
#---------------------------------------
data_wide = data.frame(subjects, behav$AT_acc_t1, behav$AT_acc_t2)
data_long = melt(data_wide,
                 id.vars = c('subjects'),
                 variable.name = 'Time',
                 value.name = 'Accuracy')
#levels(data_long$phase) = c('Stable I', 'Volatile')
levels(data_long$Time) = c('T1', 'T2')


# Parametric statistical analysis
cat('--------------------------\nParametric Test: Performance\n--------------------------')
m = lmer(Accuracy ~ Time + (1|subjects), data = data_long)
Anova(m, type = 'III')

cat('--------------------------\nTest for normality\n--------------------------')
qqnorm(resid(m))
qqline(resid(m))
shapiro.test(resid(m))


# Non-parametric statistical analysis
cat('--------------------------\nNon-Parametric Test: Performance\n--------------------------')
wilcox.test(behav$AT_acc_t1, behav$AT_acc_t2, paired = T, conf.int = T) 


# Plot results
summary <- ddply(data_long, .(time), summarise, Performance = mean(Performance))
windowsFonts(Calibri = windowsFont("Calibri"))
ggplot(data_wide, aes(x = group, y = win_switch, fill = group)) +
        geom_boxplot(outlier.shape = NA) +
        geom_jitter(position = position_jitterdodge(dodge.width = 0.75), alpha = .3) +
        labs(title="Win-Switch per Group", y = "Win-Switch Rate", x = 'Group') +
        geom_point(data = summary, size = 4, shape = 22, position = position_dodge(width=0.75), show.legend = F) +
        scale_shape_identity() +
        theme_classic() +
        theme(text = element_text (family = "Calibri", size = 18, face = 'bold'), legend.position="none")
ggsave(paste0(root_save,'win-switch_per_group.png'),
       dpi = 300)


#


cat('--------------------------\nParametric Tes: Performance\n--------------------------')
#summary(lmer(AT ~ group*phase + (1|subjects), data = data_long))
#Anova(lm(AT ~ group*phase, data = data_long), type = 'III')
m = lmer(Accuracy ~ Time + (1|subjects), data = data_long)
Anova(m, type = 'III')

cat('--------------------------\nTest for normality\n--------------------------')
qqnorm(resid(m))
qqline(resid(m))
shapiro.test(resid(m))










#---------------------------------------
# Visualize data
#---------------------------------------
hist(data$eeg_1st)

boxplot(AT ~ time, data = data_long)

boxplot(CS ~ time, data = data_long)

boxplot(perf ~ time, data = data_long)



#---------------------------------------
# Test for learning effects
#---------------------------------------
# Advice Taking
cat('--------------------------\nAdvice Taking\n--------------------------')
summary(lmer(AT ~ time + (1|IDs), data = data_long))


# CS
cat('--------------------------\nCumulative Score\n--------------------------')
summary(lmer(CS ~ time + (1|IDs), data = data_long))


# Performance
cat('--------------------------\nPerformance Accuracy\n--------------------------')
summary(lmer(perf ~ time + (1|IDs), data = data_long))



#---------------------------------------
# Visualize effects with ggplot
#---------------------------------------
ggplot(data_long, aes(x = time, y = AT, colour = time)) + 
        geom_boxplot() + 
        geom_jitter(position = position_jitterdodge(dodge.width = 0.75)) +
        labs(title="Learning effect on AT") +
        geom_segment(x = 1, y = .84, xend = 2, yend = .84, colour = 'black') +
        geom_text(x = 1.5, y = .86, label ='*', colour = 'black') +
        scale_y_continuous(limits = c(.37, .86)) +
        theme_classic() +
        theme(text = element_text (size = 20), legend.position="none")
ggsave(paste0(fig_path,'learning_effects_AT.png'))


ggplot(data_long, aes(x = time, y = CS, colour = time)) + 
        geom_boxplot() + 
        geom_jitter(position = position_jitterdodge(dodge.width = 0.75)) +
        labs(title="Learning effect on cumulative score") +
        geom_segment(x = 1, y = 82, xend = 2, yend = 82, colour = 'black') +
        geom_text(x = 1.5, y = 84, label ='n.s.', colour = 'black') +
        scale_y_continuous(limits = c(3, 84)) +
        theme_classic() +
        theme(text = element_text (size = 20), legend.position="none")
ggsave(paste0(fig_path,'learning_effects_CS.png'))

ggplot(data_long, aes(x = time, y = perf, colour = time)) + 
        geom_boxplot() + 
        geom_jitter(position = position_jitterdodge(dodge.width = 0.75)) +
        labs(title="Learning effect on performance") +
        geom_segment(x = 1, y = .75, xend = 2, yend = .75, colour = 'black') +
        geom_text(x = 1.5, y = .77, label ='n.s.', colour = 'black') +
        scale_y_continuous(limits = c(.50, .77)) +
        theme_classic() +
        theme(text = element_text (size = 20), legend.position="none")
ggsave(paste0(fig_path,'learning_effects_perf.png'))




#---------------------------------------
# Prepare data for IA analysis
#---------------------------------------
IDs = as.factor(data$ID)
eeg_1st = data$eeg_1st

# Collect variables according to measurement time points
# Advice taking
AT_stable_I_t1 = data$fMRI_AT_stable_I
AT_stable_I_t1[as.logical(eeg_1st)] = data$EEG_AT_stable_I[as.logical(eeg_1st)]
AT_stable_I_t2 = data$EEG_AT_stable_I
AT_stable_I_t2[as.logical(eeg_1st)] = data$fMRI_AT_stable_I[as.logical(eeg_1st)]

AT_volatile_t1 = data$fMRI_AT_volatile_I
AT_volatile_t1[as.logical(eeg_1st)] = data$EEG_AT_volatile_I[as.logical(eeg_1st)]
AT_volatile_t2 = data$EEG_AT_volatile_I
AT_volatile_t2[as.logical(eeg_1st)] = data$fMRI_AT_volatile_I[as.logical(eeg_1st)]

AT_stable_II_t1 = data$fMRI_AT_stable_II
AT_stable_II_t1[as.logical(eeg_1st)] = data$EEG_AT_stable_II[as.logical(eeg_1st)]
AT_stable_II_t2 = data$EEG_AT_stable_II
AT_stable_II_t2[as.logical(eeg_1st)] = data$fMRI_AT_stable_II[as.logical(eeg_1st)]



# Time point
t = as.factor(c(rep(1,length(AT1)),  rep(2,length(AT2))))


data_wide = data.frame(c(IDs,IDs),c(eeg_1st,eeg_1st), t, 
                       c(AT_stable_I_t1,AT_stable_I_t2),
                       c(AT_volatile_t1,AT_volatile_t2), 
                       c(AT_stable_II_t1,AT_stable_II_t2))
colnames(data_wide) = c('IDs','eeg_1st','time','AT_stable_I','AT_volatile','AT_stable_II')
data_wide$eeg_1st = as.factor(data_wide$eeg_1st)


data_long = melt(data_wide,
                 id.vars = c('IDs', 'eeg_1st', 'time'),
                 variable.name = 'phase',
                 value.name = 'AT')
levels(data_long$phase) = c('Stable I','Volatile','Stable II')




#---------------------------------------
# Test for learning effects with phase IA
#---------------------------------------

# Advice Taking
cat('--------------------------\nAdvice Taking * phase\n--------------------------')
summary(lmer(AT ~ time*phase + (1|IDs), data = data_long))

Anova(lm(AT ~ time * phase, data = data_long),type = 'III')

p_uncorr = rep(NaN,3)
t = t.test(AT_stable_I_t1, AT_stable_I_t2, paired = T)
t
p_uncorr[1] = t$p.value

t = t.test(AT_volatile_t1, AT_volatile_t2, paired = T)
t
p_uncorr[2] = t$p.value

t = t.test(AT_stable_II_t1, AT_stable_II_t2, paired = T)
t
p_uncorr[3] = t$p.value

p_bf = p.adjust(p_uncorr, method = 'bonferroni')
p_bf


ggplot(data_long, aes(x = phase, y = AT, colour = time)) + 
        geom_boxplot() + 
        geom_jitter(position = position_jitterdodge(dodge.width = 0.75)) +
        # labs(title="Learning effect on AT") +
        # geom_segment(x = .75, y = .99, xend = 1.25, yend = .99, colour = 'black') +
        # geom_text(x = 1, y = 1, label ='**', colour = 'black') +
        scale_y_continuous(limits = c(.20, 1)) +
        theme_classic() +
        theme(text = element_text (size = 20))
ggsave(paste0(fig_path,'learning_effects_AT_by_phase.png'))








