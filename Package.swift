// swift-tools-version: 5.6
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "package-benchmark-samples",
    platforms: [.macOS(.v12)],
    products: [
        // Products define the executables and libraries a package produces, and make them visible to other packages.
        .library(
            name: "package-benchmark-samples",
            targets: ["package-benchmark-samples"]),
    ],
    dependencies: [
        .package(url: "https://github.com/ordo-one/package-benchmark", .upToNextMajor(from: "0.0.1")),
//        .package(path: "../package-benchmark")
    ],
    targets: [
        // Targets are the basic building blocks of a package. A target can define a module or a test suite.
        // Targets can depend on other targets in this package, and on products in packages this package depends on.
        .target(
            name: "package-benchmark-samples",
            dependencies: []),
        .testTarget(
            name: "package-benchmark-samplesTests",
            dependencies: ["package-benchmark-samples"]),

        // Sample benchmark executable targets, created a handful just to show
        // how benchmarks can be split up.

        // Absolute minimal boilerplate
        .executableTarget(
            name: "Minimal-Benchmark",
            dependencies: [
                .product(name: "BenchmarkSupport", package: "package-benchmark"),
            ],
            path: "Benchmarks/Minimal"
        ),

        // Sample showing wide range of API usage
        .executableTarget(
            name: "Samples-Benchmark",
            dependencies: [
                .product(name: "BenchmarkSupport", package: "package-benchmark"),
            ],
            path: "Benchmarks/Samples"
        ),

        // Some miscellaneous tests for edge conditions
        .executableTarget(
            name: "Miscellaneous-Benchmark",
            dependencies: [
                .product(name: "BenchmarkSupport", package: "package-benchmark"),
            ],
            path: "Benchmarks/Miscellaneous"
        ),

        // Some test benchmarks on Foundation
        .executableTarget(
            name: "Foundation-Benchmark",
            dependencies: [
                .product(name: "BenchmarkSupport", package: "package-benchmark"),
            ],
            path: "Benchmarks/Foundation"
        ),

    ]
)
