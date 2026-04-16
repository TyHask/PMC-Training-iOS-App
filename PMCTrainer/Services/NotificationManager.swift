import Foundation
import UserNotifications
import SwiftUI

// MARK: - Notification Manager
class NotificationManager: ObservableObject {
    @Published var notificationsEnabled: Bool = false
    @Published var permissionStatus: UNAuthorizationStatus = .notDetermined

    private let notificationCenter = UNUserNotificationCenter.current()
    private let enabledKey = "notifications_enabled"

    init() {
        notificationsEnabled = UserDefaults.standard.bool(forKey: enabledKey)
        checkPermissionStatus()
    }

    // MARK: - Permission Check
    func checkPermissionStatus() {
        notificationCenter.getNotificationSettings { [weak self] settings in
            DispatchQueue.main.async {
                self?.permissionStatus = settings.authorizationStatus
                if settings.authorizationStatus == .denied {
                    self?.notificationsEnabled = false
                    UserDefaults.standard.set(false, forKey: self?.enabledKey ?? "")
                }
            }
        }
    }

    // MARK: - Request Permission and Schedule
    func requestPermissionAndSchedule(workouts: [DailyWorkout]) {
        notificationCenter.requestAuthorization(options: [.alert, .badge, .sound]) { [weak self] granted, error in
            DispatchQueue.main.async {
                if granted {
                    self?.notificationsEnabled = true
                    UserDefaults.standard.set(true, forKey: self?.enabledKey ?? "")
                    self?.scheduleWorkoutReminders(workouts: workouts)
                } else {
                    self?.notificationsEnabled = false
                    UserDefaults.standard.set(false, forKey: self?.enabledKey ?? "")
                    if let error = error {
                        print("Notification permission error: \(error.localizedDescription)")
                    }
                }
            }
        }
    }

    // MARK: - Schedule All Workout Reminders
    func scheduleWorkoutReminders(workouts: [DailyWorkout]) {
        // First cancel all existing
        notificationCenter.removeAllPendingNotificationRequests()

        let today = Calendar.current.startOfDay(for: Date())

        // Only schedule for future workout days (not rest days)
        let workoutDays = workouts.filter { workout in
            let workoutDate = Calendar.current.startOfDay(for: workout.date)
            return workoutDate >= today && workout.workoutType != .rest
        }

        for workout in workoutDays {
            scheduleReminder(for: workout)
        }

        print("Scheduled \(workoutDays.count) workout reminders")
    }

    // MARK: - Schedule Single Reminder
    private func scheduleReminder(for workout: DailyWorkout) {
        let content = UNMutableNotificationContent()
        content.title = notificationTitle(for: workout)
        content.body = notificationBody(for: workout)
        content.sound = .default
        content.badge = 1

        // Add workout info to userInfo for deep linking
        content.userInfo = [
            "workoutID": workout.id,
            "weekNumber": workout.weekNumber
        ]

        // Schedule for 7:00 AM on the workout day
        var dateComponents = Calendar.current.dateComponents([.year, .month, .day], from: workout.date)
        dateComponents.hour = 7
        dateComponents.minute = 0
        dateComponents.second = 0

        let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: false)
        let request = UNNotificationRequest(identifier: "workout_\(workout.id)", content: content, trigger: trigger)

        notificationCenter.add(request) { error in
            if let error = error {
                print("Failed to schedule notification for \(workout.id): \(error.localizedDescription)")
            }
        }
    }

    // MARK: - Notification Content Helpers
    private func notificationTitle(for workout: DailyWorkout) -> String {
        if workout.isRaceDay {
            return "🚴 RACE DAY! Pan-Mass Challenge"
        }
        if workout.workoutType == .rest {
            return "Rest Day"
        }
        return "🚴 Today's PMC Training"
    }

    private func notificationBody(for workout: DailyWorkout) -> String {
        if workout.isRaceDay {
            return "\(workout.title) — \(workout.estimatedDistance). Ride for those who can't. You've got this!"
        }

        var body = workout.title
        if !workout.estimatedDuration.isEmpty {
            body += " · \(workout.estimatedDuration)"
        }
        if !workout.estimatedDistance.isEmpty {
            body += " · \(workout.estimatedDistance)"
        }
        if workout.primaryZone != .rest {
            body += " · \(workout.primaryZone.displayName)"
        }
        return body
    }

    // MARK: - Cancel All
    func cancelAll() {
        notificationCenter.removeAllPendingNotificationRequests()
        notificationsEnabled = false
        UserDefaults.standard.set(false, forKey: enabledKey)
    }

    // MARK: - Cancel Specific
    func cancelReminder(for workoutID: String) {
        notificationCenter.removePendingNotificationRequests(withIdentifiers: ["workout_\(workoutID)"])
    }

    // MARK: - List Pending
    func listPendingNotifications(completion: @escaping ([UNNotificationRequest]) -> Void) {
        notificationCenter.getPendingNotificationRequests { requests in
            DispatchQueue.main.async {
                completion(requests)
            }
        }
    }

    // MARK: - Open Settings (if permission denied)
    func openNotificationSettings() {
        if let url = URL(string: UIApplication.openSettingsURLString) {
            UIApplication.shared.open(url)
        }
    }
}
