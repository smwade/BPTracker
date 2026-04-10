//
//  BPTrackerApp.swift
//  BPTracker
//
//  Blood Pressure Tracking App
//

import SwiftUI
import SwiftData

@main
struct BPTrackerApp: App {
    var sharedModelContainer: ModelContainer = {
        let schema = Schema([
            BloodPressureReading.self,
            BPSession.self,
        ])
        let modelConfiguration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false)

        do {
            return try ModelContainer(for: schema, configurations: [modelConfiguration])
        } catch {
            fatalError("Could not create ModelContainer: \(error)")
        }
    }()

    var body: some Scene {
        WindowGroup {
            ContentView()
        }
        .modelContainer(sharedModelContainer)
    }
}
