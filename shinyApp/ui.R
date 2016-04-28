library(shiny)
shinyUI(pageWithSidebar(
    headerPanel("Hello Shiny!"),
    sidebarPanel(
        h3('Control Panel'), 
        p('Enter your information here to explore your results.'),
        selectInput("gender", label = "Gender", c("Male" = "M", "Female" = "F")),
        selectInput("agegroup", label = "Age Group", c("18-34", "35-39", "40-44", "45-49", "50-54", "60-64", "65-69", "70-74", "75-79", "80+")),
        sliderInput("bib_number", label = "Bib Number", min = 1, max = 40000, value = 1, step = 1)
    ),
    mainPanel(
        h3('Boston Marathon Results Explorer')
        p('Enter Your ')
    ) ))