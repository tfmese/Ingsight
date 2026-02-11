import Foundation
import SwiftUI

/// Tek bir tarama sonucunu temsil eder.
/// Aynı yapı hem gıda hem de kozmetik için kullanılır;
/// hangi kategoriye ait olduğunu `category` alanı belirler.
struct ScannedProduct: Identifiable, Equatable, Hashable {
    let id: UUID
    let image: UIImage?
    let ingredients: [Ingredient]
    let category: ScanCategory
    let createdAt: Date
    
    init(
        id: UUID = UUID(),
        image: UIImage?,
        ingredients: [Ingredient],
        category: ScanCategory,
        createdAt: Date = Date()
    ) {
        self.id = id
        self.image = image
        self.ingredients = ingredients
        self.category = category
        self.createdAt = createdAt
    }
    
    // Basit risk özetleri – ResultsScreen ile aynı mantığı kullanır.
    var safeCount: Int {
        ingredients.filter { $0.riskLevel == .low }.count
    }
    
    var cautionCount: Int {
        ingredients.filter { $0.riskLevel == .medium }.count
    }
    
    var avoidCount: Int {
        ingredients.filter { $0.riskLevel == .high }.count
    }
    
    /// 100 üzerinden güvenlik skoru.
    var score: Int {
        guard !ingredients.isEmpty else { return 98 }
        let base = 100
        let value = base
            - (avoidCount * 8)
            - (cautionCount * 4)
            - (safeCount * 2)
        return min(98, max(22, value))
    }
}

// UIImage Equatable/Hashable olmadığı için, eşitlik ve hash hesaplamasını
// sadece `id` alanına göre yapıyoruz.
extension ScannedProduct {
    static func == (lhs: ScannedProduct, rhs: ScannedProduct) -> Bool {
        lhs.id == rhs.id
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}


