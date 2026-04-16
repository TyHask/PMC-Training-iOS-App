import SwiftUI
import MediaPlayer

// MARK: - Spotify Controls Overlay
// Uses MPRemoteCommandCenter / MPNowPlayingInfoCenter for system media control
// Works with Spotify, Apple Music, and any audio app playing in background
struct SpotifyControlsOverlay: View {
    @Binding var isVisible: Bool
    @StateObject private var mediaInfo = NowPlayingInfo()

    var body: some View {
        VStack {
            Spacer()

            VStack(spacing: 0) {
                // Drag handle
                RoundedRectangle(cornerRadius: 3)
                    .fill(PMCTheme.lightTeal.opacity(0.4))
                    .frame(width: 40, height: 4)
                    .padding(.top, 10)
                    .padding(.bottom, 14)

                // Header
                HStack {
                    HStack(spacing: 8) {
                        Image(systemName: "music.note")
                            .font(.system(size: 14, weight: .semibold))
                            .foregroundColor(Color(red: 0.12, green: 0.73, blue: 0.33)) // Spotify green
                        Text("Now Playing")
                            .font(.system(size: 14, weight: .semibold))
                            .foregroundColor(PMCTheme.scriptWhite)
                    }
                    Spacer()
                    Button(action: { withAnimation(.spring()) { isVisible = false } }) {
                        Image(systemName: "xmark.circle.fill")
                            .font(.system(size: 20))
                            .foregroundColor(PMCTheme.lightTeal)
                    }
                }
                .padding(.horizontal, 20)

                TealDivider()
                    .padding(.vertical, 12)
                    .padding(.horizontal, 20)

                // Track info
                HStack(spacing: 14) {
                    // Album art placeholder
                    ZStack {
                        RoundedRectangle(cornerRadius: 8)
                            .fill(PMCTheme.deepNavy)
                            .frame(width: 54, height: 54)
                        if let artwork = mediaInfo.artwork {
                            Image(uiImage: artwork)
                                .resizable()
                                .aspectRatio(contentMode: .fill)
                                .frame(width: 54, height: 54)
                                .cornerRadius(8)
                        } else {
                            Image(systemName: "music.note")
                                .font(.system(size: 22))
                                .foregroundColor(PMCTheme.lightTeal)
                        }
                    }

                    VStack(alignment: .leading, spacing: 3) {
                        Text(mediaInfo.title.isEmpty ? "No music playing" : mediaInfo.title)
                            .font(.system(size: 15, weight: .semibold))
                            .foregroundColor(PMCTheme.scriptWhite)
                            .lineLimit(1)
                        Text(mediaInfo.artist.isEmpty ? "Open Spotify to start music" : mediaInfo.artist)
                            .font(.system(size: 12))
                            .foregroundColor(PMCTheme.lightTeal)
                            .lineLimit(1)
                        Text(mediaInfo.album)
                            .font(.system(size: 11))
                            .foregroundColor(PMCTheme.lightTeal.opacity(0.7))
                            .lineLimit(1)
                    }
                    Spacer()
                }
                .padding(.horizontal, 20)

                // Progress bar
                if mediaInfo.duration > 0 {
                    VStack(spacing: 4) {
                        GeometryReader { geo in
                            ZStack(alignment: .leading) {
                                RoundedRectangle(cornerRadius: 2)
                                    .fill(PMCTheme.midNavy)
                                    .frame(height: 3)
                                RoundedRectangle(cornerRadius: 2)
                                    .fill(Color(red: 0.12, green: 0.73, blue: 0.33))
                                    .frame(width: geo.size.width * CGFloat(mediaInfo.progress), height: 3)
                            }
                        }
                        .frame(height: 3)

                        HStack {
                            Text(formatTime(mediaInfo.currentTime))
                                .font(.system(size: 10))
                                .foregroundColor(PMCTheme.lightTeal)
                            Spacer()
                            Text(formatTime(mediaInfo.duration))
                                .font(.system(size: 10))
                                .foregroundColor(PMCTheme.lightTeal)
                        }
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 10)
                }

                // Controls
                HStack(spacing: 36) {
                    // Previous
                    mediaButton(icon: "backward.fill", size: 24) {
                        MPRemoteCommandCenter.shared().previousTrackCommand.isEnabled = true
                        UIApplication.shared.sendAction(#selector(UIResponder.remoteControlReceived(with:)), to: nil, from: nil, for: UIEvent())
                        skipPrevious()
                    }

                    // Play/Pause
                    Button(action: togglePlayPause) {
                        ZStack {
                            Circle()
                                .fill(Color(red: 0.12, green: 0.73, blue: 0.33))
                                .frame(width: 56, height: 56)
                            Image(systemName: mediaInfo.isPlaying ? "pause.fill" : "play.fill")
                                .font(.system(size: 22, weight: .bold))
                                .foregroundColor(.white)
                        }
                    }

                    // Next
                    mediaButton(icon: "forward.fill", size: 24) {
                        skipNext()
                    }
                }
                .padding(.vertical, 16)

                // Volume slider
                HStack(spacing: 10) {
                    Image(systemName: "speaker.fill")
                        .font(.system(size: 12))
                        .foregroundColor(PMCTheme.lightTeal)
                    Slider(value: $mediaInfo.volume, in: 0...1) { _ in
                        MPVolumeView.setVolume(Float(mediaInfo.volume))
                    }
                    .accentColor(Color(red: 0.12, green: 0.73, blue: 0.33))
                    Image(systemName: "speaker.wave.3.fill")
                        .font(.system(size: 12))
                        .foregroundColor(PMCTheme.lightTeal)
                }
                .padding(.horizontal, 24)
                .padding(.bottom, 24)
            }
            .background(
                RoundedRectangle(cornerRadius: 24)
                    .fill(
                        LinearGradient(
                            colors: [PMCTheme.midNavy, PMCTheme.deepNavy],
                            startPoint: .top,
                            endPoint: .bottom
                        )
                    )
                    .overlay(
                        RoundedRectangle(cornerRadius: 24)
                            .stroke(PMCTheme.tealAccent.opacity(0.25), lineWidth: 1)
                    )
            )
        }
        .ignoresSafeArea(edges: .bottom)
        .onAppear { mediaInfo.startUpdating() }
        .onDisappear { mediaInfo.stopUpdating() }
    }

    private func mediaButton(icon: String, size: CGFloat, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            Image(systemName: icon)
                .font(.system(size: size, weight: .semibold))
                .foregroundColor(PMCTheme.scriptWhite)
        }
    }

