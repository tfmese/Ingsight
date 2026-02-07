//
//  ScannerView.swift
//  Ingsight
//

import SwiftUI
import PhotosUI

enum ScanCategory {
    case food
    case cosmetics
    
    var title: String {
        switch self {
        case .food: return "Gıda Tarayıcı"
        case .cosmetics: return "Kozmetik Tarayıcı"
        }
    }
    
    var subtitle: String {
        switch self {
        case .food: return "Gıdalardaki içerikleri, katkı maddelerini ve şüpheli bileşenleri hızlıca tara."
        case .cosmetics: return "Cildine ve saçına temas eden ürünlerin içeriğini güvenle analiz et."
        }
    }
    
    var resultTitle: String {
        switch self {
        case .food: return "Gıda Analizi"
        case .cosmetics: return "Kozmetik Analizi"
        }
    }
    
    var primaryAccent: Color {
        switch self {
        case .food: return Color(red: 0.72, green: 0.75, blue: 0.62)       // champagne / sage accent on dark
        case .cosmetics: return Color(red: 0.85, green: 0.72, blue: 0.88) // soft lilac / rose gold on dark
        }
    }
    
    var headerIconName: String {
        switch self {
        case .food: return "leaf"
        case .cosmetics: return "sparkles"
        }
    }
    
    var badgeLabel: String {
        switch self {
        case .food: return "Gıda"
        case .cosmetics: return "Kozmetik"
        }
    }

