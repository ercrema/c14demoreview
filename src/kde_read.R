read_kde <- function(x,sigma=1)
{
	x <- x[grep("kde_mean",x)]
	probNorm <- as.numeric(sub(".*?probNorm.*?(\\d+(?:\\.\\d+)?).*", "\\1", x))
	pattern <- "start:\\s*(.*?)\\s*,resolution"
	startDate <- as.numeric(regmatches(x, regexec(pattern, x))[[1]][2])
	resolution <- as.numeric(sub(".*?resolution.*?(\\d+(?:\\.\\d+)?).*", "\\1", x))

        x <- sub('.*prob_sigma:', '', x)
	x <- sub('.','',x) #Remove 1st character
	x <- sub(']};','',x) #Remove ending bit
	x <- gsub("\\[|\\]", "", x)
	x <- gsub('\\\"\\n)', "", x)
	x <- unlist(strsplit(x,',')) |> as.numeric()
	x.mat <- t(matrix(x,nrow=2)) |> as.data.frame()
	colnames(x.mat) <- c('raw.mean','raw.sd')
	x.mat$BCAD <- seq(from=startDate,by=resolution,length.out=nrow(x.mat))
	x.mat$calBP <- abs(x.mat$BCAD - 1950)
	x.mat$hi <- (x.mat$raw.mean + x.mat$raw.sd * sigma) * probNorm
	x.mat$lo <- (x.mat$raw.mean - x.mat$raw.sd * sigma) * probNorm
	x.mat$lo[which(x.mat$lo<0)] <- 0
	x.mat$m <- x.mat$raw.mean * probNorm
	return(x.mat)
}





