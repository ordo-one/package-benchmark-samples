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

    Benchmark("Foundation Date()", throughputScalingFactor: .mega) { benchmark in
        for _ in 0..<benchmark.throughputScalingFactor.rawValue {
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
