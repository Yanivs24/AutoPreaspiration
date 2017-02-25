data=Jon

summary(data)

#dataF = subset of the fortis plosives only
#dataFF = fortis plosives, durational values of PRE excluding zero
#dataG = no zero values



##############
# IS PRE-ASPIRATION NORMALLY DISTRIBUTED (excluding lenis plosives)?
#############

#this produces the histogram without zero values (it's even more skewed with zeroes)
hist(data$preasp_dur_ms[data$Ctype=="fortis" & data$preasp_dur_ms>0], breaks=30, main="Distribution of pre-aspiration duration in ms", xlab="duration", ylab="frequency", cex.lab=1.7, cex.main=2)

#normality test without zero values
shapiro.test(data$preasp_dur_ms[data$Ctype=="fortis" & data$preasp_dur_ms>0])

#normality test with zero values
shapiro.test(data$preasp_dur_ms[data$Ctype=="fortis"])



##############
# IS BREATHINESS NORMALLY DISTRIBUTED?
#############

#this produces the histogram without zero values (it's even more skewed with zeroes)

hist(data$breath_dur_ms[data$Ctype=="fortis" & data$breath_dur_ms>0], breaks=30, main="Distribution of breathiness duration in ms", xlab="duration", ylab="frequency", cex.lab=1.7, cex.main=2)

#normality test without zero values
shapiro.test(data$breath_dur_ms[data$Ctype=="fortis" & data$breath_dur_ms>0])

#normality test with zero values
shapiro.test(data$breath_dur_ms[data$Ctype=="fortis"])

summary(data$next_cons)



####################
# frequency of occurrence (big pre = br, pre, br+pre)
####################

summary(data$PRE[data$Ctype=="fortis"])
plot(data$PRE[data$Ctype=="fortis"])

609/6.98

plot(data$next_cons[data$Ctype=="fortis"],data$PRE[data$Ctype=="fortis"])

par(mfrow=c(1,2))
attach(data)
plot(data$gender[data$Welsh=="L1" & data$Ctype=="fortis"],data$PRE[data$Welsh=="L1" & data$Ctype=="fortis"], col=c("mediumpurple1","mediumaquamarine"), main="Welsh home language", xlab="gender")
plot(data$gender[data$Welsh=="L2" & data$Ctype=="fortis"],data$PRE[data$Welsh=="L2" & data$Ctype=="fortis"], col=c("mediumpurple1","mediumaquamarine"), main="English home language", xlab="gender")

plot(data$next_cons,)

summary(data$PRE[data$Welsh=="L1" & data$gender=="M"])
summary(data$PRE[data$Welsh=="L2" & data$gender=="M"])

#categorical dependent variable
library(lme4)

data=Jon
dataF <- data[data$Ctype=="fortis", ]

#/p/ contrasted to /t/, /p/ contrasted to /k/, because /p/ is the first alphabetically (1p)
c=glmer(PRE ~ vowel + next_cons + gender * Welsh + (1|speaker) + (1|lexeme), data=dataF, family="binomial") 
summary(c)

#this is a function so that we can use forward reference coding (p vs t, t vs k - successive comparisons)
forward.code <- function(variable){
  if(!is.factor(variable)) 
    stop("The provided variable must be a factor variable")
  k <- length(levels(variable))
  contr.mat <- mapply(function(k, i) {rep( c( (k-i)/k, -i/k), c(i, k-i) )}, k=k, i=1:(k-1))
  contr.mat
}

#here we specify which variable should be subject to forward reference coding
contrasts(dataF$next_cons) <- forward.code(dataF$next_cons)

l=glmer(PRE ~ vowel + next_cons + gender * Welsh + (1|speaker) + (1|lexeme), data=dataF, family="binomial") 
summary(l)

#we also tried to limit the random effects to see if then Welsh vs English home language emerges as significant
a=glmer(PRE ~ next_cons +gender * Welsh + (1|lexeme), data=dataF, family="binomial") 
summary(a)
b=glmer(PRE ~ next_cons +gender * Welsh + (1|speaker), data=dataF, family="binomial") 
summary(b)
#if significant, there is a difference
anova(a,l) #or c - c = without forward coding; l with the coding; either c or l include both random effects: speaker & lexeme
anova(b,l)

par(mfrow=c(1,1))
attach(dataF)
plot(dataF$next_cons,dataF$PRE, col=c("mediumpurple1","mediumaquamarine"), main="place of articulation")

