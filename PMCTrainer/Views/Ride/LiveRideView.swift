import SwiftUI
import MapKit
import CoreLocation
import HealthKit

// MARK: - Live Ride View (Main Container)
struct LiveRideView: View {
    @EnvironmentObject var locationManager: LocationManager
    @EnvironmentObject var healthKit:       HealthKitManager

    let workout: DailyWorkout?

    @State private var showStopwatch  = false
    @State private var showSpotify    = false
    @State private var showEndConfirm = false
    @State private var mapRegion = MKCoordinateRegion(
        center: CLLocationCoordinate2D(latitude: 42.36, longitude: -71.06),
        span: MKCoordinateSpan(latitudeDelta: 0.02, longitudeDelta: 0.02)
    )
    @State private var isMapFollowing          = true
    @State private var laps:                   [IntervalLap] = []
    @State private var currentLapStart:        Date?
    @State private var currentLapStartDistance: Double = 0
    @State private var elapsedTimer:           Timer?
    @State private var displayElapsed:         TimeInterval = 0

    // MARK: - Body
    var body: some View {
        ZStack {
            PMCTheme.speedGradient
                .ignoresSafeArea()

            VStack(spacing: 0) {
                // ── TOP SECTION: 1/3 screen height ──
                topSection
                    .frame(maxWidth: .infinity)
                    .frame(height: UIScreen.main.bounds.height / 3)

                // ── MAP + STATS ──
                mapAndStatsSection

                // ── ELEVATION TRACKER ──
                ElevationTrackerView(points: locationManager.elevationPoints)
                    .frame(height: 110)
                    .padding(.horizontal, 12)
                    .padding(.bottom, 4)

                // ── BOTTOM CONTROLS ──
                bottomControls
                    .padding(.horizontal, 12)
                    .padding(.bottom, 8)
            }

            // ── OVERLAYS ──
            if showStopwatch {
                IntervalStopwatchOverlay(
                    laps: $laps,
                    isVisible: $showStopwatch,
                    onLap: recordLap
                )
                .transition(.move(edge: .bottom).combined(with: .opacity))
            }

            if showSpotify {
                SpotifyControlsOverlay(isVisible: $showSpotify)
                    .transition(.move(edge: .bottom).combined(with: .opacity))
            }
        }
        .ignoresSafeArea(edges: .top)
        .statusBarHidden(true)
        .onAppear {
            startTimerDisplay()
            // Start live HR streaming when ride view appears
            healthKit.resetForRide()
            if healthKit.isAuthorized {
                healthKit.startStreaming()
            } else {
                healthKit.requestAuthorization { granted in
                    if granted { healthKit.startStreaming() }
                }
            }
        }
        .onDisappear {
            elapsedTimer?.invalidate()
            healthKit.stopStreaming()
        }
        .onChange(of: locationManager.currentLocation) { _, loc in
            if let loc = loc, isMapFollowing {
                withAnimation(.easeInOut(duration: 0.5)) {
                    mapRegion.center = loc.coordinate
                }
            }
        }
        .alert("End Ride?", isPresented: $showEndConfirm) {
            Button("End Ride", role: .destructive) { locationManager.stopRide() }
            Button("Cancel", role: .cancel) {}
        } message: {
            Text("This will stop GPS tracking and take you to the ride summary.")
        }
    }

    // MARK: - Top Section (1/3 screen)
    private var topSection: some View {
        ZStack {
            PMCTheme.speedGradient
                .overlay(
                    ZStack {
                        Image(systemName: "star.fill")
                            .font(.system(size: 60))
                            .foregroundColor(PMCTheme.tealAccent.opacity(0.06))
                            .offset(x: -140, y: -20)
                        Image(systemName: "star.fill")
                            .font(.system(size: 40))
                            .foregroundColor(PMCTheme.tealAccent.opacity(0.08))
                            .offset(x: 140, y: 10)
                    }
                )

            HStack(alignment: .center, spacing: 0) {
                // LEFT: Live HealthKit Heart Rate Zone
                LiveHRZonePanel()
                    .frame(maxWidth: .infinity)

                // CENTER: Speed Hero
                SpeedHeroPanel(speed: locationManager.currentSpeed, elapsed: displayElapsed)
                    .frame(maxWidth: .infinity)

                // RIGHT: Elevation Gain
                ElevationGainPanel(gain: locationManager.totalElevationGain)
                    .frame(maxWidth: .infinity)
            }
            .padding(.top, 44)
        }
    }

