// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "TYRlistr",
    platforms: [.macOS(.v14), .iOS(.v17)],
    targets: [
        .executableTarget(name: "TYRlistr", path: "Sources/TYRlistr")
    ]
)