#continuous dependent variable
library(lmerTest)
#non-normalised values
dataFF <- data[data$Ctype=="fortis" & data$PRE_DUR>0, ]

m=lmer(preasp_dur_ms+breath_dur_ms ~ vowel + next_cons + gender * Welsh + (1|speaker) + (1|lexeme), data=dataFF) 
summary(m)

#normalised values
n=lmer(preNORM+brNORM ~ vowel + next_cons + gender * Welsh + (1|speaker) + (1|lexeme), data=dataFF) 
summary(n)

#here the normalised one comes out as better fitting the data!
anova(m,n)

#plotting non-normalised durations, br+pre = PRE-DUR, without 0 values (like in the mixed effects on the duration)
par(mfrow=c(1,2))
attach(data)
plot(data$gender[data$Welsh=="L1" & data$Ctype=="fortis" & data$PRE_DUR>0],data$PRE_DUR[data$Welsh=="L1" & data$Ctype=="fortis" & data$PRE_DUR>0], col=c("mediumpurple1","mediumaquamarine"), main="Welsh home language", xlab="gender")
plot(data$gender[data$Welsh=="L2" & data$Ctype=="fortis" & data$PRE_DUR>0],data$PRE_DUR[data$Welsh=="L2" & data$Ctype=="fortis" & data$PRE_DUR>0], col=c("mediumpurple1","mediumaquamarine"), main="English home language", xlab="gender")

#plotting non-normalised durations, br+pre = PRE-DUR, with 0 values (like in the mixed effects on the duration)
par(mfrow=c(1,2))
attach(data)
plot(data$gender[data$Welsh=="L1" & data$Ctype=="fortis"],data$PRE_DUR[data$Welsh=="L1" & data$Ctype=="fortis"], col=c("mediumpurple1","mediumaquamarine"), main="Welsh home language", xlab="gender")
plot(data$gender[data$Welsh=="L2" & data$Ctype=="fortis"],data$PRE_DUR[data$Welsh=="L2" & data$Ctype=="fortis"], col=c("mediumpurple1","mediumaquamarine"), main="English home language", xlab="gender")

#plotting normalised durations, br+pre = PRE-DUR, without 0 values (like in the mixed effects on the duration)
par(mfrow=c(1,2))
attach(data)
plot(data$gender[data$Welsh=="L1" & data$Ctype=="fortis" & data$PRE_DUR>0],data$PRE_DUR_NORM[data$Welsh=="L1" & data$Ctype=="fortis" & data$PRE_DUR>0], col=c("mediumpurple1","mediumaquamarine"), main="Welsh home language", xlab="gender")
plot(data$gender[data$Welsh=="L2" & data$Ctype=="fortis" & data$PRE_DUR>0],data$PRE_DUR_NORM[data$Welsh=="L2" & data$Ctype=="fortis" & data$PRE_DUR>0], col=c("mediumpurple1","mediumaquamarine"), main="English home language", xlab="gender")


################
# noisiness analyses
################

par(mfrow=c(1,2))
attach(dataF)
plot(dataF$gender[dataF$Welsh=="L1" & dataF$Ctype=="fortis" & dataF$PRE_DUR>0],dataF$zcr_preasp[dataF$Welsh=="L1" & dataF$Ctype=="fortis" & dataF$PRE_DUR>0], col=c("mediumpurple1","mediumaquamarine"), main="Welsh home language", xlab="gender")
plot(dataF$gender[dataF$Welsh=="L2" & dataF$Ctype=="fortis" & dataF$PRE_DUR>0],dataF$zcr_preasp[dataF$Welsh=="L2" & dataF$Ctype=="fortis" & dataF$PRE_DUR>0], col=c("mediumpurple1","mediumaquamarine"), main="English home language", xlab="gender")

par(mfrow=c(1,2))
attach(dataF)
plot(dataF$gender[dataF$Welsh=="L1" & dataF$Ctype=="fortis" & dataF$PRE_DUR>0],dataF$ZCR[dataF$Welsh=="L1" & dataF$Ctype=="fortis" & dataF$PRE_DUR>0], col=c("mediumpurple1","mediumaquamarine"), main="Welsh home language", xlab="gender")
plot(dataF$gender[dataF$Welsh=="L2" & dataF$Ctype=="fortis" & dataF$PRE_DUR>0],dataF$ZCR[dataF$Welsh=="L2" & dataF$Ctype=="fortis" & dataF$PRE_DUR>0], col=c("mediumpurple1","mediumaquamarine"), main="English home language", xlab="gender")


