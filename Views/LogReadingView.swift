import SwiftUI

struct LogReadingView: View {
    @Environment(\.dismiss) private var dismiss
    
    @State private var systolic = ""
    @State private var diastolic = ""
    @State private var pulse = ""
    @State private var notes = ""
    
    let onSave: (BPReading) -> Void
    
    var body: some View {
        NavigationStack {
            Form {
                Section("Blood Pressure") {
                    HStack {
                        Text("Systolic")
                        Spacer()
                        TextField("120", text: $systolic)
                            .keyboardType(.numberPad)
                            .multilineTextAlignment(.trailing)
                            .frame(width: 80)
                    }
                    
                    HStack {
                        Text("Diastolic")
                        Spacer()
                        TextField("80", text: $diastolic)
                            .keyboardType(.numberPad)
                            .multilineTextAlignment(.trailing)
                            .frame(width: 80)
                    }
                }
                
                Section("Heart Rate") {
                    HStack {
                        Text("Pulse")
                        Spacer()
                        TextField("70", text: $pulse)
                            .keyboardType(.numberPad)
                            .multilineTextAlignment(.trailing)
                            .frame(width: 80)
                        Text("bpm")
                            .foregroundColor(.secondary)
                    }
                }
                
                Section("Notes (Optional)") {
                    TextEditor(text: $notes)
                        .frame(height: 100)
                }
            }
            .navigationTitle("Log Reading")
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
    
    private func saveReading() {
        guard let sys = Int(systolic),
              let dia = Int(diastolic),
              let pul = Int(pulse) else {
            return
        }
        
        let reading = BPReading(systolic: sys, diastolic: dia, pulse: pul, notes: notes)
        onSave(reading)
        dismiss()
    }
}
