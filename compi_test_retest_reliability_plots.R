# Plotting test-retest reliability results for "Test-retest reliability of
# behavioral and computational measures of advice taking under volatility"

# Written by: Povilas Karvelis (povilas.karvelis@camh.ca)
# 2023


library(lme4)
library(lmerTest)
library(irr)
library(tidyverse)
library(extrafont)
library(ggpubr)
library(boot)
library(ggeffects)
library(insight)
library(arm)
library(ggplot2)
library(patchwork)
library(plotrix)
library(nlme)
library(readxl)
library(reshape2)
library(robustbase)


# clear workspace
rm(list=ls())

# load data
xdata = read.table(file=paste("E:/COMPI/results/ioio/test_retest/results_behav/full_behav_measures.txt", sep=""), header=T, sep=",")

# deal with invalid trials
xdata <- xdata[xdata$valid==1, ] 
# xdata[xdata$valid!=1, ] <- NA
xdata$correct[xdata$correct==-1] <- 0


# Load necessary libraries
library(ggplot2)
library(psych) # For the icc function
library(dplyr)

# Define a function for plotting scatter plots and ICC results
plot_ICC <- function(x, y, outliers, labx, laby, titl, colr) {
  xylim <- range(c(x, y))
  
  # Create a data frame for plotting
  data_plot <- data.frame(x = x, y = y, outlier = outliers)
  
  # Create a data frame excluding outliers for geom_smooth
  data_plot_no_outliers <- data_plot[!data_plot$outlier, ]
  
  # Plot
  ggplot(data = data_plot, aes(x = x, y = y, color = outlier)) +
    geom_point(size = 4, alpha = 0.7) +
    #geom_smooth(method = lm, color = "black") +
    geom_smooth(data = data_plot_no_outliers, method = lm, color = "black") +  # Use data without outliers
    geom_abline(intercept = 0, slope = 1, linetype = "dashed", size = 1) +
    scale_x_continuous(limits = xylim) +
    scale_y_continuous(limits = xylim) +
    coord_fixed(ratio = 1) +
    theme_minimal() +
    xlab(labx) +
    ylab(laby) +
    theme_classic(base_size = 18) +
    theme(plot.title = element_text(size = 16, hjust = 0.5)) +
    ggtitle(titl) +
    scale_color_manual(values = c("FALSE" = colr, "TRUE" = "red")) +
    guides(color = "none")  # Remove the legend
}

# Detect univariate outliers using IQR method
detect_univariate_outliers <- function(x,y) {
  
  m = 3
    
  Q1x <- quantile(x, 0.25, na.rm = TRUE)
  Q3x <- quantile(x, 0.75, na.rm = TRUE)
  IQRx <- Q3x - Q1x
  lbx <- Q1x - m * IQRx
  ubx <- Q3x + m * IQRx
  
  Q1y <- quantile(y, 0.25, na.rm = TRUE)
  Q3y <- quantile(y, 0.75, na.rm = TRUE)
  IQRy <- Q3y - Q1y
  lby <- Q1y - m * IQRy
  uby <- Q3y + m * IQRy
  
  
  return(x < lbx | x > ubx | y < lby | y > uby)
}

# Function to detect influential points based on regression diagnostics
detect_influential_points <- function(x, y) {
  model <- lm(y ~ x)
  cooks_d <- cooks.distance(model)
  
  # Define thresholds
  cooks_d_threshold <- 4 / length(y)
  
  # Identify influential points
  influential_points <- cooks_d > cooks_d_threshold
  
  return(influential_points)
}

detect_outliers <- function(x, y) { 
  
  outliers <- detect_univariate_outliers(x, y)
  #outliers <- detect_influential_points(x, y)
  
  return(outliers)
  
}

# Define a function for computing ICC non-hierarchically for any variable
nonhier_analysis <- function(data, column, labx, laby, colr) {
  # Non-hierarchical estimation
  x <- vector()
  y <- vector()
  for (i in unique(data$subID)) {
    x[i] = mean(subset(data, session == 1 & subID == i)[[column]] == 1, na.rm = TRUE)
    y[i] = mean(subset(data, session == 2 & subID == i)[[column]] == 1, na.rm = TRUE)
  }
  
  outliers <- detect_outliers(x, y)
  
  # Compute ICC without outliers
  icca1 <- icc(cbind(x[!outliers], y[!outliers]), model = "twoway", type = "agreement", unit = "single")
  r <- cor.test(x[!outliers], y[!outliers])
  
  # Specify title and labels
  titl <- sprintf("ICC = %.2f [%.2f %.2f] \nr     = %.2f [%.2f %.2f]",
                  icca1$value, icca1$lbound, icca1$ubound,
                  r$estimate, r$conf.int[1], r$conf.int[2])
  
  # Plot
  plot_ICC(x, y, outliers, labx, laby, titl, colr)
}



##################
# Total accuracy #
##################


nonhier_analysis(xdata,"correct","Total Acc T1","Total Acc T2","black")


#######################
# Total advice taking #
#######################

nonhier_analysis(xdata,"choice","Total AT T1","Total AT T2", "black")


##########################################
# Advice taking during the stable phases #
##########################################

# add a new column to the data frame to make hierarchical model specification easy
choice_stable <- rep(NA,nrow(xdata))
choice_stable[which(xdata$stable==1)] <- subset(xdata,stable==1)$choice
xdata$choice_stable <- choice_stable

nonhier_analysis(xdata,"choice_stable","Stable AT T1","Stable AT T2","black")

############################################
# Advice taking during the volatile phases #
############################################

# add a new column to the data frame to make hierarchical model specification easy
choice_volatile <- rep(NA,nrow(xdata))
choice_volatile[which(xdata$stable==0)] <- subset(xdata,stable==0)$choice
xdata$choice_volatile <- choice_volatile

nonhier_analysis(xdata,"choice_volatile","Volatile AT T1","Volatile AT T2","black")


############
# Win-stay #
############


# add a new column to the data frame to make hierarchical model specification easy
win_stay <- rep(NA,nrow(xdata))

# determine win-stay trials
for (i in 2:nrow(xdata)){
  if (xdata$correct[i-1] == 1){               # if previous response was correct
    if (xdata$choice[i-1] == xdata$choice[i]){
      win_stay[i] <- 1    # if current choice is the same as in the prev trial
    } else {
      win_stay[i] <- 0    # if current choice is different
    }
  }
}

xdata$win_stay <- win_stay

nonhier_analysis(xdata,"win_stay","Win-stay T1","Win-stay T2","black")


###############
# Lose-switch #
###############


# add a new column to the data frame to make hierarchical model specification easy
lose_switch <- rep(NA,nrow(xdata))

