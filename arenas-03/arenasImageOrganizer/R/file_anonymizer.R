#!/bin/env R

## File Anonymizer
## Original script by Oliver Tam tam@cshl.edu, Sept 2020    

#' Anonymizes file names in a folder
#' This function will randomize the names of the files in the folder, while
#' keeping a dictionary for the renamed files. This allows anonymization of the
#' experimental conditions for subsequent blinded analysis.
#'
#' @param folder Folder containing files for anonymization
#' @return A dictionary linking the anonymized file to the previous name
#' @export

file_anonymizer <- function(folder,deleteOrig=TRUE){
    ## Check that the folder exists
    if(! dir.exists(folder)){
        log <- paste(c(paste("This folder", folder, "does not exist."),"Please double-check",""))
        return(log)
    }

    today <- Sys.time()
    log <- paste0("Files anonymized in ",folder, " on ", 
                  format(today, format="%d %B, %Y"), " at ", 
                  format(today, format="%I:%M %p"), ":")
  
  ## Identify image files ----
    files <- setdiff(list.files(folder, pattern="\\.czi$|\\.tif$|\\.tiff$|\\.lsm$",full.names = TRUE), list.dirs(recursive = FALSE))
    files <- files[grep("anonymizedFile",files,invert=T)]
    if(length(files) < 1){
        log = c(paste("No suitable files identified in",folder),"")
        return(log)
    }

  ## Anonymize file names by random assignment of number to name based on total number of files ----  
    counter <- 1:length(files)
    dict <- matrix(ncol=2)
    filenum <- sample(counter,length(files))
    for(i in 1:length(files)){
        oldfile <- basename(files[i])
        extension <- tools::file_ext(files[i])
        anonDate <- format(today, format="%y%m%d")
        newfile <- paste0("anonymizedFile_",anonDate,"_",filenum[i],".", extension)
        output <- file.path(folder, newfile)
        file.copy(files[i], output)
        if(deleteOrig){
            file.remove(files[i])
        }
        dict = rbind(dict,c(newfile,oldfile))
    }
      
  ## Write information in the log file ----
    dict <- dict[2:nrow(dict),]
    if(length(files) > 1){
        dict <- dict[order(dict[,1]),]
        log  <- c(log,apply(dict,1,paste,collapse = " is originally "))
    }else{
        log  <- c(log,paste(dict,collapse = " is originally "))
    }
    logfile <- file.path(folder,paste0("file_key_",anonDate,".log"))
    write(log, file=logfile, sep="\n")
    return(log)
}

