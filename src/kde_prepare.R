kde.prepare <- function(cra,cra.error,id=NA,fn=NA)
{
	if (anyNA(id)){id = 1:length(cra)}
	export <- file(fn) #create export file
	cat("Plot(){\n",file=fn,append=FALSE) #Start Sequence#
	cat('KDE_Model("")\n',file=fn,append=TRUE)
	cat('{\n',file=fn,append=TRUE)
	for (x in 1:length(cra))
	{
		cat(paste('R_Date(','\"',id[x],'\",',cra[x],',',cra.error[x],');\n',sep=""),file=fn,append=TRUE)
	}
	
	cat('};\n',file=fn,append=TRUE)
	cat('};\n',file=fn,append=TRUE)
}

