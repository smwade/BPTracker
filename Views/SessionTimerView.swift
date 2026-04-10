import SwiftUI
import SwiftData

enum TimerPhase {
    case idle
    case resting(remainingSeconds: Int)
    case logFirstReading
    case waitingBetweenReadings(remainingSeconds: Int)
    case logSecondReading
    case complete
}

struct SessionTimerView: View {
    @Environment(\.modelContext) private var modelContext
    @StateObject private var notificationManager = NotificationManager.shared
    
    @State private var phase: TimerPhase = .idle
    @State private var timer: Timer?
    @State private var firstReading: BPReading?
    @State private var showingLogSheet = false
    @State private var showingCompleteAlert = false
    @State private var currentSession: BPSession?
    
    let restDuration = 300 // 5 minutes
    let betweenReadingsDuration = 60 // 1 minute
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 30) {
                Spacer()
                
                // Timer Display
                timerDisplay
                
                // Phase Description
                phaseDescription
                
                Spacer()
                
                // Action Button
                actionButton
                
                Spacer()
            }
            .padding()
            .navigationTitle("BP Session")
            .sheet(isPresented: $showingLogSheet) {
                if case .logFirstReading = phase {
                    LogReadingView(onSave: { reading in
                        firstReading = reading
                        startBetweenReadingsTimer()
                    })
                } else if case .logSecondReading = phase {
                    LogReadingView(onSave: { reading in
                        saveSession(secondReading: reading)
                    })
                }
            }
            .alert("Session Complete", isPresented: $showingCompleteAlert) {
                Button("OK") {
                    resetSession()
                }
            } message: {
                if let session = currentSession {
                    Text("""
                    Average BP: \(Int(session.averageSystolic))/\(Int(session.averageDiastolic))
                    Average Pulse: \(Int(session.averagePulse)) bpm
                    """)
                }
            }
            .task {
                _ = await notificationManager.requestAuthorization()
            }
        }
    }
    
    @ViewBuilder
    private var timerDisplay: some View {
        switch phase {
        case .idle:
            Image(systemName: "heart.circle")
                .font(.system(size: 120))
                .foregroundColor(.red)
        case .resting(let seconds), .waitingBetweenReadings(let seconds):
            ZStack {
                Circle()
                    .stroke(Color.gray.opacity(0.2), lineWidth: 20)
                    .frame(width: 200, height: 200)
                
                Circle()
                    .trim(from: 0, to: progressFraction(for: seconds))
                    .stroke(Color.blue, style: StrokeStyle(lineWidth: 20, lineCap: .round))
                    .frame(width: 200, height: 200)
                    .rotationEffect(.degrees(-90))
                    .animation(.linear(duration: 1), value: seconds)
                
                VStack {
                    Text(timeString(from: seconds))
                        .font(.system(size: 48, weight: .bold, design: .rounded))
                    Text("remaining")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
            }
        case .logFirstReading, .logSecondReading:
            Image(systemName: "pencil.circle.fill")
                .font(.system(size: 120))
                .foregroundColor(.green)
        case .complete:
            Image(systemName: "checkmark.circle.fill")
                .font(.system(size: 120))
                .foregroundColor(.green)
        }
    }
    
    @ViewBuilder
    private var phaseDescription: some View {
        switch phase {
        case .idle:
            Text("Ready to start a BP session")
                .font(.title3)
                .multilineTextAlignment(.center)
        case .resting:
            VStack(spacing: 8) {
                Text("Rest Period")
                    .font(.title2.bold())
                Text("Relax and prepare for measurement")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
        case .logFirstReading:
            Text("Time for First Reading")
                .font(.title2.bold())
        case .waitingBetweenReadings:
            VStack(spacing: 8) {
                Text("Wait Period")
                    .font(.title2.bold())
                Text("Preparing for second reading")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
        case .logSecondReading:
            Text("Time for Second Reading")
                .font(.title2.bold())
        case .complete:
            Text("Session Complete!")
                .font(.title2.bold())
        }
    }
    
    @ViewBuilder
    private var actionButton: some View {
        switch phase {
        case .idle:
            Button(action: startSession) {
                Label("Start BP Session", systemImage: "play.fill")
                    .font(.title3)
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.blue)
                    .cornerRadius(12)
            }
        case .resting, .waitingBetweenReadings:
            Button(action: cancelSession) {
                Label("Cancel Session", systemImage: "xmark")
                    .font(.title3)
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.red)
                    .cornerRadius(12)
            }
        case .logFirstReading, .logSecondReading:
            Button(action: { showingLogSheet = true }) {
                Label("Log Reading", systemImage: "pencil")
                    .font(.title3)
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.green)
                    .cornerRadius(12)
            }
        case .complete:
            Button(action: resetSession) {
                Label("Start New Session", systemImage: "arrow.clockwise")
                    .font(.title3)
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.blue)
                    .cornerRadius(12)
            }
        }
    }
    
    // MARK: - Timer Logic
    
    private func startSession() {
        phase = .resting(remainingSeconds: restDuration)
        startTimer(duration: restDuration) {
            phase = .logFirstReading
            notificationManager.scheduleNotification(
                title: "BP Reading Ready",
                body: "Time to log your first blood pressure reading",
                timeInterval: 0.1,
                identifier: "firstReading"
            )
        }
    }
    
    private func startBetweenReadingsTimer() {
        showingLogSheet = false
        phase = .waitingBetweenReadings(remainingSeconds: betweenReadingsDuration)
        startTimer(duration: betweenReadingsDuration) {
            phase = .logSecondReading
            notificationManager.scheduleNotification(
                title: "Second Reading Ready",
                body: "Time to log your second blood pressure reading",
                timeInterval: 0.1,
                identifier: "secondReading"
            )
        }
    }
    
    private func saveSession(secondReading: BPReading) {
        guard let firstReading = firstReading else { return }
        
        let session = BPSession()
        session.readings = [firstReading, secondReading]
        
        firstReading.session = session
        secondReading.session = session
        
        modelContext.insert(session)
        modelContext.insert(firstReading)
        modelContext.insert(secondReading)
        
        currentSession = session
        phase = .complete
        showingLogSheet = false
        showingCompleteAlert = true
    }
    
    private func startTimer(duration: Int, completion: @escaping () -> Void) {
        var remaining = duration
        
        timer?.invalidate()
        timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { t in
            remaining -= 1
            
            switch phase {
            case .resting:
                phase = .resting(remainingSeconds: remaining)
            case .waitingBetweenReadings:
                phase = .waitingBetweenReadings(remainingSeconds: remaining)
            default:
                break
            }
            
            if remaining <= 0 {
                t.invalidate()
                completion()
            }
        }
    }
    
    private func cancelSession() {
        timer?.invalidate()
        notificationManager.cancelAllNotifications()
        resetSession()
    }
    
    private func resetSession() {
        phase = .idle
        firstReading = nil
        currentSession = nil
        timer?.invalidate()
    }
    
    // MARK: - Helpers
    
    private func timeString(from seconds: Int) -> String {
        let minutes = seconds / 60
        let secs = seconds % 60
        return String(format: "%d:%02d", minutes, secs)
    }
    
    private func progressFraction(for seconds: Int) -> Double {
        let totalDuration: Double
        switch phase {
        case .resting:
            totalDuration = Double(restDuration)
        case .waitingBetweenReadings:
            totalDuration = Double(betweenReadingsDuration)
        default:
            return 0
        }
        return (totalDuration - Double(seconds)) / totalDuration
    }
}
