
// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "ZCModelKit",
    platforms: [.iOS(.v13), .macOS(.v10_15)],
    products: [
        .library(name: "ZCModelKit", targets: ["ZCModelKit"]),
    ],
    targets: [
        .target(name: "ZCModelKit"),
        .testTarget(name: "ZCModelKitTests", dependencies: ["ZCModelKit"]),
    ]
)
