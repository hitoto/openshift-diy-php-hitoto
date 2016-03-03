#!/bin/sh

OPENSHIFT_RUNTIME_DIR=$OPENSHIFT_HOMEDIR/app-root/runtime
OPENSHIFT_REPO_DIR=$OPENSHIFT_HOMEDIR/app-root/runtime/repo

# PHP https://secure.php.net/downloads.php
# NOTE: If VERSION_PHP is set to "git" a checkout from the development sources will be performed instead.
#VERSION_PHP=5.6.12
VERSION_PHP=git

# Apache http://www.gtlib.gatech.edu/pub/apache/httpd/
VERSION_APACHE=2.4.18
# APR http://artfiles.org/apache.org/apr/
VERSION_APR=1.5.2
VERSION_APR_UTIL=1.5.4

# PCRE ftp://ftp.csx.cam.ac.uk/pub/software/programming/pcre
VERSION_PCRE=8.38

# XDebug http://xdebug.org/files/
VERSION_XDEBUG=2.3.3

# ZLib http://zlib.net/
VERSION_ZLIB=1.2.8

# OpenSSL https://www.openssl.org/source/
VERSION_OPENSSL=1.0.2g

# libssh2 https://www.libssh2.org/download/
VERSION_LIBSSH2=1.7.0

# curl https://curl.haxx.se/download/
VERSION_CURL=7.47.1

echo "Prepare directories"
cd $OPENSHIFT_RUNTIME_DIR
mkdir srv
mkdir srv/pcre
mkdir srv/httpd
mkdir srv/php
mkdir srv/openssl
mkdir srv/curl
mkdir tmp

cd tmp/

echo "Install zlib"
wget http://zlib.net/zlib-$VERSION_ZLIB.tar.gz
tar -zxf zlib-$VERSION_ZLIB.tar.gz
cd zlib-$VERSION_ZLIB
./configure \
--prefix=$OPENSHIFT_RUNTIME_DIR/srv/zlib/
make && make install
cd ..

echo "Install OpenSSL"
wget http://www.openssl.org/source/openssl-$VERSION_OPENSSL.tar.gz

tar -zxf openssl-$VERSION_OPENSSL.tar.gz
rm openssl-$VERSION_OPENSSL.tar.gz
cd openssl-$VERSION_OPENSSL
./config \
--prefix=$OPENSHIFT_RUNTIME_DIR/srv/openssl \
--with-zlib-lib=$OPENSHIFT_RUNTIME_DIR/srv/zlib/lib \
--with-zlib-include=$OPENSHIFT_RUNTIME_DIR/srv/zlib/include \
shared zlib

make && make install
cd ..

rm -rf openssl-$VERSION_OPENSSL

echo "Install libssh2"
wget http://www.libssh2.org/download/libssh2-$VERSION_LIBSSH2.tar.gz

tar -zxf libssh2-$VERSION_LIBSSH2.tar.gz
rm libssh2-$VERSION_LIBSSH2.tar.gz
cd libssh2-$VERSION_LIBSSH2
./configure \
--prefix=$OPENSHIFT_RUNTIME_DIR/srv/openssl \
--with-ssl=$OPENSHIFT_RUNTIME_DIR/srv/openssl

make && make install
cd ..

rm -rf libssh2-$VERSION_LIBSSH2

echo "Install curl"
wget https://curl.haxx.se/download/curl-$VERSION_CURL.tar.gz

tar -zxf curl-$VERSION_CURL.tar.gz
rm curl-$VERSION_CURL.tar.gz
cd curl-$VERSION_CURL
env LDFLAGS=-R$OPENSHIFT_RUNTIME_DIR/srv/openssl/lib ./configure \
--enable-libcurl-option \
--with-ssl=$OPENSHIFT_RUNTIME_DIR/srv/openssl \
--with-libssh2=$OPENSHIFT_RUNTIME_DIR/srv/openssl \
--prefix=$OPENSHIFT_RUNTIME_DIR/srv/curl

make && make install
cd ..

rm -rf curl-$VERSION_CURL

echo "Install pcre"
wget ftp://ftp.csx.cam.ac.uk/pub/software/programming/pcre/pcre-$VERSION_PCRE.tar.gz
tar -zxf pcre-$VERSION_PCRE.tar.gz
rm pcre-$VERSION_PCRE.tar.gz
cd pcre-$VERSION_PCRE
./configure \
--prefix=$OPENSHIFT_RUNTIME_DIR/srv/pcre
make && make install
cd ..

rm -rF pcre-$VERSION_PCRE

