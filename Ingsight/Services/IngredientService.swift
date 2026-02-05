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
    
    /// Kısa metinler (≤3 karakter) sadece kelime sınırında eşleşir; yoksa "as", "mek", "mi" gibi alias'lar
    /// başka kelimelerin içinde yanlış pozitif verir (ör. "yemek", "pas", "minimum").
    private static let maxLengthForWordBoundary = 3
    
    /// Metinde `needle` tam kelime olarak (başka harf/rakamın parçası olmadan) geçiyor mu?
    private static func textContainsAsWord(_ text: String, needle: String) -> Bool {
        let lower = text.lowercased()
        let n = needle.lowercased()
        guard !n.isEmpty else { return false }
        
        var start = lower.startIndex
        while start < lower.endIndex,
              let range = lower.range(of: n, range: start..<lower.endIndex) {
            let before = range.lowerBound == lower.startIndex
                ? true
                : !lower[lower.index(before: range.lowerBound)].isLetter && !lower[lower.index(before: range.lowerBound)].isNumber
            let after = range.upperBound == lower.endIndex
                ? true
                : !lower[range.upperBound].isLetter && !lower[range.upperBound].isNumber
            if before && after { return true }
            start = range.upperBound
        }
        return false
    }
    
    /// Verilen metin içerisinde riskli bileşenleri arar.
    /// Kısa isim/alias (≤3 karakter) sadece kelime sınırında aranır; yanlış eşleşme önlenir.
    func checkForRisk(in text: String) -> [Ingredient] {
        let lowercasedText = text.lowercased()
        
        return ingredients.filter { ingredient in
            let name = ingredient.name.lowercased()
            // 1. İsim kontrolü
            if name.count <= Self.maxLengthForWordBoundary {
                if Self.textContainsAsWord(lowercasedText, needle: name) { return true }
            } else {
                if lowercasedText.contains(name) { return true }
            }
            
            // 2. Takma adlar
            for alias in ingredient.aliases {
                let a = alias.lowercased()
                if a.count <= Self.maxLengthForWordBoundary {
                    if Self.textContainsAsWord(lowercasedText, needle: a) { return true }
                } else {
                    if lowercasedText.contains(a) { return true }
                }
            }
            
            return false
        }
    }
}
