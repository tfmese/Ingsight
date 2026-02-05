import Combine
import SwiftUI
import Vision
import PhotosUI

class ScannerViewModel: ObservableObject {
    // Arayüzün dinleyeceği değişkenler
    @Published var selectedImage: UIImage? = nil
    @Published var recognizedText: String = ""
    @Published var isAnalyzing: Bool = false
    @Published var detectedIngredients: [Ingredient] = []
    @Published var isAnalysisScreenPresented: Bool = false
    private let ingredientService: IngredientService
    
    init(service: IngredientService = .shared) {
        self.ingredientService = service
    }
    
    @Published var selectedItem: PhotosPickerItem? = nil {
        didSet {
            // Seçim yapıldığında otomatik olarak yükleme işlemini başlat
            if selectedItem != nil {
                Task {
                    await loadPhoto()
                }
            }
        }
    }
    
    // Yardımcı Durumlar (İsteğe bağlı: yükleniyor göstergesi için)
    @Published var isScanning: Bool = false
    
    // Fotoğrafı Galeriden Yükleme
    @MainActor
    func loadPhoto() async {
        guard let item = selectedItem else { return }
        
        do {
            // Datayı resme çevir
            if let data = try? await item.loadTransferable(type: Data.self),
               let image = UIImage(data: data) {
                
                self.selectedImage = image
                self.recognizedText = "" // Önceki yazıyı temizle
                
                // Resmi yükler yüklemez taramayı başlat
                recognizeText(from: image)
            }
        } catch {
            print("Fotoğraf yükleme hatası: \(error.localizedDescription)")
        }
    }
    
    // OCR İşlemi (Vision)
    func recognizeText(from image: UIImage) {
        self.isScanning = true
        
        guard let cgImage = image.cgImage else {
            self.isScanning = false
            return
        }

        // İşleyiciyi çalıştır (Arka planda)
        let cgImageForWork = cgImage
        DispatchQueue.global(qos: .userInitiated).async { [weak self] in
            guard let self = self else { return }
            // Vision İsteği
            let request = VNRecognizeTextRequest { [weak self] request, error in
                guard let self = self else { return }

                if let error = error {
                    print("Vision Hatası: \(error.localizedDescription)")
                    DispatchQueue.main.async { self.isScanning = false }
                    return
                }

                // Sonuçları al
                guard let observations = request.results as? [VNRecognizedTextObservation] else {
                    DispatchQueue.main.async { self.isScanning = false }
                    return
                }

                let recognizedString = observations.compactMap { observation in
                    observation.topCandidates(1).first?.string
                }.joined(separator: "\n")

                // UI Güncellemesi (Main Thread)
                    DispatchQueue.main.async {
                        self.recognizedText = recognizedString
                        self.isScanning = false
                        
                        // METİN OKUNDU, ŞİMDİ ANALİZ ET:
                        self.analyzeIngredients()
                    }
            }

            // Ayarlar
            request.recognitionLevel = .accurate
            request.usesLanguageCorrection = true

            // İşleyiciyi çalıştır
            let requestHandler = VNImageRequestHandler(cgImage: cgImageForWork, options: [:])
            try? requestHandler.perform([request])
        }
    }



    @MainActor // 👈 Bu işaret, tüm işlemlerin güvenli olan Ana Thread'de yapılmasını sağlar
    func analyzeIngredients() {
        // Boş kontrolü
        guard !recognizedText.isEmpty else { return }
        
        self.isAnalyzing = true
        
        // Doğrudan servisi çağırıyoruz (DispatchQueue.global YOK)
        // String karşılaştırması milisaniyeler sürer, UI'ı dondurmaz.
        let matches = ingredientService.checkForRisk(in: recognizedText)
        
        // DEBUG: Konsola biraz daha detay yazalım
        print("🔍 OCR Metni Uzunluğu: \(recognizedText.count) karakter")
        print("🔍 Toplam veri tabanı kaydı: \(ingredientService.ingredients.count)")
        print("🔍 Bulunan eşleşme sayısı: \(matches.count)")
        
        // Sonuçları işle
        self.detectedIngredients = matches
        self.isAnalyzing = false
        // Sonuç modalını aç
        self.isAnalysisScreenPresented = true
        // Konsol çıktısı
        if matches.isEmpty {
            print("✅ Temiz")
        } else {
            print("⚠️ BULUNANLAR: \(matches.map { $0.name })")
        }
    }
    
    
    // Temizleme Fonksiyonu
    func reset() {
        selectedImage = nil
        selectedItem = nil
        recognizedText = ""
        detectedIngredients.removeAll()
        isAnalysisScreenPresented = false
    }
    
    func resetAnalysis() {
        detectedIngredients.removeAll()
        isAnalysisScreenPresented = false
    }
}

