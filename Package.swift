// swift-tools-version:4.2
import PackageDescription

let package = Package(
	name: "SplitView",
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
