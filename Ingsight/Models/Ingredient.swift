//
//  File.swift
//  Ingsight
//
//  Created by Talha Fırat on 2.02.2026.
//

import Foundation

enum RiskLevel: String, Codable {
    case high = "high"
    case medium = "medium"
    case low = "low"
    
    // UI'da kullanacağımız renk ve metin yardımcıları (ilerisi için hazırlık)
    var label: String {
        switch self {
        case .high: return "Yüksek Risk"
        case .medium: return "Orta Risk"
        case .low: return "Düşük Risk"
        }
    }
}

struct Ingredient: Identifiable, Codable {
    let id: String
    let name: String
    let aliases: [String] // Alternatif isimler
    let riskLevel: RiskLevel
    let description: String
}
