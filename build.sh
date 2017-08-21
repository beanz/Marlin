#!/bin/sh

set -e

MODE=upload
if [ -n "${1:-}" ] && [ "x${1:-}" = "x-n" ]; then
  MODE=verify
else
  if ! git diff-index --quiet HEAD -- ; then
    echo "there are local changes; forcing verify mode"
    MODE=verify
  fi
fi

echo $MODE

echo cleaning old build
rm -rf .build

echo building for $MODE
$HOME/Tmp/arduino-1.6.11/arduino \
  --$MODE \
  --board arduino:avr:mega:cpu=atmega2560 \
  --pref build.path=.build --preserve-temp-files \
  --port  /dev/ttyACM0 \
  Marlin/Marlin.ino

if [ "${MODE}" = 'verify' ]; then
  echo "verify mode; not recording branch"
  exit
fi

CURRENT=`git rev-parse --abbrev-ref HEAD`
BRANCH=builds/${CURRENT}-`date +%Y%m%d-%H%M%S`
echo making build branch ${BRANCH} from ${CURRENT}
git checkout -b ${BRANCH}

echo adding built files
git add .build

echo committing build
git commit -m "Add uploaded build"

echo checking out ${CURRENT} again
git checkout -- .
git checkout ${CURRENT}
