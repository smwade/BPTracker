//
//  BPCategory.swift
//  BPTracker
//
//  Blood pressure categories based on AHA guidelines
//

import SwiftUI

enum BPCategory: String, CaseIterable {
    case normal = "Normal"
    case elevated = "Elevated"
    case hypertensionStage1 = "Hypertension Stage 1"
    case hypertensionStage2 = "Hypertension Stage 2"
    case hypertensiveCrisis = "Hypertensive Crisis"
    case low = "Low"
    
    static func categorize(systolic: Int, diastolic: Int) -> BPCategory {
        // Hypertensive Crisis (seek emergency care)
        if systolic > 180 || diastolic > 120 {
            return .hypertensiveCrisis
        }
        
        // Hypertension Stage 2
        if systolic >= 140 || diastolic >= 90 {
            return .hypertensionStage2
        }
        
        // Hypertension Stage 1
        if systolic >= 130 || diastolic >= 80 {
            return .hypertensionStage1
        }
        
        // Elevated
        if systolic >= 120 && diastolic < 80 {
            return .elevated
        }
        
        // Low blood pressure
        if systolic < 90 || diastolic < 60 {
            return .low
        }
        
        // Normal
        return .normal
    }
    
    var color: Color {
        switch self {
        case .normal:
            return .green
        case .elevated:
            return .yellow
        case .hypertensionStage1:
            return .orange
        case .hypertensionStage2:
            return .red
        case .hypertensiveCrisis:
            return .purple
        case .low:
            return .blue
        }
    }
    
    var description: String {
        switch self {
        case .normal:
            return "Less than 120/80 mmHg"
        case .elevated:
            return "120-129 systolic and less than 80 diastolic"
        case .hypertensionStage1:
            return "130-139 systolic or 80-89 diastolic"
        case .hypertensionStage2:
            return "140+ systolic or 90+ diastolic"
        case .hypertensiveCrisis:
            return "Higher than 180 systolic and/or higher than 120 diastolic"
        case .low:
            return "Less than 90 systolic or less than 60 diastolic"
        }
    }
    
    var recommendation: String {
        switch self {
        case .normal:
            return "Maintain healthy lifestyle"
        case .elevated:
            return "Adopt heart-healthy lifestyle changes"
        case .hypertensionStage1:
            return "Consider lifestyle changes and medication"
        case .hypertensionStage2:
            return "Consult your doctor about medication"
        case .hypertensiveCrisis:
            return "⚠️ SEEK EMERGENCY MEDICAL CARE"
        case .low:
            return "Monitor and consult doctor if symptomatic"
        }
    }
}
