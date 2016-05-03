library(shiny)
library(plyr)
library(dplyr)
library(lubridate)
library(ggplot2)
library(tidyr)
results = read.csv("../entrants_2016.csv", stringsAsFactors = FALSE)
#import qualifying times and add names to match results data for easy merging
qualTimes = read.table("../qualifyingTimes.txt", sep = '\t', colClasses = c("factor", "factor", "character"))
names(qualTimes) = c("age_group", "gender", "qualifying_time")
#create divisions for age groups, based on age goups listed at http://raceday.baa.org/statistics.html
#create factor variables from various demographics
#convert times to duration objects using as.difftime() and lubridate's as.duration()
#merge with qualifying times data and perform transformations to create duration objects from qualifying time strings
#create factor for elite runners

results <- results %>%
    mutate(age_group = cut(results$age, breaks = c(0, 35, 40, 45, 50, 55, 60, 65, 70, 75, 80), labels = c("18-34", "35-39", "40-44", "45-49", "50-54", "60-64", "65-69", "70-74", "75-79", "80+"), right = FALSE, ordered_result = TRUE)) %>%
    mutate(gender = factor(gender), county = factor(county)) %>%
    mutate(X5k = as.duration(as.difftime(tim = X5k, format = "%T", units = "secs")), 
           X10k = as.duration(as.difftime(tim = X10k, format = "%T", units = "secs")), 
           X15k = as.duration(as.difftime(tim = X15k, format = "%T", units = "secs")), 
           X20k = as.duration(as.difftime(tim = X20k, format = "%T", units = "secs")), 
           half = as.duration(as.difftime(tim = half, format = "%T", units = "secs")), 
           X25k = as.duration(as.difftime(tim = X25k, format = "%T", units = "secs")), 
           X30k = as.duration(as.difftime(tim = X30k, format = "%T", units = "secs")), 
           X35k = as.duration(as.difftime(tim = X35k, format = "%T", units = "secs")), 
           X40k = as.duration(as.difftime(tim = X40k, format = "%T", units = "secs")), 
           pace = as.duration(as.difftime(tim = pace, format = "%T", units = "secs")), 
           official_time = as.duration(as.difftime(tim = official_time, format = "%T", units = "secs"))) %>%
    mutate(elite = cut(gender_place, breaks = c(0, 50, max(gender_place)), labels = c("elite", "non-elite"))) %>%
    mutate(sec_half = official_time - half) %>%
    merge(qualTimes) %>%
    mutate(qualifying_time = as.duration(as.difftime(tim = qualifying_time, format = "%T", units = "secs"))) %>%
    na.omit() %>%
    unique()

#test - remove after testing
countrycounts = data.frame(table(results$county))
names(countrycounts) <- c("Country", "Entrants")
countrycounts = arrange(countrycounts, desc(Entrants), Country)

shinyServer(
    function(input, output) {
        
        output$oid1 = renderPrint({input$gender})
        output$oid2 = renderPrint({input$agegroup})
        output$oid3 = renderPrint({input$bib_number})
        output$testplot = renderPlot({
            ggplot(countrycounts[1:10,], aes(x = reorder(Country, -Entrants), y = Entrants)
                   ) + geom_bar(stat="identity") + xlab("Country") + ggtitle("Top 10 Countries By Official Finisher Counts\n2015 Boston Marathon"
                   ) + theme(axis.text.x = element_text(angle = 90, hjust = 1, vjust = 0.5))
        })
        
        #position in overall results
        #position in age group/gender
        #position in city/state/country
        #plot of 5k segment times relative to avg in age group/gender, and overall avg
        
    } )
