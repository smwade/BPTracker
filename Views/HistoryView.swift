import SwiftUI
import SwiftData
import Charts

struct HistoryView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \BPSession.timestamp, order: .reverse) private var sessions: [BPSession]
    
    var body: some View {
        NavigationStack {
            List {
                if !sessions.isEmpty {
                    Section("Trend") {
                        TrendChartView(sessions: Array(sessions.prefix(30)))
                            .frame(height: 250)
                    }
                }
                
                Section("Sessions") {
                    if sessions.isEmpty {
                        ContentUnavailableView(
                            "No Sessions Yet",
                            systemImage: "heart.text.square",
                            description: Text("Start a BP session to track your readings")
                        )
                    } else {
                        ForEach(sessions) { session in
                            SessionRowView(session: session)
                        }
                        .onDelete(perform: deleteSessions)
                    }
                }
            }
            .navigationTitle("History")
            .toolbar {
                if !sessions.isEmpty {
                    EditButton()
                }
            }
        }
    }
    
    private func deleteSessions(at offsets: IndexSet) {
        for index in offsets {
            let session = sessions[index]
            modelContext.delete(session)
        }
    }
}

struct SessionRowView: View {
    let session: BPSession
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text(session.timestamp, style: .date)
                    .font(.headline)
                Spacer()
                Text(session.timestamp, style: .time)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
            
            HStack(spacing: 20) {
                VStack(alignment: .leading) {
                    Text("Average BP")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    Text("\(Int(session.averageSystolic))/\(Int(session.averageDiastolic))")
                        .font(.title3.bold())
                        .foregroundColor(categoryColor)
                }
                
                VStack(alignment: .leading) {
                    Text("Pulse")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    Text("\(Int(session.averagePulse)) bpm")
                        .font(.title3.bold())
                }
                
                Spacer()
                
                categoryBadge
            }
            
            if session.readings.count > 0 {
                Text("\(session.readings.count) reading\(session.readings.count == 1 ? "" : "s")")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
        }
        .padding(.vertical, 4)
    }
    
    private var category: BPCategory {
        let systolic = Int(session.averageSystolic)
        let diastolic = Int(session.averageDiastolic)
        
        if systolic >= 180 || diastolic >= 120 {
            return .hypertensiveStage2
        } else if systolic >= 140 || diastolic >= 90 {
            return .hypertensiveStage1
        } else if systolic >= 130 || diastolic >= 80 {
            return .elevated
        } else {
            return .normal
        }
    }
    
    private var categoryColor: Color {
        switch category {
        case .normal: return .green
        case .elevated: return .yellow
        case .hypertensiveStage1: return .orange
        case .hypertensiveStage2: return .red
        }
    }
    
    @ViewBuilder
    private var categoryBadge: some View {
        Text(category.rawValue)
            .font(.caption.bold())
            .padding(.horizontal, 8)
            .padding(.vertical, 4)
            .background(categoryColor.opacity(0.2))
            .foregroundColor(categoryColor)
            .cornerRadius(4)
    }
}

struct TrendChartView: View {
    let sessions: [BPSession]
    
    var body: some View {
        VStack(alignment: .leading) {
            Text("30-Day Trend")
                .font(.headline)
                .padding(.horizontal)
            
            if sessions.isEmpty {
                Text("No data to display")
                    .foregroundColor(.secondary)
                    .frame(maxWidth: .infinity)
                    .padding()
            } else {
                Chart {
                    ForEach(sessions.reversed()) { session in
                        LineMark(
                            x: .value("Date", session.timestamp),
                            y: .value("Systolic", session.averageSystolic)
                        )
                        .foregroundStyle(.red)
                        .symbol(Circle())
                        
                        LineMark(
                            x: .value("Date", session.timestamp),
                            y: .value("Diastolic", session.averageDiastolic)
                        )
                        .foregroundStyle(.blue)
                        .symbol(Circle())
                    }
                }
                .chartYAxis {
                    AxisMarks(position: .leading)
                }
                .chartXAxis {
                    AxisMarks(values: .automatic(desiredCount: 5))
                }
                .padding()
            }
            
            HStack {
                Label("Systolic", systemImage: "circle.fill")
                    .foregroundColor(.red)
                    .font(.caption)
                
                Label("Diastolic", systemImage: "circle.fill")
                    .foregroundColor(.blue)
                    .font(.caption)
            }
            .padding(.horizontal)
        }
    }
}
