# Changelog

## Version 1.1 - Timer-Based Reading Feature (April 2026)

### 🎯 Major New Feature: Guided BP Sessions

Added a complete timer-based reading flow that follows medical best practices for accurate blood pressure monitoring.

#### What's New

**Guided Session Flow:**
- ⏱️ 5-minute rest timer before first reading
- 📝 Quick entry form for first reading
- ⏱️ 1-minute rest timer before second reading
- 📝 Quick entry form for second reading
- 📊 Automatic averaging of both readings
- 🎨 Session summary with color-coded category

**Timer Features:**
- Visual countdown display (MM:SS format)
- Progress bar with color coding
- Phase-specific icons and instructions
- Haptic feedback when timers complete
- Local notifications when ready to take readings
- Skip button for rest periods (if already rested)
- Cancel button to exit session any time

**Data Model Updates:**
- New `BPSession` model for paired readings
- Sessions store both readings and calculated averages
- Sessions appear first in reading list (highlighted)
- Individual readings still supported for quick entry

**UI Enhancements:**
- Full-screen timer interface
- Choice dialog: Guided Session vs. Quick Entry
- Medical guidelines card explaining best practices
- Session summary showing both readings and average
- Enhanced reading list with session grouping

#### New Files

**Models:**
- `BPSession.swift` - Session data model with averaging logic
- `TimerManager.swift` - Observable timer state management

**Views:**
- `TimedSessionView.swift` - Complete guided session interface

**Documentation:**
- `TIMER_FEATURE.md` - Detailed feature documentation

#### Benefits

**Medical Accuracy:**
- Follows AHA guidelines for proper BP measurement
- 5-minute rest reduces stress and movement effects
- Multiple readings average out variability
- Standardized procedure improves consistency

**User Experience:**
- Guided process removes guesswork
- Visual timers eliminate clock-watching
- Notifications ensure proper timing
- Flexible (can skip or use quick entry)

**Data Quality:**
- More accurate readings for better trend analysis
- Averaged values reduce measurement error
- Better data for sharing with healthcare providers

#### Technical Details

**Timer Implementation:**
- `@StateObject` for timer lifecycle management
- `@Published` properties for reactive UI updates
- `Timer.scheduledTimer` for countdown
- `UNUserNotificationCenter` for background notifications
- Proper cleanup on view dismissal

**State Machine:**
```
Initial → RestingFirst (5 min) → ReadyFirst → 
RestingSecond (1 min) → ReadySecond → Completed
```

**Data Relationships:**
- Session has optional `firstReading` and `secondReading`
- Readings can exist standalone (quick entry) or in session
- Session marked complete when both readings saved
- Deleting session removes associated readings

#### Migration Notes

**Database Schema:**
- Added `BPSession` to SwiftData schema
- Existing readings unaffected
- No migration required for existing users

**Backwards Compatible:**
- Quick entry still works identically
- Existing reading list view enhanced
- All previous features remain available

---

## Version 1.0 - Initial Release (April 2026)

### Core Features

**Blood Pressure Logging:**
- Record systolic/diastolic readings
- Track pulse/heart rate
- Add contextual notes
- Automatic timestamps

**Data Analysis:**
- Interactive charts (Swift Charts)
- Multiple time ranges
- Statistics and averages
- Pattern recognition

**User Experience:**
- SwiftUI interface
- Dark mode support
- Tab-based navigation
- Color-coded categories

**Data Management:**
- SwiftData persistence
- CSV export
- Privacy-focused (local storage)
- Zero external dependencies

**Medical Accuracy:**
- AHA guideline compliance
- 6 BP categories
- Emergency crisis warnings
- Medical recommendations

### Technical Stack

- iOS 17.0+
- Swift 5.9
- SwiftUI
- SwiftData
- Swift Charts
- UserNotifications

---

## Upgrade Path

### From 1.0 to 1.1

**No breaking changes!**

- Existing readings preserved
- New session feature is additive
- Quick entry unchanged
- All data compatible

**What to expect:**
1. Open app
2. Tap + button → see new dialog
3. Choose "Guided Session" for timer-based flow
4. Or choose "Quick Entry" for traditional logging

---

## Roadmap

### Planned Features

**v1.2 - Enhanced Analytics:**
- Session statistics (average of averages)
- Time-of-day pattern analysis
- Week-over-week comparisons
- Trend predictions

**v1.3 - HealthKit Integration:**
- Sync with Apple Health
- Import existing BP data
- Share readings with Health app
- Automatic data backup

**v1.4 - Reminders & Notifications:**
- Daily reading reminders
- Customizable times
- Streak tracking
- Achievement badges

**v1.5 - Advanced Features:**
- Medication tracking
- Doctor visit preparation
- PDF report generation
- Multi-user profiles

---

## Known Issues

**v1.1:**
- Timer notifications require user permission (requested on first use)
- Timer may not fire if app is force-quit (iOS limitation)
- Background timer accuracy ~1-2 seconds (acceptable variance)

**Workarounds:**
- Grant notification permissions when prompted
- Keep app in background during timer (don't force quit)
- Use skip button if timer drifts significantly

---

## Feedback & Support

This is a self-contained app with no cloud services.

**For questions:**
- Read `TIMER_FEATURE.md` for detailed documentation
- Check `README.md` for usage guide
- Review `DEVELOPMENT.md` for technical details

**For customization:**
- All code is open and modifiable
- Timer durations in `TimerManager.swift`
- UI strings in respective view files
- Medical guidelines in `BPCategory.swift`

---

**Thank you for using BPTracker!** 🫀
