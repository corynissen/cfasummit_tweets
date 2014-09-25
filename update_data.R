
library(twitteR)
library(stringr)

# if creds aren't saved, run this and save them
# creds <- scan("/home/c/cn/personal/keys/chireply_keys.txt", what="character",
#               sep="\n")
# creds <- substring(creds, regexpr(":  ", creds)+3, nchar(creds))
# 
# twitCred = list(consumerKey = creds[1],
#                 consumerSecret = creds[2],
#                 oauthKey = creds[6],
#                 oauthSecret = creds[7])
# 
# reqURL <- "https://api.twitter.com/oauth/request_token"
# accessURL <- "https://api.twitter.com/oauth/access_token"
# authURL <- "https://api.twitter.com/oauth/authorize"
# 
# cred <- OAuthFactory$new(consumerKey=twitCred$consumerKey, 
#                          consumerSecret=twitCred$consumerSecret,
#                          requestURL=reqURL,accessURL=accessURL,
#                          authURL=authURL)
# cred$handshake()
# registerTwitterOAuth(cred)
# save(cred, file="chireply_cred.Rdata")

add_cols <- function(df){
  df$status_link <- paste0('<a href="https://twitter.com/', df$screenName,
                           '/status/', df$id,
                           '" target="_blank">View on Twitter</a>')
  df$embedded_url <- str_extract(df$text,
                                 "http://[A-Za-z0-9].[A-Za-z]{2,3}/[A-Za-z0-9]+")
  df$text_with_links <- ifelse(is.na(df$embedded_url), df$text,
                               str_replace(df$text, df$embedded_url,
                                           paste0('<a href="', df$embedded_url,
                                                  '" target="_blank">', df$embedded_url, '</a>')))
  return(df)
}


load("chireply_cred.Rdata")
registerTwitterOAuth(cred)
# if no file exists, get the last week of data for a given hashtag
if(!file.exists("df.Rdata")){
  tweets_list <- searchTwitter("#cfasummit", n=5000, since=as.character(Sys.Date()-7))
  df <- twListToDF(tweets_list)
  df$id <- as.numeric(df$id)
  df <- add_cols(df)
  save(df, file="df.Rdata")
}else{
  load("df.Rdata")
  max_id <- as.character(max(df$id))
  new_tweets_list <- searchTwitter("#cfasummit", n=5000, sinceID=max_id)
  if(length(new_tweets_list) > 0){
    new_df <- twListToDF(new_tweets_list)
    new_df$id <- as.numeric(new_df$id)
    new_df <- add_cols(new_df)
    df <- rbind(df, new_df)
    df <- subset(df, !duplicated(df))
    df$id <- as.numeric(df$id)
    save(df, file="df.Rdata")
  }
}



