//
//  ContentView.swift
//  BPTracker
//
//  Main navigation view
//

import SwiftUI
import SwiftData

struct ContentView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \BloodPressureReading.timestamp, order: .reverse) private var readings: [BloodPressureReading]
    @State private var showingAddOptions = false
    @State private var showingQuickEntry = false
    @State private var showingTimedSession = false
    
    var body: some View {
        TabView {
            NavigationStack {
                ReadingListView()
                    .navigationTitle("BP Tracker")
                    .toolbar {
                        ToolbarItem(placement: .primaryAction) {
                            Button(action: { showingAddOptions = true }) {
                                Label("Add Reading", systemImage: "plus")
                            }
                        }
                    }
            }
            .tabItem {
                Label("Readings", systemImage: "heart.text.square")
            }
            
            NavigationStack {
                TrendsView()
                    .navigationTitle("Trends")
            }
            .tabItem {
                Label("Trends", systemImage: "chart.line.uptrend.xyaxis")
            }
            
            NavigationStack {
                StatsView()
                    .navigationTitle("Statistics")
            }
            .tabItem {
                Label("Stats", systemImage: "number")
            }
            
            NavigationStack {
                ExportView()
                    .navigationTitle("Export")
            }
            .tabItem {
                Label("Export", systemImage: "square.and.arrow.up")
            }
        }
        .confirmationDialog("Add Blood Pressure Reading", isPresented: $showingAddOptions) {
            Button("Guided Session (Recommended)") {
                showingTimedSession = true
            }
            Button("Quick Entry") {
                showingQuickEntry = true
            }
            Button("Cancel", role: .cancel) { }
        } message: {
            Text("Use the guided session for accurate readings with rest periods, or quick entry for manual logging.")
        }
        .sheet(isPresented: $showingQuickEntry) {
            AddReadingView()
        }
        .fullScreenCover(isPresented: $showingTimedSession) {
            TimedSessionView()
        }
    }
}

#Preview {
    ContentView()
        .modelContainer(for: BloodPressureReading.self, inMemory: true)
}
