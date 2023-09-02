for framework in libpng \
	libffi \
	libzmq \
	openblas \
	freetype \
	harfbuzz \
	crypto \
	openssl \
	libjpeg \
	libtiff \
	libxslt \
	libexslt \
	libfftw3 \
	libfftw3_threads \
	libspatialindex_c \
	libspatialindex \
	libgdal \
	libproj \
	libgeos_c \
	libgeos \
	liblzma
do
   echo $framework
   rm -f $framework.xcframework.zip
   zip -rq $framework.xcframework.zip $framework.xcframework
   swift package compute-checksum $framework.xcframework.zip
done


