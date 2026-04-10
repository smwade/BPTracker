//
//  StatsView.swift
//  BPTracker
//
//  Statistics and averages for blood pressure readings
//

import SwiftUI
import SwiftData

struct StatsView: View {
    @Query(sort: \BloodPressureReading.timestamp, order: .reverse) private var readings: [BloodPressureReading]
    
    var body: some View {
        List {
            if readings.isEmpty {
                ContentUnavailableView(
                    "No Statistics Yet",
                    systemImage: "number",
                    description: Text("Add some readings to see statistics")
                )
            } else {
                Section("Overall") {
                    StatRow(title: "Total Readings", value: "\(readings.count)")
                    StatRow(title: "Latest Reading", value: readings.first?.formattedReading ?? "N/A")
                    if let latest = readings.first {
                        HStack {
                            Text("Category")
                            Spacer()
                            HStack(spacing: 4) {
                                Circle()
                                    .fill(latest.category.color)
                                    .frame(width: 12, height: 12)
                                Text(latest.category.rawValue)
                                    .foregroundStyle(.secondary)
                            }
                        }
                    }
                }
                
                Section("Last 7 Days") {
                    StatsGroup(readings: last7DaysReadings)
                }
                
                Section("Last 30 Days") {
                    StatsGroup(readings: last30DaysReadings)
                }
                
                Section("All Time") {
                    StatsGroup(readings: readings)
                }
                
                Section("Patterns") {
                    if let highestReading = readings.max(by: { $0.systolic < $1.systolic }) {
                        VStack(alignment: .leading, spacing: 4) {
                            Text("Highest Reading")
                                .font(.subheadline)
                                .foregroundStyle(.secondary)
                            Text(highestReading.formattedReading)
                                .font(.title3)
                                .fontWeight(.semibold)
                            Text(highestReading.formattedDate)
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                        .padding(.vertical, 4)
                    }
                    
                    if let lowestReading = readings.min(by: { $0.systolic < $1.systolic }) {
                        VStack(alignment: .leading, spacing: 4) {
                            Text("Lowest Reading")
                                .font(.subheadline)
                                .foregroundStyle(.secondary)
                            Text(lowestReading.formattedReading)
                                .font(.title3)
                                .fontWeight(.semibold)
                            Text(lowestReading.formattedDate)
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                        .padding(.vertical, 4)
                    }
                    
                    let morningReadings = readings.filter { Calendar.current.component(.hour, from: $0.timestamp) < 12 }
                    if !morningReadings.isEmpty {
                        StatRow(
                            title: "Morning Readings",
                            value: "\(morningReadings.count) (\(Int(Double(morningReadings.count) / Double(readings.count) * 100))%)"
                        )
                    }
                    
                    let eveningReadings = readings.filter { Calendar.current.component(.hour, from: $0.timestamp) >= 18 }
                    if !eveningReadings.isEmpty {
                        StatRow(
                            title: "Evening Readings",
                            value: "\(eveningReadings.count) (\(Int(Double(eveningReadings.count) / Double(readings.count) * 100))%)"
                        )
                    }
                }
                
                Section("Health Guidelines") {
                    VStack(alignment: .leading, spacing: 12) {
                        CategoryInfo(category: .normal)
                        CategoryInfo(category: .elevated)
                        CategoryInfo(category: .hypertensionStage1)
                        CategoryInfo(category: .hypertensionStage2)
                        CategoryInfo(category: .hypertensiveCrisis)
                    }
                    .padding(.vertical, 4)
                }
            }
        }
    }
    
    private var last7DaysReadings: [BloodPressureReading] {
        let cutoff = Calendar.current.date(byAdding: .day, value: -7, to: Date()) ?? Date()
        return readings.filter { $0.timestamp >= cutoff }
    }
    
    private var last30DaysReadings: [BloodPressureReading] {
        let cutoff = Calendar.current.date(byAdding: .day, value: -30, to: Date()) ?? Date()
        return readings.filter { $0.timestamp >= cutoff }
    }
}

struct StatsGroup: View {
    let readings: [BloodPressureReading]
    
    var avgSystolic: Int {
        guard !readings.isEmpty else { return 0 }
        return readings.map { $0.systolic }.reduce(0, +) / readings.count
    }
    
    var avgDiastolic: Int {
        guard !readings.isEmpty else { return 0 }
        return readings.map { $0.diastolic }.reduce(0, +) / readings.count
    }
    
    var avgPulse: Int {
        guard !readings.isEmpty else { return 0 }
        return readings.map { $0.pulse }.reduce(0, +) / readings.count
    }
    
    var body: some View {
        if readings.isEmpty {
            Text("No readings in this period")
                .foregroundStyle(.secondary)
        } else {
            StatRow(title: "Readings", value: "\(readings.count)")
            StatRow(title: "Avg. Systolic", value: "\(avgSystolic) mmHg")
            StatRow(title: "Avg. Diastolic", value: "\(avgDiastolic) mmHg")
            StatRow(title: "Avg. Pulse", value: "\(avgPulse) bpm")
            
            let avgCategory = BPCategory.categorize(systolic: avgSystolic, diastolic: avgDiastolic)
            HStack {
                Text("Avg. Category")
                Spacer()
                HStack(spacing: 4) {
                    Circle()
                        .fill(avgCategory.color)
                        .frame(width: 12, height: 12)
                    Text(avgCategory.rawValue)
                        .foregroundStyle(.secondary)
                }
            }
        }
    }
}

struct StatRow: View {
    let title: String
    let value: String
    
    var body: some View {
        HStack {
            Text(title)
            Spacer()
            Text(value)
                .foregroundStyle(.secondary)
        }
    }
}

struct CategoryInfo: View {
    let category: BPCategory
    
    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            HStack(spacing: 4) {
                Circle()
                    .fill(category.color)
                    .frame(width: 12, height: 12)
                Text(category.rawValue)
                    .font(.subheadline)
                    .fontWeight(.semibold)
            }
            Text(category.description)
                .font(.caption)
                .foregroundStyle(.secondary)
            Text(category.recommendation)
                .font(.caption)
                .foregroundStyle(.secondary)
        }
    }
}

#Preview {
    NavigationStack {
        StatsView()
            .navigationTitle("Statistics")
    }
    .modelContainer(for: BloodPressureReading.self, inMemory: true)
}
