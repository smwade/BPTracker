//
//  TimerManager.swift
//  BPTracker
//
//  Manages countdown timers for BP reading sessions
//

import Foundation
import UserNotifications
import Combine

@MainActor
class TimerManager: ObservableObject {
    @Published var timeRemaining: TimeInterval = 0
    @Published var isRunning = false
    @Published var timerPhase: TimerPhase = .initial
    
    enum TimerPhase {
        case initial            // Before starting
        case restingFirst       // 5-minute rest before first reading
        case readyFirst         // Time to take first reading
        case restingSecond      // 1-minute rest before second reading
        case readySecond        // Time to take second reading
        case completed          // Session complete
        
        var duration: TimeInterval {
            switch self {
            case .restingFirst:
                return 5 * 60  // 5 minutes
            case .restingSecond:
                return 1 * 60  // 1 minute
            default:
                return 0
            }
        }
        
        var title: String {
            switch self {
            case .initial:
                return "Start BP Session"
            case .restingFirst:
                return "Rest Period (5 min)"
            case .readyFirst:
                return "Take First Reading"
            case .restingSecond:
                return "Rest Period (1 min)"
            case .readySecond:
                return "Take Second Reading"
            case .completed:
                return "Session Complete"
            }
        }
        
        var instruction: String {
            switch self {
            case .initial:
                return "Follow the guided timer for accurate readings"
            case .restingFirst:
                return "Sit quietly and relax. Avoid talking or movement."
            case .readyFirst:
                return "Time to take your first blood pressure reading"
            case .restingSecond:
                return "Rest for one more minute before the second reading"
            case .readySecond:
                return "Time to take your second blood pressure reading"
            case .completed:
                return "Session complete! Average reading calculated."
            }
        }
    }
    
    private var timer: Timer?
    private var backgroundTask: Task<Void, Never>?
    
    func startTimer(phase: TimerPhase) {
        timerPhase = phase
        timeRemaining = phase.duration
        isRunning = true
        
        // Request notification permissions
        Task {
            await requestNotificationPermissions()
        }
        
        // Schedule notification for when timer completes
        scheduleNotification(for: phase)
        
        // Start the countdown
        timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] _ in
            Task { @MainActor [weak self] in
                guard let self = self else { return }
                
                if self.timeRemaining > 0 {
                    self.timeRemaining -= 1
                } else {
                    self.timerCompleted()
                }
            }
        }
    }
    
    func stopTimer() {
        timer?.invalidate()
        timer = nil
        isRunning = false
        timeRemaining = 0
        cancelNotifications()
    }
    
    func resetTimer() {
        stopTimer()
        timerPhase = .initial
    }
    
    private func timerCompleted() {
        timer?.invalidate()
        timer = nil
        isRunning = false
        
        // Play haptic feedback
        playHaptic()
        
        // Move to next phase
        switch timerPhase {
        case .restingFirst:
            timerPhase = .readyFirst
        case .restingSecond:
            timerPhase = .readySecond
        default:
            break
        }
    }
    
    func advanceToNextPhase() {
        switch timerPhase {
        case .initial:
            startTimer(phase: .restingFirst)
        case .readyFirst:
            startTimer(phase: .restingSecond)
        case .readySecond:
            timerPhase = .completed
        default:
            break
        }
    }
    
    func skipToReading() {
        stopTimer()
        switch timerPhase {
        case .restingFirst:
            timerPhase = .readyFirst
        case .restingSecond:
            timerPhase = .readySecond
        default:
            break
        }
    }
    
    private func requestNotificationPermissions() async {
        let center = UNUserNotificationCenter.current()
        do {
            try await center.requestAuthorization(options: [.alert, .sound, .badge])
        } catch {
            print("Error requesting notification permissions: \(error)")
        }
    }
    
    private func scheduleNotification(for phase: TimerPhase) {
        cancelNotifications()
        
        let content = UNMutableNotificationContent()
        content.sound = .default
        
        switch phase {
        case .restingFirst:
            content.title = "Time for First Reading"
            content.body = "5 minutes are up. Take your first blood pressure reading."
        case .restingSecond:
            content.title = "Time for Second Reading"
            content.body = "1 minute rest complete. Take your second reading."
        default:
            return
        }
        
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: phase.duration, repeats: false)
        let request = UNNotificationRequest(identifier: "bpTimer", content: content, trigger: trigger)
        
        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                print("Error scheduling notification: \(error)")
            }
        }
    }
    
    private func cancelNotifications() {
        UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: ["bpTimer"])
    }
    
    private func playHaptic() {
        #if os(iOS)
        let generator = UINotificationFeedbackGenerator()
        generator.notificationOccurred(.success)
        #endif
    }
    
    func formattedTime() -> String {
        let minutes = Int(timeRemaining) / 60
        let seconds = Int(timeRemaining) % 60
        return String(format: "%d:%02d", minutes, seconds)
    }
    
    deinit {
        stopTimer()
    }
}
