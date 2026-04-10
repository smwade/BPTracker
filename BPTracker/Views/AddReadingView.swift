//
//  AddReadingView.swift
//  BPTracker
//
//  View for adding new blood pressure readings
//

import SwiftUI
import SwiftData

struct AddReadingView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    
    @State private var systolic: String = ""
    @State private var diastolic: String = ""
    @State private var pulse: String = ""
    @State private var notes: String = ""
    @State private var timestamp = Date()
    @State private var showingValidationError = false
    @State private var validationMessage = ""
    
    var body: some View {
        NavigationStack {
            Form {
                Section("Blood Pressure") {
                    HStack {
                        Text("Systolic")
                            .frame(width: 100, alignment: .leading)
                        TextField("120", text: $systolic)
                            .keyboardType(.numberPad)
                            .multilineTextAlignment(.trailing)
                        Text("mmHg")
                            .foregroundStyle(.secondary)
                    }
                    
                    HStack {
                        Text("Diastolic")
                            .frame(width: 100, alignment: .leading)
                        TextField("80", text: $diastolic)
                            .keyboardType(.numberPad)
                            .multilineTextAlignment(.trailing)
                        Text("mmHg")
                            .foregroundStyle(.secondary)
                    }
                }
                
                Section("Heart Rate") {
                    HStack {
                        Text("Pulse")
                            .frame(width: 100, alignment: .leading)
                        TextField("70", text: $pulse)
                            .keyboardType(.numberPad)
                            .multilineTextAlignment(.trailing)
                        Text("bpm")
                            .foregroundStyle(.secondary)
                    }
                }
                
                Section("Timing") {
                    DatePicker("Date & Time", selection: $timestamp)
                }
                
                Section("Notes") {
                    TextField("e.g., after exercise, morning reading", text: $notes, axis: .vertical)
                        .lineLimit(3...6)
                }
                
                if let preview = previewReading {
                    Section("Preview") {
                        HStack {
                            Circle()
                                .fill(preview.category.color)
                                .frame(width: 12, height: 12)
                            Text(preview.category.rawValue)
                                .font(.headline)
                        }
                        Text(preview.category.description)
                            .font(.caption)
                            .foregroundStyle(.secondary)
                        Text(preview.category.recommendation)
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                }
            }
            .navigationTitle("Add Reading")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        saveReading()
                    }
                    .disabled(!isValid)
                }
            }
            .alert("Invalid Reading", isPresented: $showingValidationError) {
                Button("OK", role: .cancel) { }
            } message: {
                Text(validationMessage)
            }
        }
    }
    
    private var isValid: Bool {
        guard let sys = Int(systolic),
              let dia = Int(diastolic),
              let pul = Int(pulse) else {
            return false
        }
        
        return sys > 0 && sys < 300 &&
               dia > 0 && dia < 200 &&
               pul > 0 && pul < 300
    }
    
    private var previewReading: BloodPressureReading? {
        guard let sys = Int(systolic),
              let dia = Int(diastolic),
              let pul = Int(pulse),
              isValid else {
            return nil
        }
        
        return BloodPressureReading(systolic: sys, diastolic: dia, pulse: pul)
    }
    
    private func saveReading() {
        guard let sys = Int(systolic),
              let dia = Int(diastolic),
              let pul = Int(pulse) else {
            validationMessage = "Please enter valid numbers for all fields"
            showingValidationError = true
            return
        }
        
        if sys < 40 || sys > 250 {
            validationMessage = "Systolic reading seems unusual. Please verify."
            showingValidationError = true
            return
        }
        
        if dia < 30 || dia > 150 {
            validationMessage = "Diastolic reading seems unusual. Please verify."
            showingValidationError = true
            return
        }
        
        if pul < 30 || pul > 250 {
            validationMessage = "Pulse reading seems unusual. Please verify."
            showingValidationError = true
            return
        }
        
        let reading = BloodPressureReading(
            systolic: sys,
            diastolic: dia,
            pulse: pul,
            timestamp: timestamp,
            notes: notes
        )
        
        modelContext.insert(reading)
        dismiss()
    }
}

#Preview {
    AddReadingView()
        .modelContainer(for: BloodPressureReading.self, inMemory: true)
}
