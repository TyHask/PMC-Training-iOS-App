# PMC Trainer — Setup Guide

Follow these steps to get the app running in Xcode.

---

## Step 1: Open the Project

1. Download or clone the `PMCTrainer` folder
2. Open **Xcode 15** or later
3. Go to **File → Open** and select `PMCTrainer.xcodeproj`

---

## Step 2: Set Your Development Team

1. In the Project Navigator, click **PMCTrainer** (the project, not the target)
2. Select the **PMCTrainer** target
3. Under **Signing & Capabilities**, set your **Team** to your Apple Developer account
4. Xcode will automatically manage provisioning profiles

---

## Step 3: Configure Strava API

### Get Your Credentials
1. Visit [https://www.strava.com/settings/api](https://www.strava.com/settings/api)
2. Click **Create & Manage Your App**
3. Fill in:
   - **Application Name:** PMC Trainer
   - **Category:** Training
   - **Club:** (leave blank)
   - **Website:** (your website or `https://pmc.org`)
   - **Authorization Callback Domain:** `pmctrainer`
4. Save and note your **Client ID** and **Client Secret**

### Add to the App
Open `PMCTrainer/Services/StravaService.swift` and replace:
```swift
private let clientID = "YOUR_STRAVA_CLIENT_ID"
private let clientSecret = "YOUR_STRAVA_CLIENT_SECRET"
```
with your actual values.

---

## Step 4: Configure WHOOP API

### Get Your Credentials
1. Visit [https://developer.whoop.com](https://developer.whoop.com)
2. Sign in with your WHOOP account
3. Create a new application:
   - **Redirect URI:** `pmctrainer://whoop-callback`
   - **Scopes:** `read:recovery`, `read:strain`, `read:body_measurement`, `offline`
4. Note your **Client ID** and **Client Secret**

### Add to the App
Open `PMCTrainer/Services/WhoopService.swift` and replace:
```swift
private let clientID = "YOUR_WHOOP_CLIENT_ID"
private let clientSecret = "YOUR_WHOOP_CLIENT_SECRET"
```
with your actual values.

> **Note:** WHOOP integration is optional. If you don't have a WHOOP device, the recovery card simply won't appear on the home screen until you connect.

---

## Step 5: Build and Run

1. Select your target device (iPhone running iOS 17+) or a simulator
2. Press **⌘R** to build and run
3. The app will launch with the Today tab showing the current week's workout

---

## Step 6: Enable Notifications (In-App)

1. Open the app and go to the **Settings** tab
2. Toggle on **Morning Workout Reminders**
3. Accept the system permission prompt
4. You'll receive a 7:00 AM notification on every workout day

---

## Step 7: Connect Strava (In-App)

1. Go to **Settings → Strava → Connect**
2. You'll be redirected to Strava's authorization page in Safari
3. Authorize PMC Trainer
4. Safari will redirect back to the app automatically via the `pmctrainer://` URL scheme
5. After any completed workout, tap **Log to Strava** in the workout detail view

---

## Step 8: Connect WHOOP (In-App)

1. Go to **Settings → WHOOP → Connect**
2. You'll be redirected to WHOOP's authorization page
3. Authorize PMC Trainer
4. Your recovery score and yesterday's strain will appear on the Today screen

---

## Troubleshooting

### OAuth Redirect Not Working
- Ensure the URL scheme `pmctrainer` is registered in `Info.plist` (it is by default)
- In Strava, the **Authorization Callback Domain** must be exactly `pmctrainer` (no `://`)
- In WHOOP, the **Redirect URI** must be exactly `pmctrainer://whoop-callback`

### Notifications Not Appearing
- Check **Settings → Notifications → PMC Trainer** on your device
- Make sure notifications are allowed
- The app only schedules notifications for future workout days

### Build Errors
- Ensure you're using Xcode 15+ with iOS 17 SDK
- Clean build folder: **Product → Clean Build Folder (⇧⌘K)**

---

## File Structure Reference

| File | Purpose |
|------|---------|
| `App/PMCTrainerApp.swift` | App entry, environment objects, URL handling |
| `Models/TrainingModels.swift` | All data types |
| `Models/WorkoutStore.swift` | State + UserDefaults persistence |
| `Models/TrainingPlanData.swift` | All 16 weeks of workout data |
| `Views/Today/TodayView.swift` | Home screen |
| `Views/Plan/PlanView.swift` | Calendar view |
| `Views/Progress/ProgressView.swift` | Progress tracking |
| `Views/Settings/SettingsView.swift` | Settings hub |
| `Views/Settings/ZoneCalculatorView.swift` | HR zone calculator |
| `Services/StravaService.swift` | Strava OAuth2 + logging |
| `Services/WhoopService.swift` | WHOOP OAuth2 + data |
| `Services/NotificationManager.swift` | Local notifications |

---

*Good luck at the PMC 2026! Ride for those who can't.* 🚴🏻
