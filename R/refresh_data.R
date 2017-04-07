#' Refresh Top 500
#'
#' @return A Data Frame containing all the available top 500 lists
#' @export
#'
#' @examples
refresh_top_500 <- function(){
  currentYear  <- as.integer(format(Sys.Date(), "%Y"))
  currentMonth <- as.integer(format(Sys.Date(), "%m"))
  top500 <- NULL
  for(year in 1993:currentYear){
    for(month in c("06", "11")){
      if(currentYear == year & currentMonth <= as.integer(month)) break
      filename <- paste0("TOP500_", year, month, ".xls")
      if(!file.exists(paste0("data-raw/", filename))){
        #TODO: Add a CURL call to login.
        download.file(paste0("http://www.top500.org/lists/", year, "/", month,"/download/", filename), paste0("data-raw/", filename))
      }
      temp   <- readxl::read_excel(paste0("data-raw/", filename), skip = (year < 2008))
      temp   <- cbind(temp, list=paste0(year, month))
      top500 <- rbind.fill(top500, temp)
    }
  }
  return(top500)
}

#' Refresh Bitcoin Hashrate
#'
#' @return A Data Frame containing the Date and the Bitcoin Network's Gigahashes per second
#' @export
#'
#' @examples
refresh_bitcoin_hashrate <- function(){
  ai_bitcoin_hashrate <- read.csv("https://blockchain.info/charts/hash-rate?showDataPoints=false&timespan=all&show_header=true&daysAverageString=1&scale=0&format=csv&address=", header = F)
  names(ai_bitcoin_hashrate) <- c("Date", "GHPS")
  ai_bitcoin_hashrate$Date <- as.Date(ai_bitcoin_hashrate$Date, "%d/%m/%Y")
  return(ai_bitcoin_hashrate)
}

#' Get Graph 500
#'
#' @return A Dataframe containing the Graph500 Dataset
#' @export
#'
#' @examples
get_graph_500 <- function(){
  urls <- readr::read_csv("data-raw/_graph500URLS.csv")
  ai_graph_500 <- NULL
  for(i in 1:nrow(urls)){
    filename <- paste0("data-raw/graph500",urls$year[i],urls$month[i],".csv")
    if(!file.exists(filename)) download.file(urls$url[i], filename)
    readr::read_csv(filename) %>%
      dplyr::mutate(list = paste0(urls$year[i], urls$month[i])) %>%
      rbind(ai_graph_500) ->
      ai_graph_500
  }
  return(ai_graph_500)
}
