//
//  File.swift
//  Ingsight
//
//  Created by Talha Fırat on 2.02.2026.
//

import Foundation

class IngredientService {
    /// Varsayılan gıda veri tabanı (mevcut `toxic_ingredients.json`)
    static let shared = IngredientService(resourceName: "toxic_ingredients")
    
    /// Kozmetik veri tabanı (`toxic_ingredients_cosmetics.json`)
    static let cosmetics = IngredientService(resourceName: "toxic_ingredients_cosmetics")
    
    // Yüklenen içerikleri tutacağımız liste
    var ingredients: [Ingredient] = []
    
    private let resourceName: String
    
    private init(resourceName: String) {
        self.resourceName = resourceName
        loadIngredients()
    }
    
    // JSON dosyasını yükleyen fonksiyon
    private func loadIngredients() {
        print("📁 UYGULAMA PAKETİNDEKİ DOSYALAR KONTROL EDİLİYOR (\(resourceName)).")
        if let resources = Bundle.main.urls(forResourcesWithExtension: "json", subdirectory: nil) {
            for file in resources {
                print(" - Bulunan Dosya: \(file.lastPathComponent)")
            }
        } else {
            print(" - Hiç JSON dosyası bulunamadı!")
        }
        
        // 1. Dosyayı bul
        guard let url = Bundle.main.url(forResource: resourceName, withExtension: "json") else {
            print("HATA: JSON dosyası bulunamadı: \(resourceName).json")
            return
        }
        
        // 2. Veriyi oku ve dönüştür (Decode)
        do {
            let data = try Data(contentsOf: url)
            let decoder = JSONDecoder()
            self.ingredients = try decoder.decode([Ingredient].self, from: data)
            print("BAŞARILI: \(ingredients.count) adet zararlı madde yüklendi (\(resourceName)).")
        } catch {
            print("HATA: Veri dönüştürülemedi (\(resourceName)). Sebebi: \(error)")
        }
    }
    
    /// Verilen metin içerisinde riskli bileşenleri arar.
    /// NOT: Burayı, önceden çalışan basit mantığa geri döndürdük:
    /// - Sadece `lowercased()` ile kontrol
    /// - İsim ve alias'ları doğrudan `contains` ile arama
    func checkForRisk(in text: String) -> [Ingredient] {
        let lowercasedText = text.lowercased()
        
        return ingredients.filter { ingredient in
            // 1. İsim Kontrolü
            if lowercasedText.contains(ingredient.name.lowercased()) {
                return true
            }
            
            // 2. Takma Adlar (Aliases)
            for alias in ingredient.aliases {
                if lowercasedText.contains(alias.lowercased()) {
                    return true
                }
            }
            
            return false
        }
    }
}
