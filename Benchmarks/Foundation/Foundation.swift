//
// Copyright (c) 2022 Ordo One AB.
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
//
// You may obtain a copy of the License at
// http://www.apache.org/licenses/LICENSE-2.0
//

import Foundation
import SystemPackage
import Benchmark

let benchmarks = {
    let customThreshold = BenchmarkThresholds(relative: [.p50: 5.0, .p75: 10.0],
                                              absolute: [.p25: 10, .p50: 15])
    let customThreshold2 = BenchmarkThresholds(relative: BenchmarkThresholds.Relative.strict)
    let customThreshold3 = BenchmarkThresholds(absolute: BenchmarkThresholds.Absolute.relaxed)
/*
    Benchmark.defaultConfiguration = .init(timeUnits: .microseconds,
                                           thresholds: [.wallClock: customThreshold,
                                                        .throughput: customThreshold2,
                                                        .cpuTotal: customThreshold3,
                                                        .cpuUser: .strict])
*/
    Benchmark.defaultConfiguration = .init(timeUnits: .microseconds,
                                           thresholds: [.wallClock: customThreshold,
                                                        .throughput: customThreshold2])

    Benchmark("Foundation Date()",
              configuration: .init(metrics: [.throughput, .wallClock], scalingFactor: .mega)) { benchmark in
        for _ in benchmark.scaledIterations {
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