    // MARK: - Map + Stats
    private var mapAndStatsSection: some View {
        VStack(spacing: 0) {
            liveStatsRow
                .padding(.horizontal, 12)
                .padding(.vertical, 8)

            ZStack(alignment: .topTrailing) {
                RideMapView(
                    region: $mapRegion,
                    routeCoordinates: locationManager.routeCoordinates,
                    currentLocation: locationManager.currentLocation?.coordinate
                )
                .frame(maxWidth: .infinity)
                .frame(height: UIScreen.main.bounds.height * 0.28)
                .cornerRadius(16)
                .padding(.horizontal, 12)

                Button(action: toggleMapFollowing) {
                    Image(systemName: isMapFollowing ? "location.fill" : "location")
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundColor(isMapFollowing ? PMCTheme.tealAccent : PMCTheme.lightTeal)
                        .frame(width: 44, height: 44)
                        .background(PMCTheme.deepNavy.opacity(0.92))
                        .clipShape(Circle())
                        .overlay(
                            Circle()
                                .stroke(PMCTheme.tealAccent.opacity(isMapFollowing ? 0.75 : 0.25), lineWidth: 1)
                        )
                }
                .buttonStyle(.plain)
                .contentShape(Circle())
                .accessibilityLabel(isMapFollowing ? "Disable map follow" : "Center map on current location")
                .padding(.top, 8)
                .padding(.trailing, 20)
            }
        }
    }

