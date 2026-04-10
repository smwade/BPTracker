//
//  TimedSessionView.swift
//  BPTracker
//
//  Guided timer-based BP reading session
//

import SwiftUI
import SwiftData

struct TimedSessionView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    
    @StateObject private var timerManager = TimerManager()
    @State private var session: BPSession
    @State private var showingFirstReadingForm = false
    @State private var showingSecondReadingForm = false
    @State private var currentReadingInput = ReadingInput()
    
    init() {
        _session = State(initialValue: BPSession())
    }
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 24) {
                    // Header
                    VStack(spacing: 8) {
                        Image(systemName: timerPhaseIcon)
                            .font(.system(size: 60))
                            .foregroundStyle(timerPhaseColor)
                            .symbolEffect(.pulse, isActive: timerManager.isRunning)
                        
                        Text(timerManager.timerPhase.title)
                            .font(.title)
                            .fontWeight(.bold)
                        
                        Text(timerManager.timerPhase.instruction)
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal)
                    }
                    .padding(.top)
                    
                    // Timer Display
                    if timerManager.isRunning {
                        VStack(spacing: 12) {
                            Text(timerManager.formattedTime())
                                .font(.system(size: 72, weight: .thin, design: .rounded))
                                .monospacedDigit()
                            
                            ProgressView(value: progressValue)
                                .progressViewStyle(.linear)
                                .tint(timerPhaseColor)
                                .padding(.horizontal, 40)
                            
                            HStack(spacing: 16) {
                                Button("Skip Rest", systemImage: "forward.fill") {
                                    timerManager.skipToReading()
                                }
                                .buttonStyle(.bordered)
                                
                                Button("Cancel", systemImage: "xmark.circle.fill") {
                                    timerManager.stopTimer()
                                }
                                .buttonStyle(.bordered)
                                .tint(.red)
                            }
                            .padding(.top, 8)
                        }
                        .padding()
                        .background(Color(.systemBackground))
                        .cornerRadius(16)
                        .shadow(radius: 4)
                        .padding(.horizontal)
                    }
                    
                    // Action Buttons
                    VStack(spacing: 16) {
                        switch timerManager.timerPhase {
                        case .initial:
                            Button(action: { timerManager.advanceToNextPhase() }) {
                                Label("Start Guided Session", systemImage: "timer")
                                    .frame(maxWidth: .infinity)
                                    .padding()
                                    .background(Color.blue)
                                    .foregroundStyle(.white)
                                    .cornerRadius(12)
                            }
                            
                            Button(action: { showingFirstReadingForm = true }) {
                                Label("Quick Entry (No Timer)", systemImage: "pencil")
                                    .frame(maxWidth: .infinity)
                                    .padding()
                                    .background(Color(.systemGray5))
                                    .foregroundStyle(.primary)
                                    .cornerRadius(12)
                            }
                            
                        case .readyFirst:
                            Button(action: { showingFirstReadingForm = true }) {
                                Label("Enter First Reading", systemImage: "heart.text.square.fill")
                                    .frame(maxWidth: .infinity)
                                    .padding()
                                    .background(Color.green)
                                    .foregroundStyle(.white)
                                    .cornerRadius(12)
                            }
                            
                        case .readySecond:
                            Button(action: { showingSecondReadingForm = true }) {
                                Label("Enter Second Reading", systemImage: "heart.text.square.fill")
                                    .frame(maxWidth: .infinity)
                                    .padding()
                                    .background(Color.green)
                                    .foregroundStyle(.white)
                                    .cornerRadius(12)
                            }
                            
                        case .completed:
                            if let avg = session.formattedAverage, let category = session.averageCategory {
                                VStack(spacing: 16) {
                                    VStack(spacing: 8) {
                                        Text("Average Reading")
                                            .font(.headline)
                                            .foregroundStyle(.secondary)
                                        
                                        Text(avg)
                                            .font(.system(size: 48, weight: .bold, design: .rounded))
                                        
                                        HStack {
                                            Circle()
                                                .fill(category.color)
                                                .frame(width: 12, height: 12)
                                            Text(category.rawValue)
                                                .font(.title3)
                                                .foregroundStyle(category.color)
                                        }
                                    }
                                    .padding()
                                    .frame(maxWidth: .infinity)
                                    .background(Color(.systemGray6))
                                    .cornerRadius(16)
                                    
                                    Button(action: saveSession) {
                                        Label("Save Session", systemImage: "checkmark.circle.fill")
                                            .frame(maxWidth: .infinity)
                                            .padding()
                                            .background(Color.blue)
                                            .foregroundStyle(.white)
                                            .cornerRadius(12)
                                    }
                                }
                            }
                            
                        default:
                            EmptyView()
                        }
                    }
                    .padding(.horizontal)
                    
                    // Reading Summary
                    if session.firstReading != nil || session.secondReading != nil {
                        VStack(alignment: .leading, spacing: 12) {
                            Text("Readings")
                                .font(.headline)
                            
                            if let first = session.firstReading {
                                ReadingSummaryRow(
                                    title: "First Reading",
                                    reading: first,
                                    showDelete: timerManager.timerPhase == .initial || timerManager.timerPhase == .readySecond
                                ) {
                                    session.firstReading = nil
                                }
                            }
                            
                            if let second = session.secondReading {
                                ReadingSummaryRow(
                                    title: "Second Reading",
                                    reading: second,
                                    showDelete: true
                                ) {
                                    session.secondReading = nil
                                    timerManager.timerPhase = .readySecond
                                }
                            }
                        }
                        .padding()
                        .background(Color(.systemBackground))
                        .cornerRadius(16)
                        .shadow(radius: 2)
                        .padding(.horizontal)
                    }
                    
                    // Medical Guidelines
                    MedicalGuidelinesCard()
                        .padding(.horizontal)
                }
                .padding(.bottom)
            }
            .navigationTitle("BP Session")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        timerManager.resetTimer()
                        dismiss()
                    }
                }
            }
            .sheet(isPresented: $showingFirstReadingForm) {
                QuickReadingForm(input: $currentReadingInput) { reading in
                    session.firstReading = reading
                    showingFirstReadingForm = false
                    
                    if timerManager.timerPhase == .readyFirst {
                        timerManager.advanceToNextPhase()
                    } else if timerManager.timerPhase == .initial {
                        timerManager.timerPhase = .readySecond
                    }
                }
            }
            .sheet(isPresented: $showingSecondReadingForm) {
                QuickReadingForm(input: $currentReadingInput) { reading in
                    session.secondReading = reading
                    showingSecondReadingForm = false
                    timerManager.timerPhase = .completed
                }
            }
        }
    }
    
    private var timerPhaseIcon: String {
        switch timerManager.timerPhase {
        case .initial: return "play.circle"
        case .restingFirst, .restingSecond: return "figure.mind.and.body"
        case .readyFirst, .readySecond: return "heart.text.square"
        case .completed: return "checkmark.seal.fill"
        }
    }
    
    private var timerPhaseColor: Color {
        switch timerManager.timerPhase {
        case .initial: return .blue
        case .restingFirst, .restingSecond: return .orange
        case .readyFirst, .readySecond: return .green
        case .completed: return .blue
        }
    }
    
    private var progressValue: Double {
        let total = timerManager.timerPhase.duration
        guard total > 0 else { return 0 }
        return (total - timerManager.timeRemaining) / total
    }
    
    private func saveSession() {
        session.completed = true
        modelContext.insert(session)
        
        // Also save individual readings
        if let first = session.firstReading {
            modelContext.insert(first)
        }
        if let second = session.secondReading {
            modelContext.insert(second)
        }
        
        dismiss()
    }
}

