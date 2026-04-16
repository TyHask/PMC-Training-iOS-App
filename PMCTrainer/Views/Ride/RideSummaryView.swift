import SwiftUI
import MapKit

// MARK: - Ride Summary View
struct RideSummaryView: View {
    @EnvironmentObject var workoutStore:    WorkoutStore
    @EnvironmentObject var locationManager: LocationManager

    let ride:    CompletedRide
    let workout: DailyWorkout?

    @State private var notes          = ""
    @State private var savedToHistory = false
    @Environment(\.dismiss) var dismiss

    var body: some View {
        ZStack {
            PMCTheme.backgroundGradient.ignoresSafeArea()
            StarScatterView().ignoresSafeArea().allowsHitTesting(false)

            ScrollView(showsIndicators: false) {
                VStack(spacing: 20) {
                    heroHeader
                    statGrid
                    if ride.routeCoordinates.count > 1 { summaryMapCard }
                    if ride.elevationPoints.count > 1  { elevationSummaryCard }
                    if ride.avgHeartRate > 0           { heartRateSummaryCard }
                    if !ride.laps.isEmpty              { lapsCard }
                    notesCard
                    actionButtons
                    Spacer(minLength: 40)
                }
                .padding(.horizontal, 16)
                .padding(.top, 8)
            }
        }
        .navigationTitle("Ride Summary")
        .navigationBarTitleDisplayMode(.inline)
        .navigationBarBackButtonHidden(true)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button("Done") {
                    saveRide()
                    dismiss()
                }
                .fontWeight(.semibold)
                .foregroundColor(PMCTheme.tealAccent)
            }
        }
        .onAppear {
            if !savedToHistory {
                saveRide()
                savedToHistory = true
            }
        }
    }

    // MARK: - Hero Header
    private var heroHeader: some View {
        VStack(spacing: 12) {
            ZStack {
                Circle()
                    .fill(PMCTheme.tealAccent.opacity(0.15))
                    .frame(width: 80, height: 80)
                Image(systemName: "flag.checkered.2.crossed")
                    .font(.system(size: 40))
                    .foregroundColor(PMCTheme.tealAccent)
            }

            Text("Ride Complete!")
                .font(.system(size: 28, weight: .black))
                .foregroundColor(PMCTheme.scriptWhite)

            if let w = workout {
                Text(w.title)
                    .font(.subheadline)
                    .foregroundColor(PMCTheme.lightTeal)
            }

            Text(ride.startTime.formatted(date: .abbreviated, time: .shortened))
                .font(.caption)
                .foregroundColor(PMCTheme.lightTeal.opacity(0.7))

            HStack(spacing: 8) {
                ForEach(0..<5) { _ in
                    Image(systemName: "star.fill")
                        .font(.system(size: 10))
                        .foregroundColor(PMCTheme.patriotRed.opacity(0.6))
                }
            }
        }
        .padding(.vertical, 20)
        .frame(maxWidth: .infinity)
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(PMCTheme.cardGradient)
                .overlay(
                    RoundedRectangle(cornerRadius: 20)
                        .stroke(PMCTheme.tealAccent.opacity(0.3), lineWidth: 1)
                )
        )
    }

    // MARK: - Stat Grid
    private var statGrid: some View {
        LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 12) {
            summaryStatCard(icon: "road.lanes",       value: ride.formattedDistance,    label: "Total Distance", color: PMCTheme.tealAccent)
            summaryStatCard(icon: "clock.fill",       value: ride.formattedMovingTime,  label: "Moving Time",    color: PMCTheme.lightTeal)
            summaryStatCard(icon: "speedometer",      value: ride.formattedAvgSpeed,    label: "Avg Speed",      color: PMCTheme.tealAccent)
            summaryStatCard(icon: "arrow.up.right",   value: String(format: "%.1f mph", ride.maxSpeed), label: "Max Speed", color: PMCTheme.patriotRed)
            summaryStatCard(icon: "mountain.2.fill",  value: ride.formattedElevation,   label: "Elevation Gain", color: PMCTheme.tealAccent)
            summaryStatCard(
                icon: "heart.fill",
                value: ride.avgHeartRate > 0 ? String(format: "%.0f bpm", ride.avgHeartRate) : "--",
                label: "Avg Heart Rate",
                color: PMCTheme.patriotRed
            )
        }
    }

    private func summaryStatCard(icon: String, value: String, label: String, color: Color) -> some View {
        VStack(spacing: 8) {
            Image(systemName: icon)
                .font(.system(size: 22))
                .foregroundColor(color)
            Text(value)
                .font(.system(size: 22, weight: .bold, design: .rounded))
                .foregroundColor(PMCTheme.scriptWhite)
            Text(label)
                .font(.caption2)
                .foregroundColor(PMCTheme.lightTeal)
                .textCase(.uppercase)
                .tracking(0.8)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 16)
        .background(
            RoundedRectangle(cornerRadius: 14)
                .fill(PMCTheme.cardGradient)
                .overlay(
                    RoundedRectangle(cornerRadius: 14)
                        .stroke(color.opacity(0.2), lineWidth: 1)
                )
        )
    }

    // MARK: - Route Map Card
    private var summaryMapCard: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack(spacing: 6) {
                Image(systemName: "map.fill")
                    .font(.system(size: 12))
                    .foregroundColor(PMCTheme.tealAccent)
                Text("Your Route")
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundColor(PMCTheme.lightTeal)
                    .textCase(.uppercase)
                    .tracking(0.8)
            }
            SummaryMapView(coordinates: ride.routeCoordinates)
                .frame(height: 200)
                .cornerRadius(12)
        }
        .padding(14)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(PMCTheme.cardGradient)
                .overlay(RoundedRectangle(cornerRadius: 16).stroke(PMCTheme.tealAccent.opacity(0.2), lineWidth: 1))
        )
    }

    // MARK: - Elevation Summary Card
    private var elevationSummaryCard: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack(spacing: 6) {
                Image(systemName: "mountain.2.fill")
                    .font(.system(size: 12))
                    .foregroundColor(PMCTheme.tealAccent)
                Text("Elevation Profile")
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundColor(PMCTheme.lightTeal)
                    .textCase(.uppercase)
                    .tracking(0.8)
                Spacer()
                Text(ride.formattedElevation + " gain")
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundColor(PMCTheme.tealAccent)
            }
            ElevationTrackerView(points: ride.elevationPoints)
                .frame(height: 100)
        }
        .padding(14)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(PMCTheme.cardGradient)
                .overlay(RoundedRectangle(cornerRadius: 16).stroke(PMCTheme.tealAccent.opacity(0.2), lineWidth: 1))
        )
    }

    // MARK: - Heart Rate Summary Card
    // Shows avg and max HR recorded from HealthKit during the ride
    private var heartRateSummaryCard: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(spacing: 6) {
                Image(systemName: "heart.fill")
                    .font(.system(size: 12))
                    .foregroundColor(PMCTheme.patriotRed)
                Text("Heart Rate")
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundColor(PMCTheme.lightTeal)
                    .textCase(.uppercase)
                    .tracking(0.8)
            }

            HStack(spacing: 0) {
                hrStatCell(value: String(format: "%.0f", ride.avgHeartRate), unit: "bpm", label: "Average")
                Divider().frame(height: 44).background(PMCTheme.tealAccent.opacity(0.3))
                hrStatCell(value: String(format: "%.0f", ride.maxHeartRate), unit: "bpm", label: "Maximum", color: PMCTheme.patriotRed)
                Divider().frame(height: 44).background(PMCTheme.tealAccent.opacity(0.3))
                hrStatCell(value: ride.dominantZoneShort, unit: "", label: "Top Zone", color: PMCTheme.tealAccent)
            }
        }
        .padding(14)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(PMCTheme.cardGradient)
                .overlay(RoundedRectangle(cornerRadius: 16).stroke(PMCTheme.patriotRed.opacity(0.2), lineWidth: 1))
        )
    }

    private func hrStatCell(value: String, unit: String, label: String, color: Color = PMCTheme.scriptWhite) -> some View {
        VStack(spacing: 3) {
            HStack(alignment: .lastTextBaseline, spacing: 2) {
                Text(value)
                    .font(.system(size: 22, weight: .bold, design: .rounded))
                    .foregroundColor(color)
                if !unit.isEmpty {
                    Text(unit)
                        .font(.caption2)
                        .foregroundColor(PMCTheme.lightTeal)
                }
            }
            Text(label)
                .font(.caption2)
                .foregroundColor(PMCTheme.lightTeal)
                .textCase(.uppercase)
                .tracking(0.8)
        }
        .frame(maxWidth: .infinity)
    }

    // MARK: - Laps Card
    private var lapsCard: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack(spacing: 6) {
                Image(systemName: "stopwatch.fill")
                    .font(.system(size: 12))
                    .foregroundColor(PMCTheme.patriotRed)
                Text("Interval Laps")
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundColor(PMCTheme.lightTeal)
                    .textCase(.uppercase)
                    .tracking(0.8)
            }

            HStack {
                Text("Lap").frame(width: 40, alignment: .leading)
                Text("Time").frame(maxWidth: .infinity, alignment: .leading)
                Text("Dist").frame(width: 60, alignment: .trailing)
                Text("Avg Spd").frame(width: 70, alignment: .trailing)
            }
            .font(.system(size: 10, weight: .semibold))
            .foregroundColor(PMCTheme.lightTeal)
            .textCase(.uppercase)
            .tracking(0.5)
            .padding(.horizontal, 8)

            TealDivider()

            ForEach(ride.laps) { lap in
                HStack {
                    Text("\(lap.lapNumber)")
                        .font(.system(size: 13, weight: .bold))
                        .foregroundColor(PMCTheme.tealAccent)
                        .frame(width: 40, alignment: .leading)
                    Text(lap.formattedDuration)
                        .font(.system(size: 13, design: .monospaced))
                        .foregroundColor(PMCTheme.scriptWhite)
                        .frame(maxWidth: .infinity, alignment: .leading)
                    Text(String(format: "%.2f mi", lap.distance))
                        .font(.system(size: 12))
                        .foregroundColor(PMCTheme.lightTeal)
                        .frame(width: 60, alignment: .trailing)
                    Text(String(format: "%.1f mph", lap.avgSpeed))
                        .font(.system(size: 12))
                        .foregroundColor(PMCTheme.lightTeal)
                        .frame(width: 70, alignment: .trailing)
                }
                .padding(.horizontal, 8)
                .padding(.vertical, 4)
            }
        }
        .padding(14)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(PMCTheme.cardGradient)
                .overlay(RoundedRectangle(cornerRadius: 16).stroke(PMCTheme.tealAccent.opacity(0.2), lineWidth: 1))
        )
    }

    // MARK: - Notes Card
    private var notesCard: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack(spacing: 6) {
                Image(systemName: "note.text")
                    .font(.system(size: 12))
                    .foregroundColor(PMCTheme.tealAccent)
                Text("Ride Notes")
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundColor(PMCTheme.lightTeal)
                    .textCase(.uppercase)
                    .tracking(0.8)
            }
            TextEditor(text: $notes)
                .frame(height: 80)
                .foregroundColor(PMCTheme.scriptWhite)
                .scrollContentBackground(.hidden)
                .background(Color.clear)
                .font(.subheadline)
                .overlay(
                    Group {
                        if notes.isEmpty {
                            Text("Add notes about this ride...")
                                .foregroundColor(PMCTheme.lightTeal.opacity(0.5))
                                .font(.subheadline)
                                .padding(.leading, 4)
                                .padding(.top, 8)
                                .allowsHitTesting(false)
                        }
                    }, alignment: .topLeading
                )
        }
        .padding(14)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(PMCTheme.cardGradient)
                .overlay(RoundedRectangle(cornerRadius: 16).stroke(PMCTheme.tealAccent.opacity(0.2), lineWidth: 1))
        )
    }

    // MARK: - Action Buttons
    private var actionButtons: some View {
        Button(action: {
            saveRide()
            dismiss()
        }) {
            HStack(spacing: 10) {
                Image(systemName: "checkmark.circle.fill")
                    .font(.title3)
                Text("Save & Done")
                    .fontWeight(.bold)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 16)
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

    // MARK: - Save Ride
    private func saveRide() {
        if let w = workout {
            workoutStore.markWorkout(id: w.id, status: .completed)
        }
        workoutStore.saveCompletedRide(ride)
    }
}

// MARK: - Summary Map View (static snapshot)
struct SummaryMapView: UIViewRepresentable {
    let coordinates: [CLLocationCoordinate2D]

    func makeUIView(context: Context) -> MKMapView {
        let map = MKMapView()
        map.isScrollEnabled = false
        map.isZoomEnabled = false
        map.isUserInteractionEnabled = false
        map.overrideUserInterfaceStyle = .dark
        map.mapType = .standard
        map.pointOfInterestFilter = .excludingAll
        return map
    }

    func updateUIView(_ mapView: MKMapView, context: Context) {
        mapView.removeOverlays(mapView.overlays)
        guard coordinates.count > 1 else { return }

        var coords = coordinates
        let polyline = MKPolyline(coordinates: &coords, count: coords.count)
        mapView.addOverlay(polyline)

        let region = MKCoordinateRegion(
            center: centerCoordinate,
            span: MKCoordinateSpan(
                latitudeDelta: latSpan * 1.3,
                longitudeDelta: lonSpan * 1.3
            )
        )
        mapView.setRegion(region, animated: false)

        let startAnnotation = MKPointAnnotation()
        startAnnotation.coordinate = coordinates.first!
        startAnnotation.title = "Start"
        let endAnnotation = MKPointAnnotation()
        endAnnotation.coordinate = coordinates.last!
        endAnnotation.title = "Finish"
        mapView.addAnnotations([startAnnotation, endAnnotation])
    }

    func makeCoordinator() -> Coordinator { Coordinator() }

    class Coordinator: NSObject, MKMapViewDelegate {
        func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
            if let polyline = overlay as? MKPolyline {
                let renderer = MKPolylineRenderer(polyline: polyline)
                renderer.strokeColor = UIColor(red: 0.059, green: 0.820, blue: 0.780, alpha: 1.0)
                renderer.lineWidth   = 3
                renderer.lineCap     = .round
                return renderer
            }
            return MKOverlayRenderer(overlay: overlay)
        }
    }

    private var centerCoordinate: CLLocationCoordinate2D {
        let lats = coordinates.map(\.latitude)
        let lons = coordinates.map(\.longitude)
        return CLLocationCoordinate2D(
            latitude:  (lats.min()! + lats.max()!) / 2,
            longitude: (lons.min()! + lons.max()!) / 2
        )
    }
    private var latSpan: Double {
        let lats = coordinates.map(\.latitude)
        return (lats.max()! - lats.min()!) + 0.002
    }
    private var lonSpan: Double {
        let lons = coordinates.map(\.longitude)
        return (lons.max()! - lons.min()!) + 0.002
    }
}
