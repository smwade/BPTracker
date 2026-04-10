//
//  BPSession.swift
//  BPTracker
//
//  Model for paired blood pressure readings (medical best practice)
//

import Foundation
import SwiftData

@Model
final class BPSession {
    var timestamp: Date
    var firstReading: BloodPressureReading?
    var secondReading: BloodPressureReading?
    var notes: String
    var completed: Bool
    
    init(timestamp: Date = Date(), notes: String = "", completed: Bool = false) {
        self.timestamp = timestamp
        self.notes = notes
        self.completed = completed
    }
    
    var isComplete: Bool {
        firstReading != nil && secondReading != nil
    }
    
    var averageSystolic: Int? {
        guard let first = firstReading, let second = secondReading else { return nil }
        return (first.systolic + second.systolic) / 2
    }
    
    var averageDiastolic: Int? {
        guard let first = firstReading, let second = secondReading else { return nil }
        return (first.diastolic + second.diastolic) / 2
    }
    
    var averagePulse: Int? {
        guard let first = firstReading, let second = secondReading else { return nil }
        return (first.pulse + second.pulse) / 2
    }
    
    var averageCategory: BPCategory? {
        guard let sys = averageSystolic, let dia = averageDiastolic else { return nil }
        return BPCategory.categorize(systolic: sys, diastolic: dia)
    }
    
    var formattedAverage: String? {
        guard let sys = averageSystolic, let dia = averageDiastolic else { return nil }
        return "\(sys)/\(dia)"
    }
    
    var formattedDate: String {
        timestamp.formatted(date: .abbreviated, time: .shortened)
    }
}
