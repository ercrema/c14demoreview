executeOxcal  <- function (oxcal_script,option_file) 
{
	oxcal_path <- getOption("oxcAAR.oxcal_path") 
	output_file <- paste(option_file, ".js", sep = "")
	cat(oxcal_script, file = option_file)
	suppressWarnings(system(paste(shQuote(normalizePath(oxcal_path)),option_file)))
	result <- output_file
	result
}

