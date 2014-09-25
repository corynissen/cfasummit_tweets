
library(shiny)
library(lubridate)
library(stringr)
source('df2html.R')

shinyServer(function(input, output, session) {
  queryParams <- parseQueryString(isolate(session$clientData$url_search))
  if ('tab' %in% names(queryParams))
    updateTabsetPanel(session, 'tabset', selected = paste0('tab', queryParams[['tab']]))
  
  load("df.Rdata")  
  
  ##########################################################################
  # Left panel stuff
  ##########################################################################
  data <- reactive({    
    df <- df[order(df$id, decreasing=TRUE),]
    if(!input$rt){
      df <- subset(df, !isRetweet)
    }    
    if(input$search.term != ""){
      df <- subset(df, grepl(tolower(input$search.term), tolower(df$text)))
    }
    # tzs: "America/Los_Angeles" "America/Chicago" "America/New_York"
    df$created <- with_tz(df$created + (60*60), "America/Chicago")
    
    daterange <- input$daterange
    start.date <- daterange[1]
    end.date <- daterange[2]
    df$created2 <- as.Date(df$created)
    start.date <- ifelse(start.date < min(df$created2), 
                         min(df$created2), start.date)
    start.date <- ifelse(start.date > max(df$created2), 
                         max(df$created2) - 7, start.date)
    end.date <- ifelse(end.date > max(df$created2), 
                       max(df$created2), end.date)
    df <- subset(df, created2 >= start.date &
                   created2 <= end.date)    
    
    df
  })
  
  output$tweets <- renderTable({
    df <- data()
    df <- subset(df, select=c("text", "screenName", "created"))
    df$created <- as.character(df$created)
    df
  },include.rownames = FALSE)
  
  ##########################################################################
  # Tweets tab stuff
  ##########################################################################
  output$tweet_table <- renderUI({
    df <- data()
    tab <- subset(df, select=c("text_with_links", "created",
                               "status_link"))
    names(tab) <- c("Tweet Text", "Created At", "Link")
    HTML(df2html(tab, class = "tbl", id = "tweet_table"))
  })
  output$tweet_table2 <- renderTable({
    df <- data()
    df$created <- as.character(df$created)
    tab <- subset(df, select=c("screenName", "text_with_links", "created",
                               "status_link"))
    names(tab) <- c("Author", "Tweet Text", "Created At", "Link")
    tab
  },include.rownames = FALSE, sanitize.text.function=function(x){x})
  
  ##########################################################################
  # Author tab stuff
  ##########################################################################
  get.author.freq.table <- reactive({
    df <- data()
    tab <- table(df$screenName)
    author.df <- data.frame(author=names(tab), count=as.numeric(tab),
                           stringsAsFactors=F)
    author.df <- author.df[order(author.df$count, decreasing=T),]
    #author.df <- subset(author.df, hostname!="")
    author.df
  })
  
  get.selected.author <- reactive({
    if(!is.null(input$author.freq.table)){
      if(input$author.freq.table > 0){
        author.df <- get.author.freq.table()
        ret <- author.df[input$author.freq.table,1]
      }else{
        ret <- "NULL"
      }
    }else{
      ret <- "NULL"
    }
    ret
  })
  
  output$author.freq.table <- renderUI({
    author.df <- get.author.freq.table()
    names(author.df) <- c("Author", "Count")
    HTML(df2html(author.df, class = "tbl selRow author_freq_table",
                 id = "author.freq.table"))
  })
  
  output$author.table <- renderTable({
    df <- data()
    selected.author <- get.selected.author()
    if(selected.author != "NULL"){
      df.filtered <- subset(df, screenName==selected.author)
    }else{
      df.filtered <- df[1:200,]
    }
    tab <- subset(df.filtered, select=c("text_with_links", "created",
                                        "status_link"))
    tab$created <- as.character(tab$created)
    names(tab) <- c("Tweet Text", "Created At", "Link")
    tab
    #HTML(df2html(tab, class = "tbl author_table", id = "author.table"))
  },include.rownames = FALSE, sanitize.text.function=function(x){x})
  
  output$downloadData <- downloadHandler(
    filename = function() {
      "cfasummit_tweets.csv"
    },
    content = function(file) {
      write.csv(data()[,1:16], file, row.names=F)
    }
  )
  
  # debug stuff... remove eventually  
  #observe({print(paste0("Table 2: ", ifelse(is.null(input$author.freq.table), "NULL", input$author.freq.table)))})
  #observe({print(input$daterange)})  
  #observe({print(str(input$daterange))})  
  
  
})