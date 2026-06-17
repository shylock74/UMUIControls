// swift-tools-version: 6.0
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "UMUIControls",
	platforms: [.macOS(.v10_12)],
    products: [
        .library(
            name: "UMUIControls",
            targets: ["UMUIControls"]
        ),
    ],
    targets: [
        .target(
            name: "UMUIControls"
        )
    ],
    swiftLanguageModes: [.v5]
)
