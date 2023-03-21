import Benchmark // imports supporting benchmark infrastructure
import ExtrasJSON
import Foundation

func loadGeoJSON() async -> Data {
    guard let traceURL = Bundle.module.url(forResource: "example", withExtension: "geojson") else {
        fatalError("Unable to find example.geojson in bundle")
    }
    let data: Data
    do {
        data = try Data(contentsOf: traceURL, options: .mappedIfSafe)
    } catch {
        fatalError("failed load JSON data from example.geojson URL")
    }
    return data
}

func parseDataIntoJSONSerialization(data: Data) async -> [String: Any] {
    do {
        guard let json = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any] else {
            fatalError("failed parse JSON: nil object returned")
        }
        return json
    } catch let error as NSError {
        fatalError("failed parse JSON: \(error.localizedDescription)")
    }
}

func parseDataIntoJSON(data: Data) async -> JSONValue {
    do {
        return try ExtrasJSON.JSONParser().parse(bytes: data)
    } catch {
        fatalError("failed parse JSON")
    }
}

let benchmarks = {
    Benchmark.defaultConfiguration.maxIterations = .count(1)
    Benchmark.defaultConfiguration.maxDuration = .seconds(3)

    Benchmark("Loading JSON trace data",
              configuration: .init(metrics: [.throughput, .wallClock], maxIterations: 20)) { benchmark in
        for _ in benchmark.scaledIterations {
            blackHole(await loadGeoJSON())
        }
    }

    Benchmark("parse JSON with Swift Extras parser",
              configuration: .init(metrics: [.throughput, .wallClock], maxIterations: 500)) { benchmark in
        for _ in benchmark.scaledIterations {
            let data = await loadGeoJSON()
            benchmark.startMeasurement()
            blackHole(await parseDataIntoJSON(data: data))
            benchmark.stopMeasurement()
        }
    }

    Benchmark("parse JSON with Foundation JSONSerialization parser",
              configuration: .init(metrics: [.throughput, .wallClock], maxIterations: 500)) { benchmark in
        for _ in benchmark.scaledIterations {
            let data = await loadGeoJSON()
            benchmark.startMeasurement()
            blackHole(await parseDataIntoJSONSerialization(data: data))
            benchmark.stopMeasurement()
        }
    }
}
