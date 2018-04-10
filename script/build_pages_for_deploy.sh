#!/bin/sh
#
# Simple deploy script for this blog.

: ${DEPLOY:=_deploy}

jekyll build -d $DEPLOY
