import SwiftUI
import UserNotifications
import HealthKit

@main
struct PMCTrainerApp: App {
    @StateObject private var workoutStore        = WorkoutStore()
    @StateObject private var notificationManager = NotificationManager()
    @StateObject private var locationManager     = LocationManager()
    @StateObject private var healthKit           = HealthKitManager()

    var body: some Scene {
        WindowGroup {
            RootNavigationView()
                .environmentObject(workoutStore)
                .environmentObject(notificationManager)
                .environmentObject(locationManager)
                .environmentObject(healthKit)
                .preferredColorScheme(.dark)
                .onAppear {
                    setupAppearance()
                    locationManager.requestPermission()
                    // Request HealthKit authorization on first launch
                    healthKit.requestAuthorization()
                }
        }
    }

    // MARK: - Appearance (America 250 / PMC 2026 theme)
    private func setupAppearance() {
        // Tab bar — deep navy matching jersey top
        let tabBarAppearance = UITabBarAppearance()
        tabBarAppearance.configureWithOpaqueBackground()
        tabBarAppearance.backgroundColor = UIColor(red: 0.039, green: 0.100, blue: 0.260, alpha: 1.0)

        let normalAttr: [NSAttributedString.Key: Any] = [
            .foregroundColor: UIColor(red: 0.290, green: 0.660, blue: 0.680, alpha: 1.0)
        ]
        let selectedAttr: [NSAttributedString.Key: Any] = [
            .foregroundColor: UIColor(red: 0.059, green: 0.820, blue: 0.780, alpha: 1.0)
        ]
        tabBarAppearance.stackedLayoutAppearance.normal.titleTextAttributes   = normalAttr
        tabBarAppearance.stackedLayoutAppearance.selected.titleTextAttributes = selectedAttr
        tabBarAppearance.stackedLayoutAppearance.normal.iconColor   = UIColor(red: 0.290, green: 0.660, blue: 0.680, alpha: 1.0)
        tabBarAppearance.stackedLayoutAppearance.selected.iconColor = UIColor(red: 0.059, green: 0.820, blue: 0.780, alpha: 1.0)
        UITabBar.appearance().standardAppearance   = tabBarAppearance
        UITabBar.appearance().scrollEdgeAppearance = tabBarAppearance

        // Navigation bar
        let navAppearance = UINavigationBarAppearance()
        navAppearance.configureWithOpaqueBackground()
        navAppearance.backgroundColor = UIColor(red: 0.039, green: 0.100, blue: 0.260, alpha: 1.0)
        navAppearance.titleTextAttributes = [
            .foregroundColor: UIColor.white,
            .font: UIFont.systemFont(ofSize: 17, weight: .semibold)
        ]
        navAppearance.largeTitleTextAttributes = [
            .foregroundColor: UIColor.white,
            .font: UIFont.systemFont(ofSize: 34, weight: .black)
        ]
        navAppearance.shadowColor = UIColor(red: 0.059, green: 0.820, blue: 0.780, alpha: 0.2)
        UINavigationBar.appearance().standardAppearance   = navAppearance
        UINavigationBar.appearance().scrollEdgeAppearance = navAppearance
        UINavigationBar.appearance().compactAppearance    = navAppearance
        UINavigationBar.appearance().tintColor = UIColor(red: 0.059, green: 0.820, blue: 0.780, alpha: 1.0)
    }
}

// MARK: - Root Navigation View
// Manages the ride lifecycle: tabs → live ride → ride summary → back to tabs
struct RootNavigationView: View {
    @EnvironmentObject var locationManager:     LocationManager
    @EnvironmentObject var workoutStore:        WorkoutStore
    @EnvironmentObject var healthKit:           HealthKitManager

    @State private var activeWorkout:   DailyWorkout?
    @State private var showLiveRide     = false
    @State private var completedRide:   CompletedRide?
    @State private var showRideSummary  = false

    var body: some View {
        ZStack {
            if showLiveRide {
                NavigationStack {
                    LiveRideView(workout: activeWorkout)
                        .onChange(of: locationManager.rideState) { _, state in
                            if state == .finished {
                                buildAndShowSummary()
                            }
                        }
                }
                .fullScreenCover(isPresented: $showRideSummary) {
                    if let ride = completedRide {
                        NavigationStack {
                            RideSummaryView(ride: ride, workout: activeWorkout)
                        }
                        .onDisappear {
                            showLiveRide    = false
                            showRideSummary = false
                            completedRide   = nil
                            activeWorkout   = nil
                            locationManager.reset()
                        }
                    }
                }
            } else {
                ContentView(onStartRide: { workout in
                    activeWorkout = workout
                    healthKit.resetForRide()
                    locationManager.startRide()
                    withAnimation { showLiveRide = true }
                })
            }
        }
    }

    // MARK: - Build Summary
    // Uses live HealthKit HR data captured during the ride.
    private func buildAndShowSummary() {
        let avgHR = healthKit.avgHR > 0 ? healthKit.avgHR : 0
        let maxHR = healthKit.maxHRRecorded > 0 ? healthKit.maxHRRecorded : 0

        let ride = locationManager.buildCompletedRide(
            workoutID:          activeWorkout?.id,
            workoutTitle:       activeWorkout?.title ?? "Free Ride",
            laps:               [],
            avgHR:              avgHR,
            maxHR:              maxHR,
            dominantZoneShort:  healthKit.currentZoneShort,
            notes:              ""
        )
        completedRide = ride

        // Save to workout store
        workoutStore.saveCompletedRide(ride)
        if let id = activeWorkout?.id {
            workoutStore.markWorkout(id: id, status: .completed)
        }

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            showRideSummary = true
        }
    }
}
