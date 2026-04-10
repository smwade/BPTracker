//
//  ReadingListView.swift
//  BPTracker
//
//  List view of all blood pressure readings
//

import SwiftUI
import SwiftData

struct ReadingListView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \BloodPressureReading.timestamp, order: .reverse) private var readings: [BloodPressureReading]
    @Query(sort: \BPSession.timestamp, order: .reverse) private var sessions: [BPSession]
    
    var body: some View {
        Group {
            if readings.isEmpty && sessions.isEmpty {
                ContentUnavailableView(
                    "No Readings Yet",
                    systemImage: "heart.text.square",
                    description: Text("Tap the + button to add your first blood pressure reading")
                )
            } else {
                List {
                    // Show sessions first (recommended method)
                    if !completedSessions.isEmpty {
                        Section("Guided Sessions (Averaged)") {
                            ForEach(completedSessions) { session in
                                SessionRow(session: session)
                            }
                            .onDelete { indexSet in
                                deleteSessions(at: indexSet)
                            }
                        }
                    }
                    
                    // Show individual readings
                    if !standAloneReadings.isEmpty {
                        ForEach(groupedReadings.keys.sorted(by: >), id: \.self) { date in
                            Section(header: Text(date, style: .date)) {
                                ForEach(groupedReadings[date] ?? []) { reading in
                                    ReadingRow(reading: reading)
                                }
                                .onDelete { indexSet in
                                    deleteReadings(at: indexSet, in: groupedReadings[date] ?? [])
                                }
                            }
                        }
                    }
                }
                .listStyle(.insetGrouped)
            }
        }
    }
    
    private var completedSessions: [BPSession] {
        sessions.filter { $0.isComplete }
    }
    
    private var standAloneReadings: [BloodPressureReading] {
        // Get reading IDs that are part of sessions
        let sessionReadingIds = Set(sessions.flatMap { session -> [PersistentIdentifier] in
            var ids: [PersistentIdentifier] = []
            if let first = session.firstReading {
                ids.append(first.persistentModelID)
            }
            if let second = session.secondReading {
                ids.append(second.persistentModelID)
            }
            return ids
        })
        
        // Filter out readings that are part of sessions
        return readings.filter { !sessionReadingIds.contains($0.persistentModelID) }
    }
    
    private var groupedReadings: [Date: [BloodPressureReading]] {
        Dictionary(grouping: standAloneReadings) { reading in
            Calendar.current.startOfDay(for: reading.timestamp)
        }
    }
    
    private func deleteReadings(at offsets: IndexSet, in readingsGroup: [BloodPressureReading]) {
        for index in offsets {
            modelContext.delete(readingsGroup[index])
        }
    }
    
    private func deleteSessions(at offsets: IndexSet) {
        for index in offsets {
            let session = completedSessions[index]
            // Delete associated readings
            if let first = session.firstReading {
                modelContext.delete(first)
            }
            if let second = session.secondReading {
                modelContext.delete(second)
            }
            modelContext.delete(session)
        }
    }
}

struct SessionRow: View {
    let session: BPSession
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Image(systemName: "chart.bar.doc.horizontal.fill")
                    .foregroundStyle(.blue)
                
                Text("Guided Session")
                    .font(.caption)
                    .foregroundStyle(.blue)
                    .fontWeight(.medium)
                
                Spacer()
                
                Text(session.timestamp, style: .time)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            
            HStack {
                // Average reading
                if let category = session.averageCategory {
                    Circle()
                        .fill(category.color)
                        .frame(width: 12, height: 12)
                }
                
                if let avg = session.formattedAverage {
                    Text(avg)
                        .font(.title3)
                        .fontWeight(.semibold)
                    
                    Text("mmHg (avg)")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
                
                Spacer()
                
                if let avgPulse = session.averagePulse {
                    HStack(spacing: 4) {
                        Image(systemName: "heart.fill")
                            .font(.caption)
                            .foregroundStyle(.red)
                        Text("\(avgPulse)")
                            .font(.subheadline)
                        Text("bpm")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                }
            }
            
            // Show individual readings
            HStack(spacing: 16) {
                if let first = session.firstReading {
                    VStack(alignment: .leading, spacing: 2) {
                        Text("1st")
                            .font(.caption2)
                            .foregroundStyle(.secondary)
                        Text(first.formattedReading)
                            .font(.caption)
                            .monospacedDigit()
                    }
                }
                
                if let second = session.secondReading {
                    VStack(alignment: .leading, spacing: 2) {
                        Text("2nd")
                            .font(.caption2)
                            .foregroundStyle(.secondary)
                        Text(second.formattedReading)
                            .font(.caption)
                            .monospacedDigit()
                    }
                }
            }
            .padding(.top, 4)
            
            if let category = session.averageCategory {
                HStack {
                    Text(category.rawValue)
                        .font(.caption)
                        .foregroundStyle(category.color)
                }
            }
            
            if !session.notes.isEmpty {
                Text(session.notes)
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .padding(.top, 2)
            }
        }
        .padding(.vertical, 4)
    }
}

struct ReadingRow: View {
    let reading: BloodPressureReading
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                // Category indicator
                Circle()
                    .fill(reading.category.color)
                    .frame(width: 12, height: 12)
                
                // Reading
                Text(reading.formattedReading)
                    .font(.title3)
                    .fontWeight(.semibold)
                
                Text("mmHg")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                
                Spacer()
                
                // Pulse
                HStack(spacing: 4) {
                    Image(systemName: "heart.fill")
                        .font(.caption)
                        .foregroundStyle(.red)
                    Text("\(reading.pulse)")
                        .font(.subheadline)
                    Text("bpm")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }
            
            HStack {
                Text(reading.timestamp, style: .time)
                    .font(.caption)
                    .foregroundStyle(.secondary)
                
                Text("•")
                    .foregroundStyle(.secondary)
                
                Text(reading.category.rawValue)
                    .font(.caption)
                    .foregroundStyle(reading.category.color)
            }
            
            if !reading.notes.isEmpty {
                Text(reading.notes)
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .padding(.top, 2)
            }
        }
        .padding(.vertical, 4)
    }
}

#Preview {
    NavigationStack {
        ReadingListView()
            .navigationTitle("BP Tracker")
    }
    .modelContainer(for: BloodPressureReading.self, inMemory: true)
}
