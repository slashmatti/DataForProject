# load libraries
library(shiny)


shinyUI(
    navbarPage(
        "ROSARIO TEMP",
        
        # create first tab
        tabPanel("Documentation",
            # Title
            h3("Temperatures registered in Rosario (Argentina) during the year 2014"),
            
            # paragraph
            p("This app displays the minimum, mean and maximum temperature registered in
              the city of Rosario (Argentina) during the year 2014.
                The user can:"),
            
            # ordered list
            tags$ol(
                tags$li("Select a date to see the temperature"),
                tags$li("Select to see the temperature measured in Celsius or Farenheit"),
                tags$li("Select to see the registry for a specific date, or for the entire month
                        of the selected date. In the later case, the mean registries through all the months are shown.")
            ),
            
            p("A plot of the daily (or monthly) registered temperatures is displayed, remarking the date
              selected by the user."),
            br(),
            p(strong("Note:"), " data was obtained from http://www.tutiempo.net/clima/Rosario_Aerodrome. \n
              The code for this app downloads the data file from GitHub (https://github.com/mpru/DataForProject/raw/master/data.txt) ")
        ),
        
       # second tab
       tabPanel("Run App",
           sidebarLayout(    
                sidebarPanel(
                    dateInput("date", "Date:", min = "2014-01-01", max = "2014-12-30", value = "2014-01-01"),
                    radioButtons("degreeType", "Choose scale:", c("Celsius"="cel", "Farenheit"="far")),
                    radioButtons("display", "Display temperature:", c("Daily"="day", "Monthly"="month")),
                    submitButton("Submit")
                ),
                mainPanel(
                    h3('Temperature records'),
                    h4('Minimum temperature:'),
                    verbatimTextOutput("omin"),
                    h4('Mean temperature'),
                    verbatimTextOutput("omean"),
                    h4('Maximum temperature'),
                    verbatimTextOutput("omax"),
                    plotOutput('newPlot')
                )
           )
       )
))