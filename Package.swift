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
            checksum: "d88a7fe745950eec19fc6f69321b853ee98eda75a9730d64a46d94c0de4d06b9"
        ),
        .binaryTarget(
            name: "libffi",
            url: "https://github.com/holzschu/Python-aux/releases/download/1.0/libffi.xcframework.zip",
            checksum: "f75b0388d255e38f861daf7012d0842842a33594619312db7e34bc311c815da8"
        )
    ]
)

