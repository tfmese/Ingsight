import Foundation
import SwiftUI
import Combine

/// Tüm oturum boyunca taranan ürünleri tutan ve
/// kategoriye göre filtreleyerek karşılaştırma yapılmasını sağlayan store.
class ComparisonStore: ObservableObject {
    /// Tüm taramalar (hem gıda hem kozmetik). Kategori bilgisi `ScannedProduct` içinde.
    @Published private(set) var products: [ScannedProduct] = []
    
    /// Yeni bir ürün ekler.
    func addProduct(image: UIImage?, ingredients: [Ingredient], category: ScanCategory) {
        let product = ScannedProduct(
            image: image,
            ingredients: ingredients,
            category: category
        )
        products.append(product)
    }
    
    /// Belirli bir kategoriye ait ürünleri döner.
    func products(for category: ScanCategory) -> [ScannedProduct] {
        products.filter { $0.category == category }
    }
    
    /// Bir ürünü listeden kaldırır.
    func remove(_ product: ScannedProduct) {
        products.removeAll { $0.id == product.id }
    }
    
    /// Belirli bir kategorideki tüm ürünleri temizler.
    func clearCategory(_ category: ScanCategory) {
        products.removeAll { $0.category == category }
    }
}