# determine win-stay trials
for (i in 2:nrow(xdata)){
  if (xdata$correct[i-1] == 0){               # if previous response was incorrect
    if (xdata$choice[i-1] == xdata$choice[i]){
      lose_switch[i] <- 0    # if current choice is the same as in the prev trial
    } else {
      lose_switch[i] <- 1    # if current choice is different
    }
  }
}

xdata$lose_switch <- lose_switch

nonhier_analysis(xdata,"lose_switch","Lose-switch T1","Lose-switch T2","black")



#########################
# Plot model params ICC #
#########################

# load test retest estimates of model parameters
mdata = read_excel("E:/COMPI/results/ioio/test_retest/results_hgf/ms1/sum_hgf_paramsxlsx")
#mdata = read_excel("E:/COMPI/results/ioio/test_retest_136/results_hgf/ms1/sum_hgf_params.xlsx")


# Define a function for computing ICC with outlier detection and plotting
plot_ICC_params <- function(x, y, labx, laby, colr) {
  
  outliers <- detect_outliers(x, y)
  
  # Compute ICC without outliers
  ic <- icc(cbind(x[!outliers], y[!outliers]), model = "twoway", type = "agreement", unit = "single")
  r <- cor.test(x[!outliers], y[!outliers])
  
  # Specify title and labels
  titl <- sprintf("ICC = %.2f [%.2f %.2f] \nr     = %.2f [%.2f %.2f]",
                  ic$value, ic$lbound, ic$ubound,
                  r$estimate, r$conf.int[1], r$conf.int[2])
  
  # Plot
  plot_ICC(x, y, outliers, labx, laby, titl, colr)
  return(list(icc = ic, r = r, plot = last_plot()))
}


pt1 <- plot_ICC_params(mdata$mu0_2_t1,mdata$mu0_2_t2,expression(paste(mu[2]^(0), " T1")),expression(paste(mu[2]^(0), " T2")),'#f59a14')
print(pt1$plot)

pt2 <- plot_ICC_params(mdata$mu0_3_t1,mdata$mu0_3_t2,expression(paste(mu[3]^(0), " T1")),expression(paste(mu[3]^(0), " T2")),'#f59a14')
print(pt2$plot)

pt3 <- plot_ICC_params(mdata$m_3_t1,mdata$m_3_t2,expression(paste('m'[3], " T1")),expression(paste('m'[3], " T2")),'#f59a14')
print(pt3$plot)

pt4 <- plot_ICC_params(mdata$ka_2_t1,mdata$ka_2_t2,expression(paste(kappa[2], " T1")),expression(paste(kappa[2], " T2")),'#f59a14')
print(pt4$plot)

pt5 <- plot_ICC_params(mdata$om_2_t1,mdata$om_2_t2,expression(paste(omega[2], " T1")),expression(paste(omega[2], " T2")),'#f59a14')
print(pt5$plot)

pt6 <- plot_ICC_params(mdata$ze_t1,mdata$ze_t2,expression(paste(zeta, " T1")),expression(paste(zeta, " T2")),'#f59a14')
print(pt6$plot)

pt7 <- plot_ICC_params(mdata$nu_t1,mdata$nu_t2,expression(paste(nu, " T1")),expression(paste(nu, " T2")),'#f59a14')
print(pt7$plot)


# store to be plotted later in a bar plot
retest <- c(pt1$icc$value,pt2$icc$value,pt3$icc$value,pt4$icc$value,pt5$icc$value,pt6$icc$value,pt7$icc$value)
retelb <- c(pt1$icc$lbound,pt2$icc$lbound,pt3$icc$lbound,pt4$icc$lbound,pt5$icc$lbound,pt6$icc$lbound,pt7$icc$lbound)
reteub <- c(pt1$icc$ubound,pt2$icc$ubound,pt3$icc$ubound,pt4$icc$ubound,pt5$icc$ubound,pt6$icc$ubound,pt7$icc$ubound)

# Compute standard error from confidence intervals
ret_se = (reteub - retelb)/3.92


###########################
# Plot parameter recovery #
###########################

sparams <- read.csv("E:/COMPI/results/ioio/hgf_comp/results_hgf/sim_params.csv")
rparams <- read.csv("E:/COMPI/results/ioio/hgf_comp/results_hgf/rec_params.csv")


pr1 <- plot_ICC_params(sparams$mu0_2,rparams$mu0_2,expression(paste(mu[2]^(0), " true")),expression(paste(mu[2]^(0), " recovered")),'#336799')
print(pr1$plot)

pr2 <- plot_ICC_params(sparams$mu0_3,rparams$mu0_3,expression(paste(mu[3]^(0), " true")),expression(paste(mu[3]^(0), " recovered")),'#336799')
print(pr2$plot)

pr3 <- plot_ICC_params(sparams$m_3,rparams$m_3,expression(paste('m'[3], " true")),expression(paste('m'[3], " recovered")),'#336799')
print(pr3$plot)

pr4 <- plot_ICC_params(sparams$ka_2,rparams$ka_2,expression(paste(kappa[2], " true")),expression(paste(kappa[2], " recovered")),'#336799')
print(pr4$plot)

pr5 <- plot_ICC_params(sparams$om_2,rparams$om_2,expression(paste(omega[2], " true")),expression(paste(omega[2], " recovered")),'#336799')
print(pr5$plot)

pr6 <- plot_ICC_params(sparams$ze,rparams$ze,expression(paste(zeta, " true")),expression(paste(zeta, " recovered")),'#336799')
print(pr6$plot)

pr7 <- plot_ICC_params(sparams$nu,rparams$nu,expression(paste(nu, " true")),expression(paste(nu, " recovered")),'#336799')
print(pr7$plot)


# Learning correlations
bdata = read.csv("E:/COMPI/results/ioio/test_retest/results_behav/sum_behav_measures.csv")

# Define a function for plotting scatter plots and ICC results
plot_r <- function(x,y,labx,laby){

  r  <- cor.test(x,y)

  # Specify title and labels
  if (r$p.value < 0.001){

    titl <- sprintf("r = %.2f; p < 0.001", r$estimate)

  } else {

    titl <- sprintf("r = %.2f; p = %.3f", r$estimate, r$p.value)
  }

  # Specify title and labels
  if (r$p.value < 0.05){
    cl = "red"
  } else {
    cl = "black"
  }

  # plot
  ggplot(data = NULL, aes(x = x, y = y)) +
    geom_point(size=4, alpha = 0.7,color="bisque4") +
    geom_smooth(method=lm, color = "black") +
    theme_minimal() +
    xlab(labx) +
    ylab(laby) +
    theme_set(theme_classic(base_size = 18)) +
    theme(plot.title = element_text(size = 16, hjust = 0.5, color = cl, face = "bold")) +
    ggtitle(titl)
}

