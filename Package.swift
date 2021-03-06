// swift-tools-version:5.1
import PackageDescription

let package = Package(
	name: "SplitView",
    platforms: [
        .iOS(.v9),
        .macOS(.v10_15)
    ],
    products: [
        .library(name: "SplitView", targets: ["SplitView"])
    ],
	dependencies: [],
	targets: [
        .target(
            name: "SplitView",
            dependencies: [],
            path: "SplitView"),
        .testTarget(
            name: "SplitViewTests",
            dependencies: ["SplitView"],
            path: "SplitViewTests"),
    ]
)
