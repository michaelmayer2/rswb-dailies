#!/bin/bash

echo "nameserver 8.8.8.8" > /etc/resolv.conf

/usr/lib/rstudio-server/bin/license-manager activate $RSW_LICENSE

rstudio-server start
rstudio-launcher start 

while true
do
sleep 120
done