    // Arka plan artık PatternBackground içinde (dark base + mesh). Bu gradient diğer yerlerde kullanılıyorsa tutuluyor.
    var backgroundGradient: LinearGradient {
        switch self {
        case .food:
            return LinearGradient(
                colors: [
                    Color(red: 0.12, green: 0.22, blue: 0.16),
                    Color(red: 0.10, green: 0.16, blue: 0.14)
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        case .cosmetics:
            return LinearGradient(
                colors: [
                    Color(red: 0.12, green: 0.08, blue: 0.20),
                    Color(red: 0.14, green: 0.12, blue: 0.18)
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        }
    }

    // Risk kartları — premium dark tema ile uyumlu
    func cardGradient(for risk: RiskLevel) -> LinearGradient {
        switch (self, risk) {
        case (.food, .low):
            let c = Color(red: 0.45, green: 0.55, blue: 0.45)  // sage
            return LinearGradient(colors: [c, c.opacity(0.85)], startPoint: .topLeading, endPoint: .bottomTrailing)
        case (.cosmetics, .low):
            let c = Color(red: 0.68, green: 0.58, blue: 0.78)  // soft lilac
            return LinearGradient(colors: [c, c.opacity(0.85)], startPoint: .topLeading, endPoint: .bottomTrailing)
        case (_, .medium):
            let c = Color(red: 0.82, green: 0.68, blue: 0.52)   // warm gold
            return LinearGradient(colors: [c, c.opacity(0.88)], startPoint: .topLeading, endPoint: .bottomTrailing)
        case (_, .high):
            let c = Color(red: 0.75, green: 0.35, blue: 0.38)
            return LinearGradient(colors: [c, c.opacity(0.88)], startPoint: .topLeading, endPoint: .bottomTrailing)
        }
    }
}

struct ScannerView: View {
    // 1. Canlı Kamera Yöneticisi
    @StateObject private var cameraManager = CameraManager()
    
    // 2. Galeri ve Statik Resim Yöneticisi
    @StateObject private var viewModel: ScannerViewModel
    
    private let category: ScanCategory
    
    init(category: ScanCategory, viewModel: ScannerViewModel) {
        _viewModel = StateObject(wrappedValue: viewModel)
        self.category = category
    }
    
    var body: some View {
        ZStack {
            // Desenli arka plan - organik/görsel zenginlik
            AnimatedPatternBackground(category: category)

            VStack(spacing: 0) {
                if viewModel.isAnalysisScreenPresented {
                    ResultsScreen(
                        category: category,
                        ingredients: viewModel.detectedIngredients,
                        selectedImage: viewModel.selectedImage,
                        onScanAgain: {
                            withAnimation(.spring(response: 0.5, dampingFraction: 0.8)) {
                                viewModel.resetAnalysis()
                                viewModel.reset()
                            }
                        }
                    )
                    .transition(.move(edge: .trailing).combined(with: .opacity))
                } else {
                    CameraScreen(
                        category: category,
                        cameraManager: cameraManager,
                        viewModel: viewModel
                    )
                    .transition(.move(edge: .leading).combined(with: .opacity))
                }
            }
            .animation(.spring(response: 0.5, dampingFraction: 0.9), value: viewModel.isAnalysisScreenPresented)
        }
        .onAppear { cameraManager.start() }
        .onDisappear { cameraManager.stop() }
        .onChange(of: viewModel.selectedImage) { image in
            image != nil ? cameraManager.stop() : cameraManager.start()
        }
    }
}

// MARK: - Kamera Ekranı (CameraView)

struct CameraScreen: View {
    let category: ScanCategory
    @ObservedObject var cameraManager: CameraManager
    @ObservedObject var viewModel: ScannerViewModel

    var body: some View {
        VStack(spacing: 20) {
            // Üst başlık ve AI rozeti
            VStack(alignment: .leading, spacing: 12) {
                HStack(spacing: 10) {
                    Text("AI Powered")
                        .font(.system(size: 13, weight: .bold, design: .rounded))
                        .padding(.horizontal, 10)
                        .padding(.vertical, 6)
                        .background(
                            Capsule()
                                .fill(Color.white.opacity(0.16))
                                .overlay(
                                    Capsule()
                                        .stroke(Color.white.opacity(0.3), lineWidth: 0.8)
                                )
                        )
                        .foregroundColor(.white.opacity(0.9))

                    Spacer()

                    Image(systemName: "shield.lefthalf.filled")
                        .font(.system(size: 20, weight: .semibold))
                        .foregroundColor(.white.opacity(0.9))
                }

                Text(category.title)
                    .font(.system(size: 38, weight: .bold, design: .rounded))
                    .foregroundColor(.white)

                Text(category.subtitle)
                    .font(.system(size: 17, weight: .medium, design: .rounded))
                    .foregroundColor(.white.opacity(0.9))
                    .fixedSize(horizontal: false, vertical: true)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.horizontal, 20)
            .padding(.top, 32)

            // Kamera çerçevesi + tarama overlay
            ZStack {
                RoundedRectangle(cornerRadius: 32, style: .continuous)
                    .fill(
                        LinearGradient(
                            gradient: Gradient(colors: [Color.black.opacity(0.9), Color.black.opacity(0.7)]),
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .overlay(
                        RoundedRectangle(cornerRadius: 32, style: .continuous)
                            .stroke(Color.white.opacity(0.18), lineWidth: 1)
                    )
                    .shadow(color: Color.black.opacity(0.65), radius: 30, x: 0, y: 22)

                ZStack {
                    CameraPreview(session: cameraManager.captureSession)
                        .clipShape(RoundedRectangle(cornerRadius: 28, style: .continuous))
                        .overlay(
                            // Beyaz çerçeve ve renkli köşeler (L şeklinde)
                            RoundedRectangle(cornerRadius: 24, style: .continuous)
                                .stroke(Color.white.opacity(0.85), lineWidth: 1.2)
                        )

                    // Üst overlay: REC ve kamera ikonları
                    HStack {
                        HStack(spacing: 6) {
                            Circle()
                                .fill(Color.red)
                                .frame(width: 10, height: 10)
                                .shadow(color: .red.opacity(0.7), radius: 6)
                            Text("REC")
                                .font(.system(size: 11, weight: .bold, design: .rounded))
                                .foregroundColor(.white.opacity(0.9))
                        }

                        Spacer()

                        Image(systemName: "camera.aperture")
                            .font(.system(size: 18, weight: .semibold, design: .rounded))
                            .foregroundColor(.white.opacity(0.9))
                    }
                    .padding(.horizontal, 18)
                    .padding(.top, 14)
                    .frame(maxHeight: .infinity, alignment: .top)
                }
                .padding(10)
            }
            .frame(height: 320)
            .padding(.horizontal, 20)

            Spacer()

            // Alt kısım – açıklama + büyük çekim butonu
            VStack(spacing: 14) {
                Text("İçerik listesinin fotoğrafını çek veya galeriden yükle.")
                    .font(.system(size: 15, weight: .medium, design: .rounded))
                    .foregroundColor(.white.opacity(0.88))
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 26)

                HStack(spacing: 22) {
                    // Modern galeri butonu - glassmorphism
                    PhotosPicker(selection: $viewModel.selectedItem, matching: .images) {
                        HStack(spacing: 8) {
                            Image(systemName: "photo.on.rectangle")
                                .font(.system(size: 17, weight: .bold, design: .rounded))
                            Text("Galeri")
                                .font(.system(size: 15, weight: .bold, design: .rounded))
                        }
                        .foregroundColor(.white.opacity(0.95))
                        .padding(.horizontal, 18)
                        .padding(.vertical, 12)
                        .background(
                            Capsule()
                                .fill(.ultraThinMaterial)
                                .background(
                                    Capsule()
                                        .fill(
                                            LinearGradient(
                                                colors: [
                                                    Color.white.opacity(0.25),
                                                    Color.white.opacity(0.12)
                                                ],
                                                startPoint: .topLeading,
                                                endPoint: .bottomTrailing
                                            )
                                        )
                                )
                                .overlay(
                                    Capsule()
                                        .stroke(
                                            LinearGradient(
                                                colors: [
                                                    Color.white.opacity(0.5),
                                                    Color.white.opacity(0.2)
                                                ],
                                                startPoint: .topLeading,
                                                endPoint: .bottomTrailing
                                            ),
                                            lineWidth: 1.2
                                        )
                                )
                        )
                        .shadow(color: Color.black.opacity(0.3), radius: 12, x: 0, y: 6)
                    }
                    .buttonStyle(.plain)
                    
                    // Modern kamera butonu - iOS 18+ style
                    Button {
                        withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
                            viewModel.resetAnalysis()
                            viewModel.reset()
                        }
                    } label: {
                        ZStack {
                            // Outer glow
                            Circle()
                                .fill(
                                    RadialGradient(
                                        colors: [
                                            category.primaryAccent.opacity(0.3),
                                            category.primaryAccent.opacity(0)
                                        ],
                                        center: .center,
                                        startRadius: 30,
                                        endRadius: 50
                                    )
                                )
                                .frame(width: 100, height: 100)
                                .blur(radius: 12)
                            
                            // Glassmorphism container
                            Circle()
                                .fill(.ultraThinMaterial)
                                .background(
                                    Circle()
                                        .fill(
                                            LinearGradient(
                                                colors: [
                                                    Color.white.opacity(0.3),
                                                    Color.white.opacity(0.15)
                                                ],
                                                startPoint: .topLeading,
                                                endPoint: .bottomTrailing
                                            )
                                        )
                                )
                                .frame(width: 84, height: 84)
                            
                            // Border
                            Circle()
                                .strokeBorder(
                                    LinearGradient(
                                        colors: [
                                            Color.white.opacity(0.8),
                                            Color.white.opacity(0.4)
                                        ],
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    ),
                                    lineWidth: 2.5
                                )
                                .frame(width: 76, height: 76)
                            
                            // Inner button
                            Circle()
                                .fill(
                                    LinearGradient(
                                        colors: [
                                            Color.white.opacity(0.95),
                                            Color.white.opacity(0.85)
                                        ],
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    )
                                )
                                .frame(width: 64, height: 64)
                                .overlay(
                                    Image(systemName: "camera.fill")
                                        .font(.system(size: 26, weight: .bold, design: .rounded))
                                        .foregroundColor(category.primaryAccent)
                                )
                        }
                        .shadow(color: Color.black.opacity(0.4), radius: 24, x: 0, y: 16)
                        .shadow(color: category.primaryAccent.opacity(0.3), radius: 16, x: 0, y: 8)
                    }
                    .buttonStyle(.plain)
                }
            }
            .padding(.bottom, 36)
        }
        .frame(maxWidth: 430, maxHeight: .infinity, alignment: .top)
    }

}

// MARK: - Sonuç Ekranı (ResultsView)

struct ResultsScreen: View {
    let category: ScanCategory
    let ingredients: [Ingredient]
    let selectedImage: UIImage?
    var onScanAgain: () -> Void

    // Basit skor mantığı
    private var safeCount: Int {
        ingredients.filter { $0.riskLevel == .low }.count
    }
    private var cautionCount: Int {
        ingredients.filter { $0.riskLevel == .medium }.count
    }
    private var avoidCount: Int {
        ingredients.filter { $0.riskLevel == .high }.count
    }

    /// Skor: 100’den başlayıp madde sayısına göre düşer. Yüksek/orta risk ve çok sayıda madde skoru daha belirgin düşürür.
    private var score: Int {
        guard !ingredients.isEmpty else { return 98 } // Hiç risk yok
        let puan = 100
            - (avoidCount * 8)    // Yüksek risk: madde başı 8 puan
            - (cautionCount * 4)  // Orta risk: madde başı 4 puan
            - (safeCount * 2)     // Düşük risk: madde başı 2 puan (çok madde = daha düşük skor)
        return min(98, max(22, puan))
    }

    private var scoreLabel: String {
        if score <= 45 { return "Yüksek Risk" }
        if score <= 70 { return "Dikkatli Kullan" }
        if score <= 90 { return "Genelde Güvenli" }
        return "Çok Güvenli"
    }

    private var scoreColor: Color {
        if score <= 40 { return .red }
        if score <= 65 { return .orange }
        return .green
    }

    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(spacing: 20) {
                // Üst bar: başlık + Tekrar Tara
                HStack {
                    VStack(alignment: .leading, spacing: 6) {
                        Text(category.resultTitle)
                            .font(.system(size: 28, weight: .bold, design: .rounded))
                            .foregroundColor(.white)
                        Text("Ürün içeriği, risk seviyesine göre analiz edildi.")
                            .font(.system(size: 14, weight: .medium, design: .rounded))
                            .foregroundColor(.white.opacity(0.88))
                    }

                    Spacer()

                    Button(action: onScanAgain) {
                        HStack(spacing: 6) {
                            Image(systemName: "arrow.counterclockwise")
                            Text("Tekrar Tara")
                        }
                        .font(.system(size: 14, weight: .bold, design: .rounded))
                        .padding(.horizontal, 14)
                        .padding(.vertical, 9)
                        .background(
                            RoundedRectangle(cornerRadius: 24, style: .continuous)
                                .fill(.ultraThinMaterial)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 24, style: .continuous)
                                        .stroke(Color.white.opacity(0.45), lineWidth: 0.9)
                                )
                        )
                        .foregroundColor(.white)
                    }
                }
                .padding(.top, 32)
                .padding(.horizontal, 20)

                // Skor kartı + ürün görseli
                HStack(alignment: .top, spacing: 16) {
                    scoreCard
                    productCard
                }
                .padding(.horizontal, 20)

                // 3 kolonlu istatistik grid
                statsGrid
                    .padding(.horizontal, 20)

                // İçerik kartları listesi
                VStack(alignment: .leading, spacing: 12) {
                    Text("İçindekiler Analizi")
                        .font(.system(size: 18, weight: .bold, design: .rounded))
                        .foregroundColor(.white.opacity(0.95))
                        .padding(.horizontal, 4)

                    if ingredients.isEmpty {
                        SafeIngredientCard(category: category)
                    } else {
                        VStack(spacing: 10) {
                            ForEach(ingredients) { ingredient in
                                RiskIngredientCard(
                                    ingredient: ingredient,
                                    category: category,
                                    contextLabel: category.badgeLabel
                                )
                            }
                        }
                    }
                }
                .padding(.horizontal, 20)
                .padding(.bottom, 40)
            }
        }
        .frame(maxWidth: 430, maxHeight: .infinity, alignment: .top)
    }

