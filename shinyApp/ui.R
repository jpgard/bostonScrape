library(shiny)
shinyUI(pageWithSidebar(
    headerPanel("Hello Shiny!"),
    sidebarPanel(
        conditionalPanel(condition="input.conditionedPanels==1",
                         helpText('Enter your bib number to explore your individual results.'),
                         numericInput("bib_number", label = "Bib Number", min = 1, max = 40000, value = 1, step = 1)
        ),
        conditionalPanel(condition="input.conditionedPanels==2",
                         helpText('Enter your information here to explore your results.'),
        h3('Control Panel'), 
        p('Use the selectors below to explore the 5k segment performance of various groups.'),
        selectInput("gender", label = "Gender", c("Male" = "M", "Female" = "F"), selected = NULL),
        selectInput("agegroup", label = "Age Group", 
                    c("18-34", "35-39", "40-44", "45-49", "50-54", "60-64", "65-69", "70-74", "75-79", "80+"
                      ), selected = NULL), 
        selectInput("country", label = "Country", c( "AHO", "ALB", "AND", "ARG", "AUS", "AUT", "BAH", "BEL", 
                                                     "BER", "BLR", "BRA", "CAN", "CAY", "CHI", "CHN", "COL", 
                                                     "CRC", "CRO", "CYP", "CZE", "DEN", "DOM", "ECU", "ESA", 
                                                     "ESP", "EST", "ETH", "FIN", "FRA", "GBR", "GER", "GRE", 
                                                     "GUA", "HKG", "HON", "HUN", "INA", "IND", "IRL", "ISL", 
                                                     "ISR", "ITA", "JAM", "JOR", "JPN", "KEN", "KOR", "LAT", 
                                                     "LIE", "LTU", "LUX", "MAR", "MAS", "MEX", "NED", "NOR", 
                                                     "NZL", "OMA", "PAK", "PAN", "PER", "PHI", "POL", "POR", 
                                                     "QAT", "ROU", "RSA", "RUS", "SIN", "SUI", "SVK", "SWE", 
                                                     "TRI", "TUR", "UAE", "UGA", "UKR", "URU", "USA", "VEN", 
                                                     "VGB", "VIE"), selected = "USA"),
        sliderInput("bib_range", "Bib Number Range", 1, 36000, c(1, 36000)),
        width = 3
        
    )
    ),
    mainPanel(
        tabsetPanel(type = "tabs",
            tabPanel("Individual Results Explorer", value=1,
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
                plotOutput('ind_5k_plot')),
            tabPanel("5k Segment Explorer", value=2,
                verbatimTextOutput("bib_range"),
                plotOutput('explore_5k_plot'),
                img(src="coursemap_2016.jpg",width =1000, align = "center")),
                
                     #include image of elevation from baa document
                     #needs its own control panel with more selections
            id = "conditionedPanels"
        )
    ) ))