import SwiftUI

struct MainView: View {
    var body: some View {
        TabView {
            ScannerView()
                .tabItem {
                    Label("Tara", systemImage: "barcode.viewfinder")
                }
            HistoryView()
                .tabItem {
                    Label("Geçmiş", systemImage: "clock")
                }
            InfoView()
                .tabItem {
                    Label("Bilgi", systemImage: "info.circle")
                }
        }
        .tint(.white)
    }
}

struct HistoryView: View {
    var body: some View {
        ZStack {
            LinearGradient(
                colors: [Color.black, Color.blue.opacity(0.9)],
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()
            
            VStack(spacing: 16) {
                Image(systemName: "clock.arrow.circlepath")
                    .font(.system(size: 50, weight: .semibold))
                    .foregroundColor(.white)
                
                Text("Henüz bir tarama geçmişin yok")
                    .font(.headline)
                    .foregroundColor(.white)
                
                Text("Taramaya başladığında, analiz ettiğin ürünleri burada görebileceksin.")
                    .font(.subheadline)
                    .foregroundColor(.white.opacity(0.7))
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 32)
            }
        }
    }
}

struct InfoView: View {
    var body: some View {
        ZStack {
            LinearGradient(
                colors: [Color.black, Color.blue.opacity(0.9)],
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()
            
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    HStack(spacing: 12) {
                        Image(systemName: "info.circle.fill")
                            .font(.system(size: 34))
                            .foregroundColor(.white)
                        VStack(alignment: .leading) {
                            Text("Ingsight Nedir?")
                                .font(.title2.bold())
                                .foregroundColor(.white)
                            Text("Ürün içeriklerini tarayıp, içindeki potansiyel zararlı maddeleri risk seviyelerine göre gösteren akıllı bir asistan.")
                                .font(.subheadline)
                                .foregroundColor(.white.opacity(0.8))
                        }
                    }
                    
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Öne Çıkan Özellikler")
                            .font(.headline)
                            .foregroundColor(.white)
                        
                        Label("Tamamen offline çalışır, verin cihazı terk etmez.", systemImage: "lock.shield")
                            .foregroundColor(.white.opacity(0.9))
                        Label("Kamera veya galeriden içerik etiketi tarar.", systemImage: "camera.viewfinder")
                            .foregroundColor(.white.opacity(0.9))
                        Label("Zararlı maddeleri risk seviyesine göre renklendirir.", systemImage: "exclamationmark.triangle")
                            .foregroundColor(.white.opacity(0.9))
                    }
                    
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Sorumluluk Reddi")
                            .font(.headline)
                            .foregroundColor(.white)
                        Text("Ingsight medikal bir uygulama değildir. Sağlık kararlarınız için her zaman bir uzmana danışın; uygulama yalnızca bilgilendirme amacı taşır.")
                            .font(.footnote)
                            .foregroundColor(.white.opacity(0.7))
                    }
                }
                .padding(24)
            }
        }
    }
}
