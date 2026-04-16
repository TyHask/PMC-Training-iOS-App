import SwiftUI

struct PlanView: View {
    @EnvironmentObject var workoutStore: WorkoutStore
    @EnvironmentObject var locationManager: LocationManager

    var onStartRide: ((DailyWorkout?) -> Void)?

    @State private var selectedWeek: TrainingWeek?
    @State private var showingWeekDetail = false

    var body: some View {
        NavigationView {
            ZStack {
                PMCTheme.backgroundGradient.ignoresSafeArea()
                StarScatterView().ignoresSafeArea().allowsHitTesting(false)

                ScrollView(showsIndicators: false) {
                    VStack(spacing: 12) {
                        planHeader
                        NavigationLink(destination: ZoneReferenceView()) {
                            zoneReferenceButton
                        }
                        ForEach(workoutStore.weeks) { week in
                            WeekRowCard(week: week)
                                .onTapGesture {
                                    selectedWeek = week
                                    showingWeekDetail = true
                                }
                        }
                        Spacer(minLength: 40)
                    }
                    .padding(.horizontal, 16)
                    .padding(.top, 8)
                }
            }
            .navigationTitle("Training Plan")
            .navigationBarTitleDisplayMode(.large)
            .sheet(isPresented: $showingWeekDetail) {
                if let week = selectedWeek {
                    WeekDetailView(week: week, onStartRide: onStartRide)
                }
            }
        }
    }

    // MARK: - Plan Header
    private var planHeader: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 16)
                .fill(PMCTheme.cardGradient)
                .overlay(RoundedRectangle(cornerRadius: 16).stroke(PMCTheme.tealAccent.opacity(0.2), lineWidth: 1))
            HStack(spacing: 16) {
                VStack(alignment: .leading, spacing: 4) {
                    Text("15-Week Plan")
                        .font(.headline)
                        .foregroundColor(PMCTheme.scriptWhite)
                    Text("Apr 13 – Aug 2, 2026")
                        .font(.subheadline)
                        .foregroundColor(PMCTheme.lightTeal)
                    HStack(spacing: 4) {
                        ForEach(0..<5) { _ in
                            Image(systemName: "star.fill")
                                .font(.system(size: 8))
                                .foregroundColor(PMCTheme.patriotRed.opacity(0.6))
                        }
                        Text("America 250")
                            .font(.system(size: 9, weight: .semibold))
                            .foregroundColor(PMCTheme.patriotRed.opacity(0.8))
                            .textCase(.uppercase)
                            .tracking(0.8)
                    }
                }
                Spacer()
                VStack(alignment: .trailing, spacing: 4) {
                    Text("\(workoutStore.totalCompleted) / \(workoutStore.totalScheduled)")
                        .font(.title3)
                        .fontWeight(.bold)
                        .foregroundColor(PMCTheme.tealAccent)
                    Text("workouts done")
                        .font(.caption)
                        .foregroundColor(PMCTheme.lightTeal)
                }
            }
            .padding(16)
        }
    }

    // MARK: - Zone Reference Button
    private var zoneReferenceButton: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 12)
                .fill(PMCTheme.cardGradient)
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(PMCTheme.tealAccent.opacity(0.3), lineWidth: 1)
                )
            HStack(spacing: 12) {
                Image(systemName: "speedometer")
                    .foregroundColor(PMCTheme.tealAccent)
                    .font(.title3)
                Text("Zone Reference Guide")
                    .font(.subheadline)
                    .fontWeight(.semibold)
                    .foregroundColor(PMCTheme.scriptWhite)
                Spacer()
                Image(systemName: "chevron.right")
                    .foregroundColor(PMCTheme.lightTeal)
                    .font(.caption)
            }
            .padding(14)
        }
    }
}

// MARK: - Week Row Card
struct WeekRowCard: View {
    @EnvironmentObject var workoutStore: WorkoutStore
    let week: TrainingWeek

