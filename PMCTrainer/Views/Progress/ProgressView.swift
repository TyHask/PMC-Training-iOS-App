import SwiftUI

// Renamed to PMCProgressView to avoid conflict with SwiftUI's built-in ProgressView
struct PMCProgressView: View {
    @EnvironmentObject var workoutStore: WorkoutStore
    @State private var selectedRide: CompletedRide?

    var body: some View {
        NavigationStack {
            ZStack {
                PMCTheme.backgroundGradient.ignoresSafeArea()
                StarScatterView().ignoresSafeArea().allowsHitTesting(false)

                ScrollView(showsIndicators: false) {
                    VStack(spacing: 16) {
                        overallStatsCard
                        if let week = workoutStore.currentWeek {
                            currentWeekCard(week: week)
                        }
                        completionHeatmap
                        SectionHeader(title: "Weekly Breakdown", icon: "list.bullet.rectangle")
                            .padding(.horizontal, 0)
                            .padding(.top, 4)
                        ForEach(workoutStore.weeks) { week in
                            WeekProgressRow(week: week)
                        }

                        // Ride History
                        if !workoutStore.completedRides.isEmpty {
                            SectionHeader(title: "Ride History", icon: "bicycle")
                                .padding(.horizontal, 0)
                                .padding(.top, 4)
                            ForEach(workoutStore.completedRides) { ride in
                                RideHistoryRow(ride: ride)
                                    .contentShape(Rectangle())
                                    .onTapGesture {
                                        selectedRide = ride
                                    }
                            }
                        }

                        Spacer(minLength: 40)
                    }
                    .padding(.horizontal, 16)
                    .padding(.top, 8)
                }
            }
            .navigationTitle("Progress")
            .navigationBarTitleDisplayMode(.large)
            .sheet(item: $selectedRide) { ride in
                NavigationStack {
                    RideReplayView(ride: ride)
                }
            }
        }
    }

