import SwiftUI
import MapKit

struct RideReplayView: View {
    let ride: CompletedRide

    @Environment(\.dismiss) private var dismiss
    @State private var replayIndex: Double = 0
    @State private var isPlaying = false
    @State private var speedMultiplier: Double = 1

    private let replayTimer = Timer.publish(every: 0.35, on: .main, in: .common).autoconnect()

    var body: some View {
        ZStack {
            PMCTheme.backgroundGradient.ignoresSafeArea()
            StarScatterView().ignoresSafeArea().allowsHitTesting(false)

            ScrollView(showsIndicators: false) {
                VStack(spacing: 16) {
                    replayHeader
                    replayMapCard
                    timelineCard
                    metricsCard
                    if !ride.laps.isEmpty { intervalJumpCard }
                    if !ride.notes.isEmpty { notesCard }
                    Spacer(minLength: 32)
                }
                .padding(.horizontal, 16)
                .padding(.top, 8)
            }
        }
        .navigationTitle("Ride Replay")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button("Done") { dismiss() }
                    .foregroundColor(PMCTheme.tealAccent)
            }
        }
        .onReceive(replayTimer) { _ in
            guard isPlaying, maxRouteIndex > 0 else { return }
            let step = max(1, Double(ride.routeCoordinates.count) / 140) * speedMultiplier
            if replayIndex + step >= Double(maxRouteIndex) {
                replayIndex = Double(maxRouteIndex)
                isPlaying = false
            } else {
                replayIndex += step
            }
        }
    }

    private var replayHeader: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(alignment: .top) {
                VStack(alignment: .leading, spacing: 4) {
                    Text(ride.workoutTitle)
                        .font(.system(size: 22, weight: .black))
                        .foregroundColor(PMCTheme.scriptWhite)
                    Text(ride.startTime.formatted(date: .abbreviated, time: .shortened))
                        .font(.subheadline)
                        .foregroundColor(PMCTheme.lightTeal)
                }
                Spacer()
                Image(systemName: "play.rectangle.fill")
                    .font(.system(size: 28))
                    .foregroundColor(PMCTheme.tealAccent)
            }

            HStack(spacing: 10) {
                replaySummaryPill(ride.formattedDistance, icon: "road.lanes")
                replaySummaryPill(ride.formattedMovingTime, icon: "clock.fill")
                replaySummaryPill(ride.formattedElevation, icon: "mountain.2.fill")
            }
        }
        .padding(16)
        .background(cardBackground(cornerRadius: 16))
    }

    private var replayMapCard: some View {
        VStack(alignment: .leading, spacing: 10) {
            SectionHeader(title: "Route Replay", icon: "map.fill")
            ReplayMapView(
                coordinates: ride.routeCoordinates,
                replayIndex: clampedRouteIndex
            )
            .frame(height: 260)
            .clipShape(RoundedRectangle(cornerRadius: 12))
        }
        .padding(14)
        .background(cardBackground(cornerRadius: 16))
    }

    private var timelineCard: some View {
        VStack(spacing: 12) {
            HStack {
                VStack(alignment: .leading, spacing: 2) {
                    Text(formatTime(currentElapsed))
                        .font(.system(size: 24, weight: .black, design: .monospaced))
                        .foregroundColor(PMCTheme.scriptWhite)
                    Text(String(format: "%.1f mi of %.1f mi", currentDistance, ride.totalDistance))
                        .font(.caption)
                        .foregroundColor(PMCTheme.lightTeal)
                }
                Spacer()
                Text("\(speedLabel)x")
                    .font(.system(size: 15, weight: .bold, design: .rounded))
                    .foregroundColor(PMCTheme.tealAccent)
                    .frame(width: 48, height: 34)
                    .background(PMCTheme.deepNavy.opacity(0.8))
                    .clipShape(Capsule())
            }

            Slider(value: $replayIndex, in: 0...Double(max(maxRouteIndex, 1)), step: 1)
                .tint(PMCTheme.tealAccent)

            HStack(spacing: 12) {
                replayButton(icon: "backward.end.fill", label: "Start") {
                    isPlaying = false
                    replayIndex = 0
                }
                replayButton(icon: "gobackward.15", label: "Back") {
                    seekByFraction(-0.08)
                }
                replayButton(icon: isPlaying ? "pause.fill" : "play.fill", label: isPlaying ? "Pause" : "Play", filled: true) {
                    guard maxRouteIndex > 0 else { return }
                    if replayIndex >= Double(maxRouteIndex) { replayIndex = 0 }
                    isPlaying.toggle()
                }
                replayButton(icon: "goforward.15", label: "Forward") {
                    seekByFraction(0.08)
                }
                replayButton(icon: "forward.end.fill", label: "Finish") {
                    isPlaying = false
                    replayIndex = Double(maxRouteIndex)
                }
            }

            Picker("Replay Speed", selection: $speedMultiplier) {
                Text("0.5x").tag(0.5)
                Text("1x").tag(1.0)
                Text("2x").tag(2.0)
                Text("4x").tag(4.0)
            }
            .pickerStyle(.segmented)
        }
        .padding(14)
        .background(cardBackground(cornerRadius: 16))
    }

    private var metricsCard: some View {
        VStack(alignment: .leading, spacing: 12) {
            SectionHeader(title: "Point Details", icon: "gauge.medium")
            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 10) {
                detailMetric("Distance", value: String(format: "%.2f mi", currentDistance), icon: "road.lanes")
                detailMetric("Elapsed", value: formatTime(currentElapsed), icon: "timer")
                detailMetric("Elevation", value: currentElevationText, icon: "mountain.2.fill")
                detailMetric("Avg Speed", value: ride.formattedAvgSpeed, icon: "speedometer")
                detailMetric("Avg HR", value: ride.avgHeartRate > 0 ? String(format: "%.0f bpm", ride.avgHeartRate) : "--", icon: "heart.fill")
                detailMetric("Top Zone", value: ride.dominantZoneShort, icon: "waveform.path.ecg")
            }
        }
        .padding(14)
        .background(cardBackground(cornerRadius: 16))
    }

    private var intervalJumpCard: some View {
        VStack(alignment: .leading, spacing: 10) {
            SectionHeader(title: "Quick Index", icon: "flag.fill")

            ForEach(ride.laps) { lap in
                Button {
                    seek(toElapsed: lap.startTime.timeIntervalSince(ride.startTime))
                } label: {
                    HStack {
                        Text("Lap \(lap.lapNumber)")
                            .font(.system(size: 13, weight: .bold))
                            .foregroundColor(PMCTheme.tealAccent)
                        Text(lap.formattedDuration)
                            .font(.system(size: 13, design: .monospaced))
                            .foregroundColor(PMCTheme.scriptWhite)
                        Spacer()
                        Text(String(format: "%.2f mi", lap.distance))
                            .font(.caption)
                            .foregroundColor(PMCTheme.lightTeal)
                        Image(systemName: "chevron.right")
                            .font(.caption)
                            .foregroundColor(PMCTheme.lightTeal.opacity(0.7))
                    }
                    .padding(.vertical, 9)
                    .padding(.horizontal, 10)
                    .background(PMCTheme.deepNavy.opacity(0.55))
                    .clipShape(RoundedRectangle(cornerRadius: 10))
                }
                .buttonStyle(.plain)
            }
        }
        .padding(14)
        .background(cardBackground(cornerRadius: 16))
    }

    private var notesCard: some View {
        VStack(alignment: .leading, spacing: 10) {
            SectionHeader(title: "Notes", icon: "note.text")
            Text(ride.notes)
                .font(.subheadline)
                .foregroundColor(PMCTheme.scriptWhite)
                .frame(maxWidth: .infinity, alignment: .leading)
        }
        .padding(14)
        .background(cardBackground(cornerRadius: 16))
    }

    private var maxRouteIndex: Int {
        max(ride.routeCoordinates.count - 1, 0)
    }

    private var clampedRouteIndex: Int {
        min(max(Int(replayIndex.rounded()), 0), maxRouteIndex)
    }

    private var progressFraction: Double {
        guard maxRouteIndex > 0 else { return 0 }
        return Double(clampedRouteIndex) / Double(maxRouteIndex)
    }

    private var currentElapsed: TimeInterval {
        ride.elapsedTime * progressFraction
    }

    private var currentDistance: Double {
        ride.totalDistance * progressFraction
    }

    private var currentElevationText: String {
        guard !ride.elevationPoints.isEmpty else { return "--" }
        let index = min(
            max(Int((Double(ride.elevationPoints.count - 1) * progressFraction).rounded()), 0),
            ride.elevationPoints.count - 1
        )
        return String(format: "%.0f ft", ride.elevationPoints[index].elevation)
    }

    private var speedLabel: String {
        speedMultiplier == floor(speedMultiplier)
            ? String(format: "%.0f", speedMultiplier)
            : String(format: "%.1f", speedMultiplier)
    }

    private func seekByFraction(_ delta: Double) {
        isPlaying = false
        let next = replayIndex + Double(max(maxRouteIndex, 1)) * delta
        replayIndex = min(max(next, 0), Double(maxRouteIndex))
    }

    private func seek(toElapsed elapsed: TimeInterval) {
        guard ride.elapsedTime > 0 else { return }
        isPlaying = false
        replayIndex = min(max((elapsed / ride.elapsedTime) * Double(maxRouteIndex), 0), Double(maxRouteIndex))
    }

    private func replaySummaryPill(_ text: String, icon: String) -> some View {
        HStack(spacing: 5) {
            Image(systemName: icon)
                .font(.caption2)
            Text(text)
                .font(.caption)
                .fontWeight(.semibold)
        }
        .foregroundColor(PMCTheme.lightTeal)
        .padding(.horizontal, 9)
        .padding(.vertical, 6)
        .background(PMCTheme.deepNavy.opacity(0.65))
        .clipShape(Capsule())
    }

    private func replayButton(icon: String, label: String, filled: Bool = false, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            Image(systemName: icon)
                .font(.system(size: 15, weight: .bold))
                .foregroundColor(filled ? .white : PMCTheme.tealAccent)
                .frame(width: filled ? 52 : 44, height: filled ? 52 : 44)
                .background(filled ? PMCTheme.tealAccent : PMCTheme.deepNavy.opacity(0.75))
                .clipShape(Circle())
                .overlay(Circle().stroke(PMCTheme.tealAccent.opacity(filled ? 0 : 0.35), lineWidth: 1))
        }
        .buttonStyle(.plain)
        .accessibilityLabel(label)
    }

    private func detailMetric(_ label: String, value: String, icon: String) -> some View {
        VStack(alignment: .leading, spacing: 7) {
            Image(systemName: icon)
                .font(.system(size: 15))
                .foregroundColor(PMCTheme.tealAccent)
            Text(value)
                .font(.system(size: 18, weight: .bold, design: .rounded))
                .foregroundColor(PMCTheme.scriptWhite)
                .lineLimit(1)
                .minimumScaleFactor(0.75)
            Text(label)
                .font(.caption2)
                .foregroundColor(PMCTheme.lightTeal)
                .textCase(.uppercase)
                .tracking(0.7)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(12)
        .background(PMCTheme.deepNavy.opacity(0.48))
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }

    private func cardBackground(cornerRadius: CGFloat) -> some View {
        RoundedRectangle(cornerRadius: cornerRadius)
            .fill(PMCTheme.cardGradient)
            .overlay(
                RoundedRectangle(cornerRadius: cornerRadius)
                    .stroke(PMCTheme.tealAccent.opacity(0.18), lineWidth: 1)
            )
    }

    private func formatTime(_ time: TimeInterval) -> String {
        let h = Int(time) / 3600
        let m = (Int(time) % 3600) / 60
        let s = Int(time) % 60
        if h > 0 { return String(format: "%d:%02d:%02d", h, m, s) }
        return String(format: "%d:%02d", m, s)
    }
}