dataFF <- data[data$Ctype=="fortis" & data$PRE_DUR>0, ]

m=lmer(ZCR ~ vowel + next_cons + gender * Welsh + (1|speaker) + (1|lexeme), data=dataFF) 
summary(m)



############
# plotting vowels (vowel added to the models above)
############

summary(data$vowel)

#plots within fortis plosives duration of br+pre (or just br or pre = the big PRE), first with 0 values, then with no 0 values
par(mfrow=c(1,2))
attach(dataF)
plot(dataF$vowel,dataF$PRE_DUR)
attach(dataFF)
plot(dataFF$vowel,dataFF$PRE_DUR)

#diphtongal changes? none
par(mfrow=c(1,1))
attach(dataF)
plot(dataF$vtype,dataF$PRE)
plot(dataFF$vtype,dataFF$PRE_DUR)

# 
dataFF <- data[data$Ctype=="fortis" & data$PRE_DUR>0, ]



############
# plotting vowels (vowel added to the models above)
############

plot(data$Ctype,data$PRE, col=c("mediumpurple1","mediumaquamarine"), main="rate of pre-aspiration per series")

#gender and home language separately
par(mfrow=c(2,2))
attach(data)
plot(data$Ctype[data$Welsh=="L1"],data$PRE[data$Welsh=="L1"], col=c("mediumpurple1","mediumaquamarine"), main="Welsh home language", xlab="series")
plot(data$Ctype[data$Welsh=="L2"],data$PRE[data$Welsh=="L2"], col=c("mediumpurple1","mediumaquamarine"), main="English home language", xlab="series")
plot(data$Ctype[data$gender=="F"],data$PRE[data$gender=="F"], col=c("mediumpurple1","mediumaquamarine"), main="females", xlab="series")
plot(data$Ctype[data$gender=="M"],data$PRE[data$gender=="M"], col=c("mediumpurple1","mediumaquamarine"), main="males", xlab="series")


#gender and home language intertwined: presence of PRE
par(mfrow=c(2,2))
attach(data)
plot(data$Ctype[data$Welsh=="L1" & data$gender=="F"],data$PRE[data$Welsh=="L1" & data$gender=="F"], col=c("mediumpurple1","mediumaquamarine"), main="Whome females", xlab="series")
plot(data$Ctype[data$Welsh=="L1" & data$gender=="M"],data$PRE[data$Welsh=="L1" & data$gender=="M"], col=c("mediumpurple1","mediumaquamarine"), main="Whome males", xlab="series")
plot(data$Ctype[data$Welsh=="L2" & data$gender=="F"],data$PRE[data$Welsh=="L2" & data$gender=="F"], col=c("mediumpurple1","mediumaquamarine"), main="Ehome females", xlab="series")
plot(data$Ctype[data$Welsh=="L2" & data$gender=="M"],data$PRE[data$Welsh=="L2" & data$gender=="M"], col=c("mediumpurple1","mediumaquamarine"), main="Ehome males", xlab="series")




dataG <- data[data$PRE_DUR>0, ]
#gender and home language intertwined: duration of PRE without zero values
par(mfrow=c(2,2))
attach(data)
plot(dataG$Ctype[dataG$Welsh=="L1" & dataG$gender=="F"],dataG$PRE_DUR[dataG$Welsh=="L1" & dataG$gender=="F"], col=c("mediumpurple1","mediumaquamarine"), main="Whome females", xlab="series")
plot(dataG$Ctype[dataG$Welsh=="L1" & dataG$gender=="M"],dataG$PRE_DUR[dataG$Welsh=="L1" & dataG$gender=="M"], col=c("mediumpurple1","mediumaquamarine"), main="Whome males", xlab="series")
plot(dataG$Ctype[dataG$Welsh=="L2" & dataG$gender=="F"],dataG$PRE_DUR[dataG$Welsh=="L2" & dataG$gender=="F"], col=c("mediumpurple1","mediumaquamarine"), main="Ehome females", xlab="series")
plot(dataG$Ctype[dataG$Welsh=="L2" & dataG$gender=="M"],dataG$PRE_DUR[dataG$Welsh=="L2" & dataG$gender=="M"], col=c("mediumpurple1","mediumaquamarine"), main="Ehome males", xlab="series")

