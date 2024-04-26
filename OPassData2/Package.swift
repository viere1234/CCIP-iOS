// swift-tools-version: 5.10
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "OPassData2",
    platforms: [
        .iOS(.v17)
    ],
    products: [
        .library(
            name: "OPassData2",
            type: .dynamic,
            targets: ["OPassData2"]),
    ],
    targets: [
        .target(
            name: "OPassData2",
            path: "."
        )
    ]
)
