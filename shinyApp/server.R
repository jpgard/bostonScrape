library(shiny)
shinyServer(
    function(input, output) {
        #position in overall results
        output$oid1 = renderPrint({input$gender})
        output$oid2 = renderPrint({input$agegroup})
        output$oid3 = renderPrint({input$bib_number})
        #position in age group/gender
    } )