struct ReadingSummaryRow: View {
    let title: String
    let reading: BloodPressureReading
    let showDelete: Bool
    let onDelete: () -> Void
    
    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.caption)
                    .foregroundStyle(.secondary)
                
                HStack(spacing: 8) {
                    Circle()
                        .fill(reading.category.color)
                        .frame(width: 8, height: 8)
                    
                    Text(reading.formattedReading)
                        .font(.title3)
                        .fontWeight(.semibold)
                    
                    Text("❤️ \(reading.pulse)")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
            }
            
            Spacer()
            
            if showDelete {
                Button(action: onDelete) {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundStyle(.red)
                }
            }
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(12)
    }
}

struct MedicalGuidelinesCard: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Label("Medical Best Practice", systemImage: "info.circle.fill")
                .font(.headline)
                .foregroundStyle(.blue)
            
            VStack(alignment: .leading, spacing: 8) {
                GuidelineRow(icon: "1.circle.fill", text: "Rest quietly for 5 minutes before first reading")
                GuidelineRow(icon: "2.circle.fill", text: "Take first reading while seated with feet flat")
                GuidelineRow(icon: "3.circle.fill", text: "Rest for 1 minute")
                GuidelineRow(icon: "4.circle.fill", text: "Take second reading in same position")
                GuidelineRow(icon: "chart.bar.fill", text: "Average the two readings for accuracy")
            }
        }
        .padding()
        .background(Color.blue.opacity(0.1))
        .cornerRadius(16)
    }
}

