---
title: "Air pollution and Lung Cancer (CaseMed Example)"
author: "Ellen Kendall"
date: "4/12/2020"
output:
  html_document: default
  pdf_document: default
---

```{r setup, include=FALSE}
knitr::opts_chunk$set(echo = TRUE)
```

## Downloading R and and RStudio onto your computer

This lesson assumes you have current versions of the following installed on your computer:

the R software itself https://cran.r-project.org/mirrors.html, and RStudio Desktop https://rstudio.com/products/rstudio/download/#download.

## Working directory

It is important that you download data to the correct folder, and then set that as your working directory. For example, I have created a folder called LungCancerExample. To read in the data from this folder, I need to change my working directory to this folder. If you are unsure what folder you are working in, you can use the command getwd(). 

Notice: I am working on a Mac. If you are a windows user, your file path will look different.

```{r working directory}
#this is the command to change the working directory
setwd("/Users/ellenkendall/LungCancerExample")

#IF YOU USE WINDOWS
#setwd("C:/Users/ellenkendall/LungCancerExample")

```

## Load packages used

Next, I will load in the packages that I will use for my project. To install a package, you will use install.packages("packagename"). After the package is downloaded, you just need to load it. The command to do this is library(packagename). Here, I will use dplyr which helps to manipulate data, and ggplot2, which helps make graphs.

```{r packages, message=FALSE}
library(ggplot2)
library(dplyr)
library(tidyr)
```

## Big picture and data sources

This code will walk through an example project that will test if there is a relationship between air pollution and lung cancer incidence/mortality. This analysis will pull from two public databases 1) Daily Fine Particulate Matter (air pollution) and 2) US Cancer Statistics (lung cancer rates).

Both of these databases can be accessed via CDC WONDER https://wonder.cdc.gov/. 

Cancer stats are collected by each state through CDC and NCI programs. Fine particulate matter (PM2.5) refers to inhalable particles found in the atmosphere. Increases in FPM are known to have negative health consequences.

For the specific queries on CDC WONDER:

I used lung cancer average age adjusted incidence and mortality rates from 2012-2016 by state. I used the FPM average by state from 2003-2011. Data can be searched via CDC WONDER and then downloaded to your computer. The file will download as a text file, which you can open in excel. Next, I deleted the notes column in both files, and I saved the files to my LungCancerExamle folder as a CSV file. 

I will walk through how to download and save these files in the lecture. You can also find the raw CSV files that I used on my github page for this project: https://github.com/ekkendall/LungCancerExample.

Data citation:
Daily Fine Particulate Matter (PM2.5) (µg/m≥) for years 2003-2011 on CDC WONDER Online Database, released 2013. Accessed at http://wonder.cdc.gov/NASA-PM.html on Apr 12, 2020.
United States Cancer Statistics - Mortality Incidence Rate Ratios: 1999 - 2016, WONDER Online Database. United States Department of Health and Human Services, Centers for Disease Control and Prevention and National Cancer Institute; 2019. Accessed at http://wonder.cdc.gov/CancerMIR-v2016.html on Apr 12, 2020.

## Air pollution

Now I will show how to read the air pollution data into R studio. I titled my csv file fpm and saved it into my LungCancerExample folder (file will become fpm.csv). I will use the read.csv() command. I want to save the data frame in R as the name fpm. The head(fpm) command will show the first few lines of the data frame.

```{r air pollution}
#read in data for fine particulate matter (air pollution)
fpm <- read.csv("fpm.csv", stringsAsFactors = F)
head(fpm)
```

I want easier names for my columns, so I used colnames() and then created a vector of the new column names. I also do not need all columns of the data, so I will select the State and Avg FPM columns.

In the second line of code, I use the %>% or pipe operator. This is from the dplyr package, and I like to think of it as saying THEN in a command. For expample, the command is saying, take the fpm data frame, then select these two columns. 

```{r air pollution clean}
#rename columns
colnames(fpm) <- c("State", "StateCode", "Avg_FPM")

#select columns
fpmClean <- fpm %>% select(State, Avg_FPM)

```

Like you learned in datacamp, you also clean data when you import to R. The command would be:

fpmClean <- read.csv("fpm.csv", header=TRUE, col.names=c("State", "StateCode", "Avg_FPM"), colClasses=c("character", "NULL", "numeric"))

## Summary of air pollution data

Now I want to understand the data in this data frame. I will use the summary command.

```{r summaryAir}
#summary data
summary(fpmClean)
```

## Using filter to look closer at the data

Say I was curious which states have FPM values over the mean FPM value. I will use a dplyr command that is very helpful- filter().

```{r summaryAirFilter}
#mean fpm calculation
meanFPM <- mean(fpmClean$Avg_FPM)

#using filter() to select only states that have an Average FPM level larger than the mean FPM
aboveAvgFPM <- fpmClean %>% filter(Avg_FPM >= meanFPM)

#how many states are above avg?
length(aboveAvgFPM$State)

#what are the states that are above avg?
aboveAvgFPM$State

```

We can see that there is variation in the data. It would be easier to understand the data with a graph.

I will look at the avg FPM by state using ggplot.

