#! /bin/sh

rm -rf openssl-1.1.1g
curl -OL https://www.openssl.org/source/openssl-1.1.1g.tar.gz
tar xvzf openssl-1.1.1g.tar.gz
rm openssl-1.1.1g.tar.gz

pushd openssl-1.1.1g

make distclean
./Configure ios64-xcrun
make
rm -rf build_iphoneos
mkdir -p build_iphoneos
mv libcrypto.a build_iphoneos
mv libcrypto.dylib build_iphoneos
mv libssl.a build_iphoneos
mv libssl.dylib build_iphoneos
cp -r include build_iphoneos

make distclean
./Configure iossimulator-xcrun
make 
rm -rf build_iphonesimulator
mkdir -p build_iphonesimulator
mv libcrypto.a build_iphonesimulator
mv libcrypto.dylib build_iphonesimulator
mv libssl.a build_iphonesimulator
mv libssl.dylib build_iphonesimulator
cp -r include build_iphonesimulator

popd

# Create (static) xcframeworks, distribute. 
# then, merge them into XCframeworks:
framework=openssl
rm -rf $framework.xcframework
xcodebuild -create-xcframework \
	-library openssl-1.1.1g/build_iphoneos/libssl.a -headers openssl-1.1.1g/build_iphoneos/include/openssl \
	-library openssl-1.1.1g/build_iphonesimulator/libssl.a -headers openssl-1.1.1g/build_iphonesimulator/include/openssl \
	-output $framework.xcframework

framework=crypto
rm -rf $framework.xcframework
xcodebuild -create-xcframework \
	-library openssl-1.1.1g/build_iphoneos/libcrypto.a -headers openssl-1.1.1g/build_iphoneos/include/crypto \
	-library openssl-1.1.1g/build_iphonesimulator/libcrypto.a -headers openssl-1.1.1g/build_iphonesimulator/include/crypto \
	-output $framework.xcframework

