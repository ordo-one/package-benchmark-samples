//
// Copyright (c) 2022 Ordo One AB.
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
//
// You may obtain a copy of the License at
// http://www.apache.org/licenses/LICENSE-2.0
//

import BenchmarkSupport
@main extension BenchmarkRunner {}

#if os(macOS) || os(iOS) || os(watchOS) || os(tvOS)
    import Darwin
#elseif os(Linux) || os(FreeBSD) || os(Android)
    import Glibc
#else
    #error("Unsupported Platform")
#endif

@_dynamicReplacement(for: registerBenchmarks)
func benchmarks() {
    func performAllocations(count: Int, size: Int, shouldFree: Bool = true) {
        for _ in 0 ..< count {
            let x = malloc(size)
            blackHole(x)
            if shouldFree {
                free(x)
            }
        }
    }

    Benchmark("Memory leak 123 allocations of 4K",
              metrics: BenchmarkMetric.memory) { _ in
        performAllocations(count: 123, size: 4096, shouldFree: false)
    }

    Benchmark("Memory transient allocations (1K small, 1001 large, 1M leak)",
              metrics: BenchmarkMetric.memory,
              throughputScalingFactor: .kilo) { benchmark in
        performAllocations(count: benchmark.throughputScalingFactor.rawValue, size: 10)
        performAllocations(count: benchmark.throughputScalingFactor.rawValue, size: 64 * 1024)
        performAllocations(count: 1, size: 1024 * 1024, shouldFree: false)
    }

    Benchmark("Memory transient allocations + 1 large leak",
              metrics: BenchmarkMetric.memory,
              throughputScalingFactor: .kilo) { benchmark in
        performAllocations(count: benchmark.throughputScalingFactor.rawValue, size: 11 * 1024 * 1024)
        performAllocations(count: 1, size: 32 * 1024 * 1024, shouldFree: false)
    }

    Benchmark("Memory transient allocations no leak",
              metrics: BenchmarkMetric.memory,
              throughputScalingFactor: .kilo) { benchmark in
        performAllocations(count: benchmark.throughputScalingFactor.rawValue, size: 11 * 1024 * 1024)
        performAllocations(count: 1, size: 32 * 1024 * 1024)
    }
}
