# BPTracker - Blood Pressure Tracking App

A comprehensive iOS app for logging and understanding your blood pressure readings, built with SwiftUI and SwiftData.

## Features

### Core Functionality
- **Easy Logging**: Quickly record blood pressure (systolic/diastolic), pulse, and contextual notes
- **Smart Categorization**: Automatic classification based on AHA guidelines (Normal, Elevated, Hypertension Stage 1/2, Crisis, Low)
- **Visual Feedback**: Color-coded categories for instant understanding
- **Timestamping**: All readings automatically timestamped, with option to adjust
- **Contextual Notes**: Add notes like "after exercise" or "morning reading"

### Data Analysis
- **Trend Visualization**: Interactive charts showing blood pressure and heart rate trends over time
- **Multiple Time Ranges**: View data by week, month, 3 months, year, or all time
- **Statistics**: Comprehensive stats including averages, highs/lows, and patterns
- **Category Distribution**: See what percentage of readings fall into each category
- **Pattern Recognition**: Identify morning vs. evening reading patterns

### User Experience
- **Clean Interface**: Modern, health-focused SwiftUI design
- **Dark Mode**: Full dark mode support
- **Quick Entry**: Optimized for fast data entry
- **Easy Navigation**: Tab-based interface with intuitive organization
- **Accessibility**: Built with accessibility in mind

### Data Management
- **CSV Export**: Export all your data for analysis in spreadsheet apps
- **Local Storage**: All data stored locally using SwiftData (privacy-focused)
- **No Cloud**: Your health data stays on your device
- **Data Persistence**: Reliable local database with SwiftData

## Requirements

- **iOS**: 17.0 or later
- **Xcode**: 15.0 or later
- **Swift**: 5.9 or later

## Installation

### Option 1: Open in Xcode
1. Open `BPTracker.xcodeproj` in Xcode
2. Select your target device or simulator
3. Press Cmd+R to build and run

### Option 2: Archive for Distribution
1. Open the project in Xcode
2. Select "Any iOS Device" as the build target
3. Product → Archive
4. Follow the distribution wizard for TestFlight or App Store

## Usage Guide

### Adding a Reading
1. Tap the **+** button in the top-right corner
2. Enter your systolic and diastolic blood pressure values
3. Enter your pulse/heart rate
4. Optionally adjust the date/time
5. Add any notes (e.g., "morning", "after walk")
6. Tap **Save**

The app will automatically:
- Validate your inputs
- Categorize the reading
- Show you what category it falls into before saving

### Viewing Your Readings
Navigate to the **Readings** tab to see:
- All your readings grouped by date
- Color-coded category indicators
- Timestamps and pulse rates
- Any notes you've added
- Swipe left to delete readings

### Understanding Trends
Navigate to the **Trends** tab to:
- View interactive charts of your blood pressure over time
- Switch between different time ranges (week, month, 3 months, year, all)
- See reference lines for normal/elevated/high thresholds
- View heart rate trends
- Check category distribution

### Checking Statistics
Navigate to the **Stats** tab for:
- Overall statistics (total readings, latest reading)
- 7-day, 30-day, and all-time averages
- Highest and lowest readings
- Time-of-day patterns
- Medical guideline reference

### Exporting Data
Navigate to the **Export** tab to:
- Export all readings to CSV format
- Share via AirDrop, Messages, Mail, etc.
- Import into Excel, Numbers, or other apps

## Blood Pressure Categories

Based on American Heart Association (AHA) guidelines:

| Category | Systolic | Diastolic | Color |
|----------|----------|-----------|-------|
| **Normal** | < 120 | and < 80 | Green |
| **Elevated** | 120-129 | and < 80 | Yellow |
| **Hypertension Stage 1** | 130-139 | or 80-89 | Orange |
| **Hypertension Stage 2** | ≥ 140 | or ≥ 90 | Red |
| **Hypertensive Crisis** | > 180 | or > 120 | Purple |
| **Low** | < 90 | or < 60 | Blue |

⚠️ **Important**: If you get a Hypertensive Crisis reading, seek emergency medical care immediately.

## Project Structure

```
BPTracker/
├── BPTracker.xcodeproj/          # Xcode project file
├── BPTracker/
│   ├── BPTrackerApp.swift        # App entry point & SwiftData setup
│   ├── ContentView.swift         # Main tab navigation
│   ├── Models/
│   │   ├── BloodPressureReading.swift  # Core data model
│   │   └── BPCategory.swift      # Category logic & guidelines
│   ├── Views/
│   │   ├── AddReadingView.swift  # Add/edit reading form
│   │   ├── ReadingListView.swift # List of readings
│   │   ├── TrendsView.swift      # Charts and visualizations
│   │   ├── StatsView.swift       # Statistics & averages
│   │   └── ExportView.swift      # Data export
│   └── Assets.xcassets/          # App icons & colors
├── README.md                      # This file
└── DEVELOPMENT.md                 # Developer documentation
```

## Privacy & Security

- **Local Only**: All data stored locally on your device using SwiftData
- **No Network**: No network requests, no cloud sync, no data collection
- **No Tracking**: No analytics or third-party tracking
- **Your Data**: You control when and how to export your data

## Medical Disclaimer

This app is for **informational purposes only** and is not a substitute for professional medical advice, diagnosis, or treatment. Always consult your physician or other qualified health provider with any questions about your blood pressure or medical condition.

- Do not use this app for medical diagnosis
- Seek immediate medical attention for hypertensive crisis readings
- Regular monitoring should be under physician guidance
- App accuracy depends on accurate manual data entry

## Customization

### Changing the App Icon
1. Replace the icon in `Assets.xcassets/AppIcon.appiconset/`
2. Use a 1024x1024 PNG image
3. Xcode will generate all required sizes

### Modifying Categories
Edit `BPCategory.swift` to adjust:
- Threshold values
- Color coding
- Descriptions and recommendations

### Adding Features
The codebase is well-structured for adding:
- Medication tracking
- Reminders
- HealthKit integration
- iCloud sync
- Multiple user profiles

## Technical Details

### Technologies
- **SwiftUI**: Modern declarative UI framework
- **SwiftData**: Apple's new data persistence framework
- **Swift Charts**: Native chart visualization
- **Swift 5.9**: Latest Swift features

### Architecture
- **MVVM Pattern**: Model-View separation
- **SwiftData Models**: `@Model` macro for persistence
- **Environment Objects**: Shared model context
- **Property Wrappers**: `@Query`, `@State`, `@Environment`

### Data Model
```swift
@Model
final class BloodPressureReading {
    var systolic: Int        // mmHg
    var diastolic: Int       // mmHg
    var pulse: Int           // bpm
    var timestamp: Date
    var notes: String
}
```

## Contributing

This is a complete, working app that can be extended:
- Add medication tracking
- Implement HealthKit integration
- Add reminders and notifications
- Create reports and PDF exports
- Add multi-user support

## License

This project is provided as-is for educational and personal use.

## Support

For issues or questions about using the app:
1. Check the in-app health guidelines
2. Review this README
3. Consult your healthcare provider for medical questions

## Version History

**v1.0** - Initial Release
- Core blood pressure logging
- Trend visualization
- Statistics and averages
- CSV export
- Dark mode support
- iOS 17+ with SwiftData

## Acknowledgments

- Blood pressure guidelines based on American Heart Association (AHA) standards
- Built with modern iOS development best practices
- Designed with privacy and user health in mind