plot_r(bdata$AT_total_t2-bdata$AT_total_t1,mdata$mu0_2_t2-mdata$mu0_2_t1,
       expression(paste(Delta, "Total AT")),expression(paste(Delta, mu[2]^(0))))

plot_r(bdata$AT_stable_t2-bdata$AT_stable_t1,mdata$mu0_2_t2-mdata$mu0_2_t1,
       expression(paste(Delta, "Stable AT")),expression(paste(Delta, mu[2]^(0))))

plot_r(bdata$win_stay_t2-bdata$win_stay_t1,mdata$mu0_2_t2-mdata$mu0_2_t1,
       expression(paste(Delta, "Win-stay")),expression(paste(Delta, mu[2]^(0))))

plot_r(bdata$AT_total_t2-bdata$AT_total_t1,mdata$ze_t2-mdata$ze_t1,
       expression(paste(Delta, "Total AT")),expression(paste(Delta, zeta)))

plot_r(bdata$AT_stable_t2-bdata$AT_stable_t1,mdata$ze_t2-mdata$ze_t1,
       expression(paste(Delta, "Stable AT")),expression(paste(Delta, zeta)))

plot_r(bdata$win_stay_t2-bdata$win_stay_t1,mdata$ze_t2-mdata$ze_t1,
       expression(paste(Delta, "Win-stay")),expression(paste(Delta, zeta)))


## Average across multiple seeds ##

rparamss <- read.csv("E:/COMPI/results/ioio/hgf_comp/results_hgf/rec_params_20seeds.csv")

# Initialize a data frame to store ICC values
iccs <- data.frame()

for (i in 1:20) {
  datai <- subset(rparamss, seed == i)
  
  # List of parameter pairs to check
  params_pairs <- list(
    c("mu0_2", "mu0_2"),
    c("mu0_3", "mu0_3"),
    c("m_3", "m_3"),
    c("ka_2", "ka_2"),
    c("om_2", "om_2"),
    c("ze", "ze"),
    c("nu", "nu")
  )
  
  for (j in seq_along(params_pairs)) {
    param_x <- params_pairs[[j]][1]
    param_y <- params_pairs[[j]][2]
    
    x <- datai[[param_x]]
    y <- sparams[[param_y]]
    
    outliers <- detect_outliers(x, y)
    
    # Compute ICC without outliers
    icc_value <- icc(cbind(x[!outliers], y[!outliers]), model = "twoway", type = "agreement", unit = "single")
    
    # Store the ICC value in the data frame
    iccs[i, j] <- icc_value$value
  }
}

recov_mean = colMeans(iccs)
recov_se <- std.error(iccs)


# combine for the plot
lower_se = c(retest-ret_se,recov_mean-recov_se)
upper_se = c(retest+ret_se,recov_mean+recov_se)

# set negative ICC values to 0 - as per interpretation
lower_se[lower_se < 0] <- 0


# Define the desired order of the groups
group_order <- c("mu0_2", "mu0_3", "m3", "ka2", "om2", "ze", "nu")
group_names <- expression(mu[2]^(0),mu[3]^(0),m[3],kappa[2],omega[2],zeta,nu)

rez <- data.frame(
  category = rep(c("Test-retest reliability", "Parameter recovery"), each = 7),
  group = rep(c("mu0_2", "mu0_3", "m3", "ka2", "om2", "ze", "nu"), times = 2),
  ICC = c(retest,recov_mean),
  lower = lower_se,
  upper = upper_se
)

# Create stacked bar plot
ggplot(rez, aes(x = group, y = ICC, fill = category)) +
  #geom_col(position = "stack") +
  scale_fill_manual(values = c("#336799", "#f59a14")) +
  geom_col(position = position_dodge(width = 0.9), width = 0.9) +
  geom_errorbar(aes(ymin = lower, ymax = upper),
                position = position_dodge(width = 0.9),
                width = 0.2) +
  scale_y_continuous(limits = c(0, 1)) +
  scale_x_discrete(limits = group_order, labels = group_names) +
  labs(title = "Parameter recovery vs. \ntest-retest reliability", x = "Parameters", y = "ICC") +
  theme(plot.title = element_text(size = 16)) +
  theme(axis.text.x = element_text(size = 16))


##########################
# Variance decomposition #
##########################


# # Function to calculate variance components and plot
# analyze_variance_components <- function(data, variables, variable_order) {
#   results <- data.frame(Variable=character(), Between_Subjects=numeric(), Within_Subjects=numeric(), Error=numeric(), stringsAsFactors=FALSE)
#   
#   
#   for (var in variables) {
#     # Reshape data for the current variable
#     long_data <- data.frame(
#       Subject = rep(data$ID, 2),
#       Session = factor(rep(c("Test", "Retest"), each = nrow(data))),
#       Value = c(data[[paste0(var, "_t1")]], data[[paste0(var, "_t2")]])
#     )
#     
#     # Fit linear mixed-effects model
#     model <- lmer(Value ~ (1|Subject) + (1|Session), data = long_data)
#     var_cor <- as.data.frame(VarCorr(model))
#     
#     between_subjects <- var_cor[var_cor$grp == "Subject", "vcov"]
#     within_subjects <- var_cor[var_cor$grp == "Session", "vcov"]
#     error <- var_cor[var_cor$grp == "Residual", "vcov"]
#     
#     total_variance <- between_subjects + within_subjects + error
#     results <- rbind(results, data.frame(
#       Variable = var,
#       Between_Subjects = between_subjects / total_variance * 100,
#       Within_Subjects = within_subjects / total_variance * 100,
#       Error = error / total_variance * 100
#     ))
#   }
#   
#   results_melted <- melt(results, id.vars = "Variable", variable.name = "Component", value.name = "Percentage")
#   results_melted$Variable <- factor(results_melted$Variable, levels = variable_order)
#   results_melted$Component <- factor(results_melted$Component, levels = c("Error", "Within_Subjects","Between_Subjects"))
#   
#   
#   ggplot(results_melted, aes(x = Variable, y = Percentage, fill = Component)) +
#     geom_bar(stat = "identity") +
#     scale_x_discrete(limits = variables, labels = group_names) +
#     scale_fill_manual(values = c("Between_Subjects" = "gray20", "Within_Subjects" = "gray50", "Error" = "gray70")) +
#     ylab("% of total variance") +
#     xlab("Parameters") +
#     ggtitle("Variance decomposition for model 2") +
#     theme(plot.title = element_text(size = 16)) +
#     theme(axis.text.x = element_text(size = 16))
# }
# 
# 
# 
# param_names <- c("mu0_2", "mu0_3", "m_3", "ka_2", "om_2", "ze", "nu")
# 
# 
# # Run the analysis and plot the results
# analyze_variance_components(mdata, param_names,param_names)



