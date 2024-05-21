// swift-tools-version: 5.10
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "OPassData",
    platforms: [
        .iOS(.v17)
    ],
    products: [
        .library(
            name: "OPassData",
            type: .dynamic,
            targets: ["OPassData"]),
    ],
    dependencies: [
        .package(url: "https://github.com/kishikawakatsumi/KeychainAccess", from: "4.2.2"),
        .package(url: "https://github.com/malcommac/SwiftDate", from: "7.0.0"),
        .package(url: "https://github.com/apple/swift-collections", from: "1.1.0")
    ],
    targets: [
        .target(
            name: "OPassData",
            dependencies: [
                .product(name: "OrderedCollections", package: "swift-collections"),
                "KeychainAccess",
                "SwiftDate"
            ],
            path: "."
        )
    ]
)
