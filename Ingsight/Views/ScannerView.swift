//
//  ScannerView.swift
//  Ingsight
//

import SwiftUI
import PhotosUI
import AVFoundation

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
    
    /// Ana vurgu rengi (detaylarda kullanılır). Gıda: sarı, Kozmetik: magenta.
    var primaryAccent: Color {
        switch self {
        case .food:
            return Color(red: 0.90, green: 0.72, blue: 0.22)
        case .cosmetics:
            return Color(red: 0.82, green: 0.28, blue: 0.68)
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

    var backgroundGradient: LinearGradient {
        LinearGradient(
            colors: [Color.white, Color(red: 0.98, green: 0.98, blue: 0.98)],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }

    // Risk kartları — beyaz arka plan, siyah metin, detayda sarı/pembe veya risk rengi
    func cardGradient(for risk: RiskLevel) -> LinearGradient {
        switch (self, risk) {
        case (.food, .low):
            let base = Color.white
            let accent = primaryAccent.opacity(0.25)
            return LinearGradient(
                colors: [base, base, accent],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        case (.cosmetics, .low):
            let base = Color.white
            let accent = primaryAccent.opacity(0.25)
            return LinearGradient(
                colors: [base, base, accent],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        case (_, .medium):
            let base = Color(red: 0.99, green: 0.98, blue: 0.96)
            let accent = Color(red: 0.95, green: 0.78, blue: 0.46).opacity(0.4)
            return LinearGradient(
                colors: [base, accent],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        case (_, .high):
            let base = Color(red: 0.99, green: 0.96, blue: 0.96)
            let accent = Color(red: 0.90, green: 0.45, blue: 0.45).opacity(0.35)
            return LinearGradient(
                colors: [base, accent],
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

// MARK: - Animasyonlu kamera çerçevesi (scan çizgisi + border glow)

struct AnimatedCameraPreviewFrame: View {
    let category: ScanCategory
    let session: AVCaptureSession
    
    @State private var scanLineProgress: CGFloat = 0
    @State private var borderGlowOpacity: Double = 0.35
    @State private var appeared = false
    
    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 32, style: .continuous)
                .fill(
                    LinearGradient(
                        colors: [Color.black.opacity(0.92), Color.black.opacity(0.78)],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 32, style: .continuous)
                        .strokeBorder(
                            LinearGradient(
                                colors: [
                                    category.primaryAccent.opacity(borderGlowOpacity),
                                    category.primaryAccent.opacity(borderGlowOpacity * 0.5),
                                    Color.black.opacity(0.15)
                                ],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            ),
                            lineWidth: 2
                        )
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 32, style: .continuous)
                        .stroke(Color.black.opacity(0.2), lineWidth: 1)
                )
                .shadow(color: Color.black.opacity(0.25), radius: 20, x: 0, y: 10)
                .shadow(color: category.primaryAccent.opacity(0.15), radius: 24, x: 0, y: 12)
                .scaleEffect(appeared ? 1 : 0.96)
                .opacity(appeared ? 1 : 0)

            ZStack {
                CameraPreview(session: session)
                    .clipShape(RoundedRectangle(cornerRadius: 28, style: .continuous))
                    .overlay(
                        RoundedRectangle(cornerRadius: 26, style: .continuous)
                            .stroke(Color.white.opacity(0.25), lineWidth: 1.5)
                    )
                    .overlay(scanLineOverlay)
                    .overlay(cornerAccentOverlay)

                HStack {
                    HStack(spacing: 6) {
                        Circle()
                            .fill(Color.red)
                            .frame(width: 10, height: 10)
                            .shadow(color: .red.opacity(0.8), radius: 4)
                        Text("REC")
                            .font(AppTypography.captionBold)
                            .foregroundColor(.white)
                    }
                    Spacer()
                    Image(systemName: "camera.aperture")
                        .font(.system(size: 18, weight: .bold, design: .rounded))
                        .foregroundColor(.white)
                }
                .padding(.horizontal, 18)
                .padding(.top, 14)
                .frame(maxHeight: .infinity, alignment: .top)
            }
            .padding(10)
        }
        .onAppear {
            withAnimation(.easeOut(duration: 0.4)) {
                appeared = true
            }
            startScanLineAnimation()
            startBorderGlowAnimation()
        }
        .onChange(of: category) { _ in
            startScanLineAnimation()
        }
    }
    
    private var scanLineOverlay: some View {
        GeometryReader { geo in
            let w = geo.size.width
            let h = max(geo.size.height, 280)
            ZStack(alignment: .top) {
                Color.clear
                Rectangle()
                    .fill(
                        LinearGradient(
                            colors: [
                                Color.clear,
                                category.primaryAccent.opacity(0.45),
                                category.primaryAccent.opacity(0.65),
                                category.primaryAccent.opacity(0.45),
                                Color.clear
                            ],
                            startPoint: .top,
                            endPoint: .bottom
                        )
                    )
                    .frame(width: w, height: 4)
                    .blur(radius: 1)
                    .offset(y: scanLineProgress * h)
            }
            .frame(width: w, height: geo.size.height)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .clipShape(RoundedRectangle(cornerRadius: 26, style: .continuous))
    }
    
    private var cornerAccentOverlay: some View {
        RoundedRectangle(cornerRadius: 26, style: .continuous)
            .strokeBorder(
                LinearGradient(
                    colors: [
                        category.primaryAccent.opacity(0.5),
                        category.primaryAccent.opacity(0.2),
                        Color.clear,
                        Color.clear
                    ],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                ),
                lineWidth: 2
            )
    }
    
    private func startScanLineAnimation() {
        scanLineProgress = 0
        withAnimation(
            .linear(duration: 2.2)
            .repeatForever(autoreverses: true)
        ) {
            scanLineProgress = 1
        }
    }
    
    private func startBorderGlowAnimation() {
        withAnimation(
            .easeInOut(duration: 1.8)
            .repeatForever(autoreverses: true)
        ) {
            borderGlowOpacity = 0.6
        }
    }
}

// MARK: - Kamera Ekranı (CameraView)

struct CameraScreen: View {
    let category: ScanCategory
    @ObservedObject var cameraManager: CameraManager
    @ObservedObject var viewModel: ScannerViewModel

    var body: some View {
        VStack(spacing: 28) {
            VStack(alignment: .center, spacing: 10) {
                Text(category.title)
                    .font(AppTypography.largeTitle)
                    .foregroundColor(.black)
                    .multilineTextAlignment(.center)

                Text(category.subtitle)
                    .font(AppTypography.body)
                    .lineSpacing(AppTypography.lineSpacingBody)
                    .foregroundColor(.black.opacity(0.65))
                    .multilineTextAlignment(.center)
                    .fixedSize(horizontal: false, vertical: true)
            }
            .frame(maxWidth: .infinity, alignment: .center)
            .padding(.horizontal, 24)
            .padding(.top, 40)

            AnimatedCameraPreviewFrame(category: category, session: cameraManager.captureSession)
                .frame(height: 320)
                .padding(.horizontal, 24)

            Spacer(minLength: 24)

            VStack(spacing: 20) {
                Text("İçerik listesinin fotoğrafını çek veya galeriden yükle.")
                    .font(AppTypography.body)
                    .lineSpacing(AppTypography.lineSpacingBody)
                    .foregroundColor(.black.opacity(0.65))
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 32)

                HStack(spacing: 22) {
                    // Modern galeri butonu - glassmorphism
                    PhotosPicker(selection: $viewModel.selectedItem, matching: .images) {
                        HStack(spacing: 8) {
                            Image(systemName: "photo.on.rectangle")
                                .font(.system(size: 17, weight: .bold, design: .rounded))
                            Text("Galeri")
                                .font(.system(size: 15, weight: .bold, design: .rounded))
                        }
                        .font(AppTypography.bodyBold)
                        .foregroundColor(.black)
                        .padding(.horizontal, 20)
                        .padding(.vertical, 14)
                        .background(
                            Capsule()
                                .fill(Color.white)
                                .overlay(
                                    Capsule()
                                        .stroke(Color.black.opacity(0.18), lineWidth: 1.2)
                                )
                        )
                        .shadow(color: Color.black.opacity(0.08), radius: 8, x: 0, y: 4)
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
                            
                            Circle()
                                .fill(Color.white)
                                .frame(width: 84, height: 84)
                            
                            Circle()
                                .strokeBorder(Color.black.opacity(0.2), lineWidth: 2)
                                .frame(width: 76, height: 76)
                            
                            Circle()
                                .fill(Color.white)
                                .frame(width: 64, height: 64)
                                .overlay(
                                    Image(systemName: "camera.fill")
                                        .font(.system(size: 28, weight: .semibold))
                                        .foregroundColor(category.primaryAccent)
                                )
                        }
                        .shadow(color: Color.black.opacity(0.15), radius: 20, x: 0, y: 10)
                        .shadow(color: category.primaryAccent.opacity(0.2), radius: 12, x: 0, y: 6)
                    }
                    .buttonStyle(.plain)
                }
            }
            .padding(.bottom, 44)
        }
        .frame(maxWidth: 430, maxHeight: .infinity, alignment: .top)
    }
}

// MARK: - Sonuç Ekranı (ResultsView)


