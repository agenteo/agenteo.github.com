#!/bin/bash
docker run -p 4000:4000 -v $(pwd):/app --rm -i -t teottidotcom ./script/preview.sh
