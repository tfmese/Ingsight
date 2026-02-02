import SwiftUI
import SwiftData

@main
struct IngsightApp: App {
    // Xcode'un otomatik eklediği SwiftData konteynerı
    var sharedModelContainer: ModelContainer = {
        let schema = Schema([
            Item.self, // Burayı sonra değiştireceğiz
        ])
        let modelConfiguration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false)

        do {
            return try ModelContainer(for: schema, configurations: [modelConfiguration])
        } catch {
            fatalError("Could not create ModelContainer: \(error)")
        }
    }()

    var body: some Scene {
        WindowGroup {
            ContentView()
                .onAppear {
                    // TEST KODU: Uygulama açılınca servisi tetikle
                    let _ = IngredientService.shared
                    
                    // Sahte bir test yapalım
                    let testText = "İçindekiler: Su, Şeker, MSG ve Palm Yağı içerir."
                    let results = IngredientService.shared.checkForRisk(in: testText)
                    
                    print("--- TEST SONUCU ---")
                    print("Bulunan Riskler:")
                    for risk in results {
                        print("- \(risk.name) (\(risk.riskLevel.rawValue))")
                    }
                    print("-------------------")
                }
        }
        .modelContainer(sharedModelContainer)
    }
}
