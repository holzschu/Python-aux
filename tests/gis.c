#include <assert.h>
#include <math.h>
#include <stdio.h>
#include <string.h>
#include <cpl_conv.h>
#include <cpl_string.h>
#include <geos_c.h>
#include <proj.h>
#include <gdal.h>
#include <spatialindex/capi/sidx_api.h>

int main(int argc, char **argv) {
    assert(argc == 2);
    GEOSContextHandle_t geos = GEOS_init_r();
    assert(geos);
    GEOSWKTReader *reader = GEOSWKTReader_create_r(geos);
    assert(reader);
    GEOSGeometry *geometry = GEOSWKTReader_read_r(geos, reader, "POLYGON((0 0,4 0,4 3,0 3,0 0))");
    double area = 0;
    assert(geometry && GEOSArea_r(geos, geometry, &area) && area == 12);
    GEOSGeom_destroy_r(geos, geometry);
    GEOSWKTReader_destroy_r(geos, reader);
    GEOS_finish_r(geos);

    /* A projection pipeline avoids depending on an externally installed proj.db. */
    PJ *projection = proj_create(NULL, "+proj=merc +ellps=WGS84");
    assert(projection);
    PJ_COORD point = proj_trans(projection, PJ_FWD, proj_coord(0, 0, 0, 0));
    assert(proj_errno(projection) == 0 && fabs(point.xy.x) < 1e-9 && fabs(point.xy.y) < 1e-8);
    proj_destroy(projection);

    PJ_CONTEXT *context = proj_context_create();
    assert(context);
    const char *data_path = argv[1];
    proj_context_set_search_paths(context, 1, &data_path);
    projection = proj_create_crs_to_crs(context, "EPSG:4326", "EPSG:3857", NULL);
    if (!projection) {
        fputs("Packaged PROJ database lookup failed\n", stderr);
        proj_context_destroy(context);
        return 1;
    }
    PJ *visualization = proj_normalize_for_visualization(context, projection);
    assert(visualization);
    point = proj_trans(visualization, PJ_FWD, proj_coord(1, 0, 0, 0));
    assert(proj_errno(visualization) == 0 && fabs(point.xy.x - 111319.49079327357) < 1e-6 && fabs(point.xy.y) < 1e-8);
    proj_destroy(visualization);
    proj_destroy(projection);
    proj_context_destroy(context);

    char *utf8 = CPLRecode("\xa4", "ISO-8859-15", "UTF-8");
    assert(utf8 && strcmp(utf8, "\xe2\x82\xac") == 0);
    CPLFree(utf8);

    GDALAllRegister();
    GDALDriverH driver = GDALGetDriverByName("MEM");
    assert(driver);
    GDALDatasetH dataset = GDALCreate(driver, "", 2, 2, 1, GDT_Byte, NULL);
    assert(dataset);
    GDALRasterBandH band = GDALGetRasterBand(dataset, 1);
    unsigned char input[] = {1, 2, 3, 4}, output[4] = {0};
    assert(GDALRasterIO(band, GF_Write, 0, 0, 2, 2, input, 2, 2, GDT_Byte, 0, 0) == CE_None);
    assert(GDALRasterIO(band, GF_Read, 0, 0, 2, 2, output, 2, 2, GDT_Byte, 0, 0) == CE_None);
    assert(output[0] == 1 && output[1] == 2 && output[2] == 3 && output[3] == 4);
    GDALClose(dataset);
    GDALDestroyDriverManager();

    IndexPropertyH properties = IndexProperty_Create();
    assert(properties && IndexProperty_SetIndexStorage(properties, RT_Memory) == RT_None);
    IndexH index = Index_Create(properties);
    assert(index);
    double low[] = {1, 2}, high[] = {3, 4};
    assert(Index_InsertData(index, 42, low, high, 2, NULL, 0) == RT_None);
    double query_low[] = {2, 3}, query_high[] = {4, 5};
    int64_t *ids = NULL;
    uint64_t count = 0;
    assert(Index_Intersects_id(index, query_low, query_high, 2, &ids, &count) == RT_None);
    assert(count == 1 && ids[0] == 42);
    Index_Free(ids);
    Index_Destroy(index);
    IndexProperty_Destroy(properties);
    puts("GIS geometry, projection, encoding, raster and spatial-index consumers PASS");
    return 0;
}
