//
//  TrendsView.swift
//  BPTracker
//
//  Visualization of blood pressure trends over time
//

import SwiftUI
import SwiftData
import Charts

struct TrendsView: View {
    @Query(sort: \BloodPressureReading.timestamp, order: .forward) private var readings: [BloodPressureReading]
    @State private var timeRange: TimeRange = .week
    
    enum TimeRange: String, CaseIterable {
        case week = "Week"
        case month = "Month"
        case threeMonths = "3 Months"
        case year = "Year"
        case all = "All"
        
        var days: Int? {
            switch self {
            case .week: return 7
            case .month: return 30
            case .threeMonths: return 90
            case .year: return 365
            case .all: return nil
            }
        }
    }
    
    var filteredReadings: [BloodPressureReading] {
        guard let days = timeRange.days else { return readings }
        let cutoffDate = Calendar.current.date(byAdding: .day, value: -days, to: Date()) ?? Date()
        return readings.filter { $0.timestamp >= cutoffDate }
    }
    
    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                if readings.isEmpty {
                    ContentUnavailableView(
                        "No Data Yet",
                        systemImage: "chart.line.uptrend.xyaxis",
                        description: Text("Add some readings to see trends")
                    )
                    .frame(height: 300)
                } else {
                    // Time range picker
                    Picker("Time Range", selection: $timeRange) {
                        ForEach(TimeRange.allCases, id: \.self) { range in
                            Text(range.rawValue).tag(range)
                        }
                    }
                    .pickerStyle(.segmented)
                    .padding(.horizontal)
                    
                    if filteredReadings.isEmpty {
                        ContentUnavailableView(
                            "No Data",
                            systemImage: "chart.line.uptrend.xyaxis",
                            description: Text("No readings in this time range")
                        )
                        .frame(height: 250)
                    } else {
                        // Blood Pressure Chart
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Blood Pressure")
                                .font(.headline)
                                .padding(.horizontal)
                            
                            Chart {
                                ForEach(filteredReadings) { reading in
                                    LineMark(
                                        x: .value("Date", reading.timestamp),
                                        y: .value("Systolic", reading.systolic)
                                    )
                                    .foregroundStyle(.red)
                                    .symbol(.circle)
                                    
                                    LineMark(
                                        x: .value("Date", reading.timestamp),
                                        y: .value("Diastolic", reading.diastolic)
                                    )
                                    .foregroundStyle(.blue)
                                    .symbol(.square)
                                }
                                
                                // Reference lines
                                RuleMark(y: .value("Normal", 120))
                                    .foregroundStyle(.green.opacity(0.3))
                                    .lineStyle(StrokeStyle(dash: [5, 5]))
                                
                                RuleMark(y: .value("Elevated", 130))
                                    .foregroundStyle(.orange.opacity(0.3))
                                    .lineStyle(StrokeStyle(dash: [5, 5]))
                                
                                RuleMark(y: .value("High", 140))
                                    .foregroundStyle(.red.opacity(0.3))
                                    .lineStyle(StrokeStyle(dash: [5, 5]))
                            }
                            .frame(height: 250)
                            .chartYScale(domain: 40...200)
                            .chartXAxis {
                                AxisMarks(values: .automatic) { _ in
                                    AxisValueLabel(format: .dateTime.month().day())
                                    AxisGridLine()
                                }
                            }
                            .padding()
                            .background(Color(.systemBackground))
                            .cornerRadius(12)
                            .shadow(radius: 2)
                            .padding(.horizontal)
                            
                            // Legend
                            HStack(spacing: 20) {
                                Label("Systolic", systemImage: "circle.fill")
                                    .foregroundStyle(.red)
                                Label("Diastolic", systemImage: "square.fill")
                                    .foregroundStyle(.blue)
                            }
                            .font(.caption)
                            .padding(.horizontal)
                        }
                        
                        // Pulse Chart
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Heart Rate")
                                .font(.headline)
                                .padding(.horizontal)
                            
                            Chart {
                                ForEach(filteredReadings) { reading in
                                    LineMark(
                                        x: .value("Date", reading.timestamp),
                                        y: .value("Pulse", reading.pulse)
                                    )
                                    .foregroundStyle(.pink)
                                    .symbol(.circle)
                                    
                                    AreaMark(
                                        x: .value("Date", reading.timestamp),
                                        y: .value("Pulse", reading.pulse)
                                    )
                                    .foregroundStyle(.pink.opacity(0.1))
                                }
                                
                                // Normal pulse range
                                RuleMark(y: .value("Normal Low", 60))
                                    .foregroundStyle(.green.opacity(0.3))
                                    .lineStyle(StrokeStyle(dash: [5, 5]))
                                
                                RuleMark(y: .value("Normal High", 100))
                                    .foregroundStyle(.green.opacity(0.3))
                                    .lineStyle(StrokeStyle(dash: [5, 5]))
                            }
                            .frame(height: 200)
                            .chartYScale(domain: 40...140)
                            .chartXAxis {
                                AxisMarks(values: .automatic) { _ in
                                    AxisValueLabel(format: .dateTime.month().day())
                                    AxisGridLine()
                                }
                            }
                            .padding()
                            .background(Color(.systemBackground))
                            .cornerRadius(12)
                            .shadow(radius: 2)
                            .padding(.horizontal)
                            
                            Text("Normal resting: 60-100 bpm")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                                .padding(.horizontal)
                        }
                        
                        // Category Distribution
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Category Distribution")
                                .font(.headline)
                                .padding(.horizontal)
                            
                            VStack(alignment: .leading, spacing: 12) {
                                ForEach(BPCategory.allCases, id: \.self) { category in
                                    let count = filteredReadings.filter { $0.category == category }.count
                                    if count > 0 {
                                        HStack {
                                            Circle()
                                                .fill(category.color)
                                                .frame(width: 12, height: 12)
                                            Text(category.rawValue)
                                                .font(.subheadline)
                                            Spacer()
                                            Text("\(count)")
                                                .font(.subheadline)
                                                .foregroundStyle(.secondary)
                                            Text("(\(Int(Double(count) / Double(filteredReadings.count) * 100))%)")
                                                .font(.caption)
                                                .foregroundStyle(.secondary)
                                        }
                                    }
                                }
                            }
                            .padding()
                            .background(Color(.systemBackground))
                            .cornerRadius(12)
                            .shadow(radius: 2)
                            .padding(.horizontal)
                        }
                    }
                }
            }
            .padding(.vertical)
        }
    }
}

#Preview {
    NavigationStack {
        TrendsView()
            .navigationTitle("Trends")
    }
    .modelContainer(for: BloodPressureReading.self, inMemory: true)
}
