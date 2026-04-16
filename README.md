# PMC Trainer 🚴 🇺🇸

**Pan-Mass Challenge 2026 Training App — America 250th Anniversary Edition**

A native iOS SwiftUI app built for serious PMC riders. 15-week structured training plan, GPS ride tracking, live heart rate zones via Apple Health, and a full-screen ride computer — all themed to match the 2026 PMC jersey's deep patriotic blue-to-teal gradient, bold red collar, and scattered stars.

---

## Design Language — America 250

The app mirrors the official 2026 PMC jersey:

| Token | Color | Usage |
|---|---|---|
| `deepNavy` | `#0A1E4F` | App background |
| `midNavy` | `#14386B` | Card backgrounds |
| `starBlue` | `#12306B` | Top gradient layer |
| `tealAccent` | `#0FD1C7` | Primary accent, jersey stars |
| `lightTeal` | `#4AA8AD` | Secondary text |
| `patriotRed` | `#E21828` | Collar red, finish/danger actions |
| `scriptWhite` | `#FAFAFA` | Bold display text |
| `goldStar` | `#FFC833` | Star decorations |

Scattered star motifs, the deep navy-to-teal background gradient, and bold red collar accent are woven throughout every screen.

---

## Features

### Training Plan
- Complete 15-week PMC 2026 training plan (April 27 → August 1) plus Race Week
- All workouts with zone, description, estimated duration and distance
- Recovery weeks, peak weeks, and taper weeks clearly labeled
- Tap any day for full workout detail with zone reference

### Today Tab
- Race countdown to PMC 2026 (August 1–2)
- Today's workout card with zone badge and one-tap start
- Live heart rate summary card (via Apple Health)
- Weekly mini-progress grid
- **Start Ride** button launches GPS tracking for today's workout

### Plan Tab
- Full 16-week calendar with week cards
- Tap a week → day list with all workouts
- Tap a workout → full detail sheet with zone guide and status controls
- Start GPS ride from any workout in the plan

### GPS Live Ride View
The full-screen ride computer activates when you tap **Start Ride**:

**Top 1/3 — Hero Metrics (always visible)**
- **Center**: Current speed in giant MPH display with elapsed timer
- **Left**: Live heart rate zone ring (Z1–Z5) with bpm — reads from Apple Health in real time via Bluetooth (no internet needed)
- **Right**: Live elevation gain arc with total feet climbed

**Middle — Map + Live Stats**
- Live GPS route map with teal polyline showing path ridden
- Follow/lock toggle button
- Live stats row: Distance · Avg Speed · Avg HR · Elev Gain

**Elevation Tracker**
- Live scrolling elevation profile graph
- Teal fill with gradient showing hills as you climb them
- Min/max elevation labels, current elevation, total gain

**Controls**
- **Music** — System media controls overlay (album art, skip, play/pause, volume) — works with Spotify, Apple Music, or any app playing in the background
- **Pause/Resume** — GPS pauses and resumes cleanly
- **Intervals** — Stopwatch overlay with lap recording for interval workouts
- **Finish** — Confirmation alert → Ride Summary

### Ride Summary
After finishing, you get a full summary screen:
- Total distance, moving time, avg speed, max speed, elevation gain
- Heart rate summary: avg bpm, max bpm, dominant training zone
- Route map snapshot
- Elevation profile
- Interval laps table (if recorded)
- Notes field
- Ride saved to history automatically

### Progress Tab
- Current week progress card with day grid
- All-weeks breakdown with completion bars
- Ride history list with distance, time, and elevation
- Completion heatmap

### Settings Tab
- **Zone Calculator** — Enter max HR → instant Z1–Z5 bpm ranges
- **Apple Health** — Authorize live heart rate access
- **Notifications** — Enable/disable 7:00 AM workout reminders

---

## Architecture

