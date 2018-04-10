#!/bin/sh
#
# Simple deploy script for this blog.

cd _deploy
git add --all
git commit -m "Published $(date)"
git push -fu origin master
cd ..
