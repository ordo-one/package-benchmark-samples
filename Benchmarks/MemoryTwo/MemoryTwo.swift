//
// Copyright (c) 2022 Ordo One AB.
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
//
// You may obtain a copy of the License at
// http://www.apache.org/licenses/LICENSE-2.0
//

import BenchmarkSupport // import supporting infrastructure
@main extension BenchmarkRunner {} // Required for main() definition to not get linker errors

import Foundation

@_dynamicReplacement(for: registerBenchmarks) // Register benchmarks
func benchmarks() {
    Benchmark.defaultConfiguration.metrics = BenchmarkMetric.memory
    Benchmark.defaultConfiguration.desiredDuration = .seconds(3)
    Benchmark.defaultConfiguration.throughputScalingFactor = .kilo

    Benchmark("Weak Capture Memory") { benchmark in
        for _ in benchmark.throughputIterations {
            BenchmarkSupport.blackHole(WeakCaptureEncoder())
        }
    }
}

private let formatter = ISO8601DateFormatter()

public class WeakCaptureEncoder: JSONEncoder {
    private let myFormatter: ISO8601DateFormatter
    override public init() {
        myFormatter = formatter
        super.init()
        dateEncodingStrategy = .custom { [weak self] _, _ in
            BenchmarkSupport.blackHole(self?.myFormatter)
        }
    }
}
