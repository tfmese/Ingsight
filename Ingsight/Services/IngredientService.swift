//
//  File.swift
//  Ingsight
//
//  Created by Talha Fırat on 2.02.2026.
//

import Foundation

class IngredientService {
    // Singleton yapısı: Her yerden bu tekil örneğe ulaşacağız.
    static let shared = IngredientService()
    // Yüklenen içerikleri tutacağımız liste
    var ingredients: [Ingredient] = []
    
    private init() {
        loadIngredients()
    }
    
    // JSON dosyasını yükleyen fonksiyon
    private func loadIngredients() {
        print("📁 UYGULAMA PAKETİNDEKİ DOSYALAR KONTROL EDİLİYOR...")
                if let resources = Bundle.main.urls(forResourcesWithExtension: "json", subdirectory: nil) {
                    for file in resources {
                        print(" - Bulunan Dosya: \(file.lastPathComponent)")
                    }
                } else {
                    print(" - Hiç JSON dosyası bulunamadı!")
                }
        // 1. Dosyayı bul
        guard let url = Bundle.main.url(forResource: "toxic_ingredients", withExtension: "json") else {
            print("HATA: JSON dosyası bulunamadı.")
            return
        }
        
        // 2. Veriyi oku ve dönüştür (Decode)
        do {
            let data = try Data(contentsOf: url)
            let decoder = JSONDecoder()
            self.ingredients = try decoder.decode([Ingredient].self, from: data)
            print("BAŞARILI: \(ingredients.count) adet zararlı madde yüklendi.")
        } catch {
            print("HATA: Veri dönüştürülemedi. Sebebi: \(error)")
        }
    }
    
    // Arama Fonksiyonu (İleride kullanacağız)
    // IngredientService.swift


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