    // MARK: - Live Stats Row
    // Avg HR comes from HealthKit live data (no internet needed)
    private var liveStatsRow: some View {
        HStack(spacing: 0) {
            statCell(
                value: String(format: "%.1f", locationManager.totalDistance),
                unit: "mi",
                label: "Distance"
            )
            Divider().frame(height: 36).background(PMCTheme.tealAccent.opacity(0.3))
            statCell(
                value: String(format: "%.1f", locationManager.avgSpeed),
                unit: "mph",
                label: "Avg Speed"
            )
            Divider().frame(height: 36).background(PMCTheme.tealAccent.opacity(0.3))
            // Live avg HR from HealthKit — updates every ~5 seconds
            statCell(
                value: healthKit.avgHR > 0 ? String(format: "%.0f", healthKit.avgHR) : "--",
                unit: "bpm",
                label: "Avg HR",
                highlight: healthKit.isHRFresh
            )
            Divider().frame(height: 36).background(PMCTheme.tealAccent.opacity(0.3))
            statCell(
                value: String(format: "%.0f", locationManager.totalElevationGain),
                unit: "ft",
                label: "Elev Gain"
            )
        }
        .padding(.vertical, 8)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(PMCTheme.midNavy.opacity(0.85))
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(PMCTheme.tealAccent.opacity(0.2), lineWidth: 1)
                )
        )
    }

    private func statCell(value: String, unit: String, label: String, highlight: Bool = false) -> some View {
        VStack(spacing: 2) {
            HStack(alignment: .lastTextBaseline, spacing: 2) {
                Text(value)
                    .font(.system(size: 20, weight: .bold, design: .rounded))
                    .foregroundColor(highlight ? PMCTheme.tealAccent : PMCTheme.tealAccent)
                if !unit.isEmpty {
                    Text(unit)
                        .font(.system(size: 11, weight: .semibold))
                        .foregroundColor(PMCTheme.lightTeal)
                }
            }
            Text(label)
                .font(.system(size: 9, weight: .semibold))
                .foregroundColor(PMCTheme.lightTeal)
                .textCase(.uppercase)
                .tracking(0.8)
        }
        .frame(maxWidth: .infinity)
    }

    private func toggleMapFollowing() {
        let shouldFollow = !isMapFollowing
        isMapFollowing = shouldFollow

        guard shouldFollow, let coordinate = locationManager.currentLocation?.coordinate else { return }
        withAnimation(.easeInOut(duration: 0.35)) {
            mapRegion.center = coordinate
        }
    }

    // MARK: - Bottom Controls
    private var bottomControls: some View {
        HStack(spacing: 10) {
            controlButton(icon: "music.note", label: "Music", color: PMCTheme.tealAccent) {
                withAnimation(.spring()) { showSpotify.toggle() }
            }

            if locationManager.rideState == .active {
                controlButton(icon: "pause.fill", label: "Pause", color: PMCTheme.lightTeal) {
                    locationManager.pauseRide()
                }
            } else if locationManager.rideState == .paused {
                controlButton(icon: "play.fill", label: "Resume", color: .green) {
                    locationManager.resumeRide()
                }
            }

            controlButton(
                icon: "stopwatch.fill",
                label: "Intervals",
                color: showStopwatch ? PMCTheme.patriotRed : PMCTheme.tealAccent
            ) {
                withAnimation(.spring()) { showStopwatch.toggle() }
            }

            Button(action: { showEndConfirm = true }) {
                VStack(spacing: 4) {
                    ZStack {
                        Circle()
                            .fill(PMCTheme.patriotRed)
                            .frame(width: 52, height: 52)
                        Image(systemName: "flag.checkered")
                            .font(.system(size: 22, weight: .bold))
                            .foregroundColor(.white)
                    }
                    Text("Finish")
                        .font(.system(size: 10, weight: .semibold))
                        .foregroundColor(PMCTheme.patriotRed)
                        .textCase(.uppercase)
                        .tracking(0.8)
                }
            }
        }
    }

    private func controlButton(icon: String, label: String, color: Color, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            VStack(spacing: 4) {
                ZStack {
                    Circle()
                        .fill(PMCTheme.midNavy)
                        .overlay(Circle().stroke(color.opacity(0.4), lineWidth: 1.5))
                        .frame(width: 52, height: 52)
                    Image(systemName: icon)
                        .font(.system(size: 20, weight: .semibold))
                        .foregroundColor(color)
                }
                Text(label)
                    .font(.system(size: 10, weight: .semibold))
                    .foregroundColor(color)
                    .textCase(.uppercase)
                    .tracking(0.8)
            }
        }
    }

    // MARK: - Timer
    private func startTimerDisplay() {
        elapsedTimer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { _ in
            displayElapsed = locationManager.elapsedTime
        }
    }

    // MARK: - Lap Recording
    private func recordLap() {
        let now = Date()
        let lapDist     = locationManager.totalDistance - currentLapStartDistance
        let lapDuration = now.timeIntervalSince(currentLapStart ?? now)
        let lap = IntervalLap(
            id:        UUID(),
            lapNumber: laps.count + 1,
            startTime: currentLapStart ?? now,
            endTime:   now,
            distance:  lapDist,
            avgSpeed:  lapDuration > 0 ? lapDist / (lapDuration / 3600) : 0,
            avgHeartRate: healthKit.avgHR
        )
        laps.append(lap)
        currentLapStart         = now
        currentLapStartDistance = locationManager.totalDistance
    }
}

// MARK: - Live HR Zone Panel (Left)
// Reads live heart rate from HealthKit (fed by WHOOP/Apple Watch via Bluetooth).
// No internet connection required. Updates every ~5 seconds.
struct LiveHRZonePanel: View {
    @EnvironmentObject var healthKit: HealthKitManager

