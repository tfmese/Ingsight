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
        case .food: return Color.green
        case .cosmetics: return Color.purple
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

    // Sayfa arka planı için gradient (Tailwind benzeri)
    var backgroundGradient: LinearGradient {
        switch self {
        case .food:
            // from-green-400 via-emerald-500 to-teal-600
            return LinearGradient(
                gradient: Gradient(colors: [
                    Color(red: 0.22, green: 0.87, blue: 0.53),   // green-400
                    Color(red: 0.09, green: 0.72, blue: 0.53),   // emerald-500
                    Color(red: 0.03, green: 0.55, blue: 0.62)    // teal-600
                ]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        case .cosmetics:
            // from-pink-400 via-rose-500 to-purple-600
            return LinearGradient(
                gradient: Gradient(colors: [
                    Color(red: 0.97, green: 0.53, blue: 0.75),   // pink-400
                    Color(red: 0.94, green: 0.42, blue: 0.57),   // rose-500
                    Color(red: 0.58, green: 0.27, blue: 0.88)    // purple-600
                ]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        }
    }

    // Risk kartları için gradient
    func cardGradient(for risk: RiskLevel) -> LinearGradient {
        switch (self, risk) {
        case (.food, .low):
            return LinearGradient(
                gradient: Gradient(colors: [
                    Color(red: 0.21, green: 0.83, blue: 0.44),
                    Color(red: 0.09, green: 0.68, blue: 0.47)
                ]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        case (.cosmetics, .low):
            return LinearGradient(
                gradient: Gradient(colors: [
                    Color(red: 0.98, green: 0.56, blue: 0.79),
                    Color(red: 0.89, green: 0.40, blue: 0.90)
                ]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        case (_, .medium):
            return LinearGradient(
                gradient: Gradient(colors: [
                    Color.orange,
                    Color(red: 0.91, green: 0.59, blue: 0.19)
                ]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        case (_, .high):
            return LinearGradient(
                gradient: Gradient(colors: [
                    Color.red,
                    Color(red: 0.75, green: 0.11, blue: 0.23)
                ]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
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
            // Sayfa tematik gradient arka plan
            category.backgroundGradient
                .ignoresSafeArea()

            // Büyük bulanık daireler ile derinlik (opacity-10..20, blur-3xl)
            ZStack {
                Circle()
                    .fill(Color.white.opacity(0.16))
                    .frame(width: 380, height: 380)
                    .blur(radius: 60)
                    .offset(x: -160, y: -420)

                Circle()
                    .fill(Color.white.opacity(0.10))
                    .frame(width: 260, height: 260)
                    .blur(radius: 50)
                    .offset(x: 140, y: -260)

                Circle()
                    .fill(Color.black.opacity(0.25))
                    .frame(width: 420, height: 420)
                    .blur(radius: 90)
                    .offset(x: 0, y: 420)
            }
            .ignoresSafeArea()

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
                        .font(.caption.bold())
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
                    .font(.system(size: 34, weight: .heavy, design: .rounded))
                    .foregroundColor(.white)

                Text(category.subtitle)
                    .font(.callout)
                    .foregroundColor(.white.opacity(0.82))
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
                                .font(.caption2.bold())
                                .foregroundColor(.white.opacity(0.85))
                        }

                        Spacer()

                        Image(systemName: "camera.aperture")
                            .font(.system(size: 18, weight: .medium))
                            .foregroundColor(.white.opacity(0.85))
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
                Text("Etiket üzerindeki içerik listesini kare içine hizala veya galeriden bir fotoğraf seç.")
                    .font(.footnote)
                    .foregroundColor(.white.opacity(0.75))
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 26)

                HStack(spacing: 22) {
                    // Galeri butonu (küçük kapsül)
                    PhotosPicker(selection: $viewModel.selectedItem, matching: .images) {
                        HStack(spacing: 6) {
                            Image(systemName: "photo.on.rectangle")
                                .font(.system(size: 16, weight: .semibold))
                            Text("Galeri")
                                .font(.caption.bold())
                        }
                        .foregroundColor(.white.opacity(0.9))
                        .padding(.horizontal, 14)
                        .padding(.vertical, 10)
                        .background(
                            Capsule()
                                .fill(Color.white.opacity(0.16))
                        )
                    }
                    .buttonStyle(.plain)
                    
                    // Ortadaki büyük dairesel "çekim" butonu (şimdilik reset + canlı önizleme)
                    Button {
                        withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
                            viewModel.resetAnalysis()
                            viewModel.reset()
                        }
                    } label: {
                        ZStack {
                            Circle()
                                .fill(Color.white.opacity(0.14))
                                .frame(width: 80, height: 80)
                            
                            Circle()
                                .strokeBorder(Color.white.opacity(0.65), lineWidth: 2)
                                .frame(width: 72, height: 72)
                            
                            Circle()
                                .fill(
                                    LinearGradient(
                                        gradient: Gradient(colors: [
                                            Color.white,
                                            Color.white.opacity(0.9)
                                        ]),
                                        startPoint: .top,
                                        endPoint: .bottom
                                    )
                                )
                                .frame(width: 60, height: 60)
                                .overlay(
                                    Image(systemName: "camera.fill")
                                        .font(.system(size: 22, weight: .semibold))
                                        .foregroundColor(category.primaryAccent)
                                )
                        }
                        .shadow(color: Color.black.opacity(0.55), radius: 16, x: 0, y: 10)
                    }
                    .buttonStyle(.plain)
                }
            }
            .padding(.bottom, 36)
        }
        .frame(maxWidth: 430, maxHeight: .infinity, alignment: .top)
    }

    // (Merkezleme için kullandığımız nişangah/köşe çizgilerini kaldırdık)
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

    private var score: Int {
        if avoidCount > 0 { return 35 }
        if cautionCount > 0 { return 65 }
        if !ingredients.isEmpty { return 95 }
        // Tamamen temiz – ekstra güvenli
        return 98
    }

    private var scoreLabel: String {
        if avoidCount > 0 { return "Yüksek Risk" }
        if cautionCount > 0 { return "Dikkatli Kullan" }
        if ingredients.isEmpty { return "Çok Güvenli" }
        return "Genelde Güvenli"
    }

    private var scoreColor: Color {
        if avoidCount > 0 { return .red }
        if cautionCount > 0 { return .orange }
        return .green
    }

    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(spacing: 20) {
                // Üst bar: başlık + Tekrar Tara
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        Text(category.resultTitle)
                            .font(.system(size: 26, weight: .heavy, design: .rounded))
                            .foregroundColor(.white)
                        Text("Ürün içeriği, risk seviyesine göre analiz edildi.")
                            .font(.footnote)
                            .foregroundColor(.white.opacity(0.78))
                    }

                    Spacer()

                    Button(action: onScanAgain) {
                        HStack(spacing: 6) {
                            Image(systemName: "arrow.counterclockwise")
                            Text("Tekrar Tara")
                        }
                        .font(.caption.bold())
                        .padding(.horizontal, 12)
                        .padding(.vertical, 8)
                        .background(
                            RoundedRectangle(cornerRadius: 22, style: .continuous)
                                .fill(.ultraThinMaterial)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 22, style: .continuous)
                                        .stroke(Color.white.opacity(0.4), lineWidth: 0.8)
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
                        .font(.headline)
                        .foregroundColor(.white.opacity(0.9))
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

                VStack(alignment: .leading, spacing: 2) {
                    Text("Güvenlik Skoru")
                        .font(.caption)
                        .foregroundColor(.white.opacity(0.7))
                    Text(scoreLabel)
                        .font(.subheadline.bold())
                        .foregroundColor(scoreColor)
                }
            }

            HStack(alignment: .firstTextBaseline, spacing: 4) {
                Text("\(score)")
                    .font(.system(size: 40, weight: .heavy, design: .rounded))
                    .foregroundColor(.white)
                Text("/100")
                    .font(.headline.weight(.semibold))
                    .foregroundColor(.white.opacity(0.7))
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
                .font(.caption2)
                .foregroundColor(.white.opacity(0.75))
                .fixedSize(horizontal: false, vertical: true)
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 32, style: .continuous)
                .fill(.ultraThinMaterial)
                .background(
                    RoundedRectangle(cornerRadius: 32, style: .continuous)
                        .fill(Color.white.opacity(0.12))
                )
        )
        .overlay(
            RoundedRectangle(cornerRadius: 32, style: .continuous)
                .stroke(Color.white.opacity(0.28), lineWidth: 1)
        )
        .shadow(color: Color.black.opacity(0.55), radius: 22, x: 0, y: 16)
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
                        .font(.caption.bold())
                        .foregroundColor(.white.opacity(0.85))
                        .lineLimit(1)
                }
                .padding(14)
            }

            Text(ingredients.isEmpty ? "Şüpheli içerik bulunamadı." : "İçerik listesi analizi tamamlandı.")
                .font(.caption2)
                .foregroundColor(.white.opacity(0.75))
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
        VStack(alignment: .leading, spacing: 6) {
            HStack(spacing: 6) {
                Image(systemName: icon)
                    .font(.system(size: 13, weight: .bold))
                Text(title)
                    .font(.caption.bold())
            }
            .foregroundColor(.white.opacity(0.85))

            Text("\(value)")
                .font(.headline.weight(.semibold))
                .foregroundColor(.white)

            Capsule()
                .fill(
                    LinearGradient(
                        gradient: Gradient(colors: [
                            color.opacity(0.9),
                            color.opacity(0.6)
                        ]),
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                )
                .frame(height: 4)
                .shadow(color: color.opacity(0.7), radius: 8, x: 0, y: 4)
        }
        .padding(12)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            RoundedRectangle(cornerRadius: 22, style: .continuous)
                .fill(.ultraThinMaterial)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 22, style: .continuous)
                .stroke(Color.white.opacity(0.2), lineWidth: 0.8)
        )
        .shadow(color: Color.black.opacity(0.45), radius: 14, x: 0, y: 10)
    }

    private var hintText: String {
        if avoidCount > 0 {
            return "İçerikte yüksek riskli maddeler bulunuyor. Mümkünse alternatif, daha temiz içerikli ürünler tercih et."
        } else if cautionCount > 0 {
            return "Bazı bileşenler hassas ciltler veya uzun süreli kullanım için ideal olmayabilir. Düzenli kullanımda doz ve sıklığı gözlemle."
        } else if ingredients.isEmpty {
            return "Etikette bilinen riskli veya tartışmalı bileşenlere rastlanmadı. Yine de kişisel alerji ve hassasiyetlerini göz önünde bulundur."
        } else {
            return "İçerik listesi genel olarak temiz görünüyor. Yine de uzun isimli kimyasal bileşenleri ara sıra gözden geçirmek faydalı olabilir."
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
                .font(.system(size: 11, weight: .semibold))
            Text(text)
                .font(.caption2)
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