```{r summaryAirGraph}
#plot info FPM by state
#geom_point is the type of graph
#theme helps rotate the labels on the x axis so they all can be seen

ggplot(fpmClean, aes(x=State, y=Avg_FPM)) +geom_point() +theme(axis.text.x = element_text(angle = 90, hjust = 1))
```

You can see there is a range of AVG FPM by state. We want to know if this range has any correlation to the lung cancer incidence/mortality in these states.

## Lung cancer data import and clean

I saved the csv file of the lung incidence and mortality by state as lung (will become lung.csv). I will again use read.csv(). I will then rename the columns and select the columns of interest.

```{r lungcancer}
#read in data for lung cancer
lung <- read.csv("lung.csv", stringsAsFactors = F)
head(lung)

#I am going to clean the data renaming the columns
colnames(lung) <- c("Cancer", "CancerSite","State", "StateCode", "Mortality_Incidence_Ratio", "Mortality", "Incidence")


#Now selecting columns of interest
lungClean <- lung %>% select(State, Mortality_Incidence_Ratio, 
                             Mortality, Incidence)

#You could combine these steps using 
#lungClean <- read.csv("lung.csv", header=TRUE, col.names=c("Cancer", "CancerSite","State", "StateCode", "Mortality_Incidence_Ratio", "Mortality", "Incidence"), colClasses=c("NULL", "NULL", "character", "NULL", "numeric", "numeric", "numeric")) %>% select(State, Mortality_Incidence_Ratio, Mortality, Incidence)

```

## Summary data for lung cancer

Similar to the FPM data, I will look at summary stats for each column in the dataset. I will then graph incidence and mortality by state to understand the variation.

```{r summarylung}
#Get summary stats from the data
summary(lungClean)

#plot incidence and mortality by state
ggplot(lungClean, aes(x=State, y=Incidence)) +geom_point() +theme(axis.text.x = element_text(angle = 90, hjust = 1))
ggplot(lungClean, aes(x=State, y=Mortality)) +geom_point() +theme(axis.text.x = element_text(angle = 90, hjust = 1))
```

There is clear variation between states. We want to know if this variation can be explained by average levels of fine particulate matter in the air. To do this, we need to combine the fpm data with the lung data.


## Merge lung cancer and air pollution data

We will use the full_join() command to combine lung and fpm data. In both datasets, there is a column with the name State. We will use this column to merge the data together so that we will have information on air pollution and lung cancer for each state.

```{r merge}
#combine data sets
allData <- fpmClean %>% full_join(lungClean, by="State") #note, inner_join keeps only States in common (like setting all=FALSE when using the merge.data.frame command)
```

## Air pollution and lung cancer

We want to look at how levels of air pollution correlate to lung cancer incidence and mortality using ggplot2. Ggplot2 is powerful because it is very customizable, but no need to memorize specific commands! Expert users need to constantly refer back to remember how to do a certain thing in ggplot. Linked here is the ggplot cheatsheet: https://rstudio.com/wp-content/uploads/2015/03/ggplot2-cheatsheet.pdf. 

```{r incidenceAirGraph, fig.height=8}
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
```

Notice the warning message: removed 2 rows containing missing values. Alaska and Hawaii do not have FPM information, so ggplot had to remove these rows.

If you have NAs in your data, they can cause problems, so you can remove NA values in your data set by using na.omit (make sure to reference this in your methods). You also could use allData <- merge.data.frame(lungClean, fpmClean, by="State", all = FALSE) when merging your data. Setting all=FALSE instead of TRUE will drop rows that are not included in both datasets. 

## Linear regression model for air pollution and lung cancer incidence

We want to know if the trend we see between air pollution and lung cancer incidence is statistically significant. We will use a simple regression model to test. We will fit the model with the lm() command, and then will graph the data, trend line, and key statistics.

The ggplot code is a bit more intense, but the first line is to plot the fpm and lung cancer incidence data which is embedded in the incidenceFPMFit model. Next we add the regression line with stat_smooth(). The last portion goes to extracting stats from the linear model. If you just want the stats from your model, these can be found via summary(incidenceFPMFit) as shown below.

```{r regression1}
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

```

You can see that the p value is less than 0.05, meaning the correlation is statistically significant. The R^2 value is low, meaning the air pollution only contributes to a fraction of the variation seen in lung cancer incidence by state.In this analysis, the model only has 1 covariate, so the p value for the F-stat and the coefficient are the same.In a regression with multiple predictors, the P-values for each coefficient will be different than the P-value of the F-statistic. For a more in depth explanation of the stats found in this summary, click here: https://feliperego.github.io/blog/2015/10/23/Interpreting-Model-Output-In-R.

What does this model mean? Our model is saying that the predicted lung cancer incidence (in #/100,000 per year) for a city with a Avg_FPM of 12 is 18.904 + 12*3.5060 = 60.9. As you can see, even though the model is significant, it is not great at predicting the value of cancer incidence.

## Linear regression model for air pollution and lung cancer mortality

We repeat the above steps with mortality. 

```{r regression2}
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

```

Here we see similar results as above in the incidence model.

Questions? Feel free to email ekk19 @ case.edu or post on the cavas discussion board.
Need more resources? http://swcarpentry.github.io/r-novice-gapminder/