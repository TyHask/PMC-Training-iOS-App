import SwiftUI

struct ZoneCalculatorView: View {
    @AppStorage("maxHeartRate") private var maxHR: Int = 180
    @State private var inputText: String = ""
    @FocusState private var isInputFocused: Bool

    private var zones: HeartRateZones {
        HeartRateZones(maxHR: maxHR)
    }

    var body: some View {
        ZStack {
            PMCTheme.deepNavy
                .ignoresSafeArea()

            ScrollView {
                VStack(spacing: 20) {
                    // Intro
                    introCard

                    // Max HR Input
                    maxHRInputCard

                    // Zone Results
                    if maxHR > 100 {
                        zoneResultsCard
                    }

                    // How to find max HR
                    howToCard

                    Spacer(minLength: 40)
                }
                .padding(.horizontal, 16)
                .padding(.top, 8)
            }
            .onTapGesture {
                isInputFocused = false
            }
        }
        .navigationTitle("Zone Calculator")
        .navigationBarTitleDisplayMode(.large)
        .onAppear {
            inputText = "\(maxHR)"
        }
    }

    // MARK: - Intro Card
    private var introCard: some View {
        CardContainer {
            VStack(alignment: .leading, spacing: 8) {
                SectionHeader(title: "Personalized Heart Rate Zones", icon: "heart.text.square.fill")
                Text("Enter your maximum heart rate to calculate your personalized training zones. Your zones will be used throughout the app to guide your effort levels.")
                    .font(.subheadline)
                    .foregroundColor(PMCTheme.lightTeal)
                    .lineSpacing(3)
            }
        }
    }

    // MARK: - Max HR Input
    private var maxHRInputCard: some View {
        CardContainer {
            VStack(alignment: .leading, spacing: 12) {
                SectionHeader(title: "Maximum Heart Rate", icon: "waveform.path.ecg")
                NavyDivider()

                HStack(spacing: 16) {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Max HR (bpm)")
                            .font(.caption)
                            .foregroundColor(PMCTheme.lightTeal)
                        TextField("e.g. 185", text: $inputText)
                            .keyboardType(.numberPad)
                            .focused($isInputFocused)
                            .font(.system(size: 32, weight: .bold))
                            .foregroundColor(PMCTheme.tealAccent)
                            .frame(width: 120)
                            .onChange(of: inputText) { _, newValue in
                                if let val = Int(newValue), val > 100, val < 250 {
                                    maxHR = val
                                }
                            }
                    }

                    Spacer()

                    VStack(spacing: 8) {
                        Button(action: { adjustHR(by: 1) }) {
                            Image(systemName: "plus.circle.fill")
                                .font(.title2)
                                .foregroundColor(PMCTheme.tealAccent)
                        }
                        Text("\(maxHR)")
                            .font(.headline)
                            .foregroundColor(.white)
                        Button(action: { adjustHR(by: -1) }) {
                            Image(systemName: "minus.circle.fill")
                                .font(.title2)
                                .foregroundColor(PMCTheme.tealAccent)
                        }
                    }
                }

                // 220 - age estimate
                HStack {
                    Image(systemName: "lightbulb.fill")
                        .font(.caption)
                        .foregroundColor(.yellow)
                    Text("Estimate: 220 minus your age. For a 40-year-old, that's 180 bpm.")
                        .font(.caption)
                        .foregroundColor(PMCTheme.lightTeal)
                }
                .padding(.top, 4)
            }
        }
    }

    // MARK: - Zone Results
    private var zoneResultsCard: some View {
        VStack(alignment: .leading, spacing: 8) {
            SectionHeader(title: "Your Heart Rate Zones", icon: "chart.bar.fill")
                .padding(.horizontal, 0)

            ForEach(zones.zones, id: \.zone.rawValue) { item in
                ZStack {
                    RoundedRectangle(cornerRadius: 14)
                        .fill(PMCTheme.midNavy)
                        .overlay(
                            RoundedRectangle(cornerRadius: 14)
                                .stroke(item.zone.color.opacity(0.3), lineWidth: 1)
                        )

                    HStack(spacing: 16) {
                        ZStack {
                            Circle()
                                .fill(item.zone.color.opacity(0.15))
                                .frame(width: 48, height: 48)
                            Text(item.zone.rawValue)
                                .font(.headline)
                                .fontWeight(.bold)
                                .foregroundColor(item.zone.color)
                        }

                        VStack(alignment: .leading, spacing: 3) {
                            Text(item.zone.displayName)
                                .font(.subheadline)
                                .fontWeight(.semibold)
                                .foregroundColor(.white)
                            Text(item.zone.rpeRange)
                                .font(.caption)
                                .foregroundColor(item.zone.color)
                        }

                        Spacer()

                        VStack(alignment: .trailing, spacing: 2) {
                            Text(item.range)
                                .font(.headline)
                                .fontWeight(.bold)
                                .foregroundColor(.white)
                            Text("heart rate")
                                .font(.caption2)
                                .foregroundColor(PMCTheme.lightTeal)
                        }
                    }
                    .padding(14)
                }
            }
        }
    }

    // MARK: - How To Card
    private var howToCard: some View {
        CardContainer {
            VStack(alignment: .leading, spacing: 10) {
                SectionHeader(title: "How to Find Your Max HR", icon: "questionmark.circle.fill")
                NavyDivider()

                VStack(alignment: .leading, spacing: 8) {
                    howToRow(number: "1", text: "Warm up for 10–15 minutes at an easy pace.")
                    howToRow(number: "2", text: "Find a long, steep hill or set your trainer to maximum resistance.")
                    howToRow(number: "3", text: "Ride as hard as you can for 3–5 minutes until you cannot go harder.")
                    howToRow(number: "4", text: "The highest heart rate reading is your max HR.")
                    howToRow(number: "5", text: "Alternatively, use 220 minus your age as an estimate.")
                }
            }
        }
    }

    private func howToRow(number: String, text: String) -> some View {
        HStack(alignment: .top, spacing: 12) {
            ZStack {
                Circle()
                    .fill(PMCTheme.tealAccent.opacity(0.15))
                    .frame(width: 24, height: 24)
                Text(number)
                    .font(.caption)
                    .fontWeight(.bold)
                    .foregroundColor(PMCTheme.tealAccent)
            }
            Text(text)
                .font(.subheadline)
                .foregroundColor(PMCTheme.lightTeal)
                .fixedSize(horizontal: false, vertical: true)
        }
    }

    private func adjustHR(by delta: Int) {
        let newVal = maxHR + delta
        if newVal > 100 && newVal < 250 {
            maxHR = newVal
            inputText = "\(maxHR)"
        }
    }
}
