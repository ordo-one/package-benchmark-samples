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
import BenchmarkSupport
@main extension BenchmarkRunner {}

@_dynamicReplacement(for: registerBenchmarks)
func benchmarks() {

    Benchmark("Foundation Date()", scalingFactor: .mega) { benchmark in
        for _ in 0..<benchmark.scalingFactor.rawValue {
            blackHole(Date())
        }
    }

    Benchmark("Foundation AttributedString()") { benchmark in
        var str = AttributedString(String(repeating: "a", count: 100))
        str += AttributedString(String(repeating: "b", count: 100))
        str += AttributedString(String(repeating: "c", count: 100))
        let idx = str.characters.index(str.startIndex, offsetBy: str.characters.count / 2)
        let toInsert = AttributedString(String(repeating: "c", count: str.characters.count))

        benchmark.startMeasurement()
        str.insert(toInsert, at: idx)
    }
}
