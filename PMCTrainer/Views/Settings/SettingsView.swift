import SwiftUI

struct SettingsView: View {
    @EnvironmentObject var notificationManager: NotificationManager
    @EnvironmentObject var workoutStore:        WorkoutStore
    @EnvironmentObject var healthKit:           HealthKitManager

    @State private var showingResetConfirm = false

    var body: some View {
        NavigationView {
            ZStack {
                PMCTheme.deepNavy
                    .ignoresSafeArea()

                ScrollView {
                    VStack(spacing: 20) {

                        // ── Training Tools ──────────────────────────────────
                        settingsSection(title: "Training Tools", icon: "speedometer") {
                            NavigationLink(destination: ZoneCalculatorView()) {
                                settingsRow(
                                    icon: "heart.text.square.fill",
                                    iconColor: PMCTheme.patriotRed,
                                    title: "Heart Rate Zone Calculator",
                                    subtitle: "Enter your max HR to get personalized zones",
                                    trailing: { chevron }
                                )
                            }

                            NavyDivider()

                            NavigationLink(destination: ZoneReferenceView()) {
                                settingsRow(
                                    icon: "speedometer",
                                    iconColor: PMCTheme.tealAccent,
                                    title: "Zone Reference Guide",
                                    subtitle: "RPE and HR ranges for all 5 zones",
                                    trailing: { chevron }
                                )
                            }
                        }

                        // ── Live Heart Rate (HealthKit) ──────────────────────
                        settingsSection(title: "Live Heart Rate", icon: "waveform.path.ecg.rectangle.fill") {
                            settingsRow(
                                icon: "heart.text.square.fill",
                                iconColor: PMCTheme.patriotRed,
                                title: "Apple Health Access",
                                subtitle: healthKit.isAuthorized
                                    ? "Authorized — live HR streams from your wearable during rides"
                                    : "Tap to authorize — required for live zone display on rides",
                                trailing: {
                                    if healthKit.isAuthorized {
                                        HStack(spacing: 4) {
                                            Circle()
                                                .fill(Color.green)
                                                .frame(width: 7, height: 7)
                                            Text("Active")
                                                .font(.caption)
                                                .foregroundColor(.green)
                                        }
                                    } else {
                                        Button(action: { healthKit.requestAuthorization() }) {
                                            Text("Authorize")
                                                .font(.caption)
                                                .fontWeight(.semibold)
                                                .foregroundColor(.white)
                                                .padding(.horizontal, 10)
                                                .padding(.vertical, 5)
                                                .background(PMCTheme.patriotRed)
                                                .cornerRadius(6)
                                        }
                                    }
                                }
                            )

                            NavyDivider()

                            settingsRow(
                                icon: "speedometer",
                                iconColor: PMCTheme.tealAccent,
                                title: "Max Heart Rate",
                                subtitle: "Used to calculate Z1–Z5 during rides",
                                trailing: {
                                    HStack(spacing: 4) {
                                        Button(action: { if healthKit.maxHR > 140 { healthKit.maxHR -= 1 } }) {
                                            Image(systemName: "minus.circle")
                                                .foregroundColor(PMCTheme.lightTeal)
                                        }
                                        Text("\(healthKit.maxHR)")
                                            .font(.system(size: 15, weight: .bold, design: .rounded))
                                            .foregroundColor(PMCTheme.scriptWhite)
                                            .frame(minWidth: 36)
                                        Button(action: { if healthKit.maxHR < 220 { healthKit.maxHR += 1 } }) {
                                            Image(systemName: "plus.circle")
                                                .foregroundColor(PMCTheme.tealAccent)
                                        }
                                    }
                                }
                            )

                            NavyDivider()

                            settingsRow(
                                icon: "info.circle",
                                iconColor: PMCTheme.lightTeal,
                                title: "How It Works",
                                subtitle: "Your wearable (WHOOP, Apple Watch, Garmin, etc.) writes HR to Apple Health via Bluetooth. PMC Trainer reads it live — no internet needed during rides.",
                                trailing: { EmptyView() }
                            )
                        }

                        // ── Notifications ────────────────────────────────────
                        settingsSection(title: "Notifications", icon: "bell.fill") {
                            settingsRow(
                                icon: "bell.badge.fill",
                                iconColor: PMCTheme.tealAccent,
                                title: "Morning Workout Reminders",
                                subtitle: "Daily 7:00 AM reminders on workout days",
                                trailing: {
                                    Toggle("", isOn: Binding(
                                        get: { notificationManager.notificationsEnabled },
                                        set: { enabled in
                                            if enabled {
                                                notificationManager.requestPermissionAndSchedule(workouts: workoutStore.allWorkouts)
                                            } else {
                                                notificationManager.cancelAll()
                                            }
                                        }
                                    ))
                                    .labelsHidden()
                                    .tint(PMCTheme.tealAccent)
                                }
                            )

                            if notificationManager.notificationsEnabled {
                                NavyDivider()
                                settingsRow(
                                    icon: "clock.fill",
                                    iconColor: PMCTheme.lightTeal,
                                    title: "Reminder Time",
                                    subtitle: "7:00 AM every workout day",
                                    trailing: { EmptyView() }
                                )
                            }
                        }

                        // ── About ────────────────────────────────────────────
                        settingsSection(title: "About", icon: "info.circle.fill") {
                            settingsRow(
                                icon: "bicycle",
                                iconColor: PMCTheme.tealAccent,
                                title: "PMC Trainer",
                                subtitle: "Pan-Mass Challenge 2026 · America 250 Edition",
                                trailing: {
                                    Text("v2.0")
                                        .font(.caption)
                                        .foregroundColor(PMCTheme.lightTeal)
                                }
                            )

                            NavyDivider()

                            settingsRow(
                                icon: "heart.fill",
                                iconColor: PMCTheme.patriotRed,
                                title: "Pan-Mass Challenge",
                                subtitle: "Ride to fight cancer. pmc.org",
                                trailing: { chevron }
                            )

                            NavyDivider()

                            settingsRow(
                                icon: "star.fill",
                                iconColor: PMCTheme.tealAccent,
                                title: "America 250",
                                subtitle: "Celebrating 250 years of freedom — ride for those who can't",
                                trailing: { EmptyView() }
                            )
                        }

                        // ── Data ─────────────────────────────────────────────
                        settingsSection(title: "Data", icon: "trash.fill") {
                            Button(action: { showingResetConfirm = true }) {
                                settingsRow(
                                    icon: "arrow.counterclockwise",
                                    iconColor: PMCTheme.patriotRed,
                                    title: "Reset All Progress",
                                    subtitle: "Clear all workout completion data",
                                    trailing: { EmptyView() }
                                )
                            }
                        }

                        Spacer(minLength: 40)
                    }
                    .padding(.horizontal, 16)
                    .padding(.top, 8)
                }
            }
            .navigationTitle("Settings")
            .navigationBarTitleDisplayMode(.large)
            .alert("Reset All Progress", isPresented: $showingResetConfirm) {
                Button("Reset", role: .destructive) { resetAllProgress() }
                Button("Cancel", role: .cancel) {}
            } message: {
                Text("This will clear all workout completion data. This cannot be undone.")
            }
        }
    }

