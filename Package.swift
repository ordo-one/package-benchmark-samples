// swift-tools-version: 5.7

import PackageDescription

let package = Package(
    name: "PackageBenchmarkSamples",
    platforms: [.macOS(.v13)],

    products: [
        .library(
            name: "PackageBenchmarkSamples",
            targets: ["PackageBenchmarkSamples"]
        ),
    ],

    dependencies: [
        .package(url: "https://github.com/ordo-one/package-benchmark", .upToNextMajor(from: "0.8.0")),
        .package(url: "https://github.com/swift-extras/swift-extras-json.git", .upToNextMajor(from: "0.6.0")),
    ],

    targets: [
        .target(
            name: "PackageBenchmarkSamples",
            dependencies: []
        ),

        // Sample benchmark executable targets, a few displaying how benchmarks can be split up.

        // Absolute minimal boilerplate
        .executableTarget(
            name: "Minimal",
            dependencies: [
                .product(name: "BenchmarkSupport", package: "package-benchmark"),
            ],
            path: "Benchmarks/Minimal"
        ),

        // Sample showing wide range of API usage
        .executableTarget(
            name: "Samples",
            dependencies: [
                .product(name: "BenchmarkSupport", package: "package-benchmark"),
                "PackageBenchmarkSamples",
            ],
            path: "Benchmarks/Samples"
        ),

        // Some miscellaneous tests for edge conditions
        .executableTarget(
            name: "Miscellaneous",
            dependencies: [
                .product(name: "BenchmarkSupport", package: "package-benchmark"),
            ],
            path: "Benchmarks/Miscellaneous"
        ),

        // One test for problems with memory measurements
        .executableTarget(
            name: "MemoryOne",
            dependencies: [
                .product(name: "BenchmarkSupport", package: "package-benchmark"),
            ],
            path: "Benchmarks/MemoryOne"
        ),

        // Another test for problems with memory measurements
        .executableTarget(
            name: "MemoryTwo",
            dependencies: [
                .product(name: "BenchmarkSupport", package: "package-benchmark"),
            ],
            path: "Benchmarks/MemoryTwo"
        ),

        // Some test benchmarks on Foundation
        .executableTarget(
            name: "Foundation-Benchmark",
            dependencies: [
                .product(name: "BenchmarkSupport", package: "package-benchmark"),
            ],
            path: "Benchmarks/Foundation"
        ),

        // Benchmarks on external libraries
        .executableTarget(
            name: "External-Benchmarks",
            dependencies: [
                .product(name: "ExtrasJSON", package: "swift-extras-json"),
                .product(name: "BenchmarkSupport", package: "package-benchmark")
            ],
            path: "Benchmarks/External",
            resources: [
                .process("Resources/example.geojson"),

            ]
        )
    ]
)