echo "Install Apache httpd"
wget http://www.gtlib.gatech.edu/pub/apache/httpd/httpd-$VERSION_APACHE.tar.gz
tar -zxf httpd-$VERSION_APACHE.tar.gz
wget http://artfiles.org/apache.org/apr/apr-$VERSION_APR.tar.gz
tar -zxf apr-$VERSION_APR.tar.gz
mv apr-$VERSION_APR httpd-$VERSION_APACHE/srclib/apr
wget http://artfiles.org/apache.org/apr/apr-util-$VERSION_APR_UTIL.tar.gz
tar -zxf apr-util-$VERSION_APR_UTIL.tar.gz
mv apr-util-$VERSION_APR_UTIL httpd-$VERSION_APACHE/srclib/apr-util
cd httpd-$VERSION_APACHE
./configure \
--prefix=$OPENSHIFT_RUNTIME_DIR/srv/httpd \
--with-included-apr \
--with-pcre=$OPENSHIFT_RUNTIME_DIR/srv/pcre \
--with-ssl=$OPENSHIFT_RUNTIME_DIR/srv/openssl \
--enable-so \
--enable-ssl \
--enable-modules=all \
--enable-mods-shared=all \
--disable-dav \
--disable-dav_fs

make && make install
cd ..

#echo "INSTALL ICU"
#wget http://download.icu-project.org/files/icu4c/50.1/icu4c-50_1-src.tgz
#tar -zxf icu4c-50_1-src.tgz
#cd icu/source/
#chmod +x runConfigureICU configure install-sh
#./configure \
#--prefix=$OPENSHIFT_RUNTIME_DIR/srv/icu/
#make && make install
#cd ../..


echo "INSTALL PHP $VERSION_PHP"

if [ "git" = $VERSION_PHP ]
  then
	wget http://ftp.gnu.org/gnu/bison/bison-2.7.tar.gz
	tar -xvzf bison-2.7.tar.gz
	cd bison-2.7
	./configure \
	--prefix=$OPENSHIFT_RUNTIME_DIR/tmp/bison/

	make && make install
	cd ..

	export YACC=$OPENSHIFT_RUNTIME_DIR/tmp/bison/bin/bison
	
	export PKG_CONFIG_PATH=$OPENSHIFT_RUNTIME_DIR/srv/openssl/lib/pkgconfig

    wget https://github.com/php/php-src/archive/master.tar.gz
    tar -zxf master.tar.gz
    cd php-src-master

	./buildconf
else
    wget http://de2.php.net/get/php-$VERSION_PHP.tar.gz/from/this/mirror -O php-$VERSION_PHP.tar.gz
    tar -zxf php-$VERSION_PHP.tar.gz
    cd php-$VERSION_PHP
fi

./configure \
--prefix=$OPENSHIFT_RUNTIME_DIR/srv/php/ \
--with-config-file-path=$OPENSHIFT_RUNTIME_DIR/srv/php/etc/apache2 \
--with-apxs2=$OPENSHIFT_RUNTIME_DIR/srv/httpd/bin/apxs \
--with-zlib=$OPENSHIFT_RUNTIME_DIR/srv/zlib \
--with-libdir=lib64 \
--with-layout=PHP \
--with-gd \
--with-curl=$OPENSHIFT_RUNTIME_DIR/srv/curl \
--with-mysqli \
--with-openssl \
--with-openssl-dir=$OPENSHIFT_RUNTIME_DIR/srv/openssl \
--enable-mbstring \
--enable-zip
#--enable-intl \
#--with-icu-dir=$OPENSHIFT_RUNTIME_DIR/srv/icu \

make && make install
mkdir $OPENSHIFT_RUNTIME_DIR/srv/php/etc/apache2
cd ..

#echo "Install APC"
#wget http://pecl.php.net/get/APC-3.1.13.tgz
#tar -zxf APC-3.1.13.tgz
#cd APC-3.1.13
#$OPENSHIFT_RUNTIME_DIR/srv/php/bin/phpize
#./configure \
#--with-php-config=$OPENSHIFT_RUNTIME_DIR/srv/php/bin/php-config \
#--enable-apc \
#--enable-apc-debug=no
#make && make install
#cd ..

echo "Install xdebug"
wget http://xdebug.org/files/xdebug-$VERSION_XDEBUG.tgz
tar -zxf xdebug-$VERSION_XDEBUG.tgz
cd xdebug-$VERSION_XDEBUG
$OPENSHIFT_RUNTIME_DIR/srv/php/bin/phpize
./configure \
--with-php-config=$OPENSHIFT_RUNTIME_DIR/srv/php/bin/php-config
make && cp modules/xdebug.so $OPENSHIFT_RUNTIME_DIR/srv/php/lib/php/extensions
cd ..

echo "Cleanup"
rm -r $OPENSHIFT_RUNTIME_DIR/tmp/*.tar.gz
rm -r $OPENSHIFT_RUNTIME_DIR/tmp/*.tgz

echo "COPY TEMPLATES"
cp $OPENSHIFT_REPO_DIR/misc/templates/bash_profile.tpl $OPENSHIFT_HOMEDIR/app-root/data/.bash_profile
python $OPENSHIFT_REPO_DIR/misc/parse_templates.py

echo "START APACHE"
$OPENSHIFT_RUNTIME_DIR/srv/httpd/bin/apachectl start

echo "*****************************"
echo "***  F I N I S H E D !!   ***"
echo "*****************************"