########################
# Standard HGF results #
########################

mdata = read_excel("E:/COMPI/results/ioio/test_retest/results_hgf/ms1/sum_hgf_s_params.xlsx")


pt1 <- plot_ICC_params(mdata$mu0_2_t1,mdata$mu0_2_t2,expression(paste(mu[2]^(0), " T1")),expression(paste(mu[2]^(0), " T2")),'#f59a14')
print(pt1$plot)

pt2 <- plot_ICC_params(mdata$mu0_3_t1,mdata$mu0_3_t2,expression(paste(mu[3]^(0), " T1")),expression(paste(mu[3]^(0), " T2")),'#f59a14')
print(pt2$plot)

pt4 <- plot_ICC_params(mdata$ka_2_t1,mdata$ka_2_t2,expression(paste(kappa[2], " T1")),expression(paste(kappa[2], " T2")),'#f59a14')
print(pt4$plot)

pt5 <- plot_ICC_params(mdata$om_2_t1,mdata$om_2_t2,expression(paste(omega[2], " T1")),expression(paste(omega[2], " T2")),'#f59a14')
print(pt5$plot)

pt6 <- plot_ICC_params(mdata$ze_t1,mdata$ze_t2,expression(paste(zeta, " T1")),expression(paste(zeta, " T2")),'#f59a14')
print(pt6$plot)

md <- subset(mdata,nu_t1<50) # remove one extreme outlier
pt7 <- plot_ICC_params(md$nu_t1,md$nu_t2,expression(paste(nu, " T1")),expression(paste(nu, " T2")),'#f59a14')
print(pt7$plot)


retest   <- c(pt1$icc$value,pt2$icc$value,pt4$icc$value,pt5$icc$value,pt6$icc$value,pt7$icc$value)
retelb <- c(pt1$icc$lbound,pt2$icc$lbound,pt4$icc$lbound,pt5$icc$lbound,pt6$icc$lbound,pt7$icc$lbound)
reteub <- c(pt1$icc$ubound,pt2$icc$ubound,pt4$icc$ubound,pt5$icc$ubound,pt6$icc$ubound,pt7$icc$ubound)
retse = (reteub - retelb)/3.92


rparamss <- read.csv("E:/COMPI/results/ioio/hgf_comp/results_hgf/rec_params_20seeds_sHGF.csv")
sparams  <- read.csv("E:/COMPI/results/ioio/hgf_comp/results_hgf/sim_params_sHGF.csv")


iccs<- data.frame()
for (i in 1:20){
  datai <- subset(rparamss, seed==i)


  icmu2 <- icc(cbind(datai$mu0_2,sparams$mu0_2), model="twoway", type="agreement",unit="single")
  icmu3 <- icc(cbind(datai$mu0_3,sparams$mu0_3), model="twoway", type="agreement",unit="single")
  ick2  <- icc(cbind(datai$ka_2,sparams$ka_2), model="twoway", type="agreement",unit="single")
  icom2 <- icc(cbind(datai$om_2,sparams$om_2), model="twoway", type="agreement",unit="single")
  icze  <- icc(cbind(datai$ze,sparams$ze), model="twoway", type="agreement",unit="single")
  icnu  <- icc(cbind(datai$nu,sparams$nu), model="twoway", type="agreement",unit="single")

  iccs[i,1:6] <- c(icmu2$value,icmu3$value,ick2$value,icom2$value,
                   icze$value,icnu$value)
}

recov_mean <- colMeans(iccs)
recov_se   <- std.error(iccs)

# combine for the plot
lower_se <- c(retest - retse, recov_mean - recov_se)
upper_se <- c(retest + retse, recov_mean + recov_se)

# set negative ICC values to 0 - as per interpretation
lower_se[lower_se < 0] <- 0


# Define the desired order of the groups
group_order <- c("mu0_2", "mu0_3", "ka2", "om2", "ze", "nu")
group_names <- expression(mu[2]^(0),mu[3]^(0),kappa[2],omega[2],zeta,nu)

rez <- data.frame(
  category = rep(c("Test-retest reliability", "Parameter recovery"), each = 6),
  group = rep(c("mu0_2", "mu0_3", "ka2", "om2", "ze", "nu"), times = 2),
  ICC = c(retest,recov_mean),
  lower = lower_se,
  upper = upper_se
)

# Create stacked bar plot
ggplot(rez, aes(x = group, y = ICC, fill = category)) +
  #geom_col(position = "stack") +
  scale_fill_manual(values = c("#336799", "#f59a14")) +
  geom_col(position = position_dodge(width = 0.9), width = 0.9) +
  geom_errorbar(aes(ymin = lower, ymax = upper),
                position = position_dodge(width = 0.9),
                width = 0.2) +
  scale_y_continuous(limits = c(0, 1)) +
  scale_x_discrete(limits = group_order, labels = group_names) +
  labs(title = "Parameter recovery vs. test-retest reliability of model 1", x = "Parameters", y = "ICC") +
  theme(plot.title = element_text(size = 16)) +
  theme(axis.text.x = element_text(size = 16))
icca1 <- icc(cbind(x1,x2), model="twoway", type="agreement",unit="single")


