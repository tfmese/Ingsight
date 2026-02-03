import Foundation
import SwiftUI

enum RiskLevel: String, Codable {
    case high, medium, low

    var label: String {
        switch self {
        case .high: "Yüksek Risk"
        case .medium: "Orta Risk"
        case .low: "Düşük Risk"
        }
    }

    var color: Color {
        switch self {
        case .high: .red
        case .medium: .orange
        case .low: .green
        }
    }
}

struct Ingredient: Identifiable, Codable {
    let id: String
    let name: String
    let aliases: [String]
    let riskLevel: RiskLevel
    let description: String

    var riskLabel: String { riskLevel.label }
    var riskColor: Color { riskLevel.color }
}
