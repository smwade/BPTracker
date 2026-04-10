//
//  BloodPressureReading.swift
//  BPTracker
//
//  Model for blood pressure readings
//

import Foundation
import SwiftData

@Model
final class BloodPressureReading {
    var systolic: Int
    var diastolic: Int
    var pulse: Int
    var timestamp: Date
    var notes: String
    
    init(systolic: Int, diastolic: Int, pulse: Int, timestamp: Date = Date(), notes: String = "") {
        self.systolic = systolic
        self.diastolic = diastolic
        self.pulse = pulse
        self.timestamp = timestamp
        self.notes = notes
    }
    
    var category: BPCategory {
        BPCategory.categorize(systolic: systolic, diastolic: diastolic)
    }
    
    var formattedReading: String {
        "\(systolic)/\(diastolic)"
    }
    
    var formattedDate: String {
        timestamp.formatted(date: .abbreviated, time: .shortened)
    }
}
