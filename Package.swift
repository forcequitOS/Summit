// swift-tools-version: 5.10
import PackageDescription

let package = Package(
    name: "Summit",
    platforms: [
        .macOS(.v13)
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
