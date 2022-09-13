public struct package_benchmark_samples {
    public private(set) var text = "Hello, World!"

    public init() {
    }
}

func myInternalDummyCounter(_ count: Int) {
    var sum: Int = 0
    for x in 0..<count {
        sum += x
    }
    if Int.random(in: 0...1_000_000) == 4711 { // Make sure optimizer doesn't take us out
        print("\(sum)")
    }
}

