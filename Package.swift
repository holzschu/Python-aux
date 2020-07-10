// swift-tools-version:5.3

import PackageDescription

let package = Package(
    name: "Python-aux",
    products: [
        .library(name: "Python-aux", targets: ["libpng", "libffi"])
    ],
    dependencies: [
    ],
    targets: [
        .binaryTarget(
            name: "libpng",
            url: "https://github.com/holzschu/Python-aux/releases/download/1.0/libpng.xcframework.zip",
            checksum: "164188f7710c5a5d252d1f3868375ede944c9b2ac1ca6c3b4b0e25ae5f29bde2"
        ),
        .binaryTarget(
            name: "libffi",
            url: "https://github.com/holzschu/Python-aux/releases/download/1.0/libffi.xcframework.zip",
            checksum: "575a4e6fe83136ad14abc1f87c1700b3b2f4061a9e2dd32c4dd3505e304a9ea0"
        )
    ]
)

