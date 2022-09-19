//
// Copyright (c) 2022 Ordo One AB.
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
//
// You may obtain a copy of the License at
// http://www.apache.org/licenses/LICENSE-2.0
//

@testable import PackageBenchmarkSamples

#if canImport(Darwin)
import Darwin
typealias DirectoryStreamPointer = UnsafeMutablePointer<DIR>?
#elseif canImport(Glibc)
import Glibc
typealias DirectoryStreamPointer = OpaquePointer?
#else
#error("Unsupported Platform")
#endif

import BenchmarkSupport
import SystemPackage
@main extension BenchmarkRunner {}

@_dynamicReplacement(for: registerBenchmarks)
func benchmarks() {

    // Some helper stuff
    struct CustomMetrics {
        static var one: String { "CustomOne" }
        static var two: String { "CustomTwo" }
    }

    func defaultRunTime() -> TimeDuration { .milliseconds(50)}
    @Sendable func defaultCounter() -> Int { 1_000 }
    @Sendable func dummyCounter(_ count: Int) {
        for x in 0..<count {
            blackHole(x)
        }
    }

    // The actual benchmarks

    Benchmark("myInternalDummyCounter", metrics: [.wallClock, .throughput], desiredDuration: defaultRunTime()) { benchmark in
        myInternalDummyCounter(defaultCounter()) // Calls the function internal to the library target using @testable import
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

    Benchmark("Minimal benchmark",
              metrics: [.wallClock]) { benchmark in
    }

    Benchmark("Extended metrics",
              metrics: BenchmarkMetric.extended,
              desiredDuration: defaultRunTime()) { benchmark in
        dummyCounter(defaultCounter())
    }

    Benchmark("Counter force nanoseconds (result will be power-of-two)",
              metrics: [.wallClock, .throughput],
              timeUnits: .nanoseconds,
              desiredDuration: defaultRunTime()) { benchmark in
        dummyCounter(defaultCounter())
        dummyCounter(defaultCounter())
    }

    Benchmark("Custom metrics",
              metrics: [.custom(CustomMetrics.one), .custom(CustomMetrics.two)],
              desiredDuration: defaultRunTime()) { benchmark in
        benchmark.measurement(.custom(CustomMetrics.one), Int.random(in: 0...1_000_000))
        benchmark.measurement(.custom(CustomMetrics.two), Int.random(in: 0...1_000))
    }

    Benchmark("Extended + custom metrics",
              metrics: BenchmarkMetric.extended + [.custom(CustomMetrics.one), .custom(CustomMetrics.two)],
              desiredDuration: defaultRunTime()) { benchmark in
        dummyCounter(defaultCounter())
        benchmark.measurement(.custom(CustomMetrics.one), Int.random(in: 0...1_000_000))
        benchmark.measurement(.custom(CustomMetrics.two), Int.random(in: 0...1_000))
    }

    Benchmark("Counter 57 iterations",
              metrics: [.wallClock, .throughput],
              desiredIterations:57) { benchmark in
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

    Benchmark("Specific metrics",
              metrics: [.wallClock, .cpuTotal, .memoryLeaked],
              desiredDuration: defaultRunTime()) { benchmark in
        dummyCounter(defaultCounter())
    }

    Benchmark("Memory metrics",
              metrics: BenchmarkMetric.memory,
              desiredDuration: defaultRunTime()) { benchmark in
        dummyCounter(defaultCounter())
    }

    Benchmark("Disk metrics, writing 64K x 1.000",
              metrics: BenchmarkMetric.disk,
              scalingFactor: .kilo,
              desiredDuration: .seconds(1)) { benchmark in
        do {
            let fileDescriptor = FileDescriptor(rawValue: fileno(tmpfile()))
            let data = [UInt8].init(repeating: 47, count: 64*1_024)

            benchmark.startMeasurement()

            try fileDescriptor.closeAfter {
                try data.withUnsafeBufferPointer {
                    for _ in 0..<benchmark.scalingFactor.rawValue {
                        _ = try fileDescriptor.write(UnsafeRawBufferPointer($0))
                    }
                }
            }
        } catch { }
    }

    Benchmark("System metrics",
              metrics: BenchmarkMetric.system,
              desiredDuration: defaultRunTime()) { benchmark in
        dummyCounter(defaultCounter())
    }

    Benchmark("All metrics, full concurrency, async",
              metrics: BenchmarkMetric.all,
              desiredDuration: .seconds(1)) { benchmark in

        let _ = await withTaskGroup(of: Void.self, returning: Void.self, body: { taskGroup in

            for _ in 0..<1 {
                taskGroup.addTask {
                    dummyCounter(defaultCounter()*1000)
                }
            }

            for await _ in taskGroup {
            }

        })
    }
}
