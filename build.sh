#!/bin/sh

set -e

PATH=~/Tmp/arduino-1.8.10:$PATH platformio run -e megaatmega2560
if [ -n "$1" -a "x$1" = "x-n" ]; then
  exit 0
fi

echo saving

CURRENT=`git rev-parse --abbrev-ref HEAD`
BRANCH=builds/${CURRENT}-`date +%Y%m%d-%H%M%S`
echo making build branch ${BRANCH} from ${CURRENT}
git checkout -b ${BRANCH}

echo adding built files
git add -f .pio*

echo committing build
git commit -m "Add build before upload."

echo uploading
PATH=~/Tmp/arduino-1.8.10:$PATH platformio run --target upload -e megaatmega2560

echo checking out ${CURRENT} again
git checkout -- .
git checkout ${CURRENT}
