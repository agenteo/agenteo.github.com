#!/bin/sh
#
# Simple deploy script for this blog.

: ${DEPLOY:=_deploy}
: ${BRANCH:=HEAD}

jekyll build -d $DEPLOY
cd $DEPLOY
git add --all
git commit -m "Published $(date)"
git push -fu origin $BRANCH
cd ..
