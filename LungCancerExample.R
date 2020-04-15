#R script used for the Case Med Lung Cancer Example

#this is the command to change the working directory
setwd("/Users/ellenkendall//LungCancerExample")

#IF YOU USE WINDOWS
#setwd("C:/Users/ellenkendall/LungCancerExample")

library(ggplot2)
library(dplyr)

#read in data for fine particulate matter (air pollution)
fpm <- read.csv("fpm.csv", stringsAsFactors = F)
head(fpm)

#rename columns
colnames(fpm) <- c("State", "StateCode", "Avg_FPM")

#select columns
fpmClean <- fpm %>% select(State, Avg_FPM)

#summary data
summary(fpmClean)

#mean fpm calculation
meanFPM <- mean(fpmClean$Avg_FPM)

#using filter() to select only states that have an Average FPM level larger than the mean FPM
aboveAvgFPM <- fpmClean %>% filter(Avg_FPM >= meanFPM)

#how many states are above avg?
length(aboveAvgFPM$State)

#what are the states that are above avg?
aboveAvgFPM$State

#plot info FPM by state
#geom_point is the type of graph
#theme helps rotate the labels on the x axis so they all can be seen

ggplot(fpmClean, aes(x=State, y=Avg_FPM)) +geom_point() +theme(axis.text.x = element_text(angle = 90, hjust = 1))

#read in data for lung cancer
lung <- read.csv("lung.csv", stringsAsFactors = F)
head(lung)

#I am going to clean the data renaming the columns
colnames(lung) <- c("Cancer", "CancerSite","State", "StateCode", "Mortality_Incidence_Ratio", "Mortality", "Incidence")

#Now selecting columns of interest
lungClean <- lung %>% select(State, Mortality_Incidence_Ratio, 
                             Mortality, Incidence)

#Get summary stats from the data
summary(lungClean)

#plot incidence and mortality by state
ggplot(lungClean, aes(x=State, y=Incidence)) +geom_point() +theme(axis.text.x = element_text(angle = 90, hjust = 1))
ggplot(lungClean, aes(x=State, y=Mortality)) +geom_point() +theme(axis.text.x = element_text(angle = 90, hjust = 1))

#combine data sets
allData <- merge.data.frame(lungClean, fpmClean, by="State", all = T)


#how levels of air pollution correlate to lung cancer incidence using ggplot2
allData %>%
  mutate(State=reorder(State, Incidence)) %>% # reorder the states by their incidence of lung cancer for the left axis
  select(State, Incidence, Mortality, Avg_FPM) %>% # choose the variables we want to plot
  gather('measurement', 'value', -State) %>% # use the gather function from the tidyr package to put our data into long format
  mutate(measurement=factor(measurement, c(Avg_FPM='Avg_FPM', Mortality='Mortality', Incidence='Incidence'))) %>% # reorder the measurements manually for the legend
  ggplot(aes(x=State, y=value, col=measurement)) + # pipe our new dataframe to ggplot and set our aesthetics
  geom_point() + # draw a scatter graph with measurements for each state
  coord_flip() + # rotate the graph so that States are on the X axis because 1) they fit better this way and 2) they are what we want our readers to focus on
  labs(x='State', y='Average FPM (PM2.5); Incidence (%); Mortality (%)') + # rename our left axis title and bottom axis title
  scale_color_discrete(name='', labels=c('Average FPM (PM2.5)', 'Mortality (%)', 'Incidence (%)')) + # rename our legend
  ylim(0,100) # force the bottom axis to go from 0 to 100
#Notice the warning message: removed 2 rows containing missing values. Alaska and Hawaii do not have FPM information, so ggplot had to remove these rows.

#We want to know if the trend we see between air pollution and lung cancer incidence is statistically significant. We will use a simple regression model to test. We will fit the model with the lm() command, and then will graph the data, trend line, and key statistics.

incidenceFPMFit <- lm(Incidence ~ Avg_FPM, data = allData)

summary(incidenceFPMFit)

ggplot(incidenceFPMFit$model, aes_string(x = names(incidenceFPMFit$model)[2], y = names(incidenceFPMFit$model)[1])) + 
  geom_point() +
  stat_smooth(method = "lm", col = "red") +
  geom_label(aes(x = 9, y = 82), hjust = 0, 
             label = paste("Adj R2 = ",signif(summary(incidenceFPMFit)$adj.r.squared, 5),
                           "\nIntercept =",signif(incidenceFPMFit$coef[[1]],5 ),
                           " \nSlope =",signif(incidenceFPMFit$coef[[2]], 5),
                           " \nP =",signif(summary(incidenceFPMFit)$coef[2,4], 5)))

#repeat the above steps with mortality
mortalityFPMFit <- lm(Mortality ~ Avg_FPM, data = allData)

summary(mortalityFPMFit)

ggplot(mortalityFPMFit$model, aes_string(x = names(mortalityFPMFit$model)[2], y = names(mortalityFPMFit$model)[1])) + 
  geom_point() +
  stat_smooth(method = "lm", col = "red") +
  geom_label(aes(x = 9, y = 60), hjust = 0, 
             label = paste("Adj R2 = ",signif(summary(mortalityFPMFit)$adj.r.squared, 5),
                           "\nIntercept =",signif(mortalityFPMFit$coef[[1]],5 ),
                           " \nSlope =",signif(mortalityFPMFit$coef[[2]], 5),
                           " \nP =",signif(summary(mortalityFPMFit)$coef[2,4], 5)))

