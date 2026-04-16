import SwiftUI

// MARK: - PMC 2026 America 250th Anniversary Design System
// Inspired by the PMC 2026 race jersey:
// Deep navy-to-teal gradient, bold patriot red collar, scattered stars, cursive script

struct PMCTheme {

    // MARK: - Core Colors
    static let deepNavy     = Color(red: 0.039, green: 0.118, blue: 0.310)   // #0A1E4F — darkest bg
    static let midNavy      = Color(red: 0.078, green: 0.220, blue: 0.420)   // #14386B — card bg
    static let starBlue     = Color(red: 0.071, green: 0.188, blue: 0.420)   // #12306B — top of jersey
    static let tealAccent   = Color(red: 0.059, green: 0.820, blue: 0.780)   // #0FD1C7 — jersey stars
    static let lightTeal    = Color(red: 0.290, green: 0.660, blue: 0.680)   // #4AA8AD — secondary text
    static let patriotRed   = Color(red: 0.886, green: 0.094, blue: 0.157)   // #E21828 — collar red
    static let scriptWhite  = Color(red: 0.980, green: 0.980, blue: 0.980)   // #FAFAFA — bold text
    static let goldStar     = Color(red: 1.000, green: 0.780, blue: 0.200)   // #FFC833 — star accent

    // MARK: - Background Gradient (jersey back: deep navy top → teal bottom)
    static let backgroundGradient = LinearGradient(
        colors: [
            Color(red: 0.039, green: 0.118, blue: 0.310),  // deep navy
            Color(red: 0.055, green: 0.200, blue: 0.380),  // mid blue
            Color(red: 0.059, green: 0.380, blue: 0.500),  // blue-teal
            Color(red: 0.059, green: 0.540, blue: 0.600)   // teal
        ],
        startPoint: .top,
        endPoint: .bottom
    )

    // MARK: - Card Gradient
    static let cardGradient = LinearGradient(
        colors: [
            Color(red: 0.078, green: 0.220, blue: 0.420).opacity(0.95),
            Color(red: 0.059, green: 0.300, blue: 0.460).opacity(0.90)
        ],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )

    // MARK: - Red Header Gradient (collar)
    static let redGradient = LinearGradient(
        colors: [
            Color(red: 0.940, green: 0.120, blue: 0.180),
            Color(red: 0.780, green: 0.060, blue: 0.100)
        ],
        startPoint: .leading,
        endPoint: .trailing
    )

    // MARK: - Teal Glow Gradient
    static let tealGlow = LinearGradient(
        colors: [tealAccent, Color(red: 0.059, green: 0.600, blue: 0.700)],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )

    // MARK: - Speed Hero Gradient (large speed display)
    static let speedGradient = LinearGradient(
        colors: [
            Color(red: 0.039, green: 0.100, blue: 0.260),
            Color(red: 0.039, green: 0.180, blue: 0.380),
            Color(red: 0.059, green: 0.380, blue: 0.500)
        ],
        startPoint: .top,
        endPoint: .bottom
    )
}

// MARK: - Patriot Background View Modifier
struct PatriotBackground: ViewModifier {
    func body(content: Content) -> some View {
        ZStack {
            PMCTheme.backgroundGradient
                .ignoresSafeArea()
            // Subtle star scatter overlay
            StarScatterView()
                .ignoresSafeArea()
                .allowsHitTesting(false)
            content
        }
    }
}

extension View {
    func patriotBackground() -> some View {
        modifier(PatriotBackground())
    }
}

// MARK: - Star Scatter Decoration
struct StarScatterView: View {
    private let stars: [(CGFloat, CGFloat, CGFloat, Double)] = [
        (0.08, 0.12, 14, 0.0), (0.85, 0.08, 10, 15.0), (0.45, 0.18, 18, -10.0),
        (0.15, 0.35, 12, 20.0), (0.78, 0.30, 16, -5.0), (0.92, 0.50, 11, 30.0),
        (0.05, 0.60, 20, -20.0), (0.60, 0.55, 14, 10.0), (0.30, 0.72, 22, -15.0),
        (0.88, 0.75, 18, 25.0), (0.50, 0.85, 16, 0.0), (0.20, 0.90, 12, -30.0),
        (0.70, 0.92, 24, 15.0), (0.40, 0.45, 10, -5.0), (0.95, 0.20, 14, 20.0)
    ]

    var body: some View {
        GeometryReader { geo in
            ForEach(0..<stars.count, id: \.self) { i in
                let s = stars[i]
                Image(systemName: "star.fill")
                    .font(.system(size: s.2))
                    .foregroundColor(PMCTheme.tealAccent.opacity(0.12))
                    .rotationEffect(.degrees(s.3))
                    .position(
                        x: geo.size.width * s.0,
                        y: geo.size.height * s.1
                    )
            }
        }
    }
}

// MARK: - Patriot Card Style
struct PatriotCard: ViewModifier {
    var padding: CGFloat = 16

    func body(content: Content) -> some View {
        content
            .padding(padding)
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(PMCTheme.cardGradient)
                    .overlay(
                        RoundedRectangle(cornerRadius: 16)
                            .stroke(PMCTheme.tealAccent.opacity(0.25), lineWidth: 1)
                    )
            )
    }
}

extension View {
    func patriotCard(padding: CGFloat = 16) -> some View {
        modifier(PatriotCard(padding: padding))
    }
}

// MARK: - Teal Stat Label
struct TealStatLabel: View {
    let value: String
    let label: String
    var valueSize: CGFloat = 28

    var body: some View {
        VStack(spacing: 2) {
            Text(value)
                .font(.system(size: valueSize, weight: .bold, design: .rounded))
                .foregroundColor(PMCTheme.tealAccent)
            Text(label)
                .font(.caption2)
                .fontWeight(.semibold)
                .foregroundColor(PMCTheme.lightTeal)
                .textCase(.uppercase)
                .tracking(1)
        }
    }
}

// MARK: - Red Accent Header
struct RedAccentHeader: View {
    let title: String
    let subtitle: String?

    init(_ title: String, subtitle: String? = nil) {
        self.title = title
        self.subtitle = subtitle
    }

    var body: some View {
        VStack(spacing: 2) {
            HStack(spacing: 6) {
                Image(systemName: "star.fill")
                    .font(.caption)
                    .foregroundColor(PMCTheme.patriotRed)
                Text(title)
                    .font(.headline)
                    .fontWeight(.bold)
                    .foregroundColor(PMCTheme.scriptWhite)
                Image(systemName: "star.fill")
                    .font(.caption)
                    .foregroundColor(PMCTheme.patriotRed)
            }
            if let sub = subtitle {
                Text(sub)
                    .font(.caption)
                    .foregroundColor(PMCTheme.lightTeal)
            }
        }
    }
}

// MARK: - Teal Divider
struct TealDivider: View {
    var body: some View {
        Rectangle()
            .fill(PMCTheme.tealAccent.opacity(0.30))
            .frame(height: 1)
    }
}

// MARK: - Zone Color Mapping (America theme)
extension TrainingZone {
    var patriotColor: Color {
        switch self {
        case .rest:   return PMCTheme.lightTeal
        case .z1:     return Color(red: 0.3, green: 0.8, blue: 0.7)
        case .z2:     return PMCTheme.tealAccent
        case .z3:     return Color(red: 0.2, green: 0.6, blue: 0.9)
        case .z4:     return PMCTheme.patriotRed.opacity(0.9)
        case .z5:     return PMCTheme.patriotRed
        case .mixed:  return Color(red: 0.6, green: 0.4, blue: 1.0)
        }
    }
}