# ####### Additional reduced models: ICC results #######
# 
# # hgfmr 1
# 
# 
# mdata = read_excel("E:/COMPI/results/ioio/test_retest/results_hgf/ms1/sum_hgf_1_params.xlsx")
# 
# 
# pt2 <- plot_ICC_params(mdata$mu0_3_t1,mdata$mu0_3_t2,expression(paste(mu[3]^(0), " T1")),expression(paste(mu[3]^(0), " T2")),'#f59a14')
# print(pt2$plot)
# 
# pt3 <- plot_ICC_params(mdata$m_3_t1,mdata$m_3_t2,expression(paste('m'[3], " T1")),expression(paste('m'[3], " T2")),'#f59a14')
# print(pt3$plot)
# 
# pt4 <- plot_ICC_params(mdata$ka_2_t1,mdata$ka_2_t2,expression(paste(kappa[2], " T1")),expression(paste(kappa[2], " T2")),'#f59a14')
# print(pt4$plot)
# 
# pt5 <- plot_ICC_params(mdata$om_2_t1,mdata$om_2_t2,expression(paste(omega[2], " T1")),expression(paste(omega[2], " T2")),'#f59a14')
# print(pt5$plot)
# 
# pt6 <- plot_ICC_params(mdata$ze_t1,mdata$ze_t2,expression(paste(zeta, " T1")),expression(paste(zeta, " T2")),'#f59a14')
# print(pt6$plot)
# 
# pt7 <- plot_ICC_params(mdata$nu_t1,mdata$nu_t2,expression(paste(nu, " T1")),expression(paste(nu, " T2")),'#f59a14')
# print(pt7$plot)
# 
# 
# # store to be plotted later in a bar plot
# retest <- c(pt2$icc$value,pt3$icc$value,pt4$icc$value,pt5$icc$value,pt6$icc$value,pt7$icc$value)
# retelb <- c(pt2$icc$lbound,pt3$icc$lbound,pt4$icc$lbound,pt5$icc$lbound,pt6$icc$lbound,pt7$icc$lbound)
# reteub <- c(pt2$icc$ubound,pt3$icc$ubound,pt4$icc$ubound,pt5$icc$ubound,pt6$icc$ubound,pt7$icc$ubound)
# 
# # Compute standard error from confidence intervals
# ret_se = (reteub - retelb)/3.92
# 
# 
# rparamss <- read.csv("E:/COMPI/results/ioio/hgf_comp/results_hgf/rec_params_20seeds_hgfmr_1.csv")
# sparams  <- read.csv("E:/COMPI/results/ioio/hgf_comp/results_hgf/sim_params_hgfmr_1.csv")
# 
# # Initialize a data frame to store ICC values
# iccs <- data.frame()
# 
# for (i in 1:20) {
#   datai <- subset(rparamss, seed == i)
#   
#   # List of parameter pairs to check
#   params_pairs <- list(
#     c("mu0_3", "mu0_3"),
#     c("m_3", "m_3"),
#     c("ka_2", "ka_2"),
#     c("om_2", "om_2"),
#     c("ze", "ze"),
#     c("nu", "nu")
#   )
#   
#   for (j in seq_along(params_pairs)) {
#     param_x <- params_pairs[[j]][1]
#     param_y <- params_pairs[[j]][2]
#     
#     x <- datai[[param_x]]
#     y <- sparams[[param_y]]
#     
#     outliers <- detect_outliers(x, y)
#     
#     # Compute ICC without outliers
#     icc_value <- icc(cbind(x[!outliers], y[!outliers]), model = "twoway", type = "agreement", unit = "single")
#     
#     # Store the ICC value in the data frame
#     iccs[i, j] <- icc_value$value
#   }
# }
# 
# recov_mean = colMeans(iccs)
# recov_se <- std.error(iccs)
# 
# 
# # combine for the plot
# lower_se = c(retest-ret_se,recov_mean-recov_se)
# upper_se = c(retest+ret_se,recov_mean+recov_se)
# 
# # set negative ICC values to 0 - as per interpretation
# lower_se[lower_se < 0] <- 0
# 
# 
# # Define the desired order of the groups
# group_order <- c("mu0_3", "m3", "ka2", "om2", "ze", "nu")
# group_names <- expression(mu[3]^(0),m[3],kappa[2],omega[2],zeta,nu)
# 
# rez <- data.frame(
#   category = rep(c("Test-retest reliability", "Parameter recovery"), each = 6),
#   group = rep(c("mu0_3", "m3", "ka2", "om2", "ze", "nu"), times = 2),
#   ICC = c(retest,recov_mean),
#   lower = lower_se,
#   upper = upper_se
# )
# 
# # Create stacked bar plot
# ggplot(rez, aes(x = group, y = ICC, fill = category)) +
#   #geom_col(position = "stack") +
#   scale_fill_manual(values = c("#336799", "#f59a14")) +
#   geom_col(position = position_dodge(width = 0.9), width = 0.9) +
#   geom_errorbar(aes(ymin = lower, ymax = upper),
#                 position = position_dodge(width = 0.9),
#                 width = 0.2) +
#   scale_y_continuous(limits = c(0, 1)) +
#   scale_x_discrete(limits = group_order, labels = group_names) +
#   labs(title = "Parameter recovery vs. \ntest-retest reliability", x = "Parameters", y = "ICC") +
#   theme(plot.title = element_text(size = 16)) +
#   theme(axis.text.x = element_text(size = 16))
# 
# 
# # hgfmr 2
# 
# 
# mdata = read_excel("E:/COMPI/results/ioio/test_retest/results_hgf/ms1/sum_hgf_2_params.xlsx")
# 
# pt1 <- plot_ICC_params(mdata$mu0_2_t1,mdata$mu0_2_t2,expression(paste(mu[2]^(0), " T1")),expression(paste(mu[2]^(0), " T2")),'#f59a14')
# print(pt1$plot)
# 
# pt2 <- plot_ICC_params(mdata$mu0_3_t1,mdata$mu0_3_t2,expression(paste(mu[3]^(0), " T1")),expression(paste(mu[3]^(0), " T2")),'#f59a14')
# print(pt2$plot)
# 
# pt3 <- plot_ICC_params(mdata$m_3_t1,mdata$m_3_t2,expression(paste('m'[3], " T1")),expression(paste('m'[3], " T2")),'#f59a14')
# print(pt3$plot)
# 
# pt5 <- plot_ICC_params(mdata$om_2_t1,mdata$om_2_t2,expression(paste(omega[2], " T1")),expression(paste(omega[2], " T2")),'#f59a14')
# print(pt5$plot)
# 
# pt6 <- plot_ICC_params(mdata$ze_t1,mdata$ze_t2,expression(paste(zeta, " T1")),expression(paste(zeta, " T2")),'#f59a14')
# print(pt6$plot)
# 
# pt7 <- plot_ICC_params(mdata$nu_t1,mdata$nu_t2,expression(paste(nu, " T1")),expression(paste(nu, " T2")),'#f59a14')
# print(pt7$plot)
# 
# 
# # store to be plotted later in a bar plot
# retest <- c(pt1$icc$value,pt2$icc$value,pt3$icc$value,pt5$icc$value,pt6$icc$value,pt7$icc$value)
# retelb <- c(pt1$icc$lbound,pt2$icc$lbound,pt3$icc$lbound,pt5$icc$lbound,pt6$icc$lbound,pt7$icc$lbound)
# reteub <- c(pt1$icc$ubound,pt2$icc$ubound,pt3$icc$ubound,pt5$icc$ubound,pt6$icc$ubound,pt7$icc$ubound)
# 
# # Compute standard error from confidence intervals
# ret_se = (reteub - retelb)/3.92
# 
# 
# rparamss <- read.csv("E:/COMPI/results/ioio/hgf_comp/results_hgf/rec_params_20seeds_hgfmr_2.csv")
# sparams  <- read.csv("E:/COMPI/results/ioio/hgf_comp/results_hgf/sim_params_hgfmr_2.csv")
# 
# # Initialize a data frame to store ICC values
# iccs <- data.frame()
# 
# for (i in 1:20) {
#   datai <- subset(rparamss, seed == i)
#   
#   # List of parameter pairs to check
#   params_pairs <- list(
#     c("mu0_2", "mu0_2"),
#     c("mu0_3", "mu0_3"),
#     c("m_3", "m_3"),
#     c("om_2", "om_2"),
#     c("ze", "ze"),
#     c("nu", "nu")
#   )
#   
#   for (j in seq_along(params_pairs)) {
#     param_x <- params_pairs[[j]][1]
#     param_y <- params_pairs[[j]][2]
#     
#     x <- datai[[param_x]]
#     y <- sparams[[param_y]]
#     
#     outliers <- detect_outliers(x, y)
#     
#     # Compute ICC without outliers
#     icc_value <- icc(cbind(x[!outliers], y[!outliers]), model = "twoway", type = "agreement", unit = "single")
#     
#     # Store the ICC value in the data frame
#     iccs[i, j] <- icc_value$value
#   }
# }
# 
# recov_mean = colMeans(iccs)
# recov_se <- std.error(iccs)
# 
# 
# # combine for the plot
# lower_se = c(retest-ret_se,recov_mean-recov_se)
# upper_se = c(retest+ret_se,recov_mean+recov_se)
# 
# # set negative ICC values to 0 - as per interpretation
# lower_se[lower_se < 0] <- 0
# 
# 
# # Define the desired order of the groups
# group_order <- c("mu0_2", "mu0_3","m3", "om2", "ze", "nu")
# group_names <- expression(mu[2]^(0),mu[3]^(0),m[3],omega[2],zeta,nu)
# 
# rez <- data.frame(
#   category = rep(c("Test-retest reliability", "Parameter recovery"), each = 6),
#   group = rep(c("mu0_2", "mu0_3","m3", "om2", "ze", "nu"), times = 2),
#   ICC = c(retest,recov_mean),
#   lower = lower_se,
#   upper = upper_se
# )
# 
# # Create stacked bar plot
# ggplot(rez, aes(x = group, y = ICC, fill = category)) +
#   #geom_col(position = "stack") +
#   scale_fill_manual(values = c("#336799", "#f59a14")) +
#   geom_col(position = position_dodge(width = 0.9), width = 0.9) +
#   geom_errorbar(aes(ymin = lower, ymax = upper),
#                 position = position_dodge(width = 0.9),
#                 width = 0.2) +
#   scale_y_continuous(limits = c(0, 1)) +
#   scale_x_discrete(limits = group_order, labels = group_names) +
#   labs(title = "Parameter recovery vs. \ntest-retest reliability", x = "Parameters", y = "ICC") +
#   theme(plot.title = element_text(size = 16)) +
#   theme(axis.text.x = element_text(size = 16))
# 
# 
# # hgfmr 3
# 
# mdata = read_excel("E:/COMPI/results/ioio/test_retest/results_hgf/ms1/sum_hgf_3_params.xlsx")
# 
# pt2 <- plot_ICC_params(mdata$mu0_3_t1,mdata$mu0_3_t2,expression(paste(mu[3]^(0), " T1")),expression(paste(mu[3]^(0), " T2")),'#f59a14')
# print(pt2$plot)
# 
# pt3 <- plot_ICC_params(mdata$m_3_t1,mdata$m_3_t2,expression(paste('m'[3], " T1")),expression(paste('m'[3], " T2")),'#f59a14')
# print(pt3$plot)
# 
# pt5 <- plot_ICC_params(mdata$om_2_t1,mdata$om_2_t2,expression(paste(omega[2], " T1")),expression(paste(omega[2], " T2")),'#f59a14')
# print(pt5$plot)
# 
# pt6 <- plot_ICC_params(mdata$ze_t1,mdata$ze_t2,expression(paste(zeta, " T1")),expression(paste(zeta, " T2")),'#f59a14')
# print(pt6$plot)
# 
# pt7 <- plot_ICC_params(mdata$nu_t1,mdata$nu_t2,expression(paste(nu, " T1")),expression(paste(nu, " T2")),'#f59a14')
# print(pt7$plot)
# 
# 
# # store to be plotted later in a bar plot
# retest <- c(pt2$icc$value,pt3$icc$value,pt5$icc$value,pt6$icc$value,pt7$icc$value)
# retelb <- c(pt2$icc$lbound,pt3$icc$lbound,pt5$icc$lbound,pt6$icc$lbound,pt7$icc$lbound)
# reteub <- c(pt2$icc$ubound,pt3$icc$ubound,pt5$icc$ubound,pt6$icc$ubound,pt7$icc$ubound)
# 
# # Compute standard error from confidence intervals
# ret_se = (reteub - retelb)/3.92
# 
# 
# rparamss <- read.csv("E:/COMPI/results/ioio/hgf_comp/results_hgf/rec_params_20seeds_hgfmr_3.csv")
# sparams  <- read.csv("E:/COMPI/results/ioio/hgf_comp/results_hgf/sim_params_hgfmr_3.csv")
# 
# # Initialize a data frame to store ICC values
# iccs <- data.frame()
# 
# for (i in 1:20) {
#   datai <- subset(rparamss, seed == i)
#   
#   # List of parameter pairs to check
#   params_pairs <- list(
#     c("mu0_3", "mu0_3"),
#     c("m_3", "m_3"),
#     c("om_2", "om_2"),
#     c("ze", "ze"),
#     c("nu", "nu")
#   )
#   
#   for (j in seq_along(params_pairs)) {
#     param_x <- params_pairs[[j]][1]
#     param_y <- params_pairs[[j]][2]
#     
#     x <- datai[[param_x]]
#     y <- sparams[[param_y]]
#     
#     outliers <- detect_outliers(x, y)
#     
#     # Compute ICC without outliers
#     icc_value <- icc(cbind(x[!outliers], y[!outliers]), model = "twoway", type = "agreement", unit = "single")
#     
#     # Store the ICC value in the data frame
#     iccs[i, j] <- icc_value$value
#   }
# }
# 
# recov_mean = colMeans(iccs)
# recov_se <- std.error(iccs)
# 
# 
# # combine for the plot
# lower_se = c(retest-ret_se,recov_mean-recov_se)
# upper_se = c(retest+ret_se,recov_mean+recov_se)
# 
# # set negative ICC values to 0 - as per interpretation
# lower_se[lower_se < 0] <- 0
# 
# 
# # Define the desired order of the groups
# group_order <- c("mu0_3","m3", "om2", "ze", "nu")
# group_names <- expression(mu[3]^(0),m[3],omega[2],zeta,nu)
# 
# rez <- data.frame(
#   category = rep(c("Test-retest reliability", "Parameter recovery"), each = 5),
#   group = rep(c("mu0_3","m3", "om2", "ze", "nu"), times = 2),
#   ICC = c(retest,recov_mean),
#   lower = lower_se,
#   upper = upper_se
# )
# 
# # Create stacked bar plot
# ggplot(rez, aes(x = group, y = ICC, fill = category)) +
#   #geom_col(position = "stack") +
#   scale_fill_manual(values = c("#336799", "#f59a14")) +
#   geom_col(position = position_dodge(width = 0.9), width = 0.9) +
#   geom_errorbar(aes(ymin = lower, ymax = upper),
#                 position = position_dodge(width = 0.9),
#                 width = 0.2) +
#   scale_y_continuous(limits = c(0, 1)) +
#   scale_x_discrete(limits = group_order, labels = group_names) +
#   labs(title = "Parameter recovery vs. \ntest-retest reliability", x = "Parameters", y = "ICC") +
#   theme(plot.title = element_text(size = 16)) +
#   theme(axis.text.x = element_text(size = 16))
# 
# 
# # hgfmr 4
# 
# mdata = read_excel("E:/COMPI/results/ioio/test_retest/results_hgf/ms1/sum_hgf_4_params.xlsx")
# 
# pt3 <- plot_ICC_params(mdata$m_3_t1,mdata$m_3_t2,expression(paste('m'[3], " T1")),expression(paste('m'[3], " T2")),'#f59a14')
# print(pt3$plot)
# 
# pt5 <- plot_ICC_params(mdata$om_2_t1,mdata$om_2_t2,expression(paste(omega[2], " T1")),expression(paste(omega[2], " T2")),'#f59a14')
# print(pt5$plot)
# 
# pt6 <- plot_ICC_params(mdata$ze_t1,mdata$ze_t2,expression(paste(zeta, " T1")),expression(paste(zeta, " T2")),'#f59a14')
# print(pt6$plot)
# 
# pt7 <- plot_ICC_params(mdata$nu_t1,mdata$nu_t2,expression(paste(nu, " T1")),expression(paste(nu, " T2")),'#f59a14')
# print(pt7$plot)
# 
# 
# # store to be plotted later in a bar plot
# retest <- c(pt3$icc$value,pt5$icc$value,pt6$icc$value,pt7$icc$value)
# retelb <- c(pt3$icc$lbound,pt5$icc$lbound,pt6$icc$lbound,pt7$icc$lbound)
# reteub <- c(pt3$icc$ubound,pt5$icc$ubound,pt6$icc$ubound,pt7$icc$ubound)
# 
# # Compute standard error from confidence intervals
# ret_se = (reteub - retelb)/3.92
# 
# 
# rparamss <- read.csv("E:/COMPI/results/ioio/hgf_comp/results_hgf/rec_params_20seeds_hgfmr_4.csv")
# sparams  <- read.csv("E:/COMPI/results/ioio/hgf_comp/results_hgf/sim_params_hgfmr_4.csv")
# 
# # Initialize a data frame to store ICC values
# iccs <- data.frame()
# 
# for (i in 1:20) {
#   datai <- subset(rparamss, seed == i)
#   
#   # List of parameter pairs to check
#   params_pairs <- list(
#     c("m_3", "m_3"),
#     c("om_2", "om_2"),
#     c("ze", "ze"),
#     c("nu", "nu")
#   )
#   
#   for (j in seq_along(params_pairs)) {
#     param_x <- params_pairs[[j]][1]
#     param_y <- params_pairs[[j]][2]
#     
#     x <- datai[[param_x]]
#     y <- sparams[[param_y]]
#     
#     outliers <- detect_outliers(x, y)
#     
#     # Compute ICC without outliers
#     icc_value <- icc(cbind(x[!outliers], y[!outliers]), model = "twoway", type = "agreement", unit = "single")
#     
#     # Store the ICC value in the data frame
#     iccs[i, j] <- icc_value$value
#   }
# }
# 
# recov_mean = colMeans(iccs)
# recov_se <- std.error(iccs)
# 
# 
# # combine for the plot
# lower_se = c(retest-ret_se,recov_mean-recov_se)
# upper_se = c(retest+ret_se,recov_mean+recov_se)
# 
# # set negative ICC values to 0 - as per interpretation
# lower_se[lower_se < 0] <- 0
# 
# 
# # Define the desired order of the groups
# group_order <- c("m3", "om2", "ze", "nu")
# group_names <- expression(m[3],omega[2],zeta,nu)
# 
# rez <- data.frame(
#   category = rep(c("Test-retest reliability", "Parameter recovery"), each = 4),
#   group = rep(c("m3", "om2", "ze", "nu"), times = 2),
#   ICC = c(retest,recov_mean),
#   lower = lower_se,
#   upper = upper_se
# )
# 
# # Create stacked bar plot
# ggplot(rez, aes(x = group, y = ICC, fill = category)) +
#   #geom_col(position = "stack") +
#   scale_fill_manual(values = c("#336799", "#f59a14")) +
#   geom_col(position = position_dodge(width = 0.9), width = 0.9) +
#   geom_errorbar(aes(ymin = lower, ymax = upper),
#                 position = position_dodge(width = 0.9),
#                 width = 0.2) +
#   scale_y_continuous(limits = c(0, 1)) +
#   scale_x_discrete(limits = group_order, labels = group_names) +
#   labs(title = "Parameter recovery vs. \ntest-retest reliability", x = "Parameters", y = "ICC") +
#   theme(plot.title = element_text(size = 16)) +
#   theme(axis.text.x = element_text(size = 16))
# 
# 
# 
# ## Obsolete: hierarchical analysis for behavioral measures 
# ## (something is off with two measures - feel free to fix it)
# 
# # Define a function for plotting all ICC results together
# plot_ICC_all <- function(data,labx,laby,titl,icc_m){
# 
#   # first. compute ICC for all estimates
#   ic1 = icc(cbind(data[ ,1],data[ ,2]),model = "twoway",type="agreement",unit="single")
#   ic2 = icc(cbind(data[ ,5],data[ ,6]),model = "twoway",type="agreement",unit="single")
#   ic3 = icc(cbind(data[ ,9],data[ ,10]),model = "twoway",type="agreement",unit="single")
# 
#   xylim <- range(data[,c(1,2,5,6,9,10)])
# 
#   ggplot(data = data) +
#     geom_abline(intercept = 0, slope = 1,  linetype = "dashed", size = 1) +
#     scale_x_continuous(limits = xylim) +
#     scale_y_continuous(limits = xylim) +
#     geom_point(aes(data[ ,1],data[ ,2],color='grey'), size = 3) +
#     geom_smooth(aes(data[ ,1],data[ ,2]),color='grey',method=lm,se=F,size=1.2) +
#     geom_point(aes(data[ ,5],data[ ,6],color='skyblue2'),  size = 3)+
#     geom_smooth(aes(data[ ,5],data[ ,6]),color='skyblue2',method=lm,se=F,size=1.2)+
#     geom_point(aes(data[ ,9],data[ ,10], color="palevioletred"),  size = 3) +
#     geom_smooth(aes(data[ ,9],data[ ,10]),color='palevioletred',method=lm,se=F,size=1.2) +
# 
#     labs(title = titl, x=labx, y=laby) +
#     theme(text=element_text(family="Futura Bk BT"),plot.title = element_text(hjust = 0.5,face = "bold"),
#           panel.background = element_blank(), axis.line = element_line(colour = "black", size=0.2),
#           legend.position = c(0.30, 0.85), legend.background=element_blank(), legend.key=element_rect(color=NA, fill=NA))+
#     scale_color_identity(name="",breaks = c("grey", "skyblue2", "palevioletred"),
#                          labels = c(paste("Non-hierarchical:\nICC(A,1)=",
#                                           round(ic1$value,digits=2),"[", round(ic1$lbound,digits=2),round(ic1$ubound,digits=2),"]"),
#                                     paste("Hierarchical:\nICC(A,1)=",
#                                           round(ic2$value,digits=2),"[", round(ic2$lbound,digits=2),round(ic2$ubound,digits=2),"]"),
#                                     paste("Hierarchical + joint:\nICC(A,1)=",
#                                           round(ic3$value,digits=2),"[", round(ic3$lbound,digits=2),round(ic3$ubound,digits=2),"]",
#                                           "\nmodel-derived r =", icc_m)),
#                          guide = "legend") +
#     theme(legend.text = element_text(size = 12, face = "bold")) +
#     guides(size=F, alpha=T)
#   #ggsave(filename = paste("C:/Users/karve/Dropbox/Postdoc/Studies/COMPI/code/R/figs/", titl, ".png"), width = 12, height = 12, units = 'cm')
# }