    // MARK: - Section Builder
    private func settingsSection<Content: View>(title: String, icon: String, @ViewBuilder content: () -> Content) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack(spacing: 6) {
                Image(systemName: icon)
                    .font(.caption)
                    .foregroundColor(PMCTheme.tealAccent)
                Text(title.uppercased())
                    .font(.system(size: 11, weight: .semibold))
                    .foregroundColor(PMCTheme.lightTeal)
            }
            .padding(.leading, 4)

            ZStack {
                RoundedRectangle(cornerRadius: 14)
                    .fill(PMCTheme.midNavy)
                    .overlay(
                        RoundedRectangle(cornerRadius: 14)
                            .stroke(Color.white.opacity(0.07), lineWidth: 1)
                    )

                VStack(spacing: 0) {
                    content()
                }
                .padding(.vertical, 4)
            }
        }
    }

    // MARK: - Row Builder
    private func settingsRow<Trailing: View>(
        icon: String,
        iconColor: Color,
        title: String,
        subtitle: String,
        @ViewBuilder trailing: () -> Trailing
    ) -> some View {
        HStack(spacing: 14) {
            ZStack {
                RoundedRectangle(cornerRadius: 8)
                    .fill(iconColor.opacity(0.15))
                    .frame(width: 36, height: 36)
                Image(systemName: icon)
                    .font(.system(size: 16))
                    .foregroundColor(iconColor)
            }

            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.subheadline)
                    .fontWeight(.medium)
                    .foregroundColor(.white)
                Text(subtitle)
                    .font(.caption)
                    .foregroundColor(PMCTheme.lightTeal)
                    .lineLimit(3)
                    .fixedSize(horizontal: false, vertical: true)
            }

            Spacer()
            trailing()
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 10)
    }

    private var chevron: some View {
        Image(systemName: "chevron.right")
            .font(.caption)
            .foregroundColor(PMCTheme.lightTeal.opacity(0.5))
    }

    private func resetAllProgress() {
        for week in workoutStore.weeks {
            for workout in week.workouts {
                workoutStore.updateStatus(workoutID: workout.id, status: .notStarted)
            }
        }
    }
}
