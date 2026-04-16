# PMC Trainer 🚴 🇺🇸

**Pan-Mass Challenge 2026 Training App — America 250th Anniversary Edition**

A native iOS SwiftUI app built for serious PMC riders. 15-week structured training plan, GPS ride tracking, WHOOP integration, Strava logging, and a live ride computer — all themed to match the 2026 PMC jersey's deep patriotic blue-to-teal gradient, bold red collar, and scattered stars.

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
- WHOOP recovery ring and strain display
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
- **Left**: Live WHOOP heart rate zone ring (Z1–Z5) with bpm
- **Right**: Live WHOOP strain arc (0–21) with label

**Middle — Map + Live Stats**
- Live GPS route map with teal polyline showing path ridden
- Follow/lock toggle button
- Live stats row: Distance · Avg Speed · Avg HR · Strain

**Elevation Tracker**
- Live scrolling elevation profile graph
- Teal fill with gradient showing hills as you climb them
- Min/max elevation labels, current elevation, total gain

**Controls**
- **Music** — System media controls overlay (album art, skip, play/pause, volume) — works with Spotify, Apple Music, etc.
- **Pause/Resume** — GPS pauses and resumes cleanly
- **Intervals** — Stopwatch overlay with lap recording for interval workouts
- **Finish** — Confirmation alert → Ride Summary

### Ride Summary
After finishing, you get a full summary screen:
- Total distance, moving time, avg speed, max speed, elevation gain, avg HR
- Route map snapshot
- Elevation profile
- WHOOP strain before/after/increase
- Interval laps table (if recorded)
- Notes field
- One-tap Strava log button (pre-fills name, type, zone, notes)
- Ride saved to history automatically

### Progress Tab
- Current week progress card with day grid
- All-weeks breakdown with completion bars
- Ride history list with distance, time, and elevation
- Completion heatmap

### Settings Tab
- **Zone Calculator** — Enter max HR → instant Z1–Z5 bpm ranges
- **Strava** — OAuth2 connect/disconnect
- **WHOOP** — OAuth2 connect/disconnect
- **Notifications** — Enable/disable 7:00 AM workout reminders

---

## Architecture

```
PMCTrainer/
├── App/
│   └── PMCTrainerApp.swift          # Entry point, OAuth URL handling, RootNavigationView
├── Models/
│   ├── TrainingModels.swift         # DailyWorkout, TrainingWeek, TrainingZone, etc.
│   ├── TrainingPlanData.swift       # All 15 weeks + race week workout data
│   ├── RideSession.swift            # CompletedRide, ElevationPoint, IntervalLap
│   └── WorkoutStore.swift           # @StateObject persistence layer
├── Services/
│   ├── LocationManager.swift        # CLLocationManager, GPS tracking, ride state machine
│   ├── StravaService.swift          # OAuth2, activity logging, StravaAuthView, StravaLogView
│   ├── WhoopService.swift           # OAuth2, recovery/strain fetch, WhoopAuthView
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
│   │   ├── RideOverlays.swift       # Spotify controls, interval stopwatch, StartRideSheet
│   │   └── RideSummaryView.swift    # Post-ride summary + save
│   ├── Progress/
│   │   └── ProgressView.swift       # Weekly progress + ride history
│   └── Settings/
│       ├── SettingsView.swift       # Settings hub
│       └── ZoneCalculatorView.swift # HR zone calculator
└── Resources/
    ├── Colors.xcassets/             # America 250 color palette
    └── Info.plist                   # URL schemes, permissions
```

---

## Setup

### Requirements
- Xcode 15.0+
- iOS 17.0+ deployment target
- Physical iPhone for GPS testing (simulator has no GPS)

### Quick Start

1. **Open** `PMCTrainer.xcodeproj` in Xcode
2. Set your **Team** in Signing & Capabilities
3. Add your API credentials (see below)
4. Build & run on device

### Strava API Setup
1. Go to [strava.com/settings/api](https://www.strava.com/settings/api)
2. Create an app, set **Authorization Callback Domain** to `pmctrainer`
3. In `StravaService.swift`, replace:
   ```swift
   private let clientID = "YOUR_STRAVA_CLIENT_ID"
   private let clientSecret = "YOUR_STRAVA_CLIENT_SECRET"
   ```

### WHOOP API Setup
1. Go to [developer.whoop.com](https://developer.whoop.com)
2. Create an app, set redirect URI to `pmctrainer://whoop-callback`
3. In `WhoopService.swift`, replace:
   ```swift
   private let clientID = "YOUR_WHOOP_CLIENT_ID"
   private let clientSecret = "YOUR_WHOOP_CLIENT_SECRET"
   ```

### Music Controls
The music overlay uses iOS `MediaPlayer` framework — it controls whatever is playing system-wide (Spotify, Apple Music, etc.). No additional API key needed. Start music before your ride.

### Required Permissions (already in Info.plist)
- `NSLocationWhenInUseUsageDescription` — GPS tracking
- `NSLocationAlwaysAndWhenInUseUsageDescription` — Background GPS
- URL Schemes: `pmctrainer://strava-callback`, `pmctrainer://whoop-callback`

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
