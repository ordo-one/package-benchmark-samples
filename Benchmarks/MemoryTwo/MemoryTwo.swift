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
import Benchmark

let benchmarks = {
    Benchmark.defaultConfiguration.metrics = .memory + .arc
    Benchmark.defaultConfiguration.maxDuration = .seconds(3)
    Benchmark.defaultConfiguration.scalingFactor = .kilo

    Benchmark("Weak Capture Memory") { benchmark in
        for _ in benchmark.scaledIterations {
            blackHole(WeakCaptureEncoder())
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
            blackHole(self?.myFormatter)
        }
    }
}
