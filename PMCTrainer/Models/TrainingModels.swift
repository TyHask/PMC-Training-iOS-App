import Foundation
import SwiftUI

// MARK: - Workout Status
enum WorkoutStatus: String, Codable, CaseIterable {
    case notStarted = "notStarted"
    case inProgress = "inProgress"
    case completed = "completed"
    case skipped = "skipped"

    var displayName: String {
        switch self {
        case .notStarted: return "Not Started"
        case .inProgress: return "In Progress"
        case .completed: return "Completed"
        case .skipped: return "Skipped"
        }
    }

    var icon: String {
        switch self {
        case .notStarted: return "circle"
        case .inProgress: return "clock.fill"
        case .completed: return "checkmark.circle.fill"
        case .skipped: return "forward.circle.fill"
        }
    }

    var color: Color {
        switch self {
        case .notStarted: return .gray
        case .inProgress: return Color(red: 0.059, green: 0.820, blue: 0.780) // PMCTheme.tealAccent
        case .completed: return .green
        case .skipped: return .yellow
        }
    }
}

// MARK: - Training Zone
enum TrainingZone: String, Codable {
    case z1 = "Z1"
    case z2 = "Z2"
    case z3 = "Z3"
    case z4 = "Z4"
    case z5 = "Z5"
    case rest = "Rest"
    case mixed = "Mixed"

    var displayName: String {
        switch self {
        case .z1: return "Z1 Recovery"
        case .z2: return "Z2 Aerobic"
        case .z3: return "Z3 Tempo"
        case .z4: return "Z4 Threshold"
        case .z5: return "Z5 Anaerobic"
        case .rest: return "Rest"
        case .mixed: return "Mixed Zones"
        }
    }

    var color: Color {
        switch self {
        case .z1: return Color(red: 0.4, green: 0.8, blue: 0.4)
        case .z2: return Color(red: 0.2, green: 0.6, blue: 1.0)
        case .z3: return Color(red: 1.0, green: 0.8, blue: 0.0)
        case .z4: return Color(red: 1.0, green: 0.5, blue: 0.0)
        case .z5: return Color(red: 1.0, green: 0.2, blue: 0.2)
        case .rest: return Color.gray
        case .mixed: return Color(red: 0.6, green: 0.4, blue: 1.0)
        }
    }

    var rpeRange: String {
        switch self {
        case .z1: return "RPE < 5"
        case .z2: return "RPE 5–7"
        case .z3: return "RPE 7–8"
        case .z4: return "RPE 8–9"
        case .z5: return "RPE 10"
        case .rest: return "—"
        case .mixed: return "Varies"
        }
    }

    var description: String {
        switch self {
        case .z1: return "Very easy, active recovery"
        case .z2: return "Conversational pace, aerobic base"
        case .z3: return "Tempo, conversation is difficult"
        case .z4: return "Lactate threshold, hard to sustain"
        case .z5: return "Maximum effort, short intervals only"
        case .rest: return "Full rest or gentle yoga"
        case .mixed: return "Multiple zones in one session"
        }
    }
}

// MARK: - Workout Type
enum WorkoutType: String, Codable {
    case rest = "Rest"
    case easySpin = "Easy Spin"
    case foundationRide = "Foundation Ride"
    case tempoRide = "Tempo Ride"
    case thresholdRide = "Threshold Ride"
    case longRide = "Long Ride"
    case backToBack = "Back-to-Back"
    case crossTraining = "Cross Training"
    case raceDay = "Race Day"
    case tuneUp = "Tune-Up Ride"
    case climbRide = "Climb Ride"
    case yoga = "Yoga / Stretch"
    case travel = "Travel Day"

    var icon: String {
        switch self {
        case .rest: return "moon.zzz.fill"
        case .yoga: return "figure.mind.and.body"
        case .crossTraining: return "figure.run"
        case .travel: return "car.fill"
        case .raceDay: return "flag.checkered"
        default: return "bicycle"
        }
    }
}

// MARK: - Daily Workout
struct DailyWorkout: Identifiable, Codable {
    let id: String
    let weekNumber: Int
    let dayOfWeek: Int // 0 = Monday, 6 = Sunday
    let date: Date
    let workoutType: WorkoutType
    let primaryZone: TrainingZone
    let title: String
    let description: String
    let estimatedDuration: String // e.g. "45-60 min"
    let estimatedDistance: String // e.g. "20 mi" or ""
    let isRaceDay: Bool
    var status: WorkoutStatus

    var weekdayName: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "EEEE"
        return formatter.string(from: date)
    }

    var shortDate: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMM d"
        return formatter.string(from: date)
    }

    var isToday: Bool {
        Calendar.current.isDateInToday(date)
    }

    var isPast: Bool {
        date < Calendar.current.startOfDay(for: Date())
    }

    var isFuture: Bool {
        date > Calendar.current.startOfDay(for: Date())
    }
}

// MARK: - Training Week
struct TrainingWeek: Identifiable, Codable {
    let id: Int
    let weekNumber: Int
    let startDate: Date
    let title: String
    let subtitle: String
    let isRecoveryWeek: Bool
    let isPeakWeek: Bool
    let isTaperWeek: Bool
    let isRaceWeek: Bool
    var workouts: [DailyWorkout]

    var completedCount: Int {
        workouts.filter { $0.status == .completed }.count
    }

    var scheduledCount: Int {
        workouts.filter { $0.workoutType != .rest }.count
    }

    var progressPercentage: Double {
        guard scheduledCount > 0 else { return 0 }
        return Double(completedCount) / Double(scheduledCount)
    }

    var endDate: Date {
        Calendar.current.date(byAdding: .day, value: 6, to: startDate) ?? startDate
    }
}

// MARK: - Zone Reference
struct ZoneReference: Identifiable {
    let id = UUID()
    let zone: TrainingZone
    let name: String
    let rpe: String
    let description: String
    let heartRatePercent: String
}

// MARK: - Heart Rate Zones
struct HeartRateZones {
    let maxHR: Int

    var z1Max: Int { Int(Double(maxHR) * 0.60) }
    var z2Min: Int { Int(Double(maxHR) * 0.61) }
    var z2Max: Int { Int(Double(maxHR) * 0.70) }
    var z3Min: Int { Int(Double(maxHR) * 0.71) }
    var z3Max: Int { Int(Double(maxHR) * 0.80) }
    var z4Min: Int { Int(Double(maxHR) * 0.81) }
    var z4Max: Int { Int(Double(maxHR) * 0.90) }
    var z5Min: Int { Int(Double(maxHR) * 0.91) }

    var zones: [(zone: TrainingZone, range: String)] {
        [
            (.z1, "< \(z1Max) bpm"),
            (.z2, "\(z2Min)–\(z2Max) bpm"),
            (.z3, "\(z3Min)–\(z3Max) bpm"),
            (.z4, "\(z4Min)–\(z4Max) bpm"),
            (.z5, "\(z5Min)+ bpm")
        ]
    }
}
