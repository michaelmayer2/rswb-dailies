currver <- paste0(R.Version()$major,".",R.Version()$minor)
libdir <- paste0("/data/rver/",currver)

if(dir.exists(libdir)) {unlink(libdir,recursive=TRUE)}
dir.create(libdir,recursive=TRUE)
.libPaths(libdir)

if(dir.exists("/tmp/curl")) {unlink("/tmp/curl",recursive=TRUE)}
dir.create("/tmp/curl")
install.packages("RCurl","/tmp/curl", repos="stat.ethz.ch/CRAN")
library(RCurl,lib.loc="/tmp/curl")


pnames=c("DBI", "R6", "RJDBC", "RODBC", "RSQLite", "Rcpp", "base64enc", "checkmate", "crayon", "commonmark", "curl", "devtools", "digest", "evaluate", "ellipsis", "fastmap", "glue", "haven", "highr", "htmltools", "htmlwidgets", "httpuv", "jsonlite", "keyring", "knitr", "later", "learnr", "lifecycle", "magrittr", "markdown", "mime", "miniUI", "mongolite", "odbc", "openssl", "packrat", "plumber", "png", "profvis", "promises", "r2d3", "ragg", "rappdirs", "rJava", "readr", "readxl", "renv", "reticulate", "rlang", "rmarkdown", "roxygen2", "rprojroot", "rsconnect", "rstan", "rstudioapi", "shiny", "shinytest", "sourcetools", "stringi", "stringr", "testthat", "tinytex", "withr", "xfun", "xml2", "xtable", "yaml")


currver <- paste0(R.Version()$major,".",R.Version()$minor)
releasedate <- paste0(R.version$year,"-",R.version$month,"-",R.version$day)
 
repo=paste0("https://packagemanager.rstudio.com/cran/__linux__/bionic/",releasedate)

# Attempt to install packages from snapshot - if snapshot does not exist, increase day by 1 and try again
getreleasedate <- function(repodate){
  
  repo=paste0("https://packagemanager.rstudio.com/cran/__linux__/bionic/",repodate)

  URLfound=FALSE
  while(!URLfound) {
   if (!RCurl::url.exists(paste0(repo,"/src/contrib/PACKAGES"),useragent="curl/7.39.0 Rcurl/1.95.4.5")) {
	repodate<-as.Date(repodate)+1
        cat(repodate)
        repo=paste0("https://packagemanager.rstudio.com/cran/__linux__/bionic/",repodate)
   } else {
   URLfound=TRUE
   }
 }
 return(repodate)
}

releasedate <- getreleasedate(releasedate)

repo=paste0("https://packagemanager.rstudio.com/cran/__linux__/bionic/",releasedate)

avpack<-available.packages(paste0(repo,"/src/contrib"))

for (package in pnames) {
if (package %in% avpack) {
install.packages(package,repos=repo,libdir)
}
}

sink(paste0("/opt/R/",currver,"/lib/R/etc/Rprofile.site"), append=TRUE)
cat(paste0('.libPaths(c(.libPaths(),"',libdir,'"))'))
sink() 
