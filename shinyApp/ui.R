library(shiny)
shinyUI(pageWithSidebar(
    headerPanel("Hello Shiny!"),
    sidebarPanel(
        h3('Control Panel'), 
        p('Enter your information here to explore your results.'),
        selectInput("gender", label = "Gender", c("Male" = "M", "Female" = "F")),
        selectInput("agegroup", label = "Age Group", c("18-34", "35-39", "40-44", "45-49", "50-54", "60-64", "65-69", "70-74", "75-79", "80+")),
        numericInput("bib_number", label = "Bib Number", min = 1, max = 40000, value = 1, step = 1), width = 3
    ),
    mainPanel(
        tabsetPanel(type = "tabs",
            tabPanel("Individual Results Explorer",
                h1('Boston Marathon Results Explorer'),
                p('Data dislay below'),
                h3('You Entered:'),
                p('Gender:'),
                verbatimTextOutput("oid1"),
                p('Age Group:'),
                verbatimTextOutput("oid2"),
                p('Bib Number:'),
                verbatimTextOutput("oid3"),
                h3('Your Results Overall:'),
                plotOutput('overallplot'),
                h3('Your Results Within Age/Gender Division:'),
                plotOutput('divisionplot'),
                h3('Your Performance on 5k Course Segments:'),
                plotOutput('testplot')),
            tabPanel("5k Segment Explorer"
                    )
        )
    ) ))