import Foundation
import CoreLocation
import MapKit

// MARK: - Ride Session State
enum RideState {
    case idle
    case active
    case paused
    case finished
}

// MARK: - Elevation Data Point
struct ElevationPoint: Identifiable {
    let id = UUID()
    let distance: Double   // miles from start
    let elevation: Double  // feet
    let timestamp: Date
}

// MARK: - Interval Lap
struct IntervalLap: Identifiable, Codable {
    let id: UUID
    let lapNumber: Int
    let startTime: Date
    let endTime: Date
    let distance: Double    // miles
    let avgSpeed: Double    // mph
    let avgHeartRate: Double

    var duration: TimeInterval { endTime.timeIntervalSince(startTime) }

    var formattedDuration: String {
        let mins = Int(duration) / 60
        let secs = Int(duration) % 60
        return String(format: "%d:%02d", mins, secs)
    }
}

// MARK: - Completed Ride
struct CompletedRide: Identifiable, Codable {
    let id: UUID
    let workoutID: String?
    let workoutTitle: String
    let startTime: Date
    let endTime: Date
    let totalDistance: Double       // miles
    let movingTime: TimeInterval    // seconds
    let elapsedTime: TimeInterval   // seconds
    let avgSpeed: Double            // mph
    let maxSpeed: Double            // mph
    let totalElevationGain: Double  // feet
    let avgHeartRate: Double
    let maxHeartRate: Double
    let dominantZoneShort: String  // e.g. "Z3" — most common HR zone during ride
    let routeCoordinates: [CLLocationCoordinate2D]
    let elevationPoints: [ElevationPoint]
    let laps: [IntervalLap]
    let notes: String

    var formattedDistance: String { String(format: "%.1f mi", totalDistance) }
    var formattedAvgSpeed: String { String(format: "%.1f mph", avgSpeed) }
    var formattedElevation: String { String(format: "%.0f ft", totalElevationGain) }

    var formattedMovingTime: String {
        let h = Int(movingTime) / 3600
        let m = (Int(movingTime) % 3600) / 60
        let s = Int(movingTime) % 60
        if h > 0 { return String(format: "%d:%02d:%02d", h, m, s) }
        return String(format: "%d:%02d", m, s)
    }

    func withNotes(_ updatedNotes: String) -> CompletedRide {
        CompletedRide(
            id: id,
            workoutID: workoutID,
            workoutTitle: workoutTitle,
            startTime: startTime,
            endTime: endTime,
            totalDistance: totalDistance,
            movingTime: movingTime,
            elapsedTime: elapsedTime,
            avgSpeed: avgSpeed,
            maxSpeed: maxSpeed,
            totalElevationGain: totalElevationGain,
            avgHeartRate: avgHeartRate,
            maxHeartRate: maxHeartRate,
            dominantZoneShort: dominantZoneShort,
            routeCoordinates: routeCoordinates,
            elevationPoints: elevationPoints,
            laps: laps,
            notes: updatedNotes
        )
    }
}

// MARK: - CLLocationCoordinate2D Codable
extension CLLocationCoordinate2D: @retroactive Codable {
    public init(from decoder: Decoder) throws {
        var container = try decoder.unkeyedContainer()
        let lat = try container.decode(Double.self)
        let lon = try container.decode(Double.self)
        self.init(latitude: lat, longitude: lon)
    }
    public func encode(to encoder: Encoder) throws {
        var container = encoder.unkeyedContainer()
        try container.encode(latitude)
        try container.encode(longitude)
    }
}

// MARK: - ElevationPoint Codable
extension ElevationPoint: Codable {
    enum CodingKeys: String, CodingKey {
        case distance, elevation, timestamp
    }
    init(from decoder: Decoder) throws {
        let c = try decoder.container(keyedBy: CodingKeys.self)
        distance = try c.decode(Double.self, forKey: .distance)
        elevation = try c.decode(Double.self, forKey: .elevation)
        timestamp = try c.decode(Date.self, forKey: .timestamp)
    }
    func encode(to encoder: Encoder) throws {
        var c = encoder.container(keyedBy: CodingKeys.self)
        try c.encode(distance, forKey: .distance)
        try c.encode(elevation, forKey: .elevation)
        try c.encode(timestamp, forKey: .timestamp)
    }
}
