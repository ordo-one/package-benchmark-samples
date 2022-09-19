// swift-tools-version: 5.6

import PackageDescription

let package = Package(
    name: "PackageBenchmarkSamples",
    platforms: [.macOS(.v12)],

    products: [
        .library(
            name: "PackageBenchmarkSamples",
            targets: ["PackageBenchmarkSamples"]),
    ],

    dependencies: [
        .package(url: "https://github.com/ordo-one/package-benchmark", .upToNextMajor(from: "0.0.9")),
       // .package(path: "../package-benchmark")
    ],

    targets: [
        .target(
            name: "PackageBenchmarkSamples",
            dependencies: []),

        // Sample benchmark executable targets, a few displaying how benchmarks can be split up.

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
                "PackageBenchmarkSamples"
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