    private func togglePlayPause() {
        let center = MPRemoteCommandCenter.shared()
        if mediaInfo.isPlaying {
            _ = center.pauseCommand.isEnabled
            UIApplication.shared.sendRemoteControlEvent(.pause)
        } else {
            UIApplication.shared.sendRemoteControlEvent(.play)
        }
        mediaInfo.isPlaying.toggle()
    }

    private func skipNext() {
        UIApplication.shared.sendRemoteControlEvent(.nextTrack)
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) { mediaInfo.refresh() }
    }

    private func skipPrevious() {
        UIApplication.shared.sendRemoteControlEvent(.previousTrack)
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) { mediaInfo.refresh() }
    }

    private func formatTime(_ seconds: Double) -> String {
        let m = Int(seconds) / 60
        let s = Int(seconds) % 60
        return String(format: "%d:%02d", m, s)
    }
}

// MARK: - UIApplication Remote Control Helper
extension UIApplication {
    func sendRemoteControlEvent(_ type: UIEvent.EventSubtype) {
        let event = UIEvent()
        // Use MPRemoteCommandCenter for modern remote control
        switch type {
        case .remoteControlPlay:
            MPRemoteCommandCenter.shared().playCommand.isEnabled = true
        case .remoteControlPause:
            MPRemoteCommandCenter.shared().pauseCommand.isEnabled = true
        case .remoteControlNextTrack:
            MPRemoteCommandCenter.shared().nextTrackCommand.isEnabled = true
        case .remoteControlPreviousTrack:
            MPRemoteCommandCenter.shared().previousTrackCommand.isEnabled = true
        default: break
        }
        _ = event
    }
}