struct ReplayMapView: UIViewRepresentable {
    let coordinates: [CLLocationCoordinate2D]
    let replayIndex: Int

    func makeUIView(context: Context) -> MKMapView {
        let map = MKMapView()
        map.delegate = context.coordinator
        map.overrideUserInterfaceStyle = .dark
        map.mapType = .standard
        map.pointOfInterestFilter = .excludingAll
        return map
    }

    func updateUIView(_ mapView: MKMapView, context: Context) {
        mapView.removeOverlays(mapView.overlays)
        mapView.removeAnnotations(mapView.annotations)
        guard coordinates.count > 1 else { return }

        var fullRoute = coordinates
        let fullPolyline = MKPolyline(coordinates: &fullRoute, count: fullRoute.count)
        fullPolyline.title = "full"
        mapView.addOverlay(fullPolyline)

        let completedCount = min(max(replayIndex + 1, 2), coordinates.count)
        var completedRoute = Array(coordinates.prefix(completedCount))
        let completedPolyline = MKPolyline(coordinates: &completedRoute, count: completedRoute.count)
        completedPolyline.title = "completed"
        mapView.addOverlay(completedPolyline)

        let start = MKPointAnnotation()
        start.coordinate = coordinates.first!
        start.title = "Start"

        let marker = MKPointAnnotation()
        marker.coordinate = coordinates[min(replayIndex, coordinates.count - 1)]
        marker.title = "Replay"

        let finish = MKPointAnnotation()
        finish.coordinate = coordinates.last!
        finish.title = "Finish"
        mapView.addAnnotations([start, marker, finish])

        if !context.coordinator.hasFitRegion {
            mapView.setRegion(fittedRegion, animated: false)
            context.coordinator.hasFitRegion = true
        }
    }

