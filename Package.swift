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
//        .package(url: "https://github.com/ordo-one/package-benchmark", branch: "main"),
//        .package(path: "../package-benchmark"),
        .package(url: "https://github.com/ordo-one/package-benchmark", .upToNextMajor(from: "1.0.0")),
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
                .product(name: "Benchmark", package: "package-benchmark"),
            ],
            path: "Benchmarks/Minimal",
            plugins: [
                .plugin(name: "BenchmarkPlugin", package: "package-benchmark"),
            ]
        ),

        // Sample showing wide range of API usage
        .executableTarget(
            name: "Samples",
            dependencies: [
                .product(name: "Benchmark", package: "package-benchmark"),
                "PackageBenchmarkSamples",
            ],
            path: "Benchmarks/Samples",
            plugins: [
                .plugin(name: "BenchmarkPlugin", package: "package-benchmark"),
            ]
        ),

        // Some miscellaneous tests for edge conditions
        .executableTarget(
            name: "Miscellaneous",
            dependencies: [
                .product(name: "Benchmark", package: "package-benchmark"),
            ],
            path: "Benchmarks/Miscellaneous",
            plugins: [
                .plugin(name: "BenchmarkPlugin", package: "package-benchmark"),
            ]
        ),

        // One test for problems with memory measurements
        .executableTarget(
            name: "MemoryOne",
            dependencies: [
                .product(name: "Benchmark", package: "package-benchmark"),
            ],
            path: "Benchmarks/MemoryOne",
            plugins: [
                .plugin(name: "BenchmarkPlugin", package: "package-benchmark"),
            ]
        ),

        // Another test for problems with memory measurements
        .executableTarget(
            name: "MemoryTwo",
            dependencies: [
                .product(name: "Benchmark", package: "package-benchmark"),
            ],
            path: "Benchmarks/MemoryTwo",
            plugins: [
                .plugin(name: "BenchmarkPlugin", package: "package-benchmark"),
            ]
        ),

        // Some test benchmarks on Foundation
        .executableTarget(
            name: "Foundation-Benchmark",
            dependencies: [
                .product(name: "Benchmark", package: "package-benchmark"),
            ],
            path: "Benchmarks/Foundation",
            plugins: [
                .plugin(name: "BenchmarkPlugin", package: "package-benchmark"),
            ]
        ),

        // Benchmarks on external libraries
        .executableTarget(
            name: "External-Benchmarks",
            dependencies: [
                .product(name: "ExtrasJSON", package: "swift-extras-json"),
                .product(name: "Benchmark", package: "package-benchmark"),
            ],
            path: "Benchmarks/External",
            resources: [
                .process("Resources/example.geojson"),
            ],
            plugins: [
                .plugin(name: "BenchmarkPlugin", package: "package-benchmark"),
            ]
        )
    ]
)


// Benchmark of MultiFileExample
package.targets += [
    .executableTarget(
        name: "MultiFileExample",
        dependencies: [
            .product(name: "Benchmark", package: "package-benchmark"),
        ],
        path: "Benchmarks/MultiFileExample",
        plugins: [
            .plugin(name: "BenchmarkPlugin", package: "package-benchmark")
        ]
    ),
]