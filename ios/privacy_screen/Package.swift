// swift-tools-version: 5.9
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "privacy_screen",
    platforms: [
        .iOS(.v13)
    ],
    products: [
        .library(name: "privacy-screen", targets: ["privacy_screen"])
    ],
    dependencies: [
        .package(name: "FlutterFramework", path: "../FlutterFramework")
    ],
    targets: [
        .target(
            name: "privacy_screen",
            dependencies: [
                .product(name: "FlutterFramework", package: "FlutterFramework")
            ],
            path: "Sources",
            sources: ["SwiftPrivacyScreenPlugin.swift"]
        )
    ]
)