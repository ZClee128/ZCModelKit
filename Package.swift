 // swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "ZCModelKit",
    products: [
        .library(name: "ZCModelKit", targets: ["ZCModelKit"]),
        .executable(name: "ZCModelKitDemo", targets: ["ZCModelKitDemo"]),
    ],
    dependencies: [],
    targets: [
        .target(name: "ZCModelKit", dependencies: []),
        .executableTarget(name: "ZCModelKitDemo", dependencies: ["ZCModelKit"]),
    ]
)