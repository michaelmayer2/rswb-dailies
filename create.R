# Needs to be run as an admin that has write permissions to /etc/rstudio
#
# This script when run against any R version will 
# * figure out which compatible BioConductor Version exist
# * get all the URLs for the repositories of BioConductor
# * Add both CRAN and BioConductor 
#       into files in /etc/rstudio/repos/repos-x.y.z.conf
# * add entries into /etc/rstudio/r-versions to define the respective 
#       R version (x.y.z) and point to the repos.conf file  

# OS flag for binaries (leave empty if not needed)

binaryflag <- "__linux__/bionic"

snapshot <- "latest"

# Check if BiocManager is installed - needed to determine BioConductor Version
if ( ! "BiocManager" %in% utils::installed.packages() ) {
    Sys.setenv(R_PROFILE_USER = "/dev/null")
    system(paste("mkdir -p", Sys.getenv("R_LIBS_USER")))
    utils::install.packages("BiocManager",quiet=TRUE,repos="https://cran.r-project.org/", lib=Sys.getenv("R_LIBS_USER"))
    Sys.unsetenv("R_PROFILE_USER")
  }
library(BiocManager, lib.loc=Sys.getenv("R_LIBS_USER"),quietly=TRUE,verbose=FALSE)
# Get current repo settings
r <- getOption("repos")

# Package Manager URL
pm <- "http://192.168.0.100:4242"

# Version of BioConductor as given by BiocManager (can also be manually set)
biocvers <- BiocManager::version()

# Bioconductor Repositories
r<-gsub("https://bioconductor.org", paste0(pm,"/bioconductor/",binaryflag), BiocManager::repositories(version=biocvers))

# CRAN repo
r["CRAN"] <- paste0(pm,"/cran/",binaryflag,"/",snapshot,"/")

nr=length(r)
r<-c(r[nr],r[1:nr-1])

rverstring=paste0(R.version$major,".",R.version$minor)
 
system("mkdir -p /etc/rstudio/repos")
filename=paste0("/etc/rstudio/repos/repos-",rverstring,".conf")
sink(filename)
for (i in names(r)) {cat(noquote(paste0(i,"=",r[i],"\n"))) }
sink()

x<-unlist(strsplit(R.home(),"[/]"))
r_home<-paste0(x[2:length(x)-2],"/",collapse="")

sink("/etc/rstudio/r-versions", append=TRUE)
cat("\n")
cat(paste0("Path: ",r_home,"\n"))
cat(paste0("Label: R","\n"))
cat(paste0("Repo: ",filename,"\n"))
cat("\n")
sink()


sink(paste0("/opt/R/",rverstring,"/lib/R/etc/Rprofile.site"),append=TRUE)
if ( rverstring < "4.1.0" ) {
  cat('.env = new.env()\n')
}
cat('local({\n')
cat('r<-options()$repos\n')
for (line in names(r)) {
   cat(paste0('r["',line,'"]="',r[line],'"\n'))
}
cat('options(repos=r)\n') 
libdir <- paste0("/data/rver/",rverstring)
cat(paste0('.libPaths(c(.libPaths(),"',libdir,'"))\n'))
if ( rverstring < "4.1.0" ) {
cat('}, envir = .env)\n')
cat('attach(.env)\n')
} else {
cat('})\n')
}
sink()
