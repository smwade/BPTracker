import Foundation
import SwiftData

@Model
final class BPReading {
    var id: UUID
    var timestamp: Date
    var systolic: Int
    var diastolic: Int
    var pulse: Int
    var notes: String
    var session: BPSession?
    
    init(systolic: Int, diastolic: Int, pulse: Int, notes: String = "") {
        self.id = UUID()
        self.timestamp = Date()
        self.systolic = systolic
        self.diastolic = diastolic
        self.pulse = pulse
        self.notes = notes
    }
    
    var category: BPCategory {
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
}

enum BPCategory: String {
    case normal = "Normal"
    case elevated = "Elevated"
    case hypertensiveStage1 = "Stage 1 Hypertension"
    case hypertensiveStage2 = "Stage 2 Hypertension"
    
    var color: String {
        switch self {
        case .normal: return "green"
        case .elevated: return "yellow"
        case .hypertensiveStage1: return "orange"
        case .hypertensiveStage2: return "red"
        }
    }
}