// MARK: - MPVolumeView Helper
extension MPVolumeView {
    static func setVolume(_ volume: Float) {
        let volumeView = MPVolumeView()
        let slider = volumeView.subviews.first(where: { $0 is UISlider }) as? UISlider
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.01) {
            slider?.value = volume
        }
    }
}

// MARK: - Now Playing Info Observer
class NowPlayingInfo: ObservableObject {
    @Published var title: String = ""
    @Published var artist: String = ""
    @Published var album: String = ""
    @Published var artwork: UIImage?
    @Published var isPlaying: Bool = false
    @Published var currentTime: Double = 0
    @Published var duration: Double = 0
    @Published var volume: Double = 0.7

    private var timer: Timer?

    var progress: Double {
        guard duration > 0 else { return 0 }
        return min(currentTime / duration, 1.0)
    }

    func startUpdating() {
        refresh()
        timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] _ in
            self?.refresh()
        }
    }

    func stopUpdating() {
        timer?.invalidate()
        timer = nil
    }

    func refresh() {
        let info = MPNowPlayingInfoCenter.default().nowPlayingInfo
        DispatchQueue.main.async {
            self.title = info?[MPMediaItemPropertyTitle] as? String ?? ""
            self.artist = info?[MPMediaItemPropertyArtist] as? String ?? ""
            self.album = info?[MPMediaItemPropertyAlbumTitle] as? String ?? ""
            self.duration = info?[MPMediaItemPropertyPlaybackDuration] as? Double ?? 0
            self.currentTime = info?[MPNowPlayingInfoPropertyElapsedPlaybackTime] as? Double ?? 0
            self.isPlaying = (info?[MPNowPlayingInfoPropertyPlaybackRate] as? Double ?? 0) > 0

            if let artworkItem = info?[MPMediaItemPropertyArtwork] as? MPMediaItemArtwork {
                self.artwork = artworkItem.image(at: CGSize(width: 54, height: 54))
            }
        }
    }
}

// MARK: - Interval Stopwatch Overlay
struct IntervalStopwatchOverlay: View {
    @Binding var laps: [IntervalLap]
    @Binding var isVisible: Bool
    let onLap: () -> Void

    @State private var isRunning: Bool = false
    @State private var elapsed: TimeInterval = 0
    @State private var timer: Timer?
    @State private var lapStartTime: Date?

