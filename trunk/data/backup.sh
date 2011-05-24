#!/bin/bash
# download all file from web (to commit them to svn later)
find | grep -v svn | grep dat | while read i; do
    n=`echo $i | sed 's/^.//'`
    echo "http://ayass.xf.cz/ghost/data$n --> $i"
    wget -qO $i "http://ayass.xf.cz/ghost/data$n"
done

# backup also chat and feedback data
echo "Backing up chat and feedback..."
wget -qO ../www/chat.txt "http://ayass.xf.cz/ghost/chat.txt"
wget -qO ../www/feedback.txt "http://ayass.xf.cz/ghost/feedback.txt"

echo DONE
read