    var body: some View {
        VStack(spacing: 6) {
            Spacer()

            ZStack {
                Circle()
                    .stroke(healthKit.currentZoneColor.opacity(0.20), lineWidth: 5)
                    .frame(width: 68, height: 68)

                Circle()
                    .trim(from: 0, to: zoneProgress)
                    .stroke(
                        healthKit.currentZoneColor,
                        style: StrokeStyle(lineWidth: 5, lineCap: .round)
                    )
                    .rotationEffect(.degrees(-90))
                    .frame(width: 68, height: 68)
                    .animation(.easeInOut(duration: 0.6), value: zoneProgress)

                VStack(spacing: 1) {
                    if healthKit.currentHR > 0 {
                        Text(String(format: "%.0f", healthKit.currentHR))
                            .font(.system(size: 19, weight: .bold, design: .rounded))
                            .foregroundColor(PMCTheme.scriptWhite)
                            .contentTransition(.numericText())
                            .animation(.easeInOut(duration: 0.4), value: healthKit.currentHR)
                    } else {
                        Text("--")
                            .font(.system(size: 19, weight: .bold, design: .rounded))
                            .foregroundColor(PMCTheme.lightTeal)
                    }
                    Text("bpm")
                        .font(.system(size: 9))
                        .foregroundColor(PMCTheme.lightTeal)
                }
            }

            Text(healthKit.currentHR > 0 ? healthKit.currentZoneShort : "–")
                .font(.system(size: 12, weight: .bold))
                .foregroundColor(healthKit.currentZoneColor)
                .frame(minWidth: 36)
                .padding(.horizontal, 8)
                .padding(.vertical, 3)
                .background(healthKit.currentZoneColor.opacity(0.18))
                .cornerRadius(6)
                .animation(.easeInOut(duration: 0.4), value: healthKit.currentZone)

            Text(healthKit.currentHR > 0 ? healthKit.currentZoneDescription : "HR Zone")
                .font(.system(size: 9))
                .foregroundColor(PMCTheme.lightTeal)
                .textCase(.uppercase)
                .tracking(0.8)

            if healthKit.isStreaming {
                HStack(spacing: 3) {
                    Circle()
                        .fill(healthKit.isHRFresh ? Color.green : Color.yellow)
                        .frame(width: 5, height: 5)
                    Text(healthKit.isHRFresh ? "Live" : "Stale")
                        .font(.system(size: 8))
                        .foregroundColor(healthKit.isHRFresh ? Color.green.opacity(0.8) : Color.yellow.opacity(0.8))
                }
            }

            Spacer()
        }
    }

    private var zoneProgress: CGFloat {
        switch healthKit.currentZone {
        case .rest:  return 0.1
        case .z1:    return 0.2
        case .z2:    return 0.4
        case .z3:    return 0.6
        case .z4:    return 0.8
        case .z5:    return 1.0
        case .mixed: return 0.5
        }
    }
}

// MARK: - Speed Hero Panel (Center)
struct SpeedHeroPanel: View {
    let speed:   Double
    let elapsed: TimeInterval

    private var formattedElapsed: String {
        let h = Int(elapsed) / 3600
        let m = (Int(elapsed) % 3600) / 60
        let s = Int(elapsed) % 60
        if h > 0 { return String(format: "%d:%02d:%02d", h, m, s) }
        return String(format: "%d:%02d", m, s)
    }

    var body: some View {
        VStack(spacing: 4) {
            Spacer()

            Text(String(format: "%.1f", speed))
                .font(.system(size: 72, weight: .black, design: .rounded))
                .foregroundColor(PMCTheme.scriptWhite)
                .shadow(color: PMCTheme.tealAccent.opacity(0.4), radius: 12, x: 0, y: 4)
                .minimumScaleFactor(0.6)
                .lineLimit(1)
                .contentTransition(.numericText())
                .animation(.easeInOut(duration: 0.3), value: speed)

            Text("MPH")
                .font(.system(size: 14, weight: .bold))
                .foregroundColor(PMCTheme.tealAccent)
                .tracking(4)

            Spacer()

            Text(formattedElapsed)
                .font(.system(size: 22, weight: .semibold, design: .monospaced))
                .foregroundColor(PMCTheme.lightTeal)
                .padding(.bottom, 12)
        }
    }
}

// MARK: - Elevation Gain Panel (Right)
// Replaces the former WHOOP strain panel. Shows cumulative elevation gain from GPS.
struct ElevationGainPanel: View {
    let gain: Double   // feet

