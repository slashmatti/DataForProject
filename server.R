# load libraries
library(shiny)

# download data
# fileUrl <<- "https://raw.github.com/mpru/DataForProject/master/data.txt"
# download.file(fileUrl,destfile="data.txt")
# data <- read.table("data.txt",header = T)

library(RCurl)
data <- getURL("http://raw.github.com/mpru/DataForProject/master/data.txt",
               ssl.verifypeer=0L, followlocation=1L)
writeLines(data,'temp.txt')
data <- read.table('temp.txt', header=T)
# 
# fakeData <- rnorm(364, 15, 3)
# data <- data.frame(Min = fakeData-5, Mean = fakeData, Max = fakeData + 5, Date = seq(from=as.Date("2014-01-01"), to=as.Date("2014-12-30"), by=1))

data$Date <- as.Date(data$Date, "%m/%d/%Y")
data$Month <- format(data$Date, "%m")
dataMonth <- with(data, data.frame(Min.month = round(tapply(Min, Month, mean),1),
                                   Mean.month = round(tapply(Mean, Month, mean),1),
                                   Max.month = round(tapply(Max, Month, mean),1),
                                   Months = unique(data$Month)))
dataMonth$Months <- as.character(dataMonth$Months)

# function to convert from celsius to farenheit
cels.to.far <<- function(x) {x*9/5 + 32}

dataFar <- data
dataFar[,1:3] <- cels.to.far(dataFar[,1:3])
dataMonthFar <- dataMonth
dataMonthFar[,1:3] <- cels.to.far(dataMonthFar[,1:3])


shinyServer(
    function(input, output) {
        displayDay <- reactive({input$display == "day"})
        inputDate <- reactive({input$date})
        
        # Grab the temperatures for the date in input, if displayDay is false, get the average for the month of that date
        minTemp <- reactive(ifelse(displayDay(), data$Min[data$Date == inputDate()], dataMonth$Min.month[as.numeric(format(inputDate(), "%m"))]))
        meanTemp <- reactive(ifelse(displayDay(), data$Mean[data$Date == inputDate()], dataMonth$Mean.month[as.numeric(format(inputDate(), "%m"))]))
        maxTemp <- reactive(ifelse(displayDay(), data$Max[data$Date == inputDate()], dataMonth$Max.month[as.numeric(format(inputDate(), "%m"))]))
        
        # Choose correct display message for day or month
        showDate <- reactive(ifelse(displayDay(), format(inputDate(), "%m-%d-%y"), months(inputDate())))
        
        # Choosing between celsius or farenheit
        inputGrade <- reactive({input$degreeType})
        gradeLabel <- reactive(ifelse(inputGrade() == "cel", "°C", "°F"))        
        minTemp2 <- reactive(ifelse(inputGrade() == "far", cels.to.far(minTemp()), minTemp()))
        meanTemp2 <- reactive(ifelse(inputGrade() == "far", cels.to.far(meanTemp()), meanTemp()))
        maxTemp2 <- reactive(ifelse(inputGrade() == "far", cels.to.far(maxTemp()), maxTemp()))
        
        # Prepare messages for display as output
        output$omin = renderPrint({paste("Min temp on", showDate(), "was", minTemp2(),gradeLabel())})
        output$omean = renderPrint({paste("Mean temp on", showDate(), "was", meanTemp2(),gradeLabel())})
        output$omax = renderPrint({paste("Max temp on", showDate(), "was", maxTemp2(),gradeLabel())})
        
        # Produce plot
        # max and min values for Y axis
        maxCels <- max(data$Max) + 0.05 * max(data$Max)
        maxY <- reactive(ifelse(inputGrade() == "far", cels.to.far(maxCels), maxCels))
        minCels <- min(data$Min) - 0.05 * min(data$Min)
        minY <- reactive(ifelse(inputGrade() == "far", cels.to.far(minCels), minCels))
        
        # prepare for changing between celsius and farenheit
        dataMinDay <- reactive(ifelse(inputGrade() == "far", "dataFar$Min", "data$Min"))
        dataMeanDay <- reactive(ifelse(inputGrade() == "far", "dataFar$Mean", "data$Mean"))
        dataMaxDay <- reactive(ifelse(inputGrade() == "far", "dataFar$Max", "data$Max"))
        dataMinMonth <- reactive(ifelse(inputGrade() == "far", "dataMonthFar$Min", "dataMonth$Min"))
        dataMeanMonth <- reactive(ifelse(inputGrade() == "far", "dataMonthFar$Mean", "dataMonth$Mean"))
        dataMaxMonth <- reactive(ifelse(inputGrade() == "far", "dataMonthFar$Max", "dataMonth$Max"))
        
        # prepare labels
        Ylabel <- reactive(ifelse(inputGrade() == "far", "Temperature (°F)", "Temperature (°C)"))
        Xlabel <- reactive(ifelse(displayDay(), "Date", "Month"))
        
        # produce plot    
        output$newPlot <- renderPlot({
            if (displayDay()){
                plot(data$Date, eval(parse(text=dataMinDay())), type = "l", col = "blue", ylim = c(minY(), maxY()),
                     main = "Temperatures registered in Rosario during 2014", xlab = Xlabel(), ylab = Ylabel())
                lines(data$Date, eval(parse(text=dataMeanDay())), type = "l", col = "orange")
                lines(data$Date, eval(parse(text=dataMaxDay())), type = "l", col = "red")
                abline(v = inputDate(), lwd = 2, col = "green")
                grid()
                legend(x = "bottomright", c("Min","Mean","Max"), lty=1, lwd=2,col=c("blue","orange","red"), bty = "n",ncol = 3)
            } else {
                plot(dataMonth$Months, eval(parse(text=dataMinMonth())), type = "l", col = "blue", ylim = c(minY(), maxY()),
                     main = "Temperatures registered in Rosario during 2014", xlab = Xlabel(), ylab = Ylabel())
                lines(dataMonth$Months, eval(parse(text=dataMeanMonth())), type = "l", col = "orange")
                lines(dataMonth$Months, eval(parse(text=dataMaxMonth())), type = "l", col = "red")
                abline(v = format(inputDate(), "%m"), lwd = 2, col = "green")
                grid()
                legend(x = "bottomright", c("Min","Mean","Max"), lty=1, lwd=2,col=c("blue","orange","red"), bty = "n",ncol = 3)
            }
        })
    }
)