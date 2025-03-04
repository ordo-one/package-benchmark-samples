//
// Copyright (c) 2022 Ordo One AB.
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
//
// You may obtain a copy of the License at
// http://www.apache.org/licenses/LICENSE-2.0
//

import Benchmark

#if os(macOS) || os(iOS) || os(watchOS) || os(tvOS)
    import Darwin
#elseif os(Linux) || os(FreeBSD) || os(Android)
    import Glibc
#else
    #error("Unsupported Platform")
#endif

let benchmarks: @Sendable () -> Void = {
    func performAllocations(count: Int, size: Int, shouldFree: Bool = true) {
        for _ in 0 ..< count {
            let x = malloc(size)
            blackHole(x)
            if shouldFree {
                free(x)
            }
        }
    }

    func performAllocationsMutablePointer(count: Int, size: Int, shouldFree: Bool = true) {
        for _ in 0 ..< count {
            let x: UnsafeMutablePointer<Int> = UnsafeMutablePointer.allocate(capacity: size)
            blackHole(x)
            if shouldFree {
                free(x)
            }
        }
    }

    Benchmark.defaultConfiguration = .init(metrics: .memory + .arc)
    Benchmark.defaultConfiguration.maxIterations = 1

    Benchmark("Memory leak 123 allocations of 4K - performAllocationsMutablePointer") { _ in
        performAllocationsMutablePointer(count: 123, size: 4096, shouldFree: false)
    }

    Benchmark("Memory leak 1 allocation of 1K") { _ in
        let x: UnsafeMutablePointer<Int> = UnsafeMutablePointer.allocate(capacity: 5000)
        blackHole(x)
    }

    Benchmark("Memory leak 123 allocations of 4K") { _ in
        performAllocations(count: 123, size: 4096, shouldFree: false)
    }

    Benchmark("Memory transient allocations (1K small, 1001 large, 1M leak)",
              configuration: .init(scalingFactor: .kilo)) { benchmark in
        performAllocations(count: benchmark.configuration.scalingFactor.rawValue, size: 10)
        performAllocations(count: benchmark.configuration.scalingFactor.rawValue, size: 64 * 1024)
        performAllocations(count: 1, size: 1024 * 1024, shouldFree: false)
    }

    Benchmark("Memory transient allocations + 1 large leak",
              configuration: .init(scalingFactor: .kilo)) { benchmark in
        performAllocations(count: benchmark.configuration.scalingFactor.rawValue, size: 11 * 1024 * 1024)
        performAllocations(count: 1, size: 32 * 1024 * 1024, shouldFree: false)
    }

    Benchmark("Memory transient allocations no leak",
              configuration: .init(scalingFactor: .kilo)) { benchmark in
        performAllocations(count: benchmark.configuration.scalingFactor.rawValue, size: 11 * 1024 * 1024)
        performAllocations(count: 1, size: 32 * 1024 * 1024)
    }
}