    private var gainColor: Color {
        if gain < 500  { return PMCTheme.tealAccent }
        if gain < 1500 { return .yellow }
        if gain < 3000 { return .orange }
        return PMCTheme.patriotRed
    }

    private var gainLabel: String {
        if gain < 500  { return "Flat" }
        if gain < 1500 { return "Rolling" }
        if gain < 3000 { return "Hilly" }
        return "Epic"
    }

    // Progress arc: max reference 5000 ft
    private var gainProgress: CGFloat {
        CGFloat(min(gain / 5000.0, 1.0))
    }

    var body: some View {
        VStack(spacing: 6) {
            Spacer()

            ZStack {
                Circle()
                    .stroke(gainColor.opacity(0.20), lineWidth: 5)
                    .frame(width: 68, height: 68)
                Circle()
                    .trim(from: 0, to: gainProgress)
                    .stroke(gainColor, style: StrokeStyle(lineWidth: 5, lineCap: .round))
                    .rotationEffect(.degrees(-90))
                    .frame(width: 68, height: 68)
                    .animation(.easeInOut(duration: 0.5), value: gainProgress)

                VStack(spacing: 1) {
                    Text(String(format: "%.0f", gain))
                        .font(.system(size: 18, weight: .bold, design: .rounded))
                        .foregroundColor(PMCTheme.scriptWhite)
                        .contentTransition(.numericText())
                        .animation(.easeInOut(duration: 0.4), value: gain)
                    Text("ft")
                        .font(.system(size: 9))
                        .foregroundColor(PMCTheme.lightTeal)
                }
            }

            Text(gainLabel)
                .font(.system(size: 11, weight: .bold))
                .foregroundColor(gainColor)
                .padding(.horizontal, 8)
                .padding(.vertical, 3)
                .background(gainColor.opacity(0.15))
                .cornerRadius(6)

            Text("Elev Gain")
                .font(.system(size: 9))
                .foregroundColor(PMCTheme.lightTeal)
                .textCase(.uppercase)
                .tracking(0.8)

            Spacer()
        }
    }
}

// MARK: - Ride Map View
struct RideMapView: UIViewRepresentable {
    @Binding var region: MKCoordinateRegion
    let routeCoordinates: [CLLocationCoordinate2D]
    let currentLocation:  CLLocationCoordinate2D?

    func makeUIView(context: Context) -> MKMapView {
        let map = MKMapView()
        map.delegate = context.coordinator
        map.showsUserLocation = true
        map.userTrackingMode = .followWithHeading
        map.mapType = .standard
        map.overrideUserInterfaceStyle = .dark
        map.pointOfInterestFilter = .excludingAll
        map.setRegion(region, animated: false)
        return map
    }

    func updateUIView(_ mapView: MKMapView, context: Context) {
        mapView.removeOverlays(mapView.overlays)
        if routeCoordinates.count > 1 {
            var coords = routeCoordinates
            let polyline = MKPolyline(coordinates: &coords, count: coords.count)
            mapView.addOverlay(polyline)
        }
    }

    func makeCoordinator() -> Coordinator { Coordinator() }

    class Coordinator: NSObject, MKMapViewDelegate {
        func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
            if let polyline = overlay as? MKPolyline {
                let renderer = MKPolylineRenderer(polyline: polyline)
                renderer.strokeColor = UIColor(red: 0.059, green: 0.820, blue: 0.780, alpha: 1.0)
                renderer.lineWidth   = 4
                renderer.lineCap     = .round
                renderer.lineJoin    = .round
                return renderer
            }
            return MKOverlayRenderer(overlay: overlay)
        }
    }
}

// MARK: - TrainingZone shortName extension
extension TrainingZone {
    var shortName: String {
        switch self {
        case .rest:  return "Rest"
        case .z1:    return "Z1"
        case .z2:    return "Z2"
        case .z3:    return "Z3"
        case .z4:    return "Z4"
        case .z5:    return "Z5"
        case .mixed: return "Mix"
        }
    }
}
