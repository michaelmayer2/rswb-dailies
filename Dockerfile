FROM ubuntu:18.04

# Locale configuration --------------------------------------------------------#
ENV LANG en_US.UTF-8
ENV LANGUAGE en_US:en
ENV LC_ALL en_US.UTF-8
ENV DEBIAN_FRONTEND=noninteractive
ENV RSW_LICENSE ""
ENV R_VERSION_LIST="4.1.3 3.4.3"

RUN groupadd -g 2000 mm && useradd -m -u 2000 mm -g mm
RUN echo "mm:test123" | chpasswd 
RUN apt-get update && apt-get install -y wget vim gdebi libicu-dev locales openjdk-11-jdk openjdk-8-jdk libfontconfig1-dev libcurl4-openssl-dev libssl-dev

RUN locale-gen en_US.UTF-8 && dpkg-reconfigure locales

RUN for R_VERSION in $R_VERSION_LIST; do wget https://cdn.rstudio.com/r/ubuntu-1804/pkgs/r-${R_VERSION}_1_amd64.deb && gdebi -n r-${R_VERSION}_1_amd64.deb && rm r-${R_VERSION}_1_amd64.deb; done

RUN apt-get install -y gcc-5 g++-5

RUN sed -i 's/gcc/gcc-5/' /opt/R/3.*/lib/R/etc/Makeconf
RUN sed -i 's/g++/g++-5/' /opt/R/3.*/lib/R/etc/Makeconf

COPY create.R /tmp

RUN for R_VERSION in $R_VERSION_LIST; do /opt/R/$R_VERSION/bin/Rscript /tmp/create.R; done

RUN /bin/bash -c "for R_VERSION in \$R_VERSION_LIST; do if [ \${R_VERSION:0:1} == '3' ]; then export JAVA_HOME=/usr/lib/jvm/java-8-openjdk-amd64/; else export JAVA_HOME=/usr/lib/jvm/java-11-openjdk-amd64/; fi; /opt/R/\$R_VERSION/bin/R CMD javareconf; done"

COPY run.R /tmp
RUN for R_VERSION in $R_VERSION_LIST; do /opt/R/$R_VERSION/bin/Rscript /tmp/run.R; done

ARG RSTUDIO_LINK
RUN wget $RSTUDIO_LINK && gdebi -n rstudio-workbench-*.deb && rm -f rstudio-workbench-*.deb

COPY etc/* /etc/rstudio/
COPY start-rstudio.sh /usr/local/bin

RUN echo "RSTUDIO_DISABLE_PACKAGE_INSTALL_PROMPT=yes" >> /etc/rstudio/rsession-profile 

RUN bash -c "mkdir -p /projects/{a,b,c}" && ls /projects && touch /projects/a/file.txt && chown mm /projects/b && touch /projects/b/mm-writable.txt  

CMD /usr/local/bin/start-rstudio.sh
