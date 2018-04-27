######################################################################
## R code to scrape Asahi Shimbun wesite to get election returns of
## Japanese General Election in 2017
## Author: Ikuma Ogura
## Last modified: October 25, 2017
#####################################################################

## Load package
require(XML)

##
## SMD results
##
dat <- data.frame()
pref.code <- as.character(1:47)
pref.code[nchar(pref.code) == 1] <- paste0("0", pref.code[nchar(pref.code) == 1])
for (i in 1:47){ # loop over prefectures
  u <- paste0("http://www.asahi.com/senkyo/senkyo2017/kaihyo/A", pref.code[i], ".html")
  p <- htmlParse(u)
  pref <- substring(xpathApply(p, "//title", xmlValue)[[1]], 1, 
                    regexpr("-", xpathApply(p, "//title", xmlValue)[[1]]) - 1)
  ndist <- length(xpathApply(p, "//div/ul[@class = 'snkSubnavi']/li/a"))
  tab <- readHTMLTable(u)
  for (j in 1:ndist){
    tmp <- tab[[j]]
    tmp[,1] <- as.character(tmp[,1])
    tmp[,1] <- pref # prefecture name
    tmp[,2] <- as.character(tmp[,2])
    tmp[1, 2] <- 1 # SMD winner
    tmp[-1, 2] <- 0
    tmp[,4] <- substring(as.character(tab[[j]][,4]), 1, 
                         regexpr(",", as.character(tab[[j]][,4])) + 3) # n votes
    tmp[,5] <- as.character(tmp[,5]) 
    tmp[,5] <- j # district
    tmp[,6] <- as.character(tmp[,6]) # occupation
    tmp[,7] <- as.character(tmp[,7]) # party   
    tmp[,8] <- as.character(tmp[,8]) # incumbency status
    tmp[,9] <- as.character(tmp[,9]) # n elected
    tmp[,10] <- as.character(tmp[,10]) # run for PR tier
    dat <- rbind(dat, tmp)
  }
  cat("Finished collecting data on ", pref, "\n")
  Sys.sleep(2)
}

## Change column names
colnames(dat)[1] <- "prefecture"
colnames(dat)[2] <- "SMD.win"
colnames(dat)[3] <- "name.age"
colnames(dat)[4] <- "n.votes"
colnames(dat)[5] <- "district"
colnames(dat)[6] <- "occupation"
colnames(dat)[7] <- "party"
colnames(dat)[8] <- "incumbency.status"
colnames(dat)[9] <- "n.elected"
colnames(dat)[10] <- "PR"

## Save data
write.csv(dat, "Japan_Diet_SMD_2017.csv")
save(dat, file = "Japan_Diet_SMD_2017.RData")