    // MARK: - Overall Stats
    private var overallStatsCard: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 16)
                .fill(PMCTheme.cardGradient)
                .overlay(RoundedRectangle(cornerRadius: 16).stroke(PMCTheme.tealAccent.opacity(0.2), lineWidth: 1))

            VStack(spacing: 16) {
                HStack {
                    Text("Overall Progress")
                        .font(.headline)
                        .foregroundColor(PMCTheme.scriptWhite)
                    Spacer()
                    Text("\(Int(workoutStore.overallProgress * 100))% complete")
                        .font(.subheadline)
                        .foregroundColor(PMCTheme.tealAccent)
                }

                HStack(spacing: 24) {
                    CircularProgressView(
                        progress: workoutStore.overallProgress,
                        size: 90,
                        lineWidth: 8,
                        color: PMCTheme.tealAccent
                    )

                    VStack(spacing: 12) {
                        statRow(label: "Completed", value: "\(workoutStore.totalCompleted)", color: .green)
                        statRow(label: "Remaining", value: "\(workoutStore.totalScheduled - workoutStore.totalCompleted)", color: PMCTheme.lightTeal)
                        statRow(label: "Total Scheduled", value: "\(workoutStore.totalScheduled)", color: PMCTheme.scriptWhite)
                    }

                    Spacer()
                }

                HStack {
                    Image(systemName: "flag.checkered")
                        .foregroundColor(PMCTheme.patriotRed)
                    Text("\(max(0, workoutStore.daysUntilRace)) days until race day")
                        .font(.subheadline)
                        .foregroundColor(PMCTheme.scriptWhite)
                    Spacer()
                    HStack(spacing: 3) {
                        ForEach(0..<5) { _ in
                            Image(systemName: "star.fill")
                                .font(.system(size: 8))
                                .foregroundColor(PMCTheme.patriotRed.opacity(0.6))
                        }
                    }
                }
                .padding(.top, 4)
            }
            .padding(16)
        }
    }

    private func statRow(label: String, value: String, color: Color) -> some View {
        HStack {
            Text(label)
                .font(.caption)
                .foregroundColor(PMCTheme.lightTeal)
            Spacer()
            Text(value)
                .font(.subheadline)
                .fontWeight(.bold)
                .foregroundColor(color)
        }
    }

    // MARK: - Current Week Card
    private func currentWeekCard(week: TrainingWeek) -> some View {
        ZStack {
            RoundedRectangle(cornerRadius: 16)
                .fill(PMCTheme.cardGradient)
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(PMCTheme.tealAccent.opacity(0.4), lineWidth: 1.5)
                )

            VStack(alignment: .leading, spacing: 12) {
                HStack {
                    VStack(alignment: .leading, spacing: 2) {
                        Text("Current Week")
                            .font(.caption)
                            .foregroundColor(PMCTheme.tealAccent)
                        Text(week.title + " — " + week.subtitle)
                            .font(.headline)
                            .foregroundColor(PMCTheme.scriptWhite)
                    }
                    Spacer()
                    WeekTypeBadge(week: week)
                }

                HStack(spacing: 8) {
                    ForEach(week.workouts) { workout in
                        VStack(spacing: 4) {
                            ZStack {
                                RoundedRectangle(cornerRadius: 6)
                                    .fill(dayBgColor(workout: workout))
                                    .frame(width: 36, height: 36)
                                Image(systemName: workout.status == .notStarted ? workout.workoutType.icon : workout.status.icon)
                                    .font(.system(size: 14))
                                    .foregroundColor(dayIconColor(workout: workout))
                            }
                            .overlay(
                                RoundedRectangle(cornerRadius: 6)
                                    .stroke(workout.isToday ? PMCTheme.patriotRed : Color.clear, lineWidth: 2)
                            )
                            Text(shortDay(workout.dayOfWeek))
                                .font(.system(size: 9, weight: .medium))
                                .foregroundColor(workout.isToday ? PMCTheme.tealAccent : PMCTheme.lightTeal)
                        }
                    }
                }

                VStack(alignment: .leading, spacing: 4) {
                    HStack {
                        Text("\(week.completedCount) of \(week.scheduledCount) workouts completed")
                            .font(.caption)
                            .foregroundColor(PMCTheme.lightTeal)
                        Spacer()
                        Text("\(Int(week.progressPercentage * 100))%")
                            .font(.caption)
                            .fontWeight(.bold)
                            .foregroundColor(PMCTheme.tealAccent)
                    }
                    GeometryReader { geo in
                        ZStack(alignment: .leading) {
                            RoundedRectangle(cornerRadius: 4)
                                .fill(PMCTheme.deepNavy)
                                .frame(height: 8)
                            RoundedRectangle(cornerRadius: 4)
                                .fill(
                                    LinearGradient(
                                        colors: [PMCTheme.tealAccent, Color(red: 0.059, green: 0.600, blue: 0.700)],
                                        startPoint: .leading,
                                        endPoint: .trailing
                                    )
                                )
                                .frame(width: geo.size.width * week.progressPercentage, height: 8)
                        }
                    }
                    .frame(height: 8)
                }
            }
            .padding(16)
        }
    }

    // MARK: - Completion Heatmap
    private var completionHeatmap: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 16)
                .fill(PMCTheme.cardGradient)
                .overlay(RoundedRectangle(cornerRadius: 16).stroke(PMCTheme.tealAccent.opacity(0.15), lineWidth: 1))

            VStack(alignment: .leading, spacing: 12) {
                SectionHeader(title: "Completion Map", icon: "square.grid.3x3.fill")

                let columns = Array(repeating: GridItem(.flexible(), spacing: 4), count: 7)
                LazyVGrid(columns: columns, spacing: 4) {
                    ForEach(["M","T","W","T","F","S","S"], id: \.self) { day in
                        Text(day)
                            .font(.system(size: 9, weight: .semibold))
                            .foregroundColor(PMCTheme.lightTeal)
                            .frame(maxWidth: .infinity)
                    }
                    ForEach(workoutStore.weeks) { week in
                        ForEach(week.workouts) { workout in
                            heatmapCell(workout: workout)
                        }
                    }
                }

                HStack(spacing: 12) {
                    legendItem(color: .green, label: "Done")
                    legendItem(color: PMCTheme.tealAccent, label: "In Progress")
                    legendItem(color: .yellow, label: "Skipped")
                    legendItem(color: PMCTheme.lightTeal.opacity(0.2), label: "Upcoming")
                }
                .padding(.top, 4)
            }
            .padding(16)
        }
    }

    private func heatmapCell(workout: DailyWorkout) -> some View {
        RoundedRectangle(cornerRadius: 3)
            .fill(heatmapColor(workout: workout))
            .frame(height: 14)
            .overlay(
                RoundedRectangle(cornerRadius: 3)
                    .stroke(workout.isToday ? PMCTheme.patriotRed : Color.clear, lineWidth: 1.5)
            )
    }

    private func heatmapColor(workout: DailyWorkout) -> Color {
        switch workout.status {
        case .completed: return .green.opacity(0.8)
        case .inProgress: return PMCTheme.tealAccent.opacity(0.8)
        case .skipped: return .yellow.opacity(0.6)
        case .notStarted:
            if workout.workoutType == .rest { return PMCTheme.deepNavy.opacity(0.5) }
            if workout.isPast { return PMCTheme.patriotRed.opacity(0.3) }
            return PMCTheme.lightTeal.opacity(0.15)
        }
    }

    private func legendItem(color: Color, label: String) -> some View {
        HStack(spacing: 4) {
            RoundedRectangle(cornerRadius: 2)
                .fill(color)
                .frame(width: 10, height: 10)
            Text(label)
                .font(.caption2)
                .foregroundColor(PMCTheme.lightTeal)
        }
    }

    private func dayBgColor(workout: DailyWorkout) -> Color {
        switch workout.status {
        case .completed: return .green.opacity(0.15)
        case .inProgress: return PMCTheme.tealAccent.opacity(0.15)
        case .skipped: return .yellow.opacity(0.15)
        case .notStarted:
            if workout.workoutType == .rest { return PMCTheme.deepNavy.opacity(0.5) }
            return PMCTheme.lightTeal.opacity(0.08)
        }
    }

    private func dayIconColor(workout: DailyWorkout) -> Color {
        switch workout.status {
        case .completed: return .green
        case .inProgress: return PMCTheme.tealAccent
        case .skipped: return .yellow
        case .notStarted:
            if workout.workoutType == .rest { return PMCTheme.lightTeal.opacity(0.3) }
            return PMCTheme.scriptWhite.opacity(0.5)
        }
    }

    private func shortDay(_ offset: Int) -> String {
        ["M","T","W","T","F","S","S"][safe: offset] ?? ""
    }
}

