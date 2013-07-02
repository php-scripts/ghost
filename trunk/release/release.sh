#!/bin/bash
# create all-in-one zip/tgz package with web version of ghost

# download current SVN version of ghost and purin2 library
rm -rf svn 2>/dev/null
mkdir -p svn
(cd svn; svn checkout http://ghost.googlecode.com/svn/trunk/ ghost)

# temporary directory with released version
DIR=ghost-`date +%Y-%m-%d`

# create temporary directory for release
#mkdir $DIR || exit 1

# copy data
mkdir -p $DIR/data
mkdir -p $DIR/data
cp -a svn/ghost/data/sk $DIR/data
cp -a svn/ghost/data/en $DIR/data

# copy web sources
cp -a svn/ghost/www/* $DIR/

# some files are not necessary in release
rm $DIR/next/next.tpr

# create some files that are not on SVN but will be created on the fly
touch $DIR/antispam.log
touch $DIR/log.txt
touch $DIR/data/en/lurker.local $DIR/data/sk/lurker.local

# set proper access rights (writable files)
chmod 666 $DIR/chat.txt
chmod 666 $DIR/antispam.log
chmod 666 $DIR/feedback.txt
chmod 666 $DIR/log.txt
chmod 666 $DIR/next/reindex.log
chmod 666 $DIR/data/en/improve.dat
chmod 666 $DIR/data/sk/improve.dat
chmod 666 $DIR/data/en/topic.dat
chmod 666 $DIR/data/sk/topic.dat
chmod 666 $DIR/data/en/sam.idx
chmod 666 $DIR/data/sk/sam.idx
chmod 666 $DIR/data/en/lurker.local
chmod 666 $DIR/data/sk/lurker.local

# publish on localhost (so that next can be reindexed)
sudo rm /var/www/ghost
sudo ln -s $PWD/$DIR /var/www/ghost

# reindex ghost-next
wget -qO - 'http://localhost/ghost/next/reindex.php?password=secret&lang=en'
wget -qO - 'http://localhost/ghost/next/reindex.php?password=secret&lang=sk'

# create final package
tar cz $DIR/* > $DIR.tgz
zip -r $DIR.zip $DIR