struct GuidelineRow: View {
    let icon: String
    let text: String
    
    var body: some View {
        HStack(alignment: .top, spacing: 8) {
            Image(systemName: icon)
                .foregroundStyle(.blue)
                .frame(width: 20)
            Text(text)
                .font(.subheadline)
        }
    }
}

struct ReadingInput {
    var systolic = ""
    var diastolic = ""
    var pulse = ""
    var notes = ""
}

struct QuickReadingForm: View {
    @Environment(\.dismiss) private var dismiss
    @Binding var input: ReadingInput
    let onSave: (BloodPressureReading) -> Void
    
    @State private var showingValidationError = false
    @State private var validationMessage = ""
    
    var body: some View {
        NavigationStack {
            Form {
                Section("Blood Pressure") {
                    HStack {
                        Text("Systolic")
                            .frame(width: 100, alignment: .leading)
                        TextField("120", text: $input.systolic)
                            .keyboardType(.numberPad)
                            .multilineTextAlignment(.trailing)
                        Text("mmHg")
                            .foregroundStyle(.secondary)
                    }
                    
                    HStack {
                        Text("Diastolic")
                            .frame(width: 100, alignment: .leading)
                        TextField("80", text: $input.diastolic)
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
                        TextField("70", text: $input.pulse)
                            .keyboardType(.numberPad)
                            .multilineTextAlignment(.trailing)
                        Text("bpm")
                            .foregroundStyle(.secondary)
                    }
                }
                
                Section("Notes (Optional)") {
                    TextField("e.g., felt relaxed", text: $input.notes, axis: .vertical)
                        .lineLimit(2...4)
                }
            }
            .navigationTitle("Enter Reading")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") { saveReading() }
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
        guard let sys = Int(input.systolic),
              let dia = Int(input.diastolic),
              let pul = Int(input.pulse) else {
            return false
        }
        
        return sys > 0 && sys < 300 &&
               dia > 0 && dia < 200 &&
               pul > 0 && pul < 300
    }
    
    private func saveReading() {
        guard let sys = Int(input.systolic),
              let dia = Int(input.diastolic),
              let pul = Int(input.pulse) else {
            validationMessage = "Please enter valid numbers"
            showingValidationError = true
            return
        }
        
        if sys < 40 || sys > 250 || dia < 30 || dia > 150 || pul < 30 || pul > 250 {
            validationMessage = "Reading seems unusual. Please verify."
            showingValidationError = true
            return
        }
        
        let reading = BloodPressureReading(
            systolic: sys,
            diastolic: dia,
            pulse: pul,
            notes: input.notes
        )
        
        // Reset for next use
        input = ReadingInput()
        
        onSave(reading)
    }
}

#Preview {
    TimedSessionView()
        .modelContainer(for: [BPSession.self, BloodPressureReading.self], inMemory: true)
}
