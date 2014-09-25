
library(shiny)
library(ggplot2)

shinyUI(pageWithSidebar(
  
  # Application title
  headerPanel("#cfasummit Tweets"),
  
  sidebarPanel(
    tags$head(
      tags$link(rel="stylesheet", type="text/css", href="css/styles.css"),
      tags$script(type = 'text/javascript', src = 'js/responsiveTable.js'),   
      tags$style(type="text/css", "label.radio { display: inline-block; }", ".radio input[type=\"radio\"] { float: none; }"),
      tags$style(type="text/css", "select { max-width: 200px; }"),
      tags$style(type="text/css", "textarea { max-width: 185px; }"),
      tags$style(type="text/css", ".jslider { max-width: 200px; }"),
      tags$style(type='text/css', ".well { padding: 12px; margin-bottom: 5px; max-width: 230px; }"),
      tags$style(type='text/css', ".span4 { max-width: 280px; }")
    ),
    textInput("search.term", "Subset Data By Search Term", ""),
    br(),
    dateRangeInput("daterange", "Date range:",
                   start = Sys.Date()-7,
                   end = Sys.Date()),
    br(),    
    checkboxInput("rt", "Show Retweets", FALSE),
    br(),
    downloadLink('downloadData', 'Download all tweets as .csv'),
    br(),
    br(),
    HTML('The code for this dashboard is located on <a href="https://github.com/corynissen">Github</a>'),
    tags$p("Verson 0.1")
    ),
  
  mainPanel(
    tabsetPanel(
      tabPanel("Tweets",
               #h3(textOutput("caption")),
               tableOutput("tweet_table2")
               #plotOutput("plot"),    
               #uiOutput("tweet_table")
      ),
      tabPanel("Authors",
               HTML('<h5>Click on Author on left to see her tweets on the right</h5>'),               
               div(class="row-fluid",
                   div(class="span3", 
                     uiOutput(outputId = "author.freq.table")),
                   div(class="span9", 
                     tableOutput(outputId = "author.table")))
               #tableOutput("author_table")
      )
#       tabPanel("Names",
#                uiOutput(outputId = "names.freq.table"),
#                uiOutput("names.table")
#       )
    )
  )
  ))
