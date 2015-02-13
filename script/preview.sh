#!/bin/sh
set -v

: ${PORT:=4004}

jekyll serve -P $PORT --baseurl=''
