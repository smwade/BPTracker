//
//  ExportView.swift
//  BPTracker
//
//  Export readings to CSV or other formats
//

import SwiftUI
import SwiftData

struct ExportView: View {
    @Query(sort: \BloodPressureReading.timestamp, order: .reverse) private var readings: [BloodPressureReading]
    @State private var showingShareSheet = false
    @State private var exportURL: URL?
    
    var body: some View {
        List {
            Section {
                if readings.isEmpty {
                    ContentUnavailableView(
                        "No Data to Export",
                        systemImage: "square.and.arrow.up",
                        description: Text("Add some readings first")
                    )
                } else {
                    Button(action: exportToCSV) {
                        HStack {
                            Image(systemName: "doc.text")
                                .foregroundStyle(.blue)
                            VStack(alignment: .leading) {
                                Text("Export to CSV")
                                    .foregroundStyle(.primary)
                                Text("\(readings.count) readings")
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                            }
                        }
                    }
                }
            } header: {
                Text("Export Options")
            } footer: {
                Text("Export your blood pressure data to CSV format for analysis in spreadsheet applications or import into other health tracking software.")
            }
            
            Section("Data Summary") {
                if !readings.isEmpty {
                    HStack {
                        Text("Total Readings")
                        Spacer()
                        Text("\(readings.count)")
                            .foregroundStyle(.secondary)
                    }
                    
                    if let oldest = readings.last, let newest = readings.first {
                        HStack {
                            Text("Date Range")
                            Spacer()
                            VStack(alignment: .trailing) {
                                Text(oldest.timestamp, style: .date)
                                    .foregroundStyle(.secondary)
                                Text("to")
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                                Text(newest.timestamp, style: .date)
                                    .foregroundStyle(.secondary)
                            }
                            .font(.subheadline)
                        }
                    }
                }
            }
            
            Section("Privacy Notice") {
                Text("All your data is stored locally on your device. When you export, the file is created on your device and you control where it's shared. No data is sent to external servers.")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
        }
        .sheet(isPresented: $showingShareSheet) {
            if let url = exportURL {
                ShareSheet(items: [url])
            }
        }
    }
    
    private func exportToCSV() {
        let csvString = generateCSV()
        
        let fileName = "bp_readings_\(Date().formatted(date: .numeric, time: .omitted).replacingOccurrences(of: "/", with: "-")).csv"
        let path = FileManager.default.temporaryDirectory.appendingPathComponent(fileName)
        
        do {
            try csvString.write(to: path, atomically: true, encoding: .utf8)
            exportURL = path
            showingShareSheet = true
        } catch {
            print("Error writing CSV: \(error)")
        }
    }
    
    private func generateCSV() -> String {
        var csv = "Date,Time,Systolic,Diastolic,Pulse,Category,Notes\n"
        
        let sortedReadings = readings.sorted { $0.timestamp < $1.timestamp }
        
        for reading in sortedReadings {
            let dateFormatter = DateFormatter()
            dateFormatter.dateStyle = .short
            dateFormatter.timeStyle = .none
            let date = dateFormatter.string(from: reading.timestamp)
            
            dateFormatter.dateStyle = .none
            dateFormatter.timeStyle = .short
            let time = dateFormatter.string(from: reading.timestamp)
            
            let notes = reading.notes.replacingOccurrences(of: "\"", with: "\"\"")
            
            csv += "\(date),\(time),\(reading.systolic),\(reading.diastolic),\(reading.pulse),\(reading.category.rawValue),\"\(notes)\"\n"
        }
        
        return csv
    }
}

struct ShareSheet: UIViewControllerRepresentable {
    let items: [Any]
    
    func makeUIViewController(context: Context) -> UIActivityViewController {
        let controller = UIActivityViewController(activityItems: items, applicationActivities: nil)
        return controller
    }
    
    func updateUIViewController(_ uiViewController: UIActivityViewController, context: Context) {}
}

#Preview {
    NavigationStack {
        ExportView()
            .navigationTitle("Export")
    }
    .modelContainer(for: BloodPressureReading.self, inMemory: true)
}
