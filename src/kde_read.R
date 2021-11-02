x <- readLines("~/Downloads/kde_test.js")

read_kde <- function(x,sigma=1)
{
	x <- x[grep("kde_mean",x)]
	probNorm <- as.numeric(sub(".*?probNorm.*?(\\d+(?:\\.\\d+)?).*", "\\1", x))
	startDate <- as.numeric(sub(".*?start.*?(\\d+(?:\\.\\d+)?).*", "\\1", x))
	resolution <- as.numeric(sub(".*?resolution.*?(\\d+(?:\\.\\d+)?).*", "\\1", x))

        x <- sub('.*prob_sigma:', '', x)
	x <- sub('.','',x) #Remove 1st character
	x <- sub(']};','',x) #Remove ending bit
	x <- gsub("\\[|\\]", "", x)
	x <- gsub('\\\"\\n)', "", x)
	x <- unlist(strsplit(x,',')) |> as.numeric()
	x.mat <- t(matrix(x,nrow=2)) |> as.data.frame()
	colnames(x.mat) <- c('raw.mean','raw.sd')
	x.mat$CalBP <- seq(from=startDate,by=-resolution,length.out=nrow(x.mat))
	x.mat$hi <- (x.mat$raw.mean + x.mat$raw.sd * sigma) * probNorm
	x.mat$lo <- (x.mat$raw.mean - x.mat$raw.sd * sigma) * probNorm
	x.mat$lo[which(x.mat$lo<0)] <- 0
	x.mat$m <- x.mat$raw.mean * probNorm
# 	plot(x.mat$CalBP,x.mat$m,type='n',xlim=rev(range(x.mat$CalBP)))
# 	polygon(c(x.mat$CalBP,rev(x.mat$CalBP)),c(x.mat$lo,rev(x.mat$hi)),border=NA,col=rgb(0,0,1,0.2))
# 	lines(x.mat$CalBP,x.mat$m,type='l',xlim=rev(range(x.mat$CalBP)))
	return(x.mat)
}





