import SwiftUI

struct ContentView: View {
    @EnvironmentObject var workoutStore: WorkoutStore
    @State private var selectedTab: Int = 0

    // Callback to start a GPS ride from any tab
    var onStartRide: ((DailyWorkout?) -> Void)?

    var body: some View {
        TabView(selection: $selectedTab) {
            TodayView(onStartRide: onStartRide)
                .tabItem {
                    Label("Today", systemImage: "sun.max.fill")
                }
                .tag(0)

            PlanView(onStartRide: onStartRide)
                .tabItem {
                    Label("Plan", systemImage: "calendar")
                }
                .tag(1)

            PMCProgressView()
                .tabItem {
                    Label("Progress", systemImage: "chart.bar.fill")
                }
                .tag(2)

            SettingsView()
                .tabItem {
                    Label("Settings", systemImage: "gearshape.fill")
                }
                .tag(3)
        }
        // America 250 teal accent
        .accentColor(PMCTheme.tealAccent)
    }
}
