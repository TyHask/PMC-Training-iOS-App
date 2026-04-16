import Foundation

// MARK: - Training Plan Builder
struct TrainingPlanData {

    static func buildPlan() -> [TrainingWeek] {
        var weeks: [TrainingWeek] = []

        // Week 1: Apr 13
        weeks.append(buildWeek(
            number: 1,
            startDateComponents: (2026, 4, 13),
            title: "Week 1",
            subtitle: "Getting Started",
            isRecovery: false, isPeak: false, isTaper: false, isRace: false,
            days: [
                (0, .rest, .rest, "Rest", "Full rest day. Let your body prepare for the weeks ahead.", "", ""),
                (1, .easySpin, .z2, "Easy Spin", "Easy spin 45–60 min. Get comfortable on the bike, find your fit, and enjoy the ride.", "45–60 min", ""),
                (2, .rest, .rest, "Rest", "Full rest day.", "", ""),
                (3, .easySpin, .z2, "Easy Spin — Skills", "Easy spin 45–60 min. Practice clipping in and out, and grabbing your water bottle while riding.", "45–60 min", ""),
                (4, .rest, .rest, "Rest", "Full rest day.", "", ""),
                (5, .longRide, .z2, "Long Ride — 20 mi Z2", "20-mile easy Z2 ride. Focus on smooth pedaling and staying in the aerobic zone.", "~1.5 hr", "20 mi"),
                (6, .yoga, .rest, "Rest or Yoga", "Rest or gentle yoga/stretching to aid recovery.", "Optional", "")
            ]
        ))

        // Week 2: Apr 20
        weeks.append(buildWeek(
            number: 2,
            startDateComponents: (2026, 4, 20),
            title: "Week 2",
            subtitle: "Building the Base",
            isRecovery: false, isPeak: false, isTaper: false, isRace: false,
            days: [
                (0, .rest, .rest, "Rest", "Full rest day.", "", ""),
                (1, .easySpin, .z2, "Easy Spin — Drills", "Easy spin 1 hr with drills: one-legged pedaling and hand signals. Focus on smooth pedal stroke.", "1 hr", ""),
                (2, .crossTraining, .rest, "Rest or Cross-Training", "Rest or easy cross-training (swimming, walking, yoga).", "Optional", ""),
                (3, .foundationRide, .z2, "Foundation Ride — 20 mi", "Foundation ride 20 mi Z2. Focus on maintaining 90 rpm cadence throughout.", "~1.5 hr", "20 mi"),
                (4, .rest, .rest, "Rest", "Full rest day.", "", ""),
                (5, .longRide, .z2, "Long Ride — 30 mi Z2", "30-mile Z2 ride. Keep it conversational and build your aerobic base.", "~2 hr", "30 mi"),
                (6, .crossTraining, .rest, "Rest or Cross-Training", "Rest or easy cross-training.", "Optional", "")
            ]
        ))

        // Week 3: Apr 27
        weeks.append(buildWeek(
            number: 3,
            startDateComponents: (2026, 4, 27),
            title: "Week 3",
            subtitle: "First Tempo Work",
            isRecovery: false, isPeak: false, isTaper: false, isRace: false,
            days: [
                (0, .rest, .rest, "Rest", "Full rest day.", "", ""),
                (1, .tempoRide, .mixed, "Tempo Ride", "15 min warmup → 2×10 min Z3 (5 min Z2 recovery between) → 10 min warmdown. First tempo work of the plan.", "~1 hr", ""),
                (2, .foundationRide, .z2, "Foundation Ride — 20 mi", "Foundation ride 20 mi Z2. Steady aerobic effort.", "~1.5 hr", "20 mi"),
                (3, .crossTraining, .rest, "Rest or Cross-Training", "Rest or easy cross-training.", "Optional", ""),
                (4, .rest, .rest, "Rest", "Full rest day.", "", ""),
                (5, .longRide, .z2, "Long Ride — 35 mi Z2", "35-mile Z2 ride. Stay patient and consistent.", "~2.5 hr", "35 mi"),
                (6, .easySpin, .z2, "Easy Spin or Rest", "Easy spin 1 hr or full rest.", "1 hr / Rest", "")
            ]
        ))

        // Week 4: May 4 — Recovery Week
        weeks.append(buildWeek(
            number: 4,
            startDateComponents: (2026, 5, 4),
            title: "Week 4",
            subtitle: "Recovery Week",
            isRecovery: true, isPeak: false, isTaper: false, isRace: false,
            days: [
                (0, .rest, .rest, "Rest", "Full rest day.", "", ""),
                (1, .foundationRide, .mixed, "Foundation Ride + Z3", "Foundation ride 1 hr total with 1×10 min Z3 embedded. Keep it controlled.", "1 hr", ""),
                (2, .easySpin, .z2, "Easy Spin", "Easy spin 30–45 min. Flush the legs.", "30–45 min", ""),
                (3, .crossTraining, .rest, "Rest or Cross-Training", "Rest or easy cross-training.", "Optional", ""),
                (4, .rest, .rest, "Rest", "Full rest day.", "", ""),
                (5, .longRide, .z2, "Long Ride — 25 mi Z2", "25-mile Z2 ride. Reduced volume for recovery.", "~1.5 hr", "25 mi"),
                (6, .rest, .rest, "Rest", "Full rest day.", "", "")
            ]
        ))

        // Week 5: May 11
        weeks.append(buildWeek(
            number: 5,
            startDateComponents: (2026, 5, 11),
            title: "Week 5",
            subtitle: "Building Tempo",
            isRecovery: false, isPeak: false, isTaper: false, isRace: false,
            days: [
                (0, .rest, .rest, "Rest", "Full rest day.", "", ""),
                (1, .tempoRide, .mixed, "Tempo Ride", "15 min warmup → 2×15 min Z3 (5 min recoveries) → 10 min warmdown. Longer Z3 intervals.", "~1.25 hr", ""),
                (2, .foundationRide, .z2, "Foundation Ride — 25 mi", "Foundation ride 25 mi Z2.", "~1.75 hr", "25 mi"),
                (3, .crossTraining, .rest, "Rest or Cross-Training", "Rest or easy cross-training.", "Optional", ""),
                (4, .rest, .rest, "Rest", "Full rest day.", "", ""),
                (5, .longRide, .z2, "Long Ride — 40 mi Z2", "40-mile Z2 ride. Getting into real distance territory.", "~2.75 hr", "40 mi"),
                (6, .easySpin, .z2, "Easy Spin", "Easy spin 1 hr.", "1 hr", "")
            ]
        ))

        // Week 6: May 18
        weeks.append(buildWeek(
            number: 6,
            startDateComponents: (2026, 5, 18),
            title: "Week 6",
            subtitle: "Pushing the Distance",
            isRecovery: false, isPeak: false, isTaper: false, isRace: false,
            days: [
                (0, .rest, .rest, "Rest", "Full rest day.", "", ""),
                (1, .tempoRide, .mixed, "Tempo Ride", "15 min warmup → 2×20 min Z3 (5 min recoveries) → 10 min warmdown. Longest Z3 intervals so far.", "~1.5 hr", ""),
                (2, .foundationRide, .z2, "Foundation Ride — 25 mi", "Foundation ride 25 mi Z2.", "~1.75 hr", "25 mi"),
                (3, .crossTraining, .rest, "Rest or Cross-Training", "Rest or easy cross-training.", "Optional", ""),
                (4, .rest, .rest, "Rest", "Full rest day.", "", ""),
                (5, .longRide, .z2, "Long Ride — 50 mi Z2", "50-mile Z2 ride. Half-century milestone!", "~3.5 hr", "50 mi"),
                (6, .easySpin, .z2, "Easy Spin or Rest", "Easy spin 1 hr or full rest.", "1 hr / Rest", "")
            ]
        ))

        // Week 7: May 25
        weeks.append(buildWeek(
            number: 7,
            startDateComponents: (2026, 5, 25),
            title: "Week 7",
            subtitle: "Hill Work Begins",
            isRecovery: false, isPeak: false, isTaper: false, isRace: false,
            days: [
                (0, .rest, .rest, "Rest", "Full rest day.", "", ""),
                (1, .tempoRide, .mixed, "Tempo Ride — Hills", "15 min warmup → 2×20 min Z3 on hills if possible (5 min recoveries) → 10 min warmdown. Take the hills!", "~1.5 hr", ""),
                (2, .foundationRide, .z2, "Foundation Ride — 25 mi", "Foundation ride 25 mi Z2.", "~1.75 hr", "25 mi"),
                (3, .crossTraining, .rest, "Rest or Cross-Training", "Rest or easy cross-training.", "Optional", ""),
                (4, .rest, .rest, "Rest", "Full rest day.", "", ""),
                (5, .longRide, .z2, "Long Ride — 55 mi Z2", "55-mile Z2 ride. Steady and strong.", "~4 hr", "55 mi"),
                (6, .easySpin, .z2, "Easy Spin or Group Ride", "Easy spin or group ride 1 hr.", "1 hr", "")
            ]
        ))

        // Week 8: Jun 1 — Recovery Week
        weeks.append(buildWeek(
            number: 8,
            startDateComponents: (2026, 6, 1),
            title: "Week 8",
            subtitle: "Recovery Week",
            isRecovery: true, isPeak: false, isTaper: false, isRace: false,
            days: [
                (0, .rest, .rest, "Rest", "Full rest day.", "", ""),
                (1, .foundationRide, .mixed, "Foundation Ride + Z3", "Foundation ride 1–1.5 hr total with 1×15 min Z3 embedded.", "1–1.5 hr", ""),
                (2, .foundationRide, .z2, "Foundation Ride — 25 mi", "Foundation ride 25 mi Z2.", "~1.75 hr", "25 mi"),
                (3, .crossTraining, .rest, "Rest or Cross-Training", "Rest or easy cross-training.", "Optional", ""),
                (4, .rest, .rest, "Rest", "Full rest day.", "", ""),
                (5, .longRide, .z2, "Long Ride — 35 mi Z2", "35-mile Z2 ride. Reduced volume for recovery.", "~2.5 hr", "35 mi"),
                (6, .crossTraining, .rest, "Rest or Cross-Training", "Rest or easy cross-training.", "Optional", "")
            ]
        ))

        // Week 9: Jun 8
        weeks.append(buildWeek(
            number: 9,
            startDateComponents: (2026, 6, 8),
            title: "Week 9",
            subtitle: "Sustained Effort",
            isRecovery: false, isPeak: false, isTaper: false, isRace: false,
            days: [
                (0, .rest, .rest, "Rest", "Full rest day.", "", ""),
                (1, .tempoRide, .mixed, "Tempo Ride — 30 min Z3", "20 min warmup with 6×30 sec one-leg drills → 1×30 min Z3 → 30 min Z2 → 10 min warmdown. Big sustained effort.", "~1.75 hr", ""),
                (2, .foundationRide, .z2, "Foundation Ride — 30 mi", "Foundation ride 30 mi Z2.", "~2 hr", "30 mi"),
                (3, .crossTraining, .rest, "Rest or Cross-Training", "Rest or easy cross-training.", "Optional", ""),
                (4, .rest, .rest, "Rest", "Full rest day.", "", ""),
                (5, .longRide, .z2, "Long Ride — 65 mi Z2", "65-mile Z2 ride. Getting race-distance ready.", "~4.5 hr", "65 mi"),
                (6, .easySpin, .z2, "Easy Spin — Tired Legs", "Easy spin 1 hr on tired legs. This is important training adaptation.", "1 hr", "")
            ]
        ))

        // Week 10: Jun 15
        weeks.append(buildWeek(
            number: 10,
            startDateComponents: (2026, 6, 15),
            title: "Week 10",
            subtitle: "Back-to-Back Simulation",
            isRecovery: false, isPeak: false, isTaper: false, isRace: false,
            days: [
                (0, .rest, .rest, "Rest", "Full rest day.", "", ""),
                (1, .tempoRide, .mixed, "Tempo Ride — 3×20 min Z3", "20 min warmup → 3×20 min Z3 (5 min Z1 recoveries) → 10 min warmdown. High-quality tempo work.", "~2 hr", ""),
                (2, .foundationRide, .z2, "Foundation Ride — 30 mi", "Foundation ride 30 mi Z2.", "~2 hr", "30 mi"),
                (3, .crossTraining, .rest, "Rest or Cross-Training", "Rest or easy cross-training.", "Optional", ""),
                (4, .rest, .rest, "Rest", "Full rest day.", "", ""),
                (5, .longRide, .z2, "Long Ride — 70 mi Z2", "70-mile Z2 ride. Approaching race Day 1 distance.", "~5 hr", "70 mi"),
                (6, .backToBack, .z2, "Back-to-Back — 25 mi Z2", "25-mile Z2 ride on tired legs. First back-to-back simulation!", "~1.75 hr", "25 mi")
            ]
        ))

        // Week 11: Jun 22
        weeks.append(buildWeek(
            number: 11,
            startDateComponents: (2026, 6, 22),
            title: "Week 11",
            subtitle: "Peak Distance",
            isRecovery: false, isPeak: false, isTaper: false, isRace: false,
            days: [
                (0, .rest, .rest, "Rest", "Full rest day.", "", ""),
                (1, .tempoRide, .mixed, "Tempo Ride — 2×30 min Z3", "20 min warmup → 2×30 min Z3 (5 min Z1 recoveries) → 10 min warmdown. Longest tempo intervals of the plan.", "~2 hr", ""),
                (2, .foundationRide, .z2, "Foundation Ride — 30 mi", "Foundation ride 30 mi Z2.", "~2 hr", "30 mi"),
                (3, .crossTraining, .rest, "Rest or Cross-Training", "Rest or easy cross-training.", "Optional", ""),
                (4, .rest, .rest, "Rest", "Full rest day.", "", ""),
                (5, .longRide, .z2, "Long Ride — 80 mi Z2", "80-mile Z2 ride. Biggest day of the plan — you're ready for this!", "~5.5 hr", "80 mi"),
                (6, .backToBack, .z2, "Back-to-Back — 30 mi Z2", "30-mile Z2 ride on tired legs. Back-to-back simulation.", "~2 hr", "30 mi")
            ]
        ))

        // Week 12: Jun 29 — Recovery Week
        weeks.append(buildWeek(
            number: 12,
            startDateComponents: (2026, 6, 29),
            title: "Week 12",
            subtitle: "Recovery Week",
            isRecovery: true, isPeak: false, isTaper: false, isRace: false,
            days: [
                (0, .rest, .rest, "Rest", "Full rest day.", "", ""),
                (1, .foundationRide, .mixed, "Foundation Ride + Z3", "Foundation ride 1–1.5 hr total with 1×15 min Z3 embedded.", "1–1.5 hr", ""),
                (2, .foundationRide, .z2, "Foundation Ride — 25 mi", "Foundation ride 25 mi Z2.", "~1.75 hr", "25 mi"),
                (3, .crossTraining, .rest, "Rest or Cross-Training", "Rest or easy cross-training.", "Optional", ""),
                (4, .rest, .rest, "Rest", "Full rest day.", "", ""),
                (5, .longRide, .z2, "Long Ride — 45 mi Z2", "45-mile Z2 ride. Reduced volume for recovery.", "~3 hr", "45 mi"),
                (6, .crossTraining, .rest, "Rest or Cross-Training", "Rest or easy cross-training.", "Optional", "")
            ]
        ))

        // Week 13: Jul 6
        weeks.append(buildWeek(
            number: 13,
            startDateComponents: (2026, 7, 6),
            title: "Week 13",
            subtitle: "Longest Training Day",
            isRecovery: false, isPeak: false, isTaper: false, isRace: false,
            days: [
                (0, .rest, .rest, "Rest", "Full rest day.", "", ""),
                (1, .climbRide, .mixed, "Tempo Climb Ride", "15 min warmup → 4×10 min Z3 climbs (recover on descent) → 10 min warmdown. Hill-specific training for the PMC course.", "~1.5 hr", ""),
                (2, .foundationRide, .z2, "Foundation Ride — 30 mi", "Foundation ride 30 mi Z2.", "~2 hr", "30 mi"),
                (3, .crossTraining, .rest, "Rest or Cross-Training", "Rest or easy cross-training.", "Optional", ""),
                (4, .rest, .rest, "Rest", "Full rest day.", "", ""),
                (5, .longRide, .z2, "Long Ride — 85 mi Z2", "85-mile Z2 ride. Longest training day of the entire plan. You've earned this!", "~6 hr", "85 mi"),
                (6, .backToBack, .z2, "Back-to-Back — 30–35 mi Z2", "30–35-mile Z2 ride. Back-to-back at race distance ratio.", "~2.25 hr", "30–35 mi")
            ]
        ))

        // Week 14: Jul 13 — Peak Week
        weeks.append(buildWeek(
            number: 14,
            startDateComponents: (2026, 7, 13),
            title: "Week 14",
            subtitle: "Peak Week",
            isRecovery: false, isPeak: true, isTaper: false, isRace: false,
            days: [
                (0, .rest, .rest, "Rest", "Full rest day.", "", ""),
                (1, .thresholdRide, .mixed, "Threshold Ride", "15 min warmup → 3×5 min Z4 (5 min recoveries) → 10–20 min warmdown. First Z4 work — controlled and powerful.", "~1 hr", ""),
                (2, .foundationRide, .mixed, "Foundation Ride + Z3 — 25 mi", "Foundation ride 25 mi with 1×15 min Z3 embedded.", "~1.75 hr", "25 mi"),
                (3, .crossTraining, .rest, "Rest or Cross-Training", "Rest or easy cross-training.", "Optional", ""),
                (4, .rest, .rest, "Rest", "Full rest day.", "", ""),
                (5, .longRide, .z2, "Long Ride — 50 mi Z2", "50-mile Z2 ride. Reduced volume as we enter peak week.", "~3.5 hr", "50 mi"),
                (6, .easySpin, .z2, "Easy Spin — 20 mi Z2", "Easy 20-mile Z2 ride. Legs should feel good.", "~1.5 hr", "20 mi")
            ]
        ))

        // Week 15: Jul 20 — Taper
        weeks.append(buildWeek(
            number: 15,
            startDateComponents: (2026, 7, 20),
            title: "Week 15",
            subtitle: "Taper Week",
            isRecovery: false, isPeak: false, isTaper: true, isRace: false,
            days: [
                (0, .rest, .rest, "Rest", "Full rest day. The hay is in the barn.", "", ""),
                (1, .thresholdRide, .mixed, "Threshold Ride — Short", "15 min warmup → 1×5 min Z4 → 5 min recovery → 20 min Z2 → 10 min warmdown. Keep the legs sharp.", "~55 min", ""),
                (2, .foundationRide, .mixed, "Foundation Ride + Z3 — 15–20 mi", "Foundation ride 15–20 mi with 1×10 min Z3 embedded.", "~1.25 hr", "15–20 mi"),
                (3, .rest, .rest, "Rest", "Full rest day.", "", ""),
                (4, .rest, .rest, "Rest", "Full rest day.", "", ""),
                (5, .tuneUp, .mixed, "Tune-Up Ride", "15 min warmup → 2×5 min build (3 min Z3 into 2 min Z4, 5 min recoveries) → 10 min warmdown. Final sharpener before race week.", "~50 min", ""),
                (6, .rest, .rest, "Rest & Travel Prep", "Rest and prepare for race week. Charge your devices, pack your gear, and get excited!", "", "")
            ]
        ))

        // Race Week: Jul 27
        weeks.append(buildWeek(
            number: 16,
            startDateComponents: (2026, 7, 27),
            title: "Race Week",
            subtitle: "Pan-Mass Challenge 2026",
            isRecovery: false, isPeak: false, isTaper: false, isRace: true,
            days: [
                (0, .rest, .rest, "Rest", "Full rest day. Trust your training.", "", ""),
                (1, .easySpin, .z1, "Easy Spin — 30 min", "Easy spin 30 min. Just keep the legs moving.", "30 min", ""),
                (2, .rest, .rest, "Rest", "Full rest day.", "", ""),
                (3, .rest, .rest, "Rest", "Full rest day.", "", ""),
                (4, .travel, .rest, "Travel to Worcester", "Travel to Worcester. Opening ceremonies. Early bedtime — big day tomorrow!", "", ""),
                (5, .raceDay, .mixed, "RACE DAY 1 — Worcester to Bourne", "Pan-Mass Challenge Day 1! Worcester to Bourne, approximately 84 miles. Ride for those who can't. You've trained for this!", "~6 hr", "~84 mi"),
                (6, .raceDay, .mixed, "RACE DAY 2 — Bourne to Wellesley", "Pan-Mass Challenge Day 2! Bourne to Wellesley, approximately 40 miles. Finish strong — you are a PMC rider!", "~3 hr", "~40 mi")
            ],
            isRaceDayWeek: true
        ))

        return weeks
    }

