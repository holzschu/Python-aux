#!/bin/bash
set -euo pipefail

# The pinned GDAL revision uses CMake; initialize dependencies with build_gis.sh first.
exec bash "$(cd "$(dirname "$0")" && pwd)/build_gis.sh" gdal
