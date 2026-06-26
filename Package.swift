// swift-tools-version: 6.0
import PackageDescription

let package = Package(
    name: "Paste",
    platforms: [.macOS(.v14)],
    targets: [
        .executableTarget(
            name: "Paste",
            path: "Sources"
        ),
        .testTarget(
            name: "PasteTests",
            dependencies: ["Paste"],
            path: "Tests"
        ),
    ]
)
