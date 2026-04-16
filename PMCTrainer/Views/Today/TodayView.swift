import SwiftUI

struct TodayView: View {
    @EnvironmentObject var workoutStore:    WorkoutStore
    @EnvironmentObject var locationManager: LocationManager
    @EnvironmentObject var healthKit:       HealthKitManager

    var onStartRide: ((DailyWorkout?) -> Void)?

    @State private var showingWorkoutDetail = false
    @State private var showingStartRide     = false

    var body: some View {
        NavigationStack {
            ZStack {
                PMCTheme.backgroundGradient.ignoresSafeArea()
                StarScatterView().ignoresSafeArea().allowsHitTesting(false)

                ScrollView(showsIndicators: false) {
                    VStack(spacing: 18) {
                        headerSection
                        raceCountdownCard
                        healthKitSummaryCard
                        todayWorkoutCard
                        if let week = workoutStore.currentWeek {
                            weeklyMiniProgress(week: week)
                        }
                        Spacer(minLength: 40)
                    }
                    .padding(.horizontal, 16)
                    .padding(.top, 8)
                }
            }
            .navigationTitle("PMC Trainer")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        showingStartRide = true
                    } label: {
                        Image(systemName: "bicycle")
                            .foregroundColor(PMCTheme.tealAccent)
                            .font(.title2)
                    }
                    .accessibilityLabel("Start ride")
                }
            }
        }
        .sheet(isPresented: $showingWorkoutDetail) {
            if let workout = workoutStore.todayWorkout {
                WorkoutDetailView(workout: workout)
            }
        }
        .sheet(isPresented: $showingStartRide) {
            StartRideSheet(workout: workoutStore.todayWorkout) {
                onStartRide?(workoutStore.todayWorkout)
            }
            .environmentObject(locationManager)
        }
    }

    // MARK: - Header
    private var headerSection: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text(greetingText)
                    .font(.title2)
                    .fontWeight(.semibold)
                    .foregroundColor(PMCTheme.scriptWhite)
                Text(todayDateString)
                    .font(.subheadline)
                    .foregroundColor(PMCTheme.lightTeal)
            }
            Spacer()
            if let week = workoutStore.currentWeek {
                VStack(alignment: .trailing, spacing: 2) {
                    Text(week.title)
                        .font(.headline)
                        .foregroundColor(PMCTheme.tealAccent)
                    Text(week.subtitle)
                        .font(.caption)
                        .foregroundColor(PMCTheme.lightTeal)
                }
            }
        }
        .padding(.top, 8)
    }

    // MARK: - Race Countdown Card
    private var raceCountdownCard: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 16)
                .fill(PMCTheme.cardGradient)
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(PMCTheme.patriotRed.opacity(0.5), lineWidth: 1.5)
                )

            VStack(spacing: 8) {
                HStack {
                    HStack(spacing: 6) {
                        Image(systemName: "star.fill")
                            .font(.caption)
                            .foregroundColor(PMCTheme.patriotRed)
                        Image(systemName: "flag.checkered")
                            .foregroundColor(PMCTheme.patriotRed)
                            .font(.title3)
                        Text("Pan-Mass Challenge 2026")
                            .font(.headline)
                            .foregroundColor(PMCTheme.scriptWhite)
                    }
                    Spacer()
                    Image(systemName: "star.fill")
                        .font(.caption)
                        .foregroundColor(PMCTheme.patriotRed)
                }

                HStack(alignment: .bottom, spacing: 4) {
                    Text("\(max(0, workoutStore.daysUntilRace))")
                        .font(.system(size: 64, weight: .black, design: .rounded))
                        .foregroundColor(PMCTheme.tealAccent)
                        .shadow(color: PMCTheme.tealAccent.opacity(0.3), radius: 8)
                    VStack(alignment: .leading, spacing: 2) {
                        Text("days")
                            .font(.title2)
                            .fontWeight(.medium)
                            .foregroundColor(PMCTheme.scriptWhite)
                        Text("until race day")
                            .font(.caption)
                            .foregroundColor(PMCTheme.lightTeal)
                    }
                    .padding(.bottom, 8)
                    Spacer()
                    VStack(alignment: .trailing, spacing: 4) {
                        Text("Aug 1–2, 2026")
                            .font(.subheadline)
                            .fontWeight(.semibold)
                            .foregroundColor(PMCTheme.scriptWhite)
                        Text("Worcester → Wellesley")
                            .font(.caption)
                            .foregroundColor(PMCTheme.lightTeal)
                        HStack(spacing: 3) {
                            ForEach(0..<5) { _ in
                                Image(systemName: "star.fill")
                                    .font(.system(size: 7))
                                    .foregroundColor(PMCTheme.patriotRed.opacity(0.7))
                            }
                        }
                    }
                }
            }
            .padding(16)
        }
        .frame(height: 130)
    }

    // MARK: - HealthKit Live HR Summary Card
    // Shows today's resting HR and most recent HR reading from Apple Health.
    // Data comes from WHOOP via Bluetooth — no internet needed.
    @ViewBuilder
    private var healthKitSummaryCard: some View {
        if healthKit.isAuthorized {
            ZStack {
                RoundedRectangle(cornerRadius: 16)
                    .fill(PMCTheme.cardGradient)
                    .overlay(
                        RoundedRectangle(cornerRadius: 16)
                            .stroke(PMCTheme.tealAccent.opacity(0.2), lineWidth: 1)
                    )

                VStack(spacing: 12) {
                    HStack {
                        HStack(spacing: 6) {
                            Image(systemName: "heart.fill")
                                .foregroundColor(PMCTheme.patriotRed)
                            Text("Heart Rate")
                                .font(.headline)
                                .foregroundColor(PMCTheme.scriptWhite)
                        }
                        Spacer()
                        HStack(spacing: 4) {
                            Circle()
                                .fill(healthKit.isHRFresh ? Color.green : PMCTheme.lightTeal)
                                .frame(width: 6, height: 6)
                            Text(healthKit.isHRFresh ? "Live" : "From Health")
                                .font(.caption2)
                                .foregroundColor(PMCTheme.lightTeal)
                        }
                    }

                    HStack(spacing: 24) {
                        // Current / last known HR
                        VStack(spacing: 4) {
                            HStack(alignment: .lastTextBaseline, spacing: 3) {
                                Text(healthKit.currentHR > 0 ? String(format: "%.0f", healthKit.currentHR) : "--")
                                    .font(.system(size: 38, weight: .black, design: .rounded))
                                    .foregroundColor(PMCTheme.tealAccent)
                                Text("bpm")
                                    .font(.caption)
                                    .foregroundColor(PMCTheme.lightTeal)
                            }
                            Text("Current HR")
                                .font(.caption2)
                                .foregroundColor(PMCTheme.lightTeal)
                                .textCase(.uppercase)
                                .tracking(0.8)
                        }

                        TealDivider()
                            .frame(width: 1, height: 50)

                        // Zone
                        VStack(spacing: 4) {
                            Text(healthKit.currentHR > 0 ? healthKit.currentZoneShort : "--")
                                .font(.system(size: 38, weight: .black, design: .rounded))
                                .foregroundColor(healthKit.currentZoneColor)
                            Text(healthKit.currentHR > 0 ? healthKit.currentZoneDescription : "No data")
                                .font(.caption2)
                                .foregroundColor(PMCTheme.lightTeal)
                                .textCase(.uppercase)
                                .tracking(0.8)
                        }

                        TealDivider()
                            .frame(width: 1, height: 50)

                        // Max HR setting
                        VStack(spacing: 4) {
                            Text("\(healthKit.maxHR)")
                                .font(.system(size: 38, weight: .black, design: .rounded))
                                .foregroundColor(PMCTheme.scriptWhite)
                            Text("Max HR")
                                .font(.caption2)
                                .foregroundColor(PMCTheme.lightTeal)
                                .textCase(.uppercase)
                                .tracking(0.8)
                        }
                    }

                    Text("Live HR from your WHOOP via Apple Health · Set Max HR in Settings")
                        .font(.caption2)
                        .foregroundColor(PMCTheme.lightTeal.opacity(0.7))
                        .multilineTextAlignment(.center)
                }
                .padding(16)
            }
        }
    }

    // MARK: - Today's Workout Card
    private var todayWorkoutCard: some View {
        Group {
            if let workout = workoutStore.todayWorkout {
                VStack(spacing: 10) {
                    Button(action: { showingWorkoutDetail = true }) {
                        TodayWorkoutCard(workout: workout)
                    }
                    .buttonStyle(PlainButtonStyle())

                    // Start Ride button (only for non-rest workouts)
                    if workout.workoutType != .rest {
                        Button(action: { showingStartRide = true }) {
                            HStack(spacing: 10) {
                                Image(systemName: "location.fill")
                                    .font(.system(size: 16))
                                Text("Start GPS Ride")
                                    .font(.system(size: 16, weight: .bold))
                            }
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 14)
                            .background(
                                LinearGradient(
                                    colors: [PMCTheme.tealAccent, Color(red: 0.059, green: 0.600, blue: 0.700)],
                                    startPoint: .leading,
                                    endPoint: .trailing
                                )
                            )
                            .foregroundColor(.white)
                            .cornerRadius(14)
                            .shadow(color: PMCTheme.tealAccent.opacity(0.3), radius: 8, x: 0, y: 3)
                        }
                    }
                }
            } else {
                noWorkoutCard
            }
        }
    }

    private var noWorkoutCard: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 16)
                .fill(PMCTheme.cardGradient)
                .overlay(RoundedRectangle(cornerRadius: 16).stroke(PMCTheme.tealAccent.opacity(0.15), lineWidth: 1))
            VStack(spacing: 12) {
                Image(systemName: "moon.zzz.fill")
                    .font(.system(size: 40))
                    .foregroundColor(PMCTheme.lightTeal)
                Text("No workout scheduled today")
                    .font(.headline)
                    .foregroundColor(PMCTheme.scriptWhite)
                Text("Enjoy your rest day!")
                    .font(.subheadline)
                    .foregroundColor(PMCTheme.lightTeal)
            }
            .padding(24)
        }
    }

    // MARK: - Weekly Mini Progress
    private func weeklyMiniProgress(week: TrainingWeek) -> some View {
        ZStack {
            RoundedRectangle(cornerRadius: 16)
                .fill(PMCTheme.cardGradient)
                .overlay(RoundedRectangle(cornerRadius: 16).stroke(PMCTheme.tealAccent.opacity(0.15), lineWidth: 1))
            VStack(alignment: .leading, spacing: 12) {
                HStack {
                    Text("This Week")
                        .font(.headline)
                        .foregroundColor(PMCTheme.scriptWhite)
                    Spacer()
                    Text("\(week.completedCount) / \(week.scheduledCount) workouts")
                        .font(.subheadline)
                        .foregroundColor(PMCTheme.tealAccent)
                }

                HStack(spacing: 8) {
                    ForEach(week.workouts) { workout in
                        VStack(spacing: 4) {
                            Circle()
                                .fill(dotColor(for: workout))
                                .frame(width: 10, height: 10)
                                .overlay(
                                    Circle()
                                        .stroke(workout.isToday ? PMCTheme.patriotRed : Color.clear, lineWidth: 2)
                                        .frame(width: 14, height: 14)
                                )
                            Text(shortDayName(for: workout.dayOfWeek))
                                .font(.system(size: 9))
                                .foregroundColor(PMCTheme.lightTeal)
                        }
                    }
                }

                GeometryReader { geo in
                    ZStack(alignment: .leading) {
                        RoundedRectangle(cornerRadius: 4)
                            .fill(PMCTheme.deepNavy)
                            .frame(height: 6)
                        RoundedRectangle(cornerRadius: 4)
                            .fill(
                                LinearGradient(
                                    colors: [PMCTheme.tealAccent, Color(red: 0.059, green: 0.600, blue: 0.700)],
                                    startPoint: .leading,
                                    endPoint: .trailing
                                )
                            )
                            .frame(width: geo.size.width * week.progressPercentage, height: 6)
                    }
                }
                .frame(height: 6)
            }
            .padding(16)
        }
    }

    // MARK: - Helpers
    private var greetingText: String {
        let hour = Calendar.current.component(.hour, from: Date())
        switch hour {
        case 5..<12: return "Good morning, rider!"
        case 12..<17: return "Good afternoon, rider!"
        case 17..<21: return "Good evening, rider!"
        default: return "Rest up, rider!"
        }
    }

    private var todayDateString: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "EEEE, MMMM d"
        return formatter.string(from: Date())
    }

    private func dotColor(for workout: DailyWorkout) -> Color {
        switch workout.status {
        case .completed:  return .green
        case .inProgress: return PMCTheme.tealAccent
        case .skipped:    return .yellow
        case .notStarted:
            if workout.workoutType == .rest { return PMCTheme.deepNavy }
            if workout.isToday { return PMCTheme.tealAccent.opacity(0.6) }
            if workout.isPast  { return Color.gray.opacity(0.5) }
            return PMCTheme.lightTeal.opacity(0.3)
        }
    }

    private func shortDayName(for dayOffset: Int) -> String {
        let days = ["M", "T", "W", "T", "F", "S", "S"]
        return days[safe: dayOffset] ?? ""
    }
}

