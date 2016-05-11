library(shiny)
library(plyr)
library(dplyr)
library(lubridate)
library(ggplot2)
library(tidyr)

load("results_2016_proc.Rda")
load("segment_5k_times.Rda")

#test - remove after testing
countrycounts = data.frame(table(results$county))
names(countrycounts) <- c("Country", "Entrants")
countrycounts = arrange(countrycounts, desc(Entrants), Country)

shinyServer(
    function(input, output) {
        
        output$oid1 = renderPrint({input$gender})
        output$oid2 = renderPrint({input$agegroup})
        output$oid3 = renderPrint({input$bib_number})
        output$ind_5k_plot = renderPlot({
            xage_group = results[results$bib_number==input$bib_number,'age_group']
            xgender = results[results$gender==input$gender,'gender']
            xbib_number = input$bib_number
            #plot of 5k segment times relative to avg in age group/gender, and overall avg
            ggplot(filter(segment_5k_times, age_group == xage_group, gender == xgender), aes(x = km_segment, y = time
            )) + geom_jitter(colour = "dodgerblue", alpha = 0.3)+ geom_boxplot(
                fill = "white", width = 0.2, outlier.shape = NA) + facet_grid(. ~ km_segment, scales="free_x"
                ) + xlab("5k segment") + ylab("Segment Time") + scale_y_continuous(
                limits = c(900, 2700), breaks = c(1200,  1800,  2400), labels = c(
                "20:00", "30:00", "40:00")) + ggtitle(
                "Performance over 5k race segments for your gender and age group\n2016 Boston Marathon"
                ) + geom_hline(aes(yintercept = time), data = filter(segment_5k_times, bib_number == xbib_number), size=2, colour = "gold")
        })
        output$explore_5k_plot = renderPlot({
            xage_group = input$agegroup
            xgender = input$gender
            #plot of 5k segment times relative to avg in age group/gender, and overall avg
            ggplot(filter(segment_5k_times, age_group == xage_group, gender == xgender, bib_number >= input$bib_range[1], bib_number <= input$bib_range[2]), aes(x = km_segment, y = time
            )) + geom_jitter(colour = "dodgerblue", alpha = 0.3)+ geom_boxplot(
                fill = "white", width = 0.2, outlier.shape = NA) + facet_grid(. ~ km_segment, scales="free_x"
                ) + xlab("5k segment") + ylab("Segment Time") + scale_y_continuous(
                    limits = c(900, 2700), breaks = c(1200,  1800,  2400), labels = c(
                        "20:00", "30:00", "40:00")) + ggtitle(
                            "Performance over 5k race segments\n2016 Boston Marathon"
                        ) 
            #below--add horizontal lines with means for data
            #+ geom_hline(aes(yintercept = time), data = filter(segment_5k_times, bib_number == xbib_number), size=2, colour = "gold")
        })
        
        
        #position in overall results
        output$overall_place = renderPrint(results[results$bib_number==input$bib_number,'overall_place'])
        #position in age group/gender
        output$gender_place = renderPrint(results[results$bib_number==input$bib_number,'gender_place'])
        output$age_place = renderPrint(results[results$bib_number==input$bib_number,'division_place'])
        #position in city/state/country
        
        #histogram of finish time relative to all finishers
        output$overallplot = renderPlot({
            xbib_number = input$bib_number
            plotsub = subset(results, select = c("bib_number", "official_time"))
            plotsub$bin = cut(plotsub$official_time, 30)
            df = data.frame(table(plotsub$bin))
            names(df) <- c("bin", "freq")
            xbin = plotsub[plotsub$bib_number == xbib_number,'bin']
            df$color = factor(ifelse(df$bin == xbin, 1, 0))
            ggplot(df, aes(x = bin, y = freq, fill = color)) + geom_bar(stat = "identity"
                ) + scale_fill_manual(values = c("dodgerblue","gold")
                ) + ggtitle("Your Performance Relative To All Finishers"
                ) + theme(legend.position="none", axis.title.x=element_blank(), axis.text.x = element_blank(), axis.ticks = element_blank())
        })
        
        #histogram of finish time relative to division (gender + age group)
        output$divisionplot = renderPlot({
            xbib_number = input$bib_number
            xage_group = results[results$bib_number==input$bib_number,'age_group']
            xgender = results[results$bib_number==input$bib_number,'gender']
            plotsub = subset(results, age_group == xage_group | gender == xgender, select = c("bib_number", "official_time"))
            plotsub$bin = cut(plotsub$official_time, 30)
            df = data.frame(table(plotsub$bin))
            names(df) <- c("bin", "freq")
            xbin = plotsub[plotsub$bib_number == xbib_number,'bin']
            df$color = factor(ifelse(df$bin == xbin, 1, 0))
            ggplot(df, aes(x = bin, y = freq, fill = color)) + geom_bar(stat = "identity"
            ) + scale_fill_manual(values = c("dodgerblue","gold")
            ) + ggtitle("Your Performance Within Your Division (Gender + Age Group)"
            ) + theme(legend.position="none", axis.title.x=element_blank(), axis.text.x = element_blank(), axis.ticks = element_blank())
        })
       
        
    } )
