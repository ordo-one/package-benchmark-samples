public struct PackageBenchmarkSamples {
    public private(set) var text = "Hello, World!"

    public init() {}
}

func myInternalDummyCounter(_ count: Int) {
    var sum = 0
    for x in 0 ..< count {
        sum += x
    }
    if Int.random(in: 0 ... 100_000_000) == 4711 { // Make sure optimizer doesn't take us out
        print("\(sum)")
    }
}
