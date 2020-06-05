#!/bin/sh

set -e

BUILD_FOLDER="${BUILD_FOLDER:-$HOME/im}"
mkdir -p $BUILD_FOLDER && rm -Rf $BUILD_FOLDER/* && cd $BUILD_FOLDER

# libpng
wget -qO- http://prdownloads.sourceforge.net/libpng/libpng-1.6.37.tar.gz | tar xfvz -
cd libpng-1.6.37
./configure --disable-shared --disable-dependency-tracking --enable-static --prefix=$BUILD_FOLDER/compiled/delegates
make && make install && cd ..

# libjpeg
wget -qO- http://ijg.org/files/jpegsrc.v9d.tar.gz | tar xfvz -
cd jpeg-9d
./configure --disable-shared --disable-dependency-tracking --enable-static --prefix=$BUILD_FOLDER/compiled/delegates
make && make install && cd ..

# libfreetype
wget -qO- http://download.savannah.gnu.org/releases/freetype/freetype-2.10.1.tar.gz | tar xfvz -
cd freetype-2.10.1
PKG_CONFIG_PATH="$BUILD_FOLDER/compiled/delegates/lib/pkgconfig/" LDFLAGS="-L$BUILD_FOLDER/compiled/delegates/lib" \
CPPFLAGS="-I$BUILD_FOLDER/compiled/delegates/include" ./configure --disable-shared --disable-dependency-tracking \
--enable-static --prefix=$BUILD_FOLDER/compiled/delegates
make && make install && cd ..

# ImageMagick
wget -qO- https://imagemagick.org/download/ImageMagick.tar.gz | tar xfvz -
cd ImageMagick-7.0.10-16
PKG_CONFIG_PATH="$BUILD_FOLDER/compiled/delegates/lib/pkgconfig/" \
LDFLAGS="-L$BUILD_FOLDER/compiled/delegates/lib" \
CPPFLAGS="-I$BUILD_FOLDER/compiled/delegates/include -I$BUILD_FOLDER/compiled/delegates/include/freetype2" ./configure \
  --prefix $BUILD_FOLDER/compiled/target \
  --enable-shared=no \
  --enable-static \
  --enable-delegate-build \
  --disable-dependency-tracking \
  --without-modules \
  --without-perl \
  --without-x \
  --without-magick-plus-plus \
  --enable-hdri=no \
  --disable-docs \
  --with-jpeg=yes \
  --with-png=yes \
  --with-xml=yes \
  --with-freetype=yes
make LDFLAGS="-all-static" all && make install && cd ..

cd $BUILD_FOLDER/compiled/target/
zip --symlinks -r -9 $BUILD_FOLDER/layer_ec2.zip bin/ lib/ include/ share/ etc/

exit 0