// MARK: - Week Progress Row
struct WeekProgressRow: View {
    @EnvironmentObject var workoutStore: WorkoutStore
    let week: TrainingWeek

    var currentWeek: TrainingWeek {
        workoutStore.week(for: week.weekNumber) ?? week
    }

    var isCurrentWeek: Bool {
        workoutStore.currentWeek?.id == week.id
    }

    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 12)
                .fill(PMCTheme.cardGradient)
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(isCurrentWeek ? PMCTheme.tealAccent.opacity(0.5) : PMCTheme.tealAccent.opacity(0.08), lineWidth: 1)
                )

            HStack(spacing: 12) {
                ZStack {
                    Circle()
                        .fill(isCurrentWeek ? PMCTheme.tealAccent.opacity(0.2) : PMCTheme.deepNavy)
                        .frame(width: 40, height: 40)
                    Text("\(week.weekNumber)")
                        .font(.subheadline)
                        .fontWeight(.bold)
                        .foregroundColor(isCurrentWeek ? PMCTheme.tealAccent : PMCTheme.scriptWhite)
                }

                VStack(alignment: .leading, spacing: 3) {
                    HStack(spacing: 6) {
                        Text(week.title)
                            .font(.subheadline)
                            .fontWeight(.semibold)
                            .foregroundColor(PMCTheme.scriptWhite)
                        WeekTypeBadge(week: week)
                    }
                    Text(weekDateRange)
                        .font(.caption)
                        .foregroundColor(PMCTheme.lightTeal)
                }

                Spacer()

                VStack(alignment: .trailing, spacing: 4) {
                    Text("\(currentWeek.completedCount)/\(currentWeek.scheduledCount)")
                        .font(.subheadline)
                        .fontWeight(.bold)
                        .foregroundColor(progressColor)
                    GeometryReader { geo in
                        ZStack(alignment: .leading) {
                            RoundedRectangle(cornerRadius: 2)
                                .fill(PMCTheme.deepNavy)
                                .frame(height: 4)
                            RoundedRectangle(cornerRadius: 2)
                                .fill(progressColor)
                                .frame(width: geo.size.width * currentWeek.progressPercentage, height: 4)
                        }
                    }
                    .frame(width: 60, height: 4)
                }
            }
            .padding(12)
        }
    }

    private var weekDateRange: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMM d"
        return "\(formatter.string(from: week.startDate)) – \(formatter.string(from: week.endDate))"
    }

    private var progressColor: Color {
        if currentWeek.progressPercentage >= 1.0 { return .green }
        if currentWeek.progressPercentage > 0 { return PMCTheme.tealAccent }
        return PMCTheme.lightTeal.opacity(0.3)
    }
}

// MARK: - Ride History Row
struct RideHistoryRow: View {
    let ride: CompletedRide

    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 12)
                .fill(PMCTheme.cardGradient)
                .overlay(RoundedRectangle(cornerRadius: 12).stroke(PMCTheme.tealAccent.opacity(0.15), lineWidth: 1))

            HStack(spacing: 12) {
                ZStack {
                    Circle()
                        .fill(PMCTheme.tealAccent.opacity(0.15))
                        .frame(width: 44, height: 44)
                    Image(systemName: "bicycle")
                        .font(.system(size: 20))
                        .foregroundColor(PMCTheme.tealAccent)
                }

                VStack(alignment: .leading, spacing: 3) {
                    Text(ride.workoutTitle)
                        .font(.subheadline)
                        .fontWeight(.semibold)
                        .foregroundColor(PMCTheme.scriptWhite)
                        .lineLimit(1)
                    Text(ride.startTime.formatted(date: .abbreviated, time: .shortened))
                        .font(.caption)
                        .foregroundColor(PMCTheme.lightTeal)
                }

                Spacer()

                VStack(alignment: .trailing, spacing: 3) {
                    Text(ride.formattedDistance)
                        .font(.subheadline)
                        .fontWeight(.bold)
                        .foregroundColor(PMCTheme.tealAccent)
                    Text(ride.formattedMovingTime)
                        .font(.caption)
                        .foregroundColor(PMCTheme.lightTeal)
                }

                Image(systemName: "chevron.right")
                    .font(.caption)
                    .foregroundColor(PMCTheme.lightTeal.opacity(0.7))
            }
            .padding(12)
        }
    }
}
