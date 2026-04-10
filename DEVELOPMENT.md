# Development Documentation

## Getting Started

### Prerequisites
- macOS 13.0 (Ventura) or later
- Xcode 15.0 or later
- iOS 17.0+ device or simulator

### First Time Setup
1. Clone or download the project
2. Open `BPTracker.xcodeproj` in Xcode
3. Wait for Swift Package dependencies to resolve (none required!)
4. Select a simulator or connected device
5. Build and run (Cmd+R)

## Architecture

### SwiftData Setup
The app uses SwiftData for persistence with a simple setup in `BPTrackerApp.swift`:

```swift
var sharedModelContainer: ModelContainer = {
    let schema = Schema([BloodPressureReading.self])
    let modelConfiguration = ModelConfiguration(
        schema: schema, 
        isStoredInMemoryOnly: false
    )
    return try ModelContainer(for: schema, configurations: [modelConfiguration])
}()
```

### Data Model
`BloodPressureReading` is the core `@Model` with:
- Stored properties: systolic, diastolic, pulse, timestamp, notes
- Computed properties: category, formattedReading, formattedDate

### Views

#### ContentView
- Root view with TabView
- Manages sheet presentation for adding readings
- Injects model container

#### AddReadingView
- Form-based input with validation
- Real-time preview of category
- Number pad keyboards for efficiency
- Reasonable range checking (40-250 systolic, 30-150 diastolic, 30-250 pulse)

#### ReadingListView
- `@Query` to fetch all readings sorted by timestamp
- Groups readings by date
- Swipe-to-delete functionality
- Custom `ReadingRow` component

#### TrendsView
- Swift Charts for visualization
- Time range filtering (week/month/3mo/year/all)
- Line charts with reference lines
- Area charts for pulse
- Category distribution bar chart

#### StatsView
- Computed statistics from readings
- Time-based grouping (7/30/all days)
- Min/max readings
- Pattern analysis (morning/evening)
- Health guidelines reference

#### ExportView
- CSV generation
- iOS share sheet integration
- Temporary file handling

## Key Components

### BPCategory Enum
Categorization logic based on AHA guidelines:
```swift
static func categorize(systolic: Int, diastolic: Int) -> BPCategory {
    // Crisis check first (>180/>120)
    // Then stage 2 (≥140/≥90)
    // Then stage 1 (≥130/≥80)
    // Then elevated (120-129/<80)
    // Low (<90/<60)
    // Default: normal
}
```

### Data Queries
Using SwiftData's `@Query` macro:
```swift
@Query(sort: \BloodPressureReading.timestamp, order: .reverse) 
private var readings: [BloodPressureReading]
```

## Adding Features

### HealthKit Integration
1. Add HealthKit capability in project settings
2. Request authorization for blood pressure
3. Read/write HKQuantitySample for HKQuantityTypeIdentifier.bloodPressureSystolic/Diastolic
4. Sync readings bidirectionally

Example skeleton:
```swift
import HealthKit

class HealthKitManager {
    let healthStore = HKHealthStore()
    
    func requestAuthorization() async throws {
        let types: Set = [
            HKQuantityType.quantityType(forIdentifier: .bloodPressureSystolic)!,
            HKQuantityType.quantityType(forIdentifier: .bloodPressureDiastolic)!,
            HKQuantityType.quantityType(forIdentifier: .heartRate)!
        ]
        try await healthStore.requestAuthorization(toShare: types, read: types)
    }
}
```

### Medication Tracking
1. Create `Medication` model:
```swift
@Model
final class Medication {
    var name: String
    var dosage: String
    var frequency: String
    var timestamp: Date
}
```
2. Add to schema
3. Create MedicationView
4. Link to readings (optional)

### Reminders
1. Import UserNotifications
2. Request notification permissions
3. Schedule local notifications:
```swift
let content = UNMutableNotificationContent()
content.title = "Blood Pressure Check"
content.body = "Time to log your reading"

let trigger = UNCalendarNotificationTrigger(
    dateMatching: dateComponents, 
    repeats: true
)

let request = UNNotificationRequest(
    identifier: UUID().uuidString,
    content: content,
    trigger: trigger
)
```

### iCloud Sync
1. Add iCloud capability
2. Enable CloudKit
3. Update ModelConfiguration:
```swift
ModelConfiguration(
    schema: schema,
    isStoredInMemoryOnly: false,
    cloudKitDatabase: .automatic
)
```

## Testing

### Unit Tests
Create `BPTrackerTests` target and test:
- BPCategory.categorize() with edge cases
- Reading validation logic
- CSV export formatting

### UI Tests
Create `BPTrackerUITests` target:
- Test adding a reading
- Test deleting a reading
- Test export flow
- Test navigation

