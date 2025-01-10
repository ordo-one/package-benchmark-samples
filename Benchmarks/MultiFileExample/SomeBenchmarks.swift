import Benchmark
import Foundation

func addSomeBenchmarks() {
    Benchmark("SomeBenchmark") { benchmark in
        for _ in benchmark.scaledIterations {
            blackHole(Date())
        }
    }
}