    func makeCoordinator() -> Coordinator { Coordinator() }

    final class Coordinator: NSObject, MKMapViewDelegate {
        var hasFitRegion = false

        func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
            guard let polyline = overlay as? MKPolyline else {
                return MKOverlayRenderer(overlay: overlay)
            }

            let renderer = MKPolylineRenderer(polyline: polyline)
            if polyline.title == "full" {
                renderer.strokeColor = UIColor.white.withAlphaComponent(0.22)
                renderer.lineWidth = 4
            } else {
                renderer.strokeColor = UIColor(red: 0.059, green: 0.820, blue: 0.780, alpha: 1.0)
                renderer.lineWidth = 5
            }
            renderer.lineCap = .round
            renderer.lineJoin = .round
            return renderer
        }
    }

    private var fittedRegion: MKCoordinateRegion {
        let lats = coordinates.map(\.latitude)
        let lons = coordinates.map(\.longitude)
        return MKCoordinateRegion(
            center: CLLocationCoordinate2D(
                latitude: ((lats.min() ?? 0) + (lats.max() ?? 0)) / 2,
                longitude: ((lons.min() ?? 0) + (lons.max() ?? 0)) / 2
            ),
            span: MKCoordinateSpan(
                latitudeDelta: max(((lats.max() ?? 0) - (lats.min() ?? 0)) * 1.35, 0.004),
                longitudeDelta: max(((lons.max() ?? 0) - (lons.min() ?? 0)) * 1.35, 0.004)
            )
        )
    }
}
