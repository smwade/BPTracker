# Quick Setup Guide

## For Users

### Opening the Project
1. Make sure you have **Xcode 15.0 or later** installed
2. Double-click `BPTracker.xcodeproj` to open in Xcode
3. The project will open and index automatically

### Running on Simulator
1. At the top of Xcode, click the device selector
2. Choose any iPhone simulator (iPhone 15, iPhone 15 Pro, etc.)
3. Press the **Play** button (▶) or press `Cmd+R`
4. The app will build and launch in the simulator
5. Try adding your first blood pressure reading!

### Running on Physical Device
1. Connect your iPhone via USB
2. Select your iPhone from the device selector
3. You may need to:
   - Trust the computer on your iPhone
   - Enable Developer Mode (Settings → Privacy & Security → Developer Mode)
   - Sign the app with your Apple ID (Xcode will prompt you)
4. Press the Play button (▶) or `Cmd+R`
5. The app will install and launch on your device

### First Time Sign-in
If Xcode asks you to sign in:
1. Go to Xcode → Settings → Accounts
2. Click the + button
3. Sign in with your Apple ID (free, no developer account needed)
4. Select your personal team in the project signing settings

## For Developers

### Project Structure
```
BPTracker/
├── BPTracker.xcodeproj/          # Xcode project
│   └── project.pbxproj           # Project configuration
├── BPTracker/                    # Source code
│   ├── BPTrackerApp.swift        # App entry & SwiftData setup
│   ├── ContentView.swift         # Main navigation
│   ├── Models/                   # Data models
│   │   ├── BloodPressureReading.swift
│   │   └── BPCategory.swift
│   ├── Views/                    # UI components
│   │   ├── AddReadingView.swift
│   │   ├── ReadingListView.swift
│   │   ├── TrendsView.swift
│   │   ├── StatsView.swift
│   │   └── ExportView.swift
│   └── Assets.xcassets/          # Images & colors
├── README.md                     # User documentation
├── DEVELOPMENT.md                # Developer guide
└── SETUP.md                      # This file
```

### Key Technologies
- **SwiftUI** - Modern declarative UI
- **SwiftData** - Apple's new persistence framework (iOS 17+)
- **Swift Charts** - Native chart visualization
- **No external dependencies** - Everything is built-in

### Making Changes
1. Open any `.swift` file in the editor
2. Make your changes
3. Save (Cmd+S)
4. Build and run (Cmd+R)
5. Test your changes in the simulator

### Common Modifications

**Change app name:**
1. Select project in navigator
2. Select BPTracker target
3. Change "Display Name" under General tab

**Change app icon:**
1. Open `Assets.xcassets`
2. Click `AppIcon`
3. Drag your 1024x1024 PNG into the box

**Modify blood pressure categories:**
- Edit `Models/BPCategory.swift`
- Adjust thresholds, colors, or descriptions

**Add new features:**
- Create new Swift file in appropriate folder
- Import SwiftUI and SwiftData as needed
- Follow existing patterns

### Debugging
- **Console output**: View → Debug Area → Show Debug Area (Cmd+Shift+Y)
- **Breakpoints**: Click line numbers to add breakpoints
- **Print statements**: Use `print("Debug: \(variable)")` in code

### Building for Distribution
See DEVELOPMENT.md for detailed instructions on:
- Archiving for App Store
- TestFlight distribution
- Ad-hoc distribution

## Troubleshooting

### "Command CodeSign failed"
- You need to sign the app with your Apple ID
- Go to project settings → Signing & Capabilities
- Check "Automatically manage signing"
- Select your team

### "Unable to install"
- Delete the app from the device/simulator
- Clean build folder (Cmd+Shift+K)
- Build again

### "Simulator is not available"
- Download iOS 17 simulator: Xcode → Settings → Platforms
- Select a different simulator

### App crashes on launch
- Check Console for error messages (Cmd+Shift+Y)
- Reset simulator content: Device → Erase All Content and Settings
- Clean build and try again

### SwiftData errors
- Delete the app from device/simulator
- Reinstall to start with fresh database

## Getting Help

1. **Check the README** - Comprehensive user guide
2. **Check DEVELOPMENT.md** - Developer documentation
3. **Xcode Help** - Help → Developer Documentation
4. **Apple Forums** - https://developer.apple.com/forums

## Next Steps

### For Users
- Start logging your blood pressure readings
- Explore the Trends tab to see visualizations
- Check the Stats tab for averages
- Export your data as CSV

### For Developers
- Read DEVELOPMENT.md for architecture details
- Try adding a new feature (see suggested roadmap)
- Implement HealthKit integration
- Add medication tracking

## Requirements

- **macOS**: 13.0 (Ventura) or later
- **Xcode**: 15.0 or later
- **iOS**: 17.0 or later (for deployment)
- **Swift**: 5.9 (included with Xcode)

## Tips

### Keyboard Shortcuts
- `Cmd+R` - Build and run
- `Cmd+B` - Build
- `Cmd+.` - Stop running
- `Cmd+Shift+K` - Clean build folder
- `Cmd+Option+P` - Resume preview
- `Cmd+Shift+Y` - Show/hide console

### Xcode Features
- **Live Preview**: Open any View file, click "Resume" in canvas (Cmd+Option+P)
- **Minimap**: Editor → Minimap (shows file overview)
- **Jump to definition**: Cmd+Click on any symbol
- **Find**: Cmd+F in file, Cmd+Shift+F in project

### iOS Simulator
- **Screenshot**: Cmd+S (saves to Desktop)
- **Home button**: Cmd+Shift+H
- **Rotate**: Cmd+Left/Right Arrow
- **Slow animations**: Debug → Slow Animations

## License & Usage

This project is provided as a complete, working example of:
- Modern iOS development with SwiftUI
- SwiftData for local persistence
- Health-focused app design
- Data visualization with Swift Charts

Feel free to:
- Use as learning material
- Modify for personal use
- Extend with new features
- Use as template for other health apps

**Not intended for:**
- Commercial redistribution without modification
- Medical diagnosis or treatment
- Certified medical device applications

Always consult healthcare professionals for medical advice.

## Support

This is a complete, self-contained project with no external dependencies or services. Everything runs locally on your device.

---

**Ready to start?** Open `BPTracker.xcodeproj` and press `Cmd+R`! 🚀