    var isCurrentWeek: Bool { workoutStore.currentWeek?.id == week.id }

    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 16)
                .fill(PMCTheme.cardGradient)
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(
                            isCurrentWeek ? PMCTheme.tealAccent : PMCTheme.tealAccent.opacity(0.1),
                            lineWidth: isCurrentWeek ? 2 : 1
                        )
                )

            VStack(spacing: 10) {
                HStack {
                    VStack(alignment: .leading, spacing: 2) {
                        HStack(spacing: 8) {
                            Text(week.title)
                                .font(.headline)
                                .foregroundColor(PMCTheme.scriptWhite)
                            WeekTypeBadge(week: week)
                            if isCurrentWeek {
                                Text("CURRENT")
                                    .font(.system(size: 10, weight: .bold))
                                    .padding(.horizontal, 6)
                                    .padding(.vertical, 2)
                                    .background(PMCTheme.tealAccent.opacity(0.2))
                                    .foregroundColor(PMCTheme.tealAccent)
                                    .cornerRadius(4)
                            }
                        }
                        Text(weekDateRange)
                            .font(.caption)
                            .foregroundColor(PMCTheme.lightTeal)
                    }
                    Spacer()
                    VStack(alignment: .trailing, spacing: 2) {
                        Text("\(week.completedCount)/\(week.scheduledCount)")
                            .font(.subheadline)
                            .fontWeight(.bold)
                            .foregroundColor(week.completedCount == week.scheduledCount && week.scheduledCount > 0 ? .green : PMCTheme.scriptWhite)
                        Text("done")
                            .font(.caption2)
                            .foregroundColor(PMCTheme.lightTeal)
                    }
                }

                HStack(spacing: 6) {
                    ForEach(week.workouts) { workout in
                        WorkoutDot(workout: workout)
                    }
                    Spacer()
                    GeometryReader { geo in
                        ZStack(alignment: .leading) {
                            RoundedRectangle(cornerRadius: 3)
                                .fill(PMCTheme.deepNavy)
                                .frame(height: 4)
                            RoundedRectangle(cornerRadius: 3)
                                .fill(progressColor)
                                .frame(width: geo.size.width * week.progressPercentage, height: 4)
                        }
                    }
                    .frame(width: 80, height: 4)
                }
            }
            .padding(14)
        }
    }

    private var weekDateRange: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMM d"
        let start = formatter.string(from: week.startDate)
        let end = formatter.string(from: week.endDate)
        return "\(start) – \(end)"
    }

    private var progressColor: Color {
        if week.progressPercentage >= 1.0 { return .green }
        if week.progressPercentage >= 0.5 { return PMCTheme.tealAccent }
        return PMCTheme.lightTeal.opacity(0.3)
    }
}

// MARK: - Workout Dot
struct WorkoutDot: View {
    let workout: DailyWorkout

    var body: some View {
        ZStack {
            Circle()
                .fill(dotColor)
                .frame(width: 12, height: 12)
            if workout.isToday {
                Circle()
                    .stroke(PMCTheme.patriotRed, lineWidth: 2)
                    .frame(width: 16, height: 16)
            }
        }
    }

    private var dotColor: Color {
        switch workout.status {
        case .completed: return .green
        case .inProgress: return PMCTheme.tealAccent
        case .skipped: return .yellow
        case .notStarted:
            if workout.workoutType == .rest { return PMCTheme.deepNavy }
            if workout.isRaceDay { return PMCTheme.patriotRed.opacity(0.8) }
            return PMCTheme.lightTeal.opacity(0.3)
        }
    }
}

// MARK: - Week Detail View
struct WeekDetailView: View {
    @EnvironmentObject var workoutStore: WorkoutStore
    @EnvironmentObject var locationManager: LocationManager
    @Environment(\.dismiss) var dismiss

    let week: TrainingWeek
    var onStartRide: ((DailyWorkout?) -> Void)?

    @State private var selectedWorkout: DailyWorkout?
    @State private var showingWorkoutDetail = false
    @State private var showingStartRide = false

    var currentWeek: TrainingWeek {
        workoutStore.week(for: week.weekNumber) ?? week
    }

