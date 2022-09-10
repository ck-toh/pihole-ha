#!/bin/bash
A=`docker ps --filter name=pihole --format "table {{.ID}}\t{{.Names}}\t{{.Status}}"|wc -l`
if [ $A -eq 2 ];then
    echo "pihole running";
    exit 0;
else
    echo "pihole not running";
    exit 1;
fi
