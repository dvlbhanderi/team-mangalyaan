####################################
# Experiment on Student dataset for two Portuguese schools
# From UCI Machine Learning Repo. (https://archive.ics.uci.edu/ml/datasets/student+performance)
# Main paper: https://arxiv.org/pdf/1810.02003.pdf
# Code demonstrating how one could equalize the AP of Female and
# Male defendants and vice-versa
####################################

library(grid)
library(gridExtra)
library(dplyr)
library(ggplot2)

# hyperparameter for plots
cex_factor = 1.6

# Load and clean the data selecting for the desired fields
raw_data <- read.csv("./student-mat2.csv.txt")
df <- dplyr::select(raw_data, school, sex, age,address,famsize,Pstatus,Medu,Fedu,Mjob,Fjob,reason,guardian,traveltime,studytime,failures,schoolsup,famsup,paid,activities,nursery,higher,internet,romantic,famrel,freetime,goout,Dalc,Walc,health,absences,G1,G2,G3, is_pass)

df_females = filter(df,sex=="F")
df_males = filter(df,sex=="M")
num_females = nrow(df_females)
num_males = nrow(df_males)

# Compute frequency distributions for COMPAS scores for both the groups
female_score_freq = 1:20
male_score_freq = 1:20
female_score_pdf = 1:20
male_score_pdf = 1:20
for (i in seq(1,20,by=1)){
  female_score_freq[i] = nrow(filter(df,sex=="F", G3==i))
  female_score_pdf[i] = female_score_freq[i]/num_females
  male_score_freq[i] = nrow(filter(df,sex=="M", G3==i))
  male_score_pdf[i] = male_score_freq[i]/num_males
}


# Defer on African-Americans so as to convert their AP into that of Caucasians
ratio_pdfs = female_score_pdf/male_score_pdf
delta = 1 - min(ratio_pdfs)
q_females = 1 - (1-delta)/ratio_pdfs
female_deferrals = female_score_freq*q_females
female_deferrals_frac = female_score_pdf*q_females
female_nondeferrals_frac = female_score_pdf*(1-q_females)

# Defer on Caucasians so as to convert their AP into that of African-Americans
ratio_pdfs = male_score_pdf/female_score_pdf
delta = 1 - min(ratio_pdfs)
q_males = 1 - (1-delta)/ratio_pdfs
male_deferrals = male_score_freq*q_males
male_deferrals_frac = male_score_pdf*q_males
male_nondeferrals_frac = male_score_pdf*(1-q_males)

# Pick colors to be used in the barplots
col_female = "gray38"
col_female_deferral = "gray70"
col_male = "orange2"
col_male_deferral = "moccasin"

# Generate barplot to display the deferrals of African-Americans to convert
# their AP into that of Caucasians
dat1 = rbind(female_nondeferrals_frac,female_deferrals_frac)
pdf('female_to_male.pdf')
barplot(dat1, beside=F, main=paste("Converting Female AP \ninto Male AP.",
                                    "Deferral rate = 60%"),xlab="G3", ylab="",
        ylim=c(0,0.15), names.arg=1:20, space=c(0.5,0.5),
        col=c(col_female,col_female_deferral),
        cex.names = cex_factor, cex.lab=cex_factor, cex.axis=cex_factor, cex.main=cex_factor)
barplot(dat1,space=c(0.5,0.5),add=T,angle=c(0,45), density=c(0,20),
        cex.axis= cex_factor)
title(ylab="Probability Density", line=2.85, cex.lab=cex_factor)
legend("topright",
        legend=c("Non deferrals","Deferrals"),
        fill = c(col_female,col_female_deferral), cex=cex_factor)
legend("topright",
        legend=c("Non deferrals","Deferrals"),
        density = c(0,20), fill=c("male","male"),cex=cex_factor)
abline(h=0)
dev.off()

# Printing some statistics
total_female_deferrals = Reduce(f="+",x = female_deferrals,accumulate=F)
cat("Total female deferrals: ",total_female_deferrals,"\n")
cat("Fraction of female deferrals: ", total_female_deferrals/num_females,"\n")


# Generate barplot to display the deferrals of Caucasians to convert
# their AP into that of African-Americans
dat2 = rbind(male_nondeferrals_frac,male_deferrals_frac)
pdf('male_to_female.pdf')
barplot(dat2, beside=F,main=paste("Converting Male AP into \nFemale AP.",
                                    "Deferral rate = 67%"),xlab="G3",
        ylab="", ylim=c(0,0.3), names.arg=1:10, space=c(0.5,0.5),
        col=c(col_male,col_male_deferral),
        cex.names = cex_factor, cex.lab=cex_factor, cex.axis=cex_factor, cex.main=cex_factor)
barplot(dat2,space=c(0.5,0.5),add=T,angle=c(0,45), density=c(0,20), col=c("male","female"),
        cex.axis=cex_factor)
title(ylab="Probability Density", line=2.85, cex.lab=cex_factor)
legend("topright",
        legend=c("Non deferrals","Deferrals"),
        fill = c(col_male,col_male_deferral), cex=cex_factor)
legend("topright",
        legend=c("Non deferrals","Deferrals"),
        density = c(0,20),fill=c("male","female"), cex=cex_factor)
abline(h=0)
dev.off()

# Printing some statistics
total_male_deferrals = Reduce(f="+",x = male_deferrals,accumulate=F)
cat("Total male deferrals: ",total_male_deferrals,"\n")
cat("Fraction of male deferrals: ",total_male_deferrals/num_males,"\n")