    // MARK: - Builder Helper

    private static func buildWeek(
        number: Int,
        startDateComponents: (Int, Int, Int),
        title: String,
        subtitle: String,
        isRecovery: Bool,
        isPeak: Bool,
        isTaper: Bool,
        isRace: Bool,
        days: [(Int, WorkoutType, TrainingZone, String, String, String, String)],
        isRaceDayWeek: Bool = false
    ) -> TrainingWeek {
        let cal = Calendar.current
        var comps = DateComponents()
        comps.year = startDateComponents.0
        comps.month = startDateComponents.1
        comps.day = startDateComponents.2
        let startDate = cal.date(from: comps) ?? Date()

        var workouts: [DailyWorkout] = []
        for (dayOffset, type, zone, name, desc, duration, distance) in days {
            let date = cal.date(byAdding: .day, value: dayOffset, to: startDate) ?? startDate
            let isRaceDay = type == .raceDay
            let workout = DailyWorkout(
                id: "w\(number)d\(dayOffset)",
                weekNumber: number,
                dayOfWeek: dayOffset,
                date: date,
                workoutType: type,
                primaryZone: zone,
                title: name,
                description: desc,
                estimatedDuration: duration,
                estimatedDistance: distance,
                isRaceDay: isRaceDay,
                status: .notStarted
            )
            workouts.append(workout)
        }

        return TrainingWeek(
            id: number,
            weekNumber: number,
            startDate: startDate,
            title: title,
            subtitle: subtitle,
            isRecoveryWeek: isRecovery,
            isPeakWeek: isPeak,
            isTaperWeek: isTaper,
            isRaceWeek: isRace,
            workouts: workouts
        )
    }

