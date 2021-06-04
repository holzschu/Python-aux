#!/bin/bash

# update libffi, OpenBLAS, harfbuzz and libzmq source:
git submodule update --init --recursive

# Using Xcode to create frameworks from archived libraries (lib.a) is failing randomly. 
# We stick to creating frameworks from dynamic libraries.

# building libpng:
./build_libpng.sh 

# libffi and libzmq produce static libraries. We can still put them into xcframeworks:
./build_libffi.sh
./build_libzmq.sh

# OpenBLAS creates dynamic libraries:
./build_openblas.sh

# Building harfbuzz and freetype (together):
./build_freetype.sh

# Building libjpeg:
./build_libjpg.sh

#libtiff:
./build_libtiff.sh

# XSLT/EXSLT
./build_libxslt.sh

# OpenSSL: 
./build_openssl.sh

# FFTW: 
./build_fftw.sh

# then, merge frameworks into XCframeworks:
./create_xcframeworks.sh
# and compute checksums:
./compute_checksums.sh

# crypto openssl libjpeg  
