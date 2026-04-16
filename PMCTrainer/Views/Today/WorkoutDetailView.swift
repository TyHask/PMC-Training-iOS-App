import SwiftUI

struct WorkoutDetailView: View {
    @EnvironmentObject var workoutStore: WorkoutStore
    @Environment(\.dismiss) var dismiss
    let workout: DailyWorkout

    var currentWorkout: DailyWorkout {
        workoutStore.workout(for: workout.id) ?? workout
    }

    var body: some View {
        NavigationView {
            ZStack {
                PMCTheme.deepNavy
                    .ignoresSafeArea()

                ScrollView {
                    VStack(spacing: 20) {
                        heroHeader
                        workoutDetailsCard
                        if currentWorkout.primaryZone != .rest {
                            zoneInfoCard
                        }
                        if currentWorkout.workoutType != .rest {
                            statusControlCard
                        }
                        Spacer(minLength: 40)
                    }
                    .padding(.horizontal, 16)
                    .padding(.top, 8)
                }
            }
            .navigationTitle(currentWorkout.shortDate)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Close") { dismiss() }
                        .foregroundColor(PMCTheme.tealAccent)
                }
            }
        }
    }

    // MARK: - Hero Header
    private var heroHeader: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 20)
                .fill(
                    LinearGradient(
                        colors: currentWorkout.isRaceDay
                            ? [PMCTheme.tealAccent, Color(red: 0.8, green: 0.3, blue: 0)]
                            : [PMCTheme.midNavy, PMCTheme.deepNavy],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )

            VStack(spacing: 12) {
                Image(systemName: currentWorkout.workoutType.icon)
                    .font(.system(size: 48))
                    .foregroundColor(currentWorkout.isRaceDay ? .white : PMCTheme.tealAccent)

                Text(currentWorkout.title)
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundColor(.white)
                    .multilineTextAlignment(.center)

                HStack(spacing: 12) {
                    if currentWorkout.primaryZone != .rest {
                        ZoneBadge(zone: currentWorkout.primaryZone)
                    }
                    StatusBadge(status: currentWorkout.status)
                }

                HStack(spacing: 20) {
                    if !currentWorkout.estimatedDuration.isEmpty {
                        VStack(spacing: 2) {
                            Text(currentWorkout.estimatedDuration)
                                .font(.headline)
                                .foregroundColor(.white)
                            Text("Duration")
                                .font(.caption)
                                .foregroundColor(PMCTheme.lightTeal)
                        }
                    }
                    if !currentWorkout.estimatedDistance.isEmpty {
                        VStack(spacing: 2) {
                            Text(currentWorkout.estimatedDistance)
                                .font(.headline)
                                .foregroundColor(.white)
                            Text("Distance")
                                .font(.caption)
                                .foregroundColor(PMCTheme.lightTeal)
                        }
                    }
                }
            }
            .padding(24)
        }
    }

    // MARK: - Workout Details Card
    private var workoutDetailsCard: some View {
        CardContainer {
            VStack(alignment: .leading, spacing: 12) {
                SectionHeader(title: "Workout Description", icon: "doc.text.fill")
                NavyDivider()
                Text(currentWorkout.description)
                    .font(.body)
                    .foregroundColor(.white)
                    .lineSpacing(4)
                    .fixedSize(horizontal: false, vertical: true)
            }
        }
    }

    // MARK: - Zone Info Card
    private var zoneInfoCard: some View {
        CardContainer {
            VStack(alignment: .leading, spacing: 12) {
                SectionHeader(title: "Training Zone", icon: "speedometer")
                NavyDivider()

                HStack(spacing: 16) {
                    ZStack {
                        Circle()
                            .fill(currentWorkout.primaryZone.color.opacity(0.15))
                            .frame(width: 60, height: 60)
                        Text(currentWorkout.primaryZone.rawValue)
                            .font(.title2)
                            .fontWeight(.bold)
                            .foregroundColor(currentWorkout.primaryZone.color)
                    }

                    VStack(alignment: .leading, spacing: 4) {
                        Text(currentWorkout.primaryZone.displayName)
                            .font(.headline)
                            .foregroundColor(.white)
                        Text(currentWorkout.primaryZone.rpeRange)
                            .font(.subheadline)
                            .foregroundColor(currentWorkout.primaryZone.color)
                        Text(currentWorkout.primaryZone.description)
                            .font(.caption)
                            .foregroundColor(PMCTheme.lightTeal)
                    }
                }
            }
        }
    }

    // MARK: - Status Control Card
    private var statusControlCard: some View {
        CardContainer {
            VStack(alignment: .leading, spacing: 12) {
                SectionHeader(title: "Mark Workout", icon: "checkmark.circle.fill")
                NavyDivider()

                HStack(spacing: 12) {
                    ForEach([WorkoutStatus.inProgress, .completed, .skipped], id: \.self) { status in
                        Button(action: {
                            let newStatus = currentWorkout.status == status ? WorkoutStatus.notStarted : status
                            workoutStore.updateStatus(workoutID: currentWorkout.id, status: newStatus)
                        }) {
                            VStack(spacing: 6) {
                                Image(systemName: status.icon)
                                    .font(.title2)
                                Text(status.displayName)
                                    .font(.caption)
                                    .fontWeight(.semibold)
                            }
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 12)
                            .background(currentWorkout.status == status ? status.color.opacity(0.2) : Color.white.opacity(0.05))
                            .foregroundColor(currentWorkout.status == status ? status.color : PMCTheme.lightTeal)
                            .cornerRadius(10)
                            .overlay(
                                RoundedRectangle(cornerRadius: 10)
                                    .stroke(currentWorkout.status == status ? status.color.opacity(0.5) : Color.clear, lineWidth: 1.5)
                            )
                        }
                    }
                }
            }
        }
    }
}
