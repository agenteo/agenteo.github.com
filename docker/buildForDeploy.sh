#!/bin/bash
docker run --user $(id -u $(whoami)) -v $(pwd):/app --rm -i -t teottidotcom ./script/build_pages_for_deploy.sh
