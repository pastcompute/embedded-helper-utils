# A script to apply OpenWRT patches onto a stock kernel with a git commit corresponding to each patch.
#
# Run this inside the root of a Linux kernel sources directory that is being tracked in git
#
# By default will look for openwrt sources in a co-located directory
#
#
# Argument $1 : should be a Linux point release tag e.g. v3.14.27
#

SOURCES=${SOURCES:-../openwrt}

VERSION=$1

test -z $VERSION && { echo "Missing VERSION argument (e.g: v3.14.27)" ; exit 1; }

set -e
set -x

git branch -f owrt-applied-on-$VERSION
git checkout owrt-applied-on-$VERSION


X=${SOURCES}/target/linux/generic/files
cp -av $X/* .

X=${SOURCES}/target/linux/ar71xx/files
cp -av $X/* .

X=${SOURCES}/target/linux/generic/patches-3.14
for x in `cd $X ; ls |sort` ; do
  echo "PATCH: [$X/$x]"
  patch -f -p1 -E -d. < $X/$x || { echo "Fix any conflicts then exit this shell..." ; bash; true; }
  git add -A ; git commit -m "$x"
done

X=${OWRT_SOURCES}/target/linux/ar71xx/patches-3.14
for x in `cd $X ; ls |sort` ; do
  echo "PATCH: [$X/$x]"
  patch -l -f -p1 -E -d. < $X/$x || { echo "Fix any conflicts then exit this shell..." ; bash; true; }
  git add -A ; git commit -m "$x"
done

