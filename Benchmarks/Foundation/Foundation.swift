//
// Copyright (c) 2022 Ordo One AB.
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
//
// You may obtain a copy of the License at
// http://www.apache.org/licenses/LICENSE-2.0
//

import SystemPackage
import Foundation
import BenchmarkSupport
@main extension BenchmarkRunner {}

@_dynamicReplacement(for: registerBenchmarks)
func benchmarks() {

    Benchmark.defaultTimeUnits = .microseconds

    let customThreshold = BenchmarkResult.PercentileThresholds(relative: [.p50 : 5.0, .p75 : 10.0],
                                                               absolute: [.p25 : 10, .p50 : 15])
    let customThreshold2 = BenchmarkResult.PercentileThresholds(relative: .strict)
    let customThreshold3 = BenchmarkResult.PercentileThresholds(absolute: .relaxed)

    Benchmark.defaultThresholds = [.wallClock : customThreshold,
                                   .throughput : customThreshold2,
                                   .cpuTotal: customThreshold3,
                                   .cpuUser: .strict]

    Benchmark("Foundation Date()",
              metrics: [.throughput, .wallClock],
              throughputScalingFactor: .mega) { benchmark in
        for _ in benchmark.throughputIterations {
            blackHole(Date())
        }
    }

    Benchmark("Foundation AttributedString()") { benchmark in
        let count = 200
        var str = AttributedString(String(repeating: "a", count: count))
        str += AttributedString(String(repeating: "b", count: count))
        str += AttributedString(String(repeating: "c", count: count))
        let idx = str.characters.index(str.startIndex, offsetBy: str.characters.count / 2)
        let toInsert = AttributedString(String(repeating: "c", count: str.characters.count))

        benchmark.startMeasurement()
        str.insert(toInsert, at: idx)
    }
}