    var body: some View {
        NavigationView {
            ZStack {
                PMCTheme.backgroundGradient.ignoresSafeArea()
                StarScatterView().ignoresSafeArea().allowsHitTesting(false)

                ScrollView(showsIndicators: false) {
                    VStack(spacing: 14) {
                        weekSummaryCard
                        ForEach(currentWeek.workouts) { workout in
                            DayWorkoutRow(workout: workout, onStartRide: { w in
                                selectedWorkout = w
                                showingStartRide = true
                            })
                            .onTapGesture {
                                selectedWorkout = workout
                                showingWorkoutDetail = true
                            }
                        }
                        Spacer(minLength: 40)
                    }
                    .padding(.horizontal, 16)
                    .padding(.top, 8)
                }
            }
            .navigationTitle(week.title)
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Close") { dismiss() }
                        .foregroundColor(PMCTheme.tealAccent)
                }
            }
            .sheet(isPresented: $showingWorkoutDetail) {
                if let workout = selectedWorkout {
                    WorkoutDetailView(workout: workout)
                }
            }
            .sheet(isPresented: $showingStartRide) {
                StartRideSheet(workout: selectedWorkout) {
                    onStartRide?(selectedWorkout)
                    dismiss()
                }
                .environmentObject(locationManager)
            }
        }
    }

    private var weekSummaryCard: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 16)
                .fill(PMCTheme.cardGradient)
                .overlay(RoundedRectangle(cornerRadius: 16).stroke(PMCTheme.tealAccent.opacity(0.2), lineWidth: 1))
            VStack(spacing: 10) {
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        Text(week.subtitle)
                            .font(.title3)
                            .fontWeight(.bold)
                            .foregroundColor(PMCTheme.scriptWhite)
                        Text(weekDateRange)
                            .font(.subheadline)
                            .foregroundColor(PMCTheme.lightTeal)
                    }
                    Spacer()
                    WeekTypeBadge(week: week)
                }
                HStack {
                    VStack(alignment: .leading, spacing: 2) {
                        Text("\(currentWeek.completedCount) / \(currentWeek.scheduledCount)")
                            .font(.title2)
                            .fontWeight(.bold)
                            .foregroundColor(PMCTheme.tealAccent)
                        Text("workouts completed")
                            .font(.caption)
                            .foregroundColor(PMCTheme.lightTeal)
                    }
                    Spacer()
                    CircularProgressView(
                        progress: currentWeek.progressPercentage,
                        size: 60,
                        lineWidth: 5,
                        color: PMCTheme.tealAccent
                    )
                }
            }
            .padding(16)
        }
    }

    private var weekDateRange: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMMM d"
        let start = formatter.string(from: week.startDate)
        formatter.dateFormat = "MMMM d, yyyy"
        let end = formatter.string(from: week.endDate)
        return "\(start) – \(end)"
    }
}

// MARK: - Day Workout Row
struct DayWorkoutRow: View {
    @EnvironmentObject var workoutStore: WorkoutStore
    let workout: DailyWorkout
    var onStartRide: ((DailyWorkout) -> Void)?

