import Foundation
import Combine

class WorkoutStore: ObservableObject {
    @Published var weeks: [TrainingWeek] = []
    @Published var selectedWeek: TrainingWeek?
    @Published var selectedWorkout: DailyWorkout?
    @Published var completedRides: [CompletedRide] = []

    private let storageKey = "pmc_workout_statuses"
    private let ridesKey   = "pmc_completed_rides"

    init() {
        weeks = TrainingPlanData.buildPlan()
        loadStatuses()
        loadRides()
    }

    // MARK: - Computed Properties

    var raceDate: Date {
        var components = DateComponents()
        components.year = 2026
        components.month = 8
        components.day = 1
        return Calendar.current.date(from: components) ?? Date()
    }

    var daysUntilRace: Int {
        let today = Calendar.current.startOfDay(for: Date())
        let race  = Calendar.current.startOfDay(for: raceDate)
        return Calendar.current.dateComponents([.day], from: today, to: race).day ?? 0
    }

    var currentWeek: TrainingWeek? {
        let today = Calendar.current.startOfDay(for: Date())
        return weeks.first { week in
            let start = Calendar.current.startOfDay(for: week.startDate)
            let end   = Calendar.current.startOfDay(for: week.endDate)
            return today >= start && today <= end
        }
    }

    var todayWorkout: DailyWorkout? {
        let today = Calendar.current.startOfDay(for: Date())
        for week in weeks {
            for workout in week.workouts {
                if Calendar.current.startOfDay(for: workout.date) == today {
                    return workout
                }
            }
        }
        return nil
    }

    var allWorkouts: [DailyWorkout] {
        weeks.flatMap { $0.workouts }
    }

    var totalCompleted: Int {
        allWorkouts.filter { $0.status == .completed }.count
    }

    var totalScheduled: Int {
        allWorkouts.filter { $0.workoutType != .rest }.count
    }

    var overallProgress: Double {
        guard totalScheduled > 0 else { return 0 }
        return Double(totalCompleted) / Double(totalScheduled)
    }

    // MARK: - Status Updates

    func updateStatus(workoutID: String, status: WorkoutStatus) {
        for weekIndex in weeks.indices {
            for workoutIndex in weeks[weekIndex].workouts.indices {
                if weeks[weekIndex].workouts[workoutIndex].id == workoutID {
                    weeks[weekIndex].workouts[workoutIndex].status = status
                    saveStatuses()
                    return
                }
            }
        }
    }

    /// Convenience alias used by RideSummaryView
    func markWorkout(id: String, status: WorkoutStatus) {
        updateStatus(workoutID: id, status: status)
    }

    func workout(for id: String) -> DailyWorkout? {
        allWorkouts.first { $0.id == id }
    }

    // MARK: - Ride History

    func saveCompletedRide(_ ride: CompletedRide) {
        if let existingIndex = completedRides.firstIndex(where: { $0.id == ride.id }) {
            completedRides[existingIndex] = ride
        } else {
            completedRides.insert(ride, at: 0)
        }
        completedRides.sort { $0.startTime > $1.startTime }
        persistRides()
    }

    // MARK: - Week Helpers

    func week(for weekNumber: Int) -> TrainingWeek? {
        weeks.first { $0.weekNumber == weekNumber }
    }

    func nextWorkout(after date: Date) -> DailyWorkout? {
        let sortedWorkouts = allWorkouts
            .filter { $0.date > date && $0.workoutType != .rest }
            .sorted { $0.date < $1.date }
        return sortedWorkouts.first
    }

    // MARK: - Persistence (workout statuses)

    private func saveStatuses() {
        var statusMap: [String: String] = [:]
        for workout in allWorkouts {
            statusMap[workout.id] = workout.status.rawValue
        }
        UserDefaults.standard.set(statusMap, forKey: storageKey)
    }

    private func loadStatuses() {
        guard let statusMap = UserDefaults.standard.dictionary(forKey: storageKey) as? [String: String] else { return }
        for weekIndex in weeks.indices {
            for workoutIndex in weeks[weekIndex].workouts.indices {
                let id = weeks[weekIndex].workouts[workoutIndex].id
                if let rawValue = statusMap[id], let status = WorkoutStatus(rawValue: rawValue) {
                    weeks[weekIndex].workouts[workoutIndex].status = status
                }
            }
        }
    }

    // MARK: - Persistence (completed rides)

    private func persistRides() {
        if let data = try? JSONEncoder().encode(completedRides) {
            UserDefaults.standard.set(data, forKey: ridesKey)
        }
    }

    private func loadRides() {
        guard let data = UserDefaults.standard.data(forKey: ridesKey),
              let rides = try? JSONDecoder().decode([CompletedRide].self, from: data) else { return }
        completedRides = rides
    }
}
