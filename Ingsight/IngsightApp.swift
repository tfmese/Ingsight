import SwiftUI

@main
struct IngsightApp: App {
    @StateObject private var comparisonStore = ComparisonStore()
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(comparisonStore)
        }
    }
}