    private var scoreCard: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack(spacing: 10) {
                ZStack {
                    Circle()
                        .fill(Color.white.opacity(0.12))
                        .frame(width: 40, height: 40)
                    Circle()
                        .fill(Color.white.opacity(0.18))
                        .frame(width: 28, height: 28)
                    Image(systemName: category.headerIconName)
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(.white)
                }

                VStack(alignment: .leading, spacing: 4) {
                    Text("Güvenlik Skoru")
                        .font(.system(size: 13, weight: .semibold, design: .rounded))
                        .foregroundColor(.white.opacity(0.85))
                    Text(scoreLabel)
                        .font(.system(size: 16, weight: .bold, design: .rounded))
                        .foregroundColor(scoreColor)
                }
            }

            HStack(alignment: .firstTextBaseline, spacing: 4) {
                Text("\(score)")
                    .font(.system(size: 44, weight: .bold, design: .rounded))
                    .foregroundColor(.white)
                Text("/100")
                    .font(.system(size: 18, weight: .semibold, design: .rounded))
                    .foregroundColor(.white.opacity(0.85))
            }

            ZStack(alignment: .leading) {
                RoundedRectangle(cornerRadius: 999, style: .continuous)
                    .fill(Color.white.opacity(0.18))
                GeometryReader { proxy in
                    let width = proxy.size.width * CGFloat(score) / 100.0
                    RoundedRectangle(cornerRadius: 999, style: .continuous)
                        .fill(
                            LinearGradient(
                                gradient: Gradient(colors: [
                                    Color.white,
                                    scoreColor
                                ]),
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .frame(width: width)
                        .shadow(color: scoreColor.opacity(0.6), radius: 12, x: 0, y: 6)
                }
            }
            .frame(height: 10)

            Text(hintText)
                .font(.system(size: 12, weight: .medium, design: .rounded))
                .foregroundColor(.white.opacity(0.85))
                .fixedSize(horizontal: false, vertical: true)
        }
        .padding(20)
        .background(
            // Modern glassmorphism - iOS 18+ style
            RoundedRectangle(cornerRadius: 28, style: .continuous)
                .fill(.ultraThinMaterial)
                .background(
                    // Subtle gradient overlay
                    RoundedRectangle(cornerRadius: 28, style: .continuous)
                        .fill(
                            LinearGradient(
                                colors: [
                                    Color.white.opacity(0.18),
                                    Color.white.opacity(0.08)
                                ],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                )
        )
        .overlay(
            // Modern border - subtle glow
            RoundedRectangle(cornerRadius: 28, style: .continuous)
                .stroke(
                    LinearGradient(
                        colors: [
                            Color.white.opacity(0.4),
                            Color.white.opacity(0.15)
                        ],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    ),
                    lineWidth: 1.2
                )
        )
        .shadow(color: Color.black.opacity(0.4), radius: 30, x: 0, y: 20)
        .shadow(color: Color.black.opacity(0.2), radius: 10, x: 0, y: 5)
    }

    private var productCard: some View {
        VStack(alignment: .leading, spacing: 8) {
            ZStack {
                RoundedRectangle(cornerRadius: 28, style: .continuous)
                    .fill(.ultraThinMaterial)
                    .background(
                        RoundedRectangle(cornerRadius: 28, style: .continuous)
                            .fill(Color.white.opacity(0.14))
                    )
                    .overlay(
                        RoundedRectangle(cornerRadius: 28, style: .continuous)
                            .stroke(Color.white.opacity(0.2), lineWidth: 0.8)
                    )

                VStack(spacing: 10) {
                    if let image = selectedImage {
                        // Gerçek ürün görselini göster
                        Image(uiImage: image)
                            .resizable()
                            .scaledToFill()
                            .frame(width: 90, height: 70)
                            .clipped()
                            .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
                            .overlay(
                                RoundedRectangle(cornerRadius: 18, style: .continuous)
                                    .stroke(Color.white.opacity(0.35), lineWidth: 0.8)
                            )
                            .shadow(color: Color.black.opacity(0.55), radius: 12, x: 0, y: 8)
                    } else {
                        // Yedek ikon
                        ImageWithFallback(systemName: "shippingbox.and.arrow.backward")
                            .frame(width: 56, height: 56)
                    }
                    
                    Text("Taradığın Ürün")
                        .font(.system(size: 13, weight: .bold, design: .rounded))
                        .foregroundColor(.white.opacity(0.9))
                        .lineLimit(1)
                }
                .padding(14)
            }

            Text(ingredients.isEmpty ? "Şüpheli içerik bulunamadı." : "İçerik listesi analizi tamamlandı.")
                .font(.system(size: 12, weight: .medium, design: .rounded))
                .foregroundColor(.white.opacity(0.85))
        }
        .frame(width: 150)
    }

    private var statsGrid: some View {
        HStack(spacing: 10) {
            statItem(
                title: "Güvenli",
                value: safeCount,
                icon: "arrow.up.right",
                color: .green
            )
            statItem(
                title: "Dikkat",
                value: cautionCount,
                icon: "minus",
                color: .orange
            )
            statItem(
                title: "Kaçın",
                value: avoidCount,
                icon: "arrow.down.right",
                color: .red
            )
        }
    }

    private func statItem(title: String, value: Int, icon: String, color: Color) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack(spacing: 8) {
                // Icon container - modern pill shape
                ZStack {
                    Circle()
                        .fill(color.opacity(0.2))
                        .frame(width: 32, height: 32)
                    Image(systemName: icon)
                        .font(.system(size: 14, weight: .bold, design: .rounded))
                        .foregroundColor(color)
                }
                
                Text(title)
                    .font(.system(size: 13, weight: .bold, design: .rounded))
                    .foregroundColor(.white.opacity(0.95))
            }

            Text("\(value)")
                .font(.system(size: 28, weight: .bold, design: .rounded))
                .foregroundColor(.white)
                .padding(.top, 2)

            // Modern progress indicator
            Capsule()
                .fill(
                    LinearGradient(
                        gradient: Gradient(colors: [
                            color.opacity(0.95),
                            color.opacity(0.75)
                        ]),
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                )
                .frame(height: 5)
                .shadow(color: color.opacity(0.6), radius: 6, x: 0, y: 3)
        }
        .padding(16)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            // Glassmorphism stat card
            RoundedRectangle(cornerRadius: 24, style: .continuous)
                .fill(.ultraThinMaterial)
                .background(
                    RoundedRectangle(cornerRadius: 24, style: .continuous)
                        .fill(
                            LinearGradient(
                                colors: [
                                    Color.white.opacity(0.15),
                                    Color.white.opacity(0.05)
                                ],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                )
        )
        .overlay(
            RoundedRectangle(cornerRadius: 24, style: .continuous)
                .stroke(
                    LinearGradient(
                        colors: [
                            Color.white.opacity(0.35),
                            Color.white.opacity(0.12)
                        ],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    ),
                    lineWidth: 1
                )
        )
        .shadow(color: Color.black.opacity(0.35), radius: 20, x: 0, y: 12)
        .shadow(color: Color.black.opacity(0.15), radius: 8, x: 0, y: 4)
    }

    private var hintText: String {
        switch category {
        case .food:
            if avoidCount > 0 {
                return "İçerikte yüksek riskli katkı veya bileşenler var. Mümkünse daha az işlenmiş veya daha temiz içerikli alternatiflere yönelebilirsin."
            } else if cautionCount > 0 {
                return "Bazı katkı maddeleri özellikle sık veya yüksek miktarda tüketimde sorun yaratabilir. Porsiyon ve tüketim sıklığını göz önünde bulundur."
            } else if ingredients.isEmpty {
                return "Etikette bilinen riskli veya tartışmalı bileşenlere rastlanmadı. Kişisel alerji ve hassasiyetlerini yine de göz önünde bulundur."
            } else {
                return "İçerik listesi genel olarak temiz görünüyor. Uzun vadede dengeli beslenme ve çeşitlilik önemli."
            }
        case .cosmetics:
            if avoidCount > 0 {
                return "İçerikte yüksek riskli maddeler bulunuyor. Mümkünse daha temiz formüllü veya doğal içerikli alternatiflere yönelebilirsin."
            } else if cautionCount > 0 {
                return "Bazı bileşenler hassas ciltler veya uzun süreli kullanım için ideal olmayabilir. Doz ve uygulama sıklığını gözlemle."
            } else if ingredients.isEmpty {
                return "Etikette bilinen riskli veya tartışmalı bileşenlere rastlanmadı. Kişisel alerji ve cilt hassasiyetini yine de göz önünde bulundur."
            } else {
                return "İçerik listesi genel olarak temiz görünüyor. Özellikle yüz ve saç derisine uygulanan ürünlerde içerik takibi faydalı olabilir."
            }
        }
    }
}

// Küçük özellik etiketi bileşeni
struct FeatureChip: View {
    let icon: String
    let text: String
    
    var body: some View {
        HStack(spacing: 6) {
            Image(systemName: icon)
                .font(.system(size: 11, weight: .bold, design: .rounded))
            Text(text)
                .font(.system(size: 11, weight: .semibold, design: .rounded))
        }
        .padding(.horizontal, 10)
        .padding(.vertical, 6)
        .background(
            Capsule()
                .fill(Color.white)
                .shadow(color: Color.black.opacity(0.04), radius: 4, x: 0, y: 2)
        )
        .foregroundColor(.primary)
    }
}

// Köşe yuvarlama eklentisi
extension View {
    func cornerRadius(_ radius: CGFloat, corners: UIRectCorner) -> some View {
        clipShape(RoundedCorner(radius: radius, corners: corners))
    }
}

struct RoundedCorner: Shape {
    var radius: CGFloat = .infinity
    var corners: UIRectCorner = .allCorners
    func path(in rect: CGRect) -> Path {
        let path = UIBezierPath(roundedRect: rect, byRoundingCorners: corners, cornerRadii: CGSize(width: radius, height: radius))
        return Path(path.cgPath)
    }
}
