import Benchmark
import Foundation

func addSomeMoreBenchmarks() {
    Benchmark("SomeMoreBenchmark") { benchmark in
        for _ in benchmark.scaledIterations {
            blackHole(Date())
        }
    }
}