    var body: some View {
        VStack {
            Spacer()

            VStack(spacing: 0) {
                // Drag handle
                RoundedRectangle(cornerRadius: 3)
                    .fill(PMCTheme.lightTeal.opacity(0.4))
                    .frame(width: 40, height: 4)
                    .padding(.top, 10)
                    .padding(.bottom, 14)

                // Header
                HStack {
                    HStack(spacing: 8) {
                        Image(systemName: "stopwatch.fill")
                            .font(.system(size: 14))
                            .foregroundColor(PMCTheme.patriotRed)
                        Text("Interval Stopwatch")
                            .font(.system(size: 14, weight: .semibold))
                            .foregroundColor(PMCTheme.scriptWhite)
                    }
                    Spacer()
                    Button(action: { withAnimation(.spring()) { isVisible = false } }) {
                        Image(systemName: "xmark.circle.fill")
                            .font(.system(size: 20))
                            .foregroundColor(PMCTheme.lightTeal)
                    }
                }
                .padding(.horizontal, 20)

                TealDivider()
                    .padding(.vertical, 12)
                    .padding(.horizontal, 20)

                // Timer display
                Text(formatElapsed(elapsed))
                    .font(.system(size: 56, weight: .black, design: .monospaced))
                    .foregroundColor(isRunning ? PMCTheme.tealAccent : PMCTheme.scriptWhite)
                    .shadow(color: isRunning ? PMCTheme.tealAccent.opacity(0.4) : .clear, radius: 8)
                    .padding(.vertical, 8)

                // Current lap time
                if isRunning, let lapStart = lapStartTime {
                    let lapElapsed = Date().timeIntervalSince(lapStart)
                    Text("Lap \(laps.count + 1): \(formatElapsed(lapElapsed))")
                        .font(.system(size: 14, weight: .semibold, design: .monospaced))
                        .foregroundColor(PMCTheme.lightTeal)
                        .padding(.bottom, 4)
                }

                // Controls
                HStack(spacing: 20) {
                    // Reset
                    Button(action: resetTimer) {
                        Text("Reset")
                            .font(.system(size: 15, weight: .semibold))
                            .foregroundColor(PMCTheme.lightTeal)
                            .frame(width: 80, height: 44)
                            .background(PMCTheme.midNavy)
                            .cornerRadius(22)
                            .overlay(RoundedRectangle(cornerRadius: 22).stroke(PMCTheme.tealAccent.opacity(0.3), lineWidth: 1))
                    }

                    // Start / Stop
                    Button(action: toggleTimer) {
                        Text(isRunning ? "Stop" : "Start")
                            .font(.system(size: 17, weight: .bold))
                            .foregroundColor(.white)
                            .frame(width: 100, height: 52)
                            .background(isRunning ? PMCTheme.patriotRed : Color.green)
                            .cornerRadius(26)
                    }

                    // Lap
                    Button(action: recordLap) {
                        Text("Lap")
                            .font(.system(size: 15, weight: .semibold))
                            .foregroundColor(isRunning ? PMCTheme.tealAccent : PMCTheme.lightTeal.opacity(0.5))
                            .frame(width: 80, height: 44)
                            .background(PMCTheme.midNavy)
                            .cornerRadius(22)
                            .overlay(RoundedRectangle(cornerRadius: 22).stroke(
                                isRunning ? PMCTheme.tealAccent.opacity(0.5) : PMCTheme.tealAccent.opacity(0.1),
                                lineWidth: 1
                            ))
                    }
                    .disabled(!isRunning)
                }
                .padding(.vertical, 12)

                // Laps list
                if !laps.isEmpty {
                    TealDivider()
                        .padding(.horizontal, 20)
                        .padding(.vertical, 8)

                    ScrollView {
                        VStack(spacing: 6) {
                            ForEach(laps.reversed()) { lap in
                                lapRow(lap: lap)
                            }
                        }
                        .padding(.horizontal, 20)
                    }
                    .frame(maxHeight: 160)
                }

                Spacer(minLength: 24)
            }
            .background(
                RoundedRectangle(cornerRadius: 24)
                    .fill(
                        LinearGradient(
                            colors: [PMCTheme.midNavy, PMCTheme.deepNavy],
                            startPoint: .top,
                            endPoint: .bottom
                        )
                    )
                    .overlay(
                        RoundedRectangle(cornerRadius: 24)
                            .stroke(PMCTheme.patriotRed.opacity(0.3), lineWidth: 1)
                    )
            )
        }
        .ignoresSafeArea(edges: .bottom)
    }

    private func lapRow(lap: IntervalLap) -> some View {
        HStack {
            Text("Lap \(lap.lapNumber)")
                .font(.system(size: 13, weight: .semibold))
                .foregroundColor(PMCTheme.lightTeal)
            Spacer()
            Text(lap.formattedDuration)
                .font(.system(size: 13, weight: .bold, design: .monospaced))
                .foregroundColor(PMCTheme.tealAccent)
            Text(String(format: "%.2f mi", lap.distance))
                .font(.system(size: 12))
                .foregroundColor(PMCTheme.lightTeal)
                .frame(width: 60, alignment: .trailing)
        }
        .padding(.vertical, 6)
        .padding(.horizontal, 12)
        .background(PMCTheme.deepNavy.opacity(0.5))
        .cornerRadius(8)
    }

    private func toggleTimer() {
        if isRunning {
            timer?.invalidate()
            timer = nil
        } else {
            if lapStartTime == nil { lapStartTime = Date() }
            timer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { _ in
                elapsed += 0.1
            }
        }
        isRunning.toggle()
    }

    private func resetTimer() {
        timer?.invalidate()
        timer = nil
        isRunning = false
        elapsed = 0
        lapStartTime = nil
    }

    private func recordLap() {
        onLap()
        lapStartTime = Date()
    }

    private func formatElapsed(_ t: TimeInterval) -> String {
        let m = Int(t) / 60
        let s = Int(t) % 60
        let cs = Int((t.truncatingRemainder(dividingBy: 1)) * 10)
        return String(format: "%02d:%02d.%d", m, s, cs)
    }
}

