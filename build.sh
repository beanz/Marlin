#!/bin/sh

set -e

TEST=0
if [ -n "$1" -a "x$1" = "x-n" ]; then
  TEST=1
fi

( rm -f src ; ln -sf Marlin src ) || true

echo cleaning
ino clean

echo removing .pde file
rm -f Marlin/Marlin.pde

echo building
ino build

if [ $TEST = "1" ]; then
  git checkout -- Marlin/Marlin.pde
  rm -f src
  exit
fi

CURRENT=`git rev-parse --abbrev-ref HEAD`
BRANCH=builds/${CURRENT}-`date +%Y%m%d-%H%M%S`
echo making build branch ${BRANCH} from ${CURRENT}
git checkout -b ${BRANCH}

echo adding built files
git add .build

echo removing .pde from git
#git rm Marlin/Marlin.pde

echo committing build
git commit -m "Add build before upload."

echo uploading
ino upload

echo checking out ${CURRENT} again
git checkout -- .
git checkout ${CURRENT}

rm -f src
