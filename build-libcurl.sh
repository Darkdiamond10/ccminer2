#!/usr/bin/env bash

set -e

CURL_VERSION="8.6.0"
CURL_TAR="curl-${CURL_VERSION}.tar.gz"
CURL_URL="https://curl.se/download/${CURL_TAR}"
CURL_DIR="curl-${CURL_VERSION}"
INSTALL_DIR="$(pwd)/curl-static"

if [ ! -f "$INSTALL_DIR/lib/libcurl.a" ]; then
    echo "Downloading curl..."
    wget -qO $CURL_TAR $CURL_URL

    echo "Extracting curl..."
    tar -xzf $CURL_TAR

    echo "Configuring minimal curl..."
    cd $CURL_DIR

    # Configure curl to only build the static library, and disable all extra features
    # except for basic HTTP/HTTPS, OpenSSL, and zlib.
    ./configure \
        --prefix="$INSTALL_DIR" \
        --libdir="$INSTALL_DIR/lib" \
        --disable-shared \
        --enable-static \
        --disable-ldap \
        --disable-ldaps \
        --disable-rtsp \
        --disable-dict \
        --disable-file \
        --disable-telnet \
        --disable-tftp \
        --disable-pop3 \
        --disable-imap \
        --disable-smb \
        --disable-smtp \
        --disable-gopher \
        --disable-mqtt \
        --disable-manual \
        --disable-libcurl-option \
        --without-brotli \
        --without-zstd \
        --without-libidn2 \
        --without-librtmp \
        --without-nghttp2 \
        --without-nghttp3 \
        --without-ngtcp2 \
        --without-quiche \
        --without-msh3 \
        --without-libssh2 \
        --without-libpsl \
        --with-openssl \
        --with-zlib

    echo "Building minimal curl..."
    make -j$(nproc)
    make install

    cd ..
    # Clean up source to save space
    rm -rf $CURL_DIR $CURL_TAR
    echo "Curl static build complete in $INSTALL_DIR"
else
    echo "Static libcurl already exists at $INSTALL_DIR/lib/libcurl.a, skipping build."
fi