```
PMCTrainer/
├── App/
│   └── PMCTrainerApp.swift          # Entry point, RootNavigationView
├── Models/
│   ├── TrainingModels.swift         # DailyWorkout, TrainingWeek, TrainingZone, etc.
│   ├── TrainingPlanData.swift       # All 15 weeks + race week workout data
│   ├── RideSession.swift            # CompletedRide, ElevationPoint, IntervalLap
│   └── WorkoutStore.swift           # @StateObject persistence layer
├── Services/
│   ├── LocationManager.swift        # CLLocationManager, GPS tracking, ride state machine
│   ├── HealthKitManager.swift       # Live HR streaming from Apple Health (HKAnchoredObjectQuery)
│   └── NotificationManager.swift   # Local push notifications (7am reminders)
├── Utils/
│   └── PMCTheme.swift               # Design tokens, gradients, StarScatterView, TealDivider
├── Views/
│   ├── ContentView.swift            # TabView (Today · Plan · Progress · Settings)
│   ├── SharedComponents.swift       # ZoneBadge, SectionHeader, CardContainer
│   ├── Today/
│   │   ├── TodayView.swift          # Home screen
│   │   └── WorkoutDetailView.swift  # Workout detail sheet
│   ├── Plan/
│   │   └── PlanView.swift           # Full 16-week calendar
│   ├── Ride/
│   │   ├── LiveRideView.swift       # Full-screen GPS ride computer
│   │   ├── ElevationTrackerView.swift # Live elevation graph
│   │   ├── RideOverlays.swift       # Music controls, interval stopwatch, StartRideSheet
│   │   └── RideSummaryView.swift    # Post-ride summary + save
│   ├── Progress/
│   │   └── ProgressView.swift       # Weekly progress + ride history
│   └── Settings/
│       ├── SettingsView.swift       # Settings hub
│       └── ZoneCalculatorView.swift # HR zone calculator
└── Resources/
    ├── Colors.xcassets/             # America 250 color palette
    └── Info.plist                   # Permissions
```

---

## Setup

### Requirements
- Xcode 15.0+
- iOS 17.0+ deployment target
- Physical iPhone for GPS and heart rate testing (simulator has no GPS or live HR)

### Quick Start

1. **Open** `PMCTrainer.xcodeproj` in Xcode
2. Set your **Team** in Signing & Capabilities
3. Enable the **HealthKit** capability (Signing & Capabilities → + Capability → HealthKit)
4. Build & run on your iPhone

### Live Heart Rate Setup
The app reads live heart rate from **Apple Health** — no API key or account needed.

To enable live HR from your wearable:
- **WHOOP**: In the WHOOP app → Settings → Health → toggle **Heart Rate** on
- **Apple Watch**: Automatically writes HR to Health during workouts
- **Garmin / other**: Enable Apple Health sync in your device's companion app

Heart rate is streamed via Bluetooth from your wearable to your iPhone and into Apple Health. The app reads it every ~5 seconds using `HKAnchoredObjectQuery` — **no internet connection required during rides.**

### Music Controls
The music overlay uses iOS `MediaPlayer` framework — it controls whatever is playing system-wide (Spotify, Apple Music, etc.). No additional setup needed. Start your music before tapping Start Ride.

### Required Permissions (already in Info.plist)
- `NSHealthShareUsageDescription` — Live heart rate from Apple Health
- `NSHealthUpdateUsageDescription` — Write workout summaries to Health
- `NSLocationWhenInUseUsageDescription` — GPS tracking
- `NSLocationAlwaysAndWhenInUseUsageDescription` — Background GPS

---

## Training Zones

| Zone | Name | RPE | Description |
|---|---|---|---|
| Z1 | Recovery | < 5 | Very easy, active recovery |
| Z2 | Aerobic Endurance | 5–7 | Conversational pace |
| Z3 | Tempo | 7–8 | Conversation is difficult |
| Z4 | Lactate Threshold | 8–9 | Legs and lungs burning |
| Z5 | Anaerobic | 10 | Maximum effort, short intervals |

---

## Race Details

- **Day 1 (Aug 1):** Worcester → Bourne, ~84 miles
- **Day 2 (Aug 2):** Bourne → Wellesley, ~40 miles
- **Opening Ceremonies:** July 31, Worcester

---

*Ride for those who can't. See you at the PMC 2026!* 🚴 🇺🇸
