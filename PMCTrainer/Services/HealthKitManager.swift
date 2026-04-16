import Foundation
import HealthKit
import SwiftUI
import Combine

// MARK: - HealthKitManager
// Streams live heart rate from Apple Health (fed by WHOOP via Bluetooth).
// Works entirely on-device — no internet connection required during rides.
// Uses HKAnchoredObjectQuery with a live observer for ~5-second HR updates.

class HealthKitManager: ObservableObject {

    // MARK: - Published State
    @Published var isAuthorized: Bool = false
    @Published var currentHR: Double = 0          // bpm, live
    @Published var currentZone: TrainingZone = .rest
    @Published var maxHR: Int = 190               // user-configured max HR
    @Published var isStreaming: Bool = false
    @Published var lastHRDate: Date?
    @Published var hrHistory: [HRSample] = []     // for avg/max calc during ride
    @Published var authorizationStatus: String = "Not requested"

    // MARK: - Private
    private let store = HKHealthStore()
    private var anchoredQuery: HKAnchoredObjectQuery?
    private var observerQuery: HKObserverQuery?
    private var anchor: HKQueryAnchor?

    static let shared = HealthKitManager()

    // MARK: - HR Sample
    struct HRSample: Identifiable {
        let id = UUID()
        let bpm: Double
        let date: Date
    }

    // MARK: - Availability
    var isAvailable: Bool { HKHealthStore.isHealthDataAvailable() }

    // MARK: - Request Authorization
    func requestAuthorization(completion: @escaping (Bool) -> Void = { _ in }) {
        guard isAvailable else {
            DispatchQueue.main.async { self.authorizationStatus = "Not available on this device" }
            completion(false)
            return
        }

        let hrType = HKQuantityType.quantityType(forIdentifier: .heartRate)!
        let readTypes: Set<HKObjectType> = [hrType]

        store.requestAuthorization(toShare: nil, read: readTypes) { [weak self] success, error in
            DispatchQueue.main.async {
                self?.isAuthorized = success
                if success {
                    self?.authorizationStatus = "Authorized"
                } else {
                    self?.authorizationStatus = error?.localizedDescription ?? "Denied"
                }
                completion(success)
            }
        }
    }

    // MARK: - Start Live HR Streaming
    // Uses HKAnchoredObjectQuery + observer so we get called every time
    // a new HR sample is written — WHOOP writes ~every 5 seconds during activity.
    func startStreaming() {
        guard isAvailable, !isStreaming else { return }

        let hrType = HKQuantityType.quantityType(forIdentifier: .heartRate)!

        // Predicate: only samples from the last 30 seconds at startup,
        // then live updates from the observer
        let predicate = HKQuery.predicateForSamples(
            withStart: Date().addingTimeInterval(-30),
            end: nil,
            options: .strictStartDate
        )

        // Anchored query — fires immediately with recent samples, then stays live
        let query = HKAnchoredObjectQuery(
            type: hrType,
            predicate: predicate,
            anchor: anchor,
            limit: HKObjectQueryNoLimit
        ) { [weak self] _, samples, _, newAnchor, _ in
            self?.anchor = newAnchor
            self?.process(samples: samples)
        }

        // Update handler — called every time a new HR sample arrives
        query.updateHandler = { [weak self] _, samples, _, newAnchor, _ in
            self?.anchor = newAnchor
            self?.process(samples: samples)
        }

        store.execute(query)
        anchoredQuery = query

        // Enable background delivery so updates arrive even when screen is locked
        store.enableBackgroundDelivery(for: hrType, frequency: .immediate) { _, _ in }

        DispatchQueue.main.async { self.isStreaming = true }
    }

    // MARK: - Stop Streaming
    func stopStreaming() {
        if let q = anchoredQuery { store.stop(q) }
        if let q = observerQuery { store.stop(q) }
        anchoredQuery = nil
        observerQuery = nil
        DispatchQueue.main.async {
            self.isStreaming = false
            self.currentHR = 0
            self.currentZone = .rest
        }
    }

    // MARK: - Reset for new ride
    func resetForRide() {
        hrHistory.removeAll()
        anchor = nil
    }

    // MARK: - Process Incoming Samples
    private func process(samples: [HKSample]?) {
        guard let samples = samples as? [HKQuantitySample], !samples.isEmpty else { return }

        // Sort by date, take the most recent
        let sorted = samples.sorted { $0.startDate < $1.startDate }

        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            for sample in sorted {
                let bpm = sample.quantity.doubleValue(for: HKUnit(from: "count/min"))
                let hrSample = HRSample(bpm: bpm, date: sample.startDate)
                self.hrHistory.append(hrSample)
            }

            if let latest = sorted.last {
                let bpm = latest.quantity.doubleValue(for: HKUnit(from: "count/min"))
                self.currentHR = bpm
                self.lastHRDate = latest.startDate
                self.currentZone = self.zone(for: bpm)
            }
        }
    }

    // MARK: - Zone Calculation
    // Uses the user's configured maxHR to calculate zones
    func zone(for bpm: Double) -> TrainingZone {
        guard maxHR > 0, bpm > 0 else { return .rest }
        let pct = bpm / Double(maxHR)
        switch pct {
        case ..<0.60: return .rest
        case 0.60..<0.70: return .z1
        case 0.70..<0.80: return .z2
        case 0.80..<0.90: return .z3
        case 0.90..<0.95: return .z4
        default: return .z5
        }
    }

    // MARK: - Ride Stats
    var avgHR: Double {
        guard !hrHistory.isEmpty else { return 0 }
        return hrHistory.map(\.bpm).reduce(0, +) / Double(hrHistory.count)
    }

    var maxHRRecorded: Double {
        hrHistory.map(\.bpm).max() ?? 0
    }

    // MARK: - Zone Name & Color helpers (convenience)
    var currentZoneName: String {
        switch currentZone {
        case .rest: return "Rest"
        case .z1:   return "Zone 1"
        case .z2:   return "Zone 2"
        case .z3:   return "Zone 3"
        case .z4:   return "Zone 4"
        case .z5:   return "Zone 5"
        case .mixed: return "Mixed Zones"
        }
    }

    var currentZoneShort: String {
        switch currentZone {
        case .rest: return "–"
        case .z1:   return "Z1"
        case .z2:   return "Z2"
        case .z3:   return "Z3"
        case .z4:   return "Z4"
        case .z5:   return "Z5"
        case .mixed: return "Mix"
        }
    }

    var currentZoneColor: Color {
        switch currentZone {
        case .rest: return PMCTheme.lightTeal
        case .z1:   return Color(red: 0.3, green: 0.85, blue: 0.7)
        case .z2:   return PMCTheme.tealAccent
        case .z3:   return Color(red: 1.0, green: 0.78, blue: 0.2)   // gold
        case .z4:   return Color(red: 1.0, green: 0.45, blue: 0.1)   // orange
        case .z5:   return PMCTheme.patriotRed
        case .mixed: return TrainingZone.mixed.color
        }
    }

    var currentZoneDescription: String {
        switch currentZone {
        case .rest: return "Recovery"
        case .z1:   return "Easy"
        case .z2:   return "Endurance"
        case .z3:   return "Tempo"
        case .z4:   return "Threshold"
        case .z5:   return "Max Effort"
        case .mixed: return "Variable"
        }
    }

    // MARK: - HR Freshness
    // Returns true if the last HR reading is within 15 seconds (WHOOP syncs ~every 5s)
    var isHRFresh: Bool {
        guard let last = lastHRDate else { return false }
        return Date().timeIntervalSince(last) < 15
    }
}
