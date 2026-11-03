import XCTest
@testable import InSite

final class RouteEngineTests: XCTestCase {
    /// `a` and `b` are joined by a short stairs edge and a longer ramp edge.
    private func parallelEdgeGraph() throws -> FloorGraph {
        let json = """
        {
          "data_state": "ui_prototype",
          "map_id": "test",
          "coordinate_frame": "test",
          "units": "schematic",
          "nodes": [
            { "id": "a", "label": "A", "kind": "corridor", "x": 0, "y": 0, "z": 0 },
            { "id": "b", "label": "B", "kind": "corridor", "x": 1, "y": 0, "z": 0 }
          ],
          "edges": [
            { "from": "a", "to": "b", "edge_type": "stairs", "length_meters": 2,
              "has_stairs": true, "status": "open", "verified": true },
            { "from": "a", "to": "b", "edge_type": "ramp", "length_meters": 5,
              "has_stairs": false, "status": "open", "verified": true }
          ]
        }
        """.data(using: .utf8)!
        return try JSONDecoder().decode(FloorGraph.self, from: json)
    }

    func testAccessibleRouteReportsTheEdgeActuallyTaken() throws {
        let engine = RouteEngine(graph: try parallelEdgeGraph())
        let result = try engine.route(from: "a", to: "b", accessibleMode: true)

        XCTAssertEqual(result.steps.count, 1)
        XCTAssertEqual(result.steps.first?.edge.edgeType, .ramp)
        XCTAssertEqual(result.totalLengthMeters, 5)
    }

    func testNonAccessibleRouteTakesShortestEdge() throws {
        let engine = RouteEngine(graph: try parallelEdgeGraph())
        let result = try engine.route(from: "a", to: "b", accessibleMode: false)

        XCTAssertEqual(result.steps.first?.edge.edgeType, .stairs)
        XCTAssertEqual(result.totalLengthMeters, 2)
    }
}
