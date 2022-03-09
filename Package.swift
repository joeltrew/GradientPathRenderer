// swift-tools-version:5.5
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "GradientPathRenderer",
    platforms: [
        .iOS(.v12), .macOS(.v10_14), .tvOS(.v12)
    ],
    products: [
        .library(
            name: "GradientPathRenderer",
            targets: ["GradientPathRenderer"]),
    ],
    targets: [
        .target(
            name: "GradientPathRenderer",
            path: "Sources"
        )
    ]
)
