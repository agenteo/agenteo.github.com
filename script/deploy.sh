#!/bin/sh
#
# Simple deploy script for this blog.

: ${DEPLOY:=_deploy}
: ${BRANCH:=HEAD}

cd $DEPLOY
git add --all
git commit -m "Published $(date)"
git push -fu origin $BRANCH
cd ..