// MARK: - Today Workout Card Component
struct TodayWorkoutCard: View {
    @EnvironmentObject var workoutStore: WorkoutStore
    let workout: DailyWorkout

    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 16)
                .fill(PMCTheme.cardGradient)
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(
                            workout.isRaceDay ? PMCTheme.patriotRed : PMCTheme.tealAccent.opacity(0.25),
                            lineWidth: workout.isRaceDay ? 2 : 1
                        )
                )

            VStack(alignment: .leading, spacing: 14) {
                HStack {
                    HStack(spacing: 8) {
                        Image(systemName: workout.workoutType.icon)
                            .font(.title2)
                            .foregroundColor(workout.isRaceDay ? PMCTheme.patriotRed : PMCTheme.tealAccent)
                        VStack(alignment: .leading, spacing: 2) {
                            Text("Today's Workout")
                                .font(.caption)
                                .foregroundColor(PMCTheme.lightTeal)
                            Text(workout.title)
                                .font(.title3)
                                .fontWeight(.bold)
                                .foregroundColor(PMCTheme.scriptWhite)
                        }
                    }
                    Spacer()
                    StatusBadge(status: workout.status)
                }

                if workout.primaryZone != .rest {
                    HStack(spacing: 8) {
                        ZoneBadge(zone: workout.primaryZone)
                        if !workout.estimatedDistance.isEmpty {
                            InfoChip(icon: "arrow.right", text: workout.estimatedDistance)
                        }
                        if !workout.estimatedDuration.isEmpty {
                            InfoChip(icon: "clock", text: workout.estimatedDuration)
                        }
                    }
                }

                Text(workout.description)
                    .font(.subheadline)
                    .foregroundColor(PMCTheme.lightTeal)
                    .lineLimit(3)
                    .fixedSize(horizontal: false, vertical: true)

                if workout.workoutType != .rest {
                    HStack(spacing: 12) {
                        WorkoutStatusButton(workoutID: workout.id, status: .inProgress, label: "Start", icon: "play.fill")
                        WorkoutStatusButton(workoutID: workout.id, status: .completed,  label: "Done",  icon: "checkmark")
                        WorkoutStatusButton(workoutID: workout.id, status: .skipped,    label: "Skip",  icon: "forward.fill")
                    }
                }

                HStack {
                    Spacer()
                    Text("Tap for full details")
                        .font(.caption2)
                        .foregroundColor(PMCTheme.lightTeal.opacity(0.6))
                    Image(systemName: "chevron.right")
                        .font(.caption2)
                        .foregroundColor(PMCTheme.lightTeal.opacity(0.6))
                }
            }
            .padding(16)
        }
    }
}

// MARK: - Workout Status Button
struct WorkoutStatusButton: View {
    @EnvironmentObject var workoutStore: WorkoutStore
    let workoutID: String
    let status: WorkoutStatus
    let label: String
    let icon: String

    var isActive: Bool {
        workoutStore.workout(for: workoutID)?.status == status
    }

    var body: some View {
        Button(action: {
            workoutStore.updateStatus(workoutID: workoutID, status: isActive ? .notStarted : status)
        }) {
            HStack(spacing: 4) {
                Image(systemName: icon).font(.caption)
                Text(label).font(.caption).fontWeight(.semibold)
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 7)
            .background(isActive ? status.color : PMCTheme.deepNavy)
            .foregroundColor(isActive ? .white : PMCTheme.lightTeal)
            .cornerRadius(8)
            .overlay(
                RoundedRectangle(cornerRadius: 8)
                    .stroke(isActive ? status.color : PMCTheme.tealAccent.opacity(0.2), lineWidth: 1)
            )
        }
    }
}

// MARK: - Array Safe Subscript
extension Array {
    subscript(safe index: Int) -> Element? {
        guard index >= 0, index < count else { return nil }
        return self[index]
    }
}