    var currentWorkout: DailyWorkout {
        workoutStore.workout(for: workout.id) ?? workout
    }

    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 14)
                .fill(PMCTheme.cardGradient)
                .overlay(
                    RoundedRectangle(cornerRadius: 14)
                        .stroke(
                            currentWorkout.isToday ? PMCTheme.tealAccent.opacity(0.6) : PMCTheme.tealAccent.opacity(0.08),
                            lineWidth: currentWorkout.isToday ? 1.5 : 1
                        )
                )

            VStack(spacing: 0) {
                HStack(spacing: 14) {
                    // Day indicator
                    VStack(spacing: 2) {
                        Text(dayName)
                            .font(.system(size: 11, weight: .semibold))
                            .foregroundColor(currentWorkout.isToday ? PMCTheme.tealAccent : PMCTheme.lightTeal)
                        Text(dayNumber)
                            .font(.system(size: 18, weight: .bold))
                            .foregroundColor(currentWorkout.isToday ? PMCTheme.tealAccent : PMCTheme.scriptWhite)
                    }
                    .frame(width: 36)

                    Image(systemName: currentWorkout.workoutType.icon)
                        .font(.title3)
                        .foregroundColor(iconColor)
                        .frame(width: 28)

                    VStack(alignment: .leading, spacing: 4) {
                        Text(currentWorkout.title)
                            .font(.subheadline)
                            .fontWeight(.semibold)
                            .foregroundColor(PMCTheme.scriptWhite)
                        HStack(spacing: 6) {
                            if currentWorkout.primaryZone != .rest {
                                ZoneBadge(zone: currentWorkout.primaryZone)
                            }
                            if !currentWorkout.estimatedDistance.isEmpty {
                                Text(currentWorkout.estimatedDistance)
                                    .font(.caption)
                                    .foregroundColor(PMCTheme.lightTeal)
                            }
                        }
                    }

                    Spacer()

                    Image(systemName: currentWorkout.status.icon)
                        .foregroundColor(currentWorkout.status.color)
                        .font(.title3)

                    Image(systemName: "chevron.right")
                        .foregroundColor(PMCTheme.lightTeal.opacity(0.4))
                        .font(.caption)
                }
                .padding(14)

                // Start Ride button for today's cycling workouts
                if currentWorkout.isToday && currentWorkout.workoutType != .rest {
                    TealDivider().padding(.horizontal, 14)
                    Button(action: { onStartRide?(currentWorkout) }) {
                        HStack(spacing: 8) {
                            Image(systemName: "location.fill")
                                .font(.system(size: 12))
                            Text("Start GPS Ride")
                                .font(.system(size: 13, weight: .semibold))
                        }
                        .foregroundColor(PMCTheme.tealAccent)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 10)
                    }
                }
            }
        }
    }

    private var dayName: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "EEE"
        return formatter.string(from: workout.date).uppercased()
    }

    private var dayNumber: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "d"
        return formatter.string(from: workout.date)
    }

    private var iconColor: Color {
        if currentWorkout.isRaceDay { return PMCTheme.patriotRed }
        if currentWorkout.workoutType == .rest { return PMCTheme.lightTeal.opacity(0.4) }
        return PMCTheme.scriptWhite.opacity(0.8)
    }
}

// MARK: - Zone Reference View
struct ZoneReferenceView: View {
    var body: some View {
        ZStack {
            PMCTheme.backgroundGradient.ignoresSafeArea()
            StarScatterView().ignoresSafeArea().allowsHitTesting(false)

            ScrollView(showsIndicators: false) {
                VStack(spacing: 14) {
                    Text("Use these zones to guide your effort during every workout. RPE (Rate of Perceived Exertion) is the most accessible way to gauge intensity.")
                        .font(.subheadline)
                        .foregroundColor(PMCTheme.lightTeal)
                        .padding(.horizontal, 16)
                        .padding(.top, 8)

                    ForEach(TrainingPlanData.zoneReferences) { ref in
                        ZoneReferenceCard(reference: ref)
                    }

                    Spacer(minLength: 40)
                }
                .padding(.horizontal, 16)
            }
        }
        .navigationTitle("Zone Reference")
        .navigationBarTitleDisplayMode(.large)
    }
}

// MARK: - Zone Reference Card
struct ZoneReferenceCard: View {
    let reference: ZoneReference

    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 16)
                .fill(PMCTheme.cardGradient)
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(reference.zone.color.opacity(0.3), lineWidth: 1)
                )

            HStack(spacing: 16) {
                ZStack {
                    Circle()
                        .fill(reference.zone.color.opacity(0.15))
                        .frame(width: 56, height: 56)
                    Text(reference.zone.rawValue)
                        .font(.title3)
                        .fontWeight(.bold)
                        .foregroundColor(reference.zone.color)
                }

                VStack(alignment: .leading, spacing: 5) {
                    Text(reference.name)
                        .font(.headline)
                        .foregroundColor(PMCTheme.scriptWhite)
                    HStack(spacing: 8) {
                        Text(reference.rpe)
                            .font(.caption)
                            .fontWeight(.semibold)
                            .foregroundColor(reference.zone.color)
                        Text("·")
                            .foregroundColor(PMCTheme.lightTeal)
                        Text(reference.heartRatePercent)
                            .font(.caption)
                            .foregroundColor(PMCTheme.lightTeal)
                    }
                    Text(reference.description)
                        .font(.caption)
                        .foregroundColor(PMCTheme.lightTeal)
                        .lineLimit(2)
                        .fixedSize(horizontal: false, vertical: true)
                }

                Spacer()
            }
            .padding(16)
        }
    }
}
