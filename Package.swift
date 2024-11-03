// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "Summit",
    platforms: [
        .macOS(.v14)
    ],
    products: [
        .library(
            name: "Summit",
            targets: ["Summit"]),
    ],
    targets: [
        .target(
            name: "Summit",
            path: "Sources"
        ),
    ],
    swiftLanguageVersions: [.v5]
)
