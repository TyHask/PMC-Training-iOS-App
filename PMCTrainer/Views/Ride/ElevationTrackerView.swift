import SwiftUI

// MARK: - Elevation Tracker View
// A live scrolling elevation profile graph showing hills ridden so far
struct ElevationTrackerView: View {
    let points: [ElevationPoint]

    private var minElev: Double {
        (points.map(\.elevation).min() ?? 0) - 20
    }
    private var maxElev: Double {
        (points.map(\.elevation).max() ?? 100) + 20
    }
    private var elevRange: Double {
        max(maxElev - minElev, 50) // minimum 50ft range for readability
    }
    private var totalDist: Double {
        points.last?.distance ?? 1.0
    }

    var body: some View {
        VStack(spacing: 4) {
            // Header
            HStack {
                HStack(spacing: 5) {
                    Image(systemName: "mountain.2.fill")
                        .font(.system(size: 11))
                        .foregroundColor(PMCTheme.tealAccent)
                    Text("Elevation Profile")
                        .font(.system(size: 11, weight: .semibold))
                        .foregroundColor(PMCTheme.lightTeal)
                        .textCase(.uppercase)
                        .tracking(0.8)
                }
                Spacer()
                if !points.isEmpty {
                    Text(String(format: "+%.0f ft gain", gainSoFar))
                        .font(.system(size: 11, weight: .semibold))
                        .foregroundColor(PMCTheme.tealAccent)
                }
            }
            .padding(.horizontal, 4)

            // Graph
            GeometryReader { geo in
                ZStack(alignment: .bottom) {
                    // Background
                    RoundedRectangle(cornerRadius: 10)
                        .fill(PMCTheme.deepNavy.opacity(0.7))
                        .overlay(
                            RoundedRectangle(cornerRadius: 10)
                                .stroke(PMCTheme.tealAccent.opacity(0.2), lineWidth: 1)
                        )

                    if points.count > 1 {
                        // Filled area under curve
                        elevationFillPath(size: geo.size)
                            .fill(
                                LinearGradient(
                                    colors: [
                                        PMCTheme.tealAccent.opacity(0.35),
                                        PMCTheme.tealAccent.opacity(0.05)
                                    ],
                                    startPoint: .top,
                                    endPoint: .bottom
                                )
                            )

                        // Stroke line
                        elevationLinePath(size: geo.size)
                            .stroke(PMCTheme.tealAccent, style: StrokeStyle(lineWidth: 2, lineCap: .round, lineJoin: .round))

                        // Current position dot
                        if let last = points.last {
                            let x = xPos(dist: last.distance, width: geo.size.width)
                            let y = yPos(elev: last.elevation, height: geo.size.height)
                            Circle()
                                .fill(PMCTheme.patriotRed)
                                .frame(width: 8, height: 8)
                                .shadow(color: PMCTheme.patriotRed.opacity(0.6), radius: 4)
                                .position(x: x, y: y)
                        }

                        // Y-axis labels
                        yAxisLabels(height: geo.size.height)

                        // Horizontal grid lines
                        gridLines(size: geo.size)
                    } else {
                        // Empty state
                        VStack(spacing: 4) {
                            Image(systemName: "waveform.path.ecg")
                                .font(.system(size: 20))
                                .foregroundColor(PMCTheme.lightTeal.opacity(0.4))
                            Text("Elevation data will appear as you ride")
                                .font(.caption2)
                                .foregroundColor(PMCTheme.lightTeal.opacity(0.5))
                        }
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                    }
                }
            }
        }
        .padding(8)
        .background(
            RoundedRectangle(cornerRadius: 14)
                .fill(PMCTheme.midNavy.opacity(0.85))
                .overlay(
                    RoundedRectangle(cornerRadius: 14)
                        .stroke(PMCTheme.tealAccent.opacity(0.2), lineWidth: 1)
                )
        )
    }

    // MARK: - Path Builders
    private func elevationLinePath(size: CGSize) -> Path {
        var path = Path()
        guard points.count > 1 else { return path }
        let first = points[0]
        path.move(to: CGPoint(x: xPos(dist: first.distance, width: size.width),
                              y: yPos(elev: first.elevation, height: size.height)))
        for point in points.dropFirst() {
            path.addLine(to: CGPoint(x: xPos(dist: point.distance, width: size.width),
                                     y: yPos(elev: point.elevation, height: size.height)))
        }
        return path
    }

    private func elevationFillPath(size: CGSize) -> Path {
        var path = Path()
        guard points.count > 1 else { return path }
        let first = points[0]
        path.move(to: CGPoint(x: xPos(dist: first.distance, width: size.width), y: size.height))
        path.addLine(to: CGPoint(x: xPos(dist: first.distance, width: size.width),
                                  y: yPos(elev: first.elevation, height: size.height)))
        for point in points.dropFirst() {
            path.addLine(to: CGPoint(x: xPos(dist: point.distance, width: size.width),
                                      y: yPos(elev: point.elevation, height: size.height)))
        }
        if let last = points.last {
            path.addLine(to: CGPoint(x: xPos(dist: last.distance, width: size.width), y: size.height))
        }
        path.closeSubpath()
        return path
    }

    // MARK: - Grid Lines
    private func gridLines(size: CGSize) -> some View {
        let steps = 3
        return ForEach(0..<steps, id: \.self) { i in
            let y = size.height * CGFloat(i) / CGFloat(steps - 1)
            Path { p in
                p.move(to: CGPoint(x: 0, y: y))
                p.addLine(to: CGPoint(x: size.width, y: y))
            }
            .stroke(PMCTheme.tealAccent.opacity(0.08), lineWidth: 1)
        }
    }

    // MARK: - Y-axis Labels
    private func yAxisLabels(height: CGFloat) -> some View {
        VStack {
            Text(String(format: "%.0f ft", maxElev))
                .font(.system(size: 8))
                .foregroundColor(PMCTheme.lightTeal.opacity(0.6))
            Spacer()
            Text(String(format: "%.0f ft", minElev))
                .font(.system(size: 8))
                .foregroundColor(PMCTheme.lightTeal.opacity(0.6))
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.leading, 4)
    }

    // MARK: - Coordinate Helpers
    private func xPos(dist: Double, width: CGFloat) -> CGFloat {
        let maxDist = max(totalDist, 0.1)
        return CGFloat(dist / maxDist) * width
    }

    private func yPos(elev: Double, height: CGFloat) -> CGFloat {
        let normalized = (elev - minElev) / elevRange
        return height * (1.0 - CGFloat(normalized))
    }

    private var gainSoFar: Double {
        var gain: Double = 0
        for i in 1..<points.count {
            let delta = points[i].elevation - points[i-1].elevation
            if delta > 0 { gain += delta }
        }
        return gain
    }
}

// MARK: - Preview Helper
struct ElevationTrackerView_Previews: PreviewProvider {
    static var samplePoints: [ElevationPoint] = {
        var pts: [ElevationPoint] = []
        for i in 0..<50 {
            let dist = Double(i) * 0.1
            let elev = 100.0 + sin(Double(i) * 0.3) * 80 + Double(i) * 2
            pts.append(ElevationPoint(distance: dist, elevation: elev, timestamp: Date()))
        }
        return pts
    }()

    static var previews: some View {
        ElevationTrackerView(points: samplePoints)
            .frame(height: 120)
            .padding()
            .background(PMCTheme.deepNavy)
    }
}
