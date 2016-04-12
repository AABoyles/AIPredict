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
  years <- 1993:currentYear
  months <- c("06", "11")
  for(year in years){
    for(month in months){
      if(currentYear == year & currentMonth <= as.integer(month)) break
      filename <- paste0("TOP500_", year, month, ".xls")
      if(!file.exists(paste0("data-raw/", filename))){
        #TODO: Add a CURL call to login.
        download.file(paste0("http://www.top500.org/lists/", year, "/", month,"/download/", filename), paste0("data-raw/", filename))
      }
      skip   <- ifelse(year < 2008, 1, 0)
      temp   <- read_excel(paste0("data-raw/", filename), skip = skip)
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
