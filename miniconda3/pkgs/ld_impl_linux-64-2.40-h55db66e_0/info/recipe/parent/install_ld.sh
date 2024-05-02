#!/bin/bash

set -e

cd build

make DESTDIR=$PWD/install install-strip

CHOST="${triplet}"
OLD_CHOST="${triplet/conda/${ctng_vendor}}"
mkdir -p $PREFIX/bin
mkdir -p $PREFIX/$OLD_CHOST/bin
mkdir -p $PREFIX/$CHOST/bin
if [[ "$target_platform" == "$cross_target_platform" ]]; then
  cp $PWD/install/$PREFIX/bin/ld $PREFIX/bin/$CHOST-ld
else
  cp $PWD/install/$PREFIX/bin/$CHOST-ld $PREFIX/bin/$CHOST-ld
fi
if [[ "$CHOST" != "$OLD_CHOST" ]]; then
  ln -s $PREFIX/bin/$CHOST-ld $PREFIX/bin/$OLD_CHOST-ld
  ln -s $PREFIX/bin/$CHOST-ld $PREFIX/$OLD_CHOST/bin/ld
fi
ln -s $PREFIX/bin/$CHOST-ld $PREFIX/$CHOST/bin/ld
