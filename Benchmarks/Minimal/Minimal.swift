//
// Copyright (c) 2022 Ordo One AB.
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
//
// You may obtain a copy of the License at
// http://www.apache.org/licenses/LICENSE-2.0
//

import BenchmarkSupport // import supporting infrastructure
@main extension BenchmarkRunner {} // Required for main() definition to not get linker errors

@_dynamicReplacement(for: registerBenchmarks) // Register benchmarks
func benchmarks() {
    Benchmark("Minimal benchmark") { _ in
    }
}
