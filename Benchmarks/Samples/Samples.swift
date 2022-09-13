//
// Copyright (c) 2022 Ordo One AB.
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
//
// You may obtain a copy of the License at
// http://www.apache.org/licenses/LICENSE-2.0
//

@testable import package_benchmark_samples

import BenchmarkSupport
@main extension BenchmarkRunner {}

@_dynamicReplacement(for: registerBenchmarks)
func benchmarks() {

    func defaultRunTime() -> TimeDuration { .milliseconds(100)}
    func defaultCounter() -> Int { 10_000 }
    func dummyCounter(_ count: Int) {
        for x in 0..<count {
            blackHole(x)
        }
    }

    Benchmark("myInternalDummyCounter", metrics: [.wallClock, .throughput], desiredDuration: defaultRunTime()) { benchmark in
        myInternalDummyCounter(defaultCounter())
    }

    Benchmark("Counter", metrics: [.wallClock, .throughput], desiredDuration: defaultRunTime()) { benchmark in
        dummyCounter(defaultCounter())
        dummyCounter(defaultCounter())
    }

    Benchmark("Counter no init (should be ~2x faster than Counter)",
              metrics: [.wallClock, .throughput],
              desiredDuration: defaultRunTime()) { benchmark in
        dummyCounter(defaultCounter())
        benchmark.startMeasurement() // don't include setup
        dummyCounter(defaultCounter())
    }

    Benchmark("Counter no deinit (should be ~2x faster than Counter)",
              metrics: [.wallClock, .throughput],
              desiredDuration: defaultRunTime()) { benchmark in
        dummyCounter(defaultCounter())
        benchmark.stopMeasurement() // skip cleanup
        dummyCounter(defaultCounter())
    }

    Benchmark("Counter no init (should be ~2x faster than Counter)",
              metrics: [.wallClock, .throughput],
              desiredDuration: defaultRunTime()) { benchmark in
        dummyCounter(defaultCounter())
        benchmark.startMeasurement() // skip both setup
        dummyCounter(defaultCounter())
        benchmark.stopMeasurement() // and cleanup
        dummyCounter(defaultCounter())
    }

    Benchmark("Minimal benchmark", metrics: [.wallClock], desiredDuration: defaultRunTime()) { benchmark in
    }

    Benchmark("Extended metrics", metrics: BenchmarkMetric.extended, desiredDuration: defaultRunTime()) { benchmark in
        dummyCounter(defaultCounter())
    }

    Benchmark("Counter force nanoseconds (result will be power-of-two)",
              metrics: [.wallClock, .throughput],
              timeUnits: .nanoseconds,
              desiredDuration: defaultRunTime()) { benchmark in
        dummyCounter(defaultCounter())
        dummyCounter(defaultCounter())
    }

    Benchmark("Custom metrics", metrics: [.custom("CustomOne"), .custom("CustomTwo")], desiredDuration: defaultRunTime()) { benchmark in
        benchmark.measurement(.custom("CustomOne"), Int.random(in: 0...1_000_000))
        benchmark.measurement(.custom("CustomTwo"), Int.random(in: 0...1_000))
    }

    Benchmark("Extended + custom metrics",
              metrics: BenchmarkMetric.extended + [.custom("CustomOne"), .custom("CustomTwo")],
              desiredDuration: defaultRunTime()) { benchmark in
        dummyCounter(defaultCounter())
        benchmark.measurement(.custom("CustomOne"), Int.random(in: 0...1_000_000))
        benchmark.measurement(.custom("CustomTwo"), Int.random(in: 0...1_000))
    }

    Benchmark("Counter 57 iterations", metrics: [.wallClock, .throughput], desiredIterations:57) { benchmark in
        dummyCounter(57)
    }

    Benchmark("Counter 57 iterations no warmup",
              metrics: [.wallClock, .throughput],
              warmup: false,
              desiredIterations:57) { benchmark in
        dummyCounter(57)
    }

    Benchmark("Counter disabled test", disabled: true) { benchmark in
        fatalError("This test is disabled and should not have been run")
    }

    Benchmark("Specific metrics", metrics: [.wallClock, .cpuTotal, .memoryLeaked], desiredDuration: defaultRunTime()) { benchmark in
        dummyCounter(defaultCounter())
    }

    /* There metrics doesn't exist yet, so we will crash if trying to enable them
    Benchmark("Memory metrics", metrics: BenchmarkMetric.memory, desiredDuration: defaultRunTime()) { benchmark in
        dummyCounter(defaultCounter())
    }

    Benchmark("Disk metrics", metrics: BenchmarkMetric.disk, desiredDuration: defaultRunTime()) { benchmark in
        dummyCounter(defaultCounter())
    }

    Benchmark("System metrics", metrics: BenchmarkMetric.system, desiredDuration: defaultRunTime()) { benchmark in
        dummyCounter(defaultCounter())
    }

    Benchmark("All metrics", metrics: BenchmarkMetric.all, desiredDuration: defaultRunTime()) { benchmark in
        dummyCounter(defaultCounter())
    }
*/
}
