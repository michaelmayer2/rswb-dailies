

wget -O index.json https://dailies.rstudio.com/rstudio/spotted-wakerobin/index.json
version=`cat index.json | jq -r ".workbench.platforms.bionic.version" | sed 's#+#-#'`
link=`cat index.json | jq -r ".workbench.platforms.bionic.link"`


docker build --build-arg RSTUDIO_LINK=$link . -t rswb-dailies:$version -t rswb-dailies:latest 