// MARK: - Pre-Ride Launch Sheet
struct StartRideSheet: View {
    @EnvironmentObject var locationManager: LocationManager
    @Environment(\.dismiss) var dismiss
    let workout: DailyWorkout?
    let onStart: () -> Void

    var body: some View {
        NavigationView {
            ZStack {
                PMCTheme.backgroundGradient.ignoresSafeArea()
                StarScatterView().ignoresSafeArea().allowsHitTesting(false)

                VStack(spacing: 28) {
                    Spacer()

                    // Icon
                    ZStack {
                        Circle()
                            .fill(PMCTheme.tealAccent.opacity(0.15))
                            .frame(width: 100, height: 100)
                        Image(systemName: "figure.outdoor.cycle")
                            .font(.system(size: 50))
                            .foregroundColor(PMCTheme.tealAccent)
                    }

                    // Title
                    VStack(spacing: 6) {
                        Text("Ready to Ride?")
                            .font(.system(size: 28, weight: .black))
                            .foregroundColor(PMCTheme.scriptWhite)
                        if let w = workout {
                            Text(w.title)
                                .font(.subheadline)
                                .foregroundColor(PMCTheme.lightTeal)
                        }
                    }

                    // Checklist
                    VStack(spacing: 10) {
                        checkRow(icon: "location.fill", text: "GPS will track your route and speed", color: PMCTheme.tealAccent)
                        checkRow(icon: "heart.fill", text: "Live HR zone from Apple Health", color: PMCTheme.patriotRed)
                        checkRow(icon: "music.note", text: "Spotify controls available during ride", color: Color(red: 0.12, green: 0.73, blue: 0.33))
                        checkRow(icon: "mountain.2.fill", text: "Live elevation profile tracked", color: PMCTheme.tealAccent)
                    }
                    .padding(.horizontal, 24)

                    // Location permission check
                    if locationManager.authorizationStatus == .notDetermined {
                        Button(action: { locationManager.requestPermission() }) {
                            Label("Allow Location Access", systemImage: "location.fill")
                                .font(.headline)
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 14)
                                .background(PMCTheme.midNavy)
                                .cornerRadius(14)
                                .overlay(RoundedRectangle(cornerRadius: 14).stroke(PMCTheme.tealAccent.opacity(0.4), lineWidth: 1))
                        }
                        .padding(.horizontal, 24)
                    } else if locationManager.authorizationStatus == .denied {
                        VStack(spacing: 8) {
                            Text("Location access is required for GPS tracking.")
                                .font(.caption)
                                .foregroundColor(PMCTheme.patriotRed)
                                .multilineTextAlignment(.center)
                            Button("Open Settings") {
                                if let url = URL(string: UIApplication.openSettingsURLString) {
                                    UIApplication.shared.open(url)
                                }
                            }
                            .font(.caption)
                            .foregroundColor(PMCTheme.tealAccent)
                        }
                        .padding(.horizontal, 24)
                    }

                    Spacer()

                    // Start button
                    Button(action: {
                        locationManager.startRide()
                        onStart()
                        dismiss()
                    }) {
                        HStack(spacing: 10) {
                            Image(systemName: "play.fill")
                            Text("Start Ride")
                                .fontWeight(.bold)
                        }
                        .font(.title3)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 18)
                        .background(
                            LinearGradient(
                                colors: [PMCTheme.tealAccent, Color(red: 0.059, green: 0.600, blue: 0.700)],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .cornerRadius(16)
                        .shadow(color: PMCTheme.tealAccent.opacity(0.4), radius: 12, x: 0, y: 4)
                    }
                    .padding(.horizontal, 24)
                    .padding(.bottom, 32)
                    .disabled(locationManager.authorizationStatus == .denied)
                }
            }
            .navigationTitle("Start Ride")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") { dismiss() }
                        .foregroundColor(PMCTheme.tealAccent)
                }
            }
        }
    }

    private func checkRow(icon: String, text: String, color: Color) -> some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .font(.system(size: 16))
                .foregroundColor(color)
                .frame(width: 24)
            Text(text)
                .font(.subheadline)
                .foregroundColor(PMCTheme.scriptWhite)
            Spacer()
        }
    }
}