# # Define a function for computing ICC non-hierarchically for any variable
# hier_analysis <- function(data,column,labx,laby,titl){
# 
#   # non-hierarchical estimation (for comparison purposes)
#   x1 <- vector(); sx1 <- vector();
#   x2 <- vector(); sx2 <- vector();
#   ids = unique(data$subID);
#   for (i in 1:length(ids)){
#     x1[i]  = mean(subset(data, session==1 & subID==ids[i])[[column]] == 1,na.rm=T)
#     x2[i]  = mean(subset(data, session==2 & subID==ids[i])[[column]] == 1,na.rm=T)
#     sx1[i] = std.error(subset(data, session==1 & subID==ids[i])[[column]] == 1,na.rm=T)
#     sx2[i] = std.error(subset(data, session==2 & subID==ids[i])[[column]] == 1,na.rm=T)
#   };
# 
#   # Hierarchical estimation with the sessions treated separately
#   fh = as.formula(paste(column, "~ 1 + (1|subID)"))
# 
#   # session 1
#   hf1  = glmer(fh, data=subset(data, session == 1), family=binomial,control=glmerControl(optimizer="bobyqa", optCtrl=list(maxfun=1e5)), na.action = na.exclude)
#   #temp <- ggpredict(hf1, terms=c("subID[all]"), type="re")
#   #xh1  = temp$predicted
#   xh1  = predict(hf1, newdata = filter(data, session == 1) %>% distinct(subID), type = "response")
#   sxh1 = as.vector(unlist(se.ranef(hf1)))
# 
#   # session 2
#   hf2  = glmer(fh, data=subset(data, session == 2), family=binomial,control=glmerControl(optimizer="bobyqa", optCtrl=list(maxfun=1e5)), na.action = na.exclude)
#   #temp <- ggpredict(hf2, terms=c("subID[all]"), type="re")
#   #xh2  = temp$predicted
#   xh2  = predict(hf2, newdata = filter(data, session == 2) %>% distinct(subID), type = "response")
#   sxh2  = as.vector(unlist(se.ranef(hf2)))
# 
#   # Same, but the sessions are treated jointly (interaction between session and subID)
#   fH = as.formula(paste(column, "~ session + (1|subID/session)"))
#   HF = glmer(fH, data=data, family=binomial,control=glmerControl(optimizer="bobyqa", optCtrl=list(maxfun=1e5)), na.action = na.exclude)
# 
#   # predicted values & standard errors
#   temp <- predict(HF, newdata = data %>% distinct(subID, session), type = "response")
#   #temp <- ggpredict(HF, terms=c("subID [all]", "session [all]"), type="re")
#   #xH1  = temp[temp$group==1,]$predicted
#   #xH2  = temp[temp$group==2,]$predicted
#   xH1 = temp[c(TRUE,FALSE)]
#   xH2 = temp[c(FALSE,TRUE)]
#   sxH1 = as.vector(unlist(se.ranef(HF)[2]))
#   sxH2 = as.vector(unlist(se.ranef(HF)[2]))
# 
#   var_int <- get_variance_intercept(HF)
#   icc_m = round(var_int[2]/(var_int[2] + var_int[1]),digits = 2)
# 
#   cdata = data.frame(x1,x2,sx1,sx2,xh1,xh2,sxh1,sxh2,xH1,xH2,sxH1,sxH2)
#   plot_ICC_all(cdata,labx,laby,titl,icc_m)
# 
# }
# 
# hier_analysis(xdata,"correct","Total Acc T1","Total Acc T2","Total Acc")
# hier_analysis(xdata,"choice","Total AT T1","Total AT T2","Total AT")
# hier_analysis(xdata,"choice_stable","Stable AT T1","Stable AT T2","Stable AT")
# hier_analysis(xdata,"choice_volatile","Volatile AT T1","Volatile AT T2","Volatile AT")
# hier_analysis(xdata,"win_stay","Win-stay AT T1","Win-stay AT T2","Win-stay AT")
# hier_analysis(xdata,"lose_switch","Lose-switch AT T1","Lose-switch AT T2","Lose-switch AT")
# 
# # note, need to make the function non-binomial for this to run
# #hier_analysis(x1data,"RT","RT T1","RT T2","RT")