### Manual Testing Checklist
- [ ] Add reading with valid values
- [ ] Add reading with boundary values
- [ ] Add reading with invalid values (should reject)
- [ ] View reading list
- [ ] Delete reading
- [ ] View trends with different time ranges
- [ ] View statistics
- [ ] Export CSV
- [ ] Share CSV via AirDrop
- [ ] Test dark mode
- [ ] Test on different device sizes
- [ ] Test landscape orientation (iPad)

## Performance

### Current Optimizations
- SwiftData automatic batching
- Lazy loading with `@Query`
- Efficient date grouping
- Chart data filtering

### Future Optimizations
For apps with 1000+ readings:
- Add pagination to reading list
- Implement data sampling for charts
- Add search/filter functionality
- Consider archiving old readings

## Debugging

### Common Issues

**SwiftData not persisting:**
- Check `isStoredInMemoryOnly: false`
- Verify model has `@Model` macro
- Check file permissions

**Charts not displaying:**
- Verify data is not empty
- Check time range filter
- Ensure valid data values

**CSV export failing:**
- Check file system permissions
- Verify temporary directory access
- Ensure valid CSV escaping

### Debug Tools
```swift
// Print SwiftData location
print(modelContext.container.configurations.first?.url)

// Log all readings
for reading in readings {
    print("\(reading.timestamp): \(reading.systolic)/\(reading.diastolic)")
}
```

## Code Style

### Conventions
- SwiftUI view files: PascalCase + "View" suffix
- Models: PascalCase, singular
- Properties: camelCase
- Enums: PascalCase
- Computed properties over functions where appropriate

### SwiftUI Best Practices
- Extract complex views into separate structs
- Use `@State` for view-local state
- Use `@Environment` for shared state
- Minimize `@Published` usage (SwiftData handles it)

### Comments
- Document complex logic
- Explain "why" not "what"
- Use `// MARK:` for section headers

## Building for Release

### Pre-Release Checklist
- [ ] Update version number in project settings
- [ ] Test on physical device
- [ ] Verify all features work
- [ ] Check dark mode appearance
- [ ] Review app icon
- [ ] Update README with new features
- [ ] Test export on various apps (Mail, Numbers, Excel)

### Archive Steps
1. Select "Any iOS Device" target
2. Product → Archive
3. Validate app
4. Distribute to TestFlight or App Store

### App Store Requirements
- Set up App Store Connect entry
- Prepare screenshots (required sizes)
- Write app description
- Set privacy policy (data stored locally)
- Set age rating
- Choose pricing

## Accessibility

### Current Support
- VoiceOver compatible labels
- Dynamic Type support (uses system fonts)
- Color indicators supplemented with text
- High contrast mode compatible

### Future Improvements
- Add VoiceOver hints
- Improve chart accessibility
- Add accessibility identifiers for UI testing
- Support reduce motion preference

## Localization

### Preparation for Localization
All user-facing strings are currently hardcoded but can be extracted:

```swift
// Current
Text("Add Reading")

// Localized
Text(NSLocalizedString("add_reading", comment: "Button to add new reading"))
```

Use Xcode's Export for Localization feature to generate `.xliff` files.

## Troubleshooting

### Xcode Build Issues
- Clean build folder: Cmd+Shift+K
- Reset package cache: File → Packages → Reset Package Caches
- Delete derived data: ~/Library/Developer/Xcode/DerivedData

### Simulator Issues
- Reset simulator: Device → Erase All Content and Settings
- Delete app and reinstall
- Check disk space

### Runtime Crashes
- Check SwiftData model changes (requires migration)
- Verify optional unwrapping
- Check array bounds

## Resources

### Apple Documentation
- [SwiftData Documentation](https://developer.apple.com/documentation/swiftdata)
- [SwiftUI Documentation](https://developer.apple.com/documentation/swiftui)
- [Swift Charts](https://developer.apple.com/documentation/charts)
- [HealthKit](https://developer.apple.com/documentation/healthkit)

### Medical Guidelines
- [American Heart Association Blood Pressure Guidelines](https://www.heart.org/en/health-topics/high-blood-pressure/understanding-blood-pressure-readings)

## Future Roadmap

### Short Term
- [ ] Add widget for quick entry
- [ ] Add Siri shortcuts
- [ ] Implement search/filter
- [ ] Add data backup/restore

### Medium Term
- [ ] HealthKit integration
- [ ] Medication tracking
- [ ] Reminder notifications
- [ ] PDF report generation

### Long Term
- [ ] Multi-user profiles
- [ ] Doctor sharing (secure)
- [ ] Apple Watch app
- [ ] Trends insights with ML
