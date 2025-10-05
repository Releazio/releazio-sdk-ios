// swift-tools-version: 5.9
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "Releazio",
    defaultLocalization: "en",
    platforms: [
        .iOS(.v15),
        .macOS(.v12),
        .watchOS(.v8),
        .tvOS(.v15)
    ],
    products: [
        .library(
            name: "Releazio",
            targets: ["Releazio"]),
    ],
    dependencies: [
    ],
    targets: [
        .target(
            name: "Releazio",
            dependencies: [
            ],
            resources: [
                .process("Resources")
            ]),
        .testTarget(
            name: "ReleazioTests",
            dependencies: [
                "Releazio"
            ]),
    ]
)