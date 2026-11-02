#include <stddef.h>
#include <stdio.h>
#include <jpeglib.h>
#include <tiffio.h>

int main(void) {
    struct jpeg_compress_struct compressor;
    struct jpeg_error_mgr error;
    compressor.err = jpeg_std_error(&error);
    jpeg_create_compress(&compressor);
    jpeg_destroy_compress(&compressor);
    const uint16_t codecs[] = {
        COMPRESSION_NONE, COMPRESSION_CCITTRLE, COMPRESSION_CCITTFAX3,
        COMPRESSION_CCITTFAX4, COMPRESSION_LZW, COMPRESSION_JPEG, COMPRESSION_OJPEG,
        COMPRESSION_NEXT, COMPRESSION_THUNDERSCAN,
        COMPRESSION_PACKBITS, COMPRESSION_DEFLATE, COMPRESSION_ADOBE_DEFLATE,
        COMPRESSION_PIXARLOG, COMPRESSION_SGILOG, COMPRESSION_SGILOG24
    };
    for (size_t i = 0; i < sizeof(codecs) / sizeof(codecs[0]); i++) {
        if (!TIFFIsCODECConfigured(codecs[i])) {
            fprintf(stderr, "TIFF codec %u is unavailable\n", codecs[i]);
            return 1;
        }
    }
    puts("JPEG and TIFF codecs passed");
    return 0;
}
