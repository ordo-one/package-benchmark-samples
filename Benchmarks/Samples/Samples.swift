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
    // A way to define custom metrics fairly compact
    enum CustomMetrics {
        static var one: BenchmarkMetric { .custom("CustomMetricOne") }
        static var two: BenchmarkMetric { .custom("CustomMetricTwo", polarity: .prefersLarger) }
    }

    Benchmark.defaultDesiredDuration = .milliseconds(20)

    @Sendable func defaultCounter() -> Int { 1000 }
    @Sendable func dummyCounter(_ count: Int) {
        for x in 0 ..< count {
            blackHole(x)
        }
    }

    // The actual benchmarks

    Benchmark("myInternalDummyCounter", metrics: [.wallClock, .throughput]) { _ in
        myInternalDummyCounter(defaultCounter()) // Calls the function internal to the library target using @testable import
    }

    Benchmark("Counter", metrics: [.wallClock, .throughput]) { _ in
        dummyCounter(defaultCounter())
        dummyCounter(defaultCounter())
    }

    Benchmark("Counter no init (should be ~2x faster than Counter)",
              metrics: [.wallClock, .throughput]) { benchmark in
        dummyCounter(defaultCounter())
        benchmark.startMeasurement() // don't include setup
        dummyCounter(defaultCounter())
    }

    Benchmark("Counter no deinit (should be ~2x faster than Counter)",
              metrics: [.wallClock, .throughput]) { benchmark in
        dummyCounter(defaultCounter())
        benchmark.stopMeasurement() // skip cleanup
        dummyCounter(defaultCounter())
    }

    Benchmark("Counter no init/deinit (should be ~2x faster than Counter)",
              metrics: [.wallClock, .throughput]) { benchmark in
        dummyCounter(defaultCounter())
        benchmark.startMeasurement() // skip both setup
        dummyCounter(defaultCounter())
        benchmark.stopMeasurement() // and cleanup
        dummyCounter(defaultCounter())
    }

    Benchmark("Minimal benchmark",
              metrics: [.wallClock]) { _ in
    }

    Benchmark("Extended metrics",
              metrics: BenchmarkMetric.extended) { _ in
        dummyCounter(defaultCounter())
    }

    Benchmark("Counter force nanoseconds (result may be power-of-two)",
              metrics: [.wallClock, .throughput],
              timeUnits: .nanoseconds) { _ in
        dummyCounter(defaultCounter())
        dummyCounter(defaultCounter())
    }

    Benchmark("Custom metrics",
              metrics: [CustomMetrics.one, CustomMetrics.two]) { benchmark in
        benchmark.measurement(CustomMetrics.one, Int.random(in: 1 ... 1_000_000))
        benchmark.measurement(CustomMetrics.two, Int.random(in: 1 ... 1000))
    }

    Benchmark("Extended + custom metrics",
              metrics: BenchmarkMetric.extended + [CustomMetrics.one, CustomMetrics.two]) { benchmark in
        dummyCounter(defaultCounter())
        benchmark.measurement(CustomMetrics.one, Int.random(in: 1 ... 1_000_000))
        benchmark.measurement(CustomMetrics.two, Int.random(in: 1 ... 1000))
    }

    Benchmark("Counter 57 iterations",
              metrics: [.wallClock, .throughput],
              desiredIterations: 57) { _ in
        dummyCounter(57)
    }

    Benchmark("Counter 57 iterations no warmup",
              metrics: [.wallClock, .throughput],
              warmupIterations: 0,
              desiredIterations: 57) { benchmark in
        dummyCounter(57)
        if benchmark.currentIteration > 57 {
            fatalError("benchmark.currentIteration > 57!")
        }
    }

    Benchmark("Counter disabled test", skip: true) { _ in
        fatalError("This test is disabled and should not have been run")
    }

    Benchmark("Specific metrics",
              metrics: [.wallClock, .cpuTotal, .memoryLeaked]) { _ in
        dummyCounter(defaultCounter())
    }

    Benchmark("Disk metrics, writing 64K x 1.000",
              metrics: BenchmarkMetric.disk,
              throughputScalingFactor: .kilo,
              desiredDuration: .seconds(1)) { benchmark in
        do {
            let fileDescriptor = FileDescriptor(rawValue: fileno(tmpfile()))
            let data = [UInt8].init(repeating: 47, count: 64 * 1024)

            benchmark.startMeasurement()

            try fileDescriptor.closeAfter {
                try data.withUnsafeBufferPointer {
                    for _ in benchmark.throughputIterations {
                        _ = try fileDescriptor.write(UnsafeRawBufferPointer($0))
                    }
                }
            }
        } catch {}
    }

    func concurrentWork(tasks: Int = 4, mallocs: Int = 0) async {
        _ = await withTaskGroup(of: Void.self, returning: Void.self, body: { taskGroup in

            for _ in 0 ..< tasks {
                taskGroup.addTask {
                    dummyCounter(defaultCounter() * 1000)
                    for _ in 0 ..< mallocs {
                        let x = malloc(1024 * 1024)
                        blackHole(x)
                        free(x)
                    }
                }
            }

            for await _ in taskGroup {}

        })
    }

    Benchmark("Memory metrics, async",
              metrics: BenchmarkMetric.memory) { _ in
        await concurrentWork(tasks: 10, mallocs: 1000)
    }

    Benchmark("System metrics, async",
              metrics: BenchmarkMetric.system) { _ in
        await concurrentWork(mallocs: 10)
    }

    Benchmark("All metrics, full concurrency, async",
              metrics: BenchmarkMetric.all,
              desiredDuration: .seconds(1)) { _ in
        await concurrentWork(tasks: 80)
    }

    Benchmark("Counter, standard metric thresholds",
              metrics: [.wallClock, .throughput],
              thresholds: [.wallClock: .relaxed,
                           .throughput: .strict]) { _ in
        dummyCounter(defaultCounter())
        dummyCounter(defaultCounter())
    }

    let customThreshold = BenchmarkResult.PercentileThresholds(relative: [.p50: 5.0, .p75: 10.0],
                                                               absolute: [.p25: 10, .p50: 15])
    let customThreshold2 = BenchmarkResult.PercentileThresholds(relative: .strict)
    let customThreshold3 = BenchmarkResult.PercentileThresholds(absolute: .relaxed)

    Benchmark("Counter, custom metric thresholds",
              metrics: [.wallClock, .throughput, .cpuTotal, .cpuUser],
              thresholds: [.wallClock: customThreshold,
                           .throughput: customThreshold2,
                           .cpuTotal: customThreshold3,
                           .cpuUser: .strict]) { _ in
        dummyCounter(defaultCounter())
        dummyCounter(defaultCounter())
    }

    Benchmark("Failing benchmark") { _ in
        //    benchmark.error("This benchmark failed due to reason XXX")
    }
}
