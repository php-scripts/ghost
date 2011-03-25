#!/bin/bash
# download all file from web (to commit them to svn later)
find | grep -v svn | grep dat | while read i; do
    n=`echo $i | sed 's/^.//'`
    echo "http://ayass.xf.cz/ghost/data$n --> $i"
    wget -qO $i "http://ayass.xf.cz/ghost/data$n"
done
