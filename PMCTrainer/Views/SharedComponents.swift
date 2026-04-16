import SwiftUI

// MARK: - Zone Badge
struct ZoneBadge: View {
    let zone: TrainingZone

    var body: some View {
        Text(zone.rawValue)
            .font(.caption)
            .fontWeight(.bold)
            .padding(.horizontal, 10)
            .padding(.vertical, 4)
            .background(zone.color.opacity(0.2))
            .foregroundColor(zone.color)
            .cornerRadius(6)
            .overlay(
                RoundedRectangle(cornerRadius: 6)
                    .stroke(zone.color.opacity(0.5), lineWidth: 1)
            )
    }
}

// MARK: - Info Chip
struct InfoChip: View {
    let icon: String
    let text: String

    var body: some View {
        HStack(spacing: 4) {
            Image(systemName: icon)
                .font(.caption2)
                .foregroundColor(PMCTheme.lightTeal)
            Text(text)
                .font(.caption)
                .foregroundColor(PMCTheme.lightTeal)
        }
        .padding(.horizontal, 8)
        .padding(.vertical, 4)
        .background(PMCTheme.deepNavy.opacity(0.6))
        .cornerRadius(6)
        .overlay(RoundedRectangle(cornerRadius: 6).stroke(PMCTheme.tealAccent.opacity(0.2), lineWidth: 1))
    }
}

// MARK: - Status Badge
struct StatusBadge: View {
    let status: WorkoutStatus

    var body: some View {
        HStack(spacing: 4) {
            Image(systemName: status.icon)
                .font(.caption)
            Text(status.displayName)
                .font(.caption)
                .fontWeight(.semibold)
        }
        .padding(.horizontal, 10)
        .padding(.vertical, 5)
        .background(status.color.opacity(0.15))
        .foregroundColor(status.color)
        .cornerRadius(8)
    }
}

// MARK: - Section Header
struct SectionHeader: View {
    let title: String
    let icon: String

    var body: some View {
        HStack(spacing: 8) {
            Image(systemName: icon)
                .foregroundColor(PMCTheme.tealAccent)
                .font(.subheadline)
            Text(title)
                .font(.headline)
                .fontWeight(.semibold)
                .foregroundColor(PMCTheme.scriptWhite)
            Spacer()
        }
    }
}

// MARK: - Card Container
struct CardContainer<Content: View>: View {
    let content: Content

    init(@ViewBuilder content: () -> Content) {
        self.content = content()
    }

    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 16)
                .fill(PMCTheme.cardGradient)
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(PMCTheme.tealAccent.opacity(0.15), lineWidth: 1)
                )
            content
                .padding(16)
        }
    }
}

// MARK: - Week Type Badge
struct WeekTypeBadge: View {
    let week: TrainingWeek

    var body: some View {
        if week.isRaceWeek {
            badge(text: "RACE WEEK", color: PMCTheme.patriotRed)
        } else if week.isRecoveryWeek {
            badge(text: "RECOVERY", color: .green)
        } else if week.isPeakWeek {
            badge(text: "PEAK", color: PMCTheme.patriotRed)
        } else if week.isTaperWeek {
            badge(text: "TAPER", color: .purple)
        } else {
            EmptyView()
        }
    }

    private func badge(text: String, color: Color) -> some View {
        Text(text)
            .font(.system(size: 10, weight: .bold))
            .padding(.horizontal, 8)
            .padding(.vertical, 3)
            .background(color.opacity(0.2))
            .foregroundColor(color)
            .cornerRadius(4)
            .overlay(
                RoundedRectangle(cornerRadius: 4)
                    .stroke(color.opacity(0.4), lineWidth: 1)
            )
    }
}

// MARK: - Circular Progress
struct CircularProgressView: View {
    let progress: Double
    let size: CGFloat
    let lineWidth: CGFloat
    let color: Color

    var body: some View {
        ZStack {
            Circle()
                .stroke(PMCTheme.deepNavy, lineWidth: lineWidth)
                .frame(width: size, height: size)
            Circle()
                .trim(from: 0, to: progress)
                .stroke(color, style: StrokeStyle(lineWidth: lineWidth, lineCap: .round))
                .frame(width: size, height: size)
                .rotationEffect(.degrees(-90))
                .animation(.easeInOut(duration: 0.6), value: progress)
            Text("\(Int(progress * 100))%")
                .font(.system(size: size * 0.22, weight: .bold))
                .foregroundColor(PMCTheme.scriptWhite)
        }
    }
}

// TealDivider and StarScatterView are defined in PMCTheme.swift
// Legacy alias for backward compatibility
typealias NavyDivider = TealDivider

