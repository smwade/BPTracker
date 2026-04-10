import Foundation
import SwiftData

@Model
final class BPSession {
    var id: UUID
    var timestamp: Date
    var readings: [BPReading]
    
    init(readings: [BPReading] = []) {
        self.id = UUID()
        self.timestamp = Date()
        self.readings = readings
    }
    
    var averageSystolic: Double {
        guard !readings.isEmpty else { return 0 }
        return Double(readings.reduce(0) { $0 + $1.systolic }) / Double(readings.count)
    }
    
    var averageDiastolic: Double {
        guard !readings.isEmpty else { return 0 }
        return Double(readings.reduce(0) { $0 + $1.diastolic }) / Double(readings.count)
    }
    
    var averagePulse: Double {
        guard !readings.isEmpty else { return 0 }
        return Double(readings.reduce(0) { $0 + $1.pulse }) / Double(readings.count)
    }
}