    // MARK: - Zone Reference Data

    static let zoneReferences: [ZoneReference] = [
        ZoneReference(zone: .z1, name: "Z1 Recovery", rpe: "RPE < 5", description: "Very easy effort. Active recovery. You could hold a full conversation with ease.", heartRatePercent: "< 60% max HR"),
        ZoneReference(zone: .z2, name: "Z2 Aerobic Endurance", rpe: "RPE 5–7", description: "Conversational pace. You can speak in full sentences but are clearly working. The foundation of endurance training.", heartRatePercent: "61–70% max HR"),
        ZoneReference(zone: .z3, name: "Z3 Tempo", rpe: "RPE 7–8", description: "Comfortably hard. Conversation is difficult — short sentences only. Sustainable for 20–60 minutes.", heartRatePercent: "71–80% max HR"),
        ZoneReference(zone: .z4, name: "Z4 Lactate Threshold", rpe: "RPE 8–9", description: "Hard. Legs and lungs are burning. Hard to hold for more than an hour. Race pace for many cyclists.", heartRatePercent: "81–90% max HR"),
        ZoneReference(zone: .z5, name: "Z5 Anaerobic", rpe: "RPE 10", description: "Maximum effort. Short intervals only — 30 seconds to a few minutes. Everything hurts.", heartRatePercent: "91–100% max HR")
    ]
}
