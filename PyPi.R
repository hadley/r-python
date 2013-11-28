library(httr)
library(ggplot2)
library(XML)
library(stringr)
library(reshape2)

base <- "https://pypi.python.org/stats/months/"
doc <- content(GET(base),as="text")
regexp <- "([[:digit:]]{4})-([[:digit:]]{2}).bz2"
filenames <- unique(str_extract_all(doc,regexp)[[1]])


dest <- "~/Desktop/PyPiFiles"
dir.create(dest)

getFile <- function(filename){
  Sys.sleep(10)
  theFile <- getBinaryURL(paste0(base,filename))
  writeBin(theFile, paste(dest,filename,sep="/"))
}

#download the files
lapply(filenames, getFile)

#unzip the files...works on MacOS (and Linux, I would think)
lapply(filenames, FUN=function(filename) try(system(paste0("bzip2 -d ", dest,"/",filename))))



dataAnalysisPackages <- c("pandas","matplotlib", "numpy","scipy")

summarizeFiles <- function(filename){
  TEMP <- read.csv(filename,header=FALSE)
  packageCounts <- table(TEMP[,1])
  packageCounts[dataAnalysisPackages]
}

#do the summary, takes a long time
packageDownloads <- lapply(list.files(dest,full=TRUE), FUN=summarizeFiles)

packageDownloads <- lapply(packageDownloads, FUN = function(x)  as.numeric(x) )
packageDownloads <- as.data.frame(do.call(rbind,packageDownloads))
names(packageDownloads) <- dataAnalysisPackages
packageDownloads$month <- list.files(dest)
thePlot <- qplot(x=month,y=value, data=melt(packageDownloads,id="month"), geom="line",group=variable, color=variable)
thePlot + theme(axis.text.x=element_text(angle = -90, hjust = 0))
#what the heck happened in March 2013?
ggsave("images/PyPiPackages.png", width = 8, height = 6) 