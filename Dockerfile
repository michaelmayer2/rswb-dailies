FROM ubuntu:18.04

# Locale configuration --------------------------------------------------------#
ENV LANG en_US.UTF-8
ENV LANGUAGE en_US:en
ENV LC_ALL en_US.UTF-8
ENV DEBIAN_FRONTEND=noninteractive
ENV RSW_LICENSE ""
ENV R_VERSION_LIST="3.2.5 3.4.4 3.6.3 4.0.5 4.1.2"

RUN apt-get update && apt-get install -y gdebi wget vim


RUN for R_VERSION in $R_VERSION_LIST; do wget https://cdn.rstudio.com/r/ubuntu-1804/pkgs/r-${R_VERSION}_1_amd64.deb && gdebi -n r-${R_VERSION}_1_amd64.deb && rm r-${R_VERSION}_1_amd64.deb; done

RUN wget https://rstudio.org/download/latest/daily/server/bionic/rstudio-workbench-latest-amd64.deb && gdebi -n rstudio-workbench-latest-amd64.deb && rm rstudio-workbench-latest-amd64.deb

RUN /usr/lib/rstudio-server/bin/license-manager activate $RSW_LICENSE