#gender and home language intertwined: duration of PRE_NORM without zero values
par(mfrow=c(2,2))
attach(data)
plot(dataG$Ctype[dataG$Welsh=="L1" & dataG$gender=="F"],dataG$PRE_DUR_NORM[dataG$Welsh=="L1" & dataG$gender=="F"], col=c("mediumpurple1","mediumaquamarine"), main="Whome females", xlab="series")
plot(dataG$Ctype[dataG$Welsh=="L1" & dataG$gender=="M"],dataG$PRE_DUR_NORM[dataG$Welsh=="L1" & dataG$gender=="M"], col=c("mediumpurple1","mediumaquamarine"), main="Whome males", xlab="series")
plot(dataG$Ctype[dataG$Welsh=="L2" & dataG$gender=="F"],dataG$PRE_DUR_NORM[dataG$Welsh=="L2" & dataG$gender=="F"], col=c("mediumpurple1","mediumaquamarine"), main="Ehome females", xlab="series")
plot(dataG$Ctype[dataG$Welsh=="L2" & dataG$gender=="M"],dataG$PRE_DUR_NORM[dataG$Welsh=="L2" & dataG$gender=="M"], col=c("mediumpurple1","mediumaquamarine"), main="Ehome males", xlab="series")

#gender and home language intertwined: noisiness without 0 values
par(mfrow=c(2,2))
attach(data)
plot(dataG$Ctype[dataG$Welsh=="L1" & dataG$gender=="F"],dataG$ZCR[dataG$Welsh=="L1" & dataG$gender=="F"], col=c("mediumpurple1","mediumaquamarine"), main="Whome females", xlab="series")
plot(dataG$Ctype[dataG$Welsh=="L1" & dataG$gender=="M"],dataG$ZCR[dataG$Welsh=="L1" & dataG$gender=="M"], col=c("mediumpurple1","mediumaquamarine"), main="Whome males", xlab="series")
plot(dataG$Ctype[dataG$Welsh=="L2" & dataG$gender=="F"],dataG$ZCR[dataG$Welsh=="L2" & dataG$gender=="F"], col=c("mediumpurple1","mediumaquamarine"), main="Ehome females", xlab="series")
plot(dataG$Ctype[dataG$Welsh=="L2" & dataG$gender=="M"],dataG$ZCR[dataG$Welsh=="L2" & dataG$gender=="M"], col=c("mediumpurple1","mediumaquamarine"), main="Ehome males", xlab="series")


#conditioning of the presence of pre-aspiration with both series
a=glmer(PRE ~ Ctype + Welsh + gender + (1|speaker) + (1|lexeme), data=data, family="binomial") 
summary(a)

#normalised duration of PRE - 0's automatically excluded because of the normalisation
b=lmer(PRE_DUR_NORM ~ Ctype + Welsh + gender + (1|speaker) + (1|lexeme), data=data) 
summary(b)

bb=lmer(PRE_DUR_NORM ~ Ctype + Welsh * gender + (1|speaker) + (1|lexeme), data=data) 
summary(bb)
anova(b,bb) #not significantly different

bbb=lmer(PRE_DUR_NORM ~ Ctype * Welsh * gender + (1|speaker) + (1|lexeme), data=data) 
summary(bbb)
anova(b,bbb) #bbb is better in deviance and AIC, not BIC 2:1

#non-ormalised duration of PRE - 0's excluded 
c=lmer(PRE_DUR ~ Ctype + Welsh + gender + (1|speaker) + (1|lexeme), data=dataG) 
summary(c)

cc=lmer(PRE_DUR ~ Ctype + Welsh * gender + (1|speaker) + (1|lexeme), data=dataG) 
summary(cc)

ccc=lmer(PRE_DUR ~ Ctype * Welsh * gender + (1|speaker) + (1|lexeme), data=dataG) 
summary(ccc)

anova(c,ccc) #none better in terms of significance etc.

#ZCR - 0's excluded 
d=lmer(ZCR ~ Ctype + Welsh + gender + (1|speaker) + (1|lexeme), data=dataG) 
summary(d)

dd=lmer(ZCR ~ Ctype + Welsh * gender + (1|speaker) + (1|lexeme), data=dataG) 
summary(dd)

ddd=lmer(ZCR ~ Ctype * Welsh * gender + (1|speaker) + (1|lexeme), data=dataG) 
summary(ddd)

anova(d,ddd) #we can choose any of the thre
