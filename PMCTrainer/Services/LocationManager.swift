import Foundation
import CoreLocation
import Combine
import MapKit

// MARK: - Location Manager
class LocationManager: NSObject, ObservableObject, CLLocationManagerDelegate {

    private let manager = CLLocationManager()

    // MARK: - Published State
    @Published var authorizationStatus: CLAuthorizationStatus = .notDetermined
    @Published var currentLocation: CLLocation?
    @Published var currentSpeed: Double = 0         // mph
    @Published var currentAltitude: Double = 0      // feet
    @Published var totalDistance: Double = 0        // miles
    @Published var totalElevationGain: Double = 0   // feet
    @Published var avgSpeed: Double = 0             // mph
    @Published var maxSpeed: Double = 0             // mph
    @Published var routeCoordinates: [CLLocationCoordinate2D] = []
    @Published var elevationPoints: [ElevationPoint] = []
    @Published var rideState: RideState = .idle

    // MARK: - Internal Tracking
    private var lastLocation: CLLocation?
    private var lastAltitude: Double = 0
    private var speedReadings: [Double] = []
    private var movingTime: TimeInterval = 0
    private var lastUpdateTime: Date?
    private var pausedAt: Date?

    // MARK: - Ride Timing
    private(set) var rideStartTime: Date?
    private(set) var ridePauseTime: TimeInterval = 0

    override init() {
        super.init()
        manager.delegate = self
        manager.desiredAccuracy = kCLLocationAccuracyBestForNavigation
        manager.distanceFilter = 5  // update every 5 meters
        manager.activityType = .fitness
        manager.allowsBackgroundLocationUpdates = true
        manager.pausesLocationUpdatesAutomatically = false
        authorizationStatus = manager.authorizationStatus
    }

    // MARK: - Permission
    func requestPermission() {
        manager.requestAlwaysAuthorization()
    }

    // MARK: - Start Ride
    func startRide() {
        reset()
        rideStartTime = Date()
        rideState = .active
        manager.startUpdatingLocation()
        manager.startUpdatingHeading()
    }

    // MARK: - Pause Ride
    func pauseRide() {
        guard rideState == .active else { return }
        rideState = .paused
        pausedAt = Date()
        manager.stopUpdatingLocation()
    }

    // MARK: - Resume Ride
    func resumeRide() {
        guard rideState == .paused else { return }
        if let pausedAt = pausedAt {
            ridePauseTime += Date().timeIntervalSince(pausedAt)
        }
        pausedAt = nil
        rideState = .active
        manager.startUpdatingLocation()
    }

    // MARK: - Stop Ride
    func stopRide() {
        rideState = .finished
        manager.stopUpdatingLocation()
        manager.stopUpdatingHeading()
    }

    // MARK: - Reset
    func reset() {
        lastLocation = nil
        lastAltitude = 0
        speedReadings = []
        movingTime = 0
        lastUpdateTime = nil
        pausedAt = nil
        ridePauseTime = 0
        rideStartTime = nil
        currentSpeed = 0
        currentAltitude = 0
        totalDistance = 0
        totalElevationGain = 0
        avgSpeed = 0
        maxSpeed = 0
        routeCoordinates = []
        elevationPoints = []
        rideState = .idle
    }

    // MARK: - Elapsed Time
    var elapsedTime: TimeInterval {
        guard let start = rideStartTime else { return 0 }
        let total = Date().timeIntervalSince(start)
        return total - ridePauseTime
    }

    // MARK: - CLLocationManagerDelegate
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard rideState == .active else { return }
        guard let location = locations.last else { return }

        // Filter out inaccurate readings
        guard location.horizontalAccuracy < 20 else { return }

        currentLocation = location

        // Speed (convert m/s to mph)
        let speedMPS = max(location.speed, 0)
        let speedMPH = speedMPS * 2.23694
        currentSpeed = speedMPH

        if speedMPH > 0.5 { // Only count when actually moving
            speedReadings.append(speedMPH)
            if speedMPH > maxSpeed { maxSpeed = speedMPH }
        }

        // Altitude (convert meters to feet)
        let altitudeFeet = location.altitude * 3.28084
        currentAltitude = altitudeFeet

        // Elevation gain
        if lastAltitude > 0 {
            let gain = altitudeFeet - lastAltitude
            if gain > 1.0 { // Only count meaningful gains (>1 ft)
                totalElevationGain += gain
            }
        }
        lastAltitude = altitudeFeet

        // Distance
        if let last = lastLocation {
            let delta = location.distance(from: last)
            if delta > 1 { // Only count if moved > 1 meter
                totalDistance += delta / 1609.344 // meters to miles
            }
        }
        lastLocation = location

        // Route coordinates
        routeCoordinates.append(location.coordinate)

        // Elevation points (sample every 0.05 miles)
        let lastElevDist = elevationPoints.last?.distance ?? -1
        if totalDistance - lastElevDist > 0.05 || elevationPoints.isEmpty {
            elevationPoints.append(ElevationPoint(
                distance: totalDistance,
                elevation: altitudeFeet,
                timestamp: Date()
            ))
        }

        // Average speed
        if !speedReadings.isEmpty {
            avgSpeed = speedReadings.reduce(0, +) / Double(speedReadings.count)
        }
    }

    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        DispatchQueue.main.async {
            self.authorizationStatus = status
        }
    }

    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("Location error: \(error.localizedDescription)")
    }

    // MARK: - Snapshot for Summary
    func buildCompletedRide(
        workoutID: String?,
        workoutTitle: String,
        laps: [IntervalLap],
        avgHR: Double,
        maxHR: Double,
        dominantZoneShort: String = "--",
        notes: String
    ) -> CompletedRide {
        let end = Date()
        let elapsed = rideStartTime.map { end.timeIntervalSince($0) } ?? 0

        return CompletedRide(
            id: UUID(),
            workoutID: workoutID,
            workoutTitle: workoutTitle,
            startTime: rideStartTime ?? end,
            endTime: end,
            totalDistance: totalDistance,
            movingTime: elapsed - ridePauseTime,
            elapsedTime: elapsed,
            avgSpeed: avgSpeed,
            maxSpeed: maxSpeed,
            totalElevationGain: totalElevationGain,
            avgHeartRate: avgHR,
            maxHeartRate: maxHR,
            dominantZoneShort: dominantZoneShort,
            routeCoordinates: routeCoordinates,
            elevationPoints: elevationPoints,
            laps: laps,
            notes: notes
        )
    }
}
