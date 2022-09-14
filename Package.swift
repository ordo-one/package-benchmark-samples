// swift-tools-version: 5.6

import PackageDescription

let package = Package(
    name: "package-benchmark-samples",
    platforms: [.macOS(.v12)],
    products: [
        .library(
            name: "package-benchmark-samples",
            targets: ["package-benchmark-samples"]),
    ],
    dependencies: [
//        .package(url: "https://github.com/ordo-one/package-benchmark", .upToNextMajor(from: "0.0.3")),
        .package(path: "../package-benchmark")
    ],
    targets: [
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
		"package-benchmark-samples"
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
