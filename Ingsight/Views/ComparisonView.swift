import SwiftUI
import PhotosUI
import AVFoundation

/// Yeni karşılaştırma ekranı: Sol ve sağda CameraPreview'lar,
/// her biri için foto çekme/galeri butonları, otomatik karşılaştırma.
struct ComparisonRootView: View {
    @State private var selectedCategory: ScanCategory = .food
    
    // Sol taraf (Ürün A)
    @StateObject private var leftCameraManager = CameraManager()
    @State private var leftViewModel: ScannerViewModel
    
    // Sağ taraf (Ürün B)
    @StateObject private var rightCameraManager = CameraManager()
    @State private var rightViewModel: ScannerViewModel
    
    @State private var showingComparisonResults = false
    
    init() {
        // İlk kategori için viewModel'leri initialize et
        _leftViewModel = State(initialValue: ScannerViewModel(service: .shared))
        _rightViewModel = State(initialValue: ScannerViewModel(service: .shared))
    }
    
    private var canCompare: Bool {
        leftViewModel.detectedIngredients.isEmpty == false &&
        rightViewModel.detectedIngredients.isEmpty == false &&
        leftViewModel.selectedImage != nil &&
        rightViewModel.selectedImage != nil
    }
    
    var body: some View {
        ZStack {
            // Arka plan - ScannerView ile aynı stil
            AnimatedPatternBackground(category: selectedCategory)
            
            ScrollView(showsIndicators: false) {
                VStack(spacing: 28) {
                    // Başlık bölümü
                    VStack(alignment: .center, spacing: 10) {
                        Text("Karşılaştırma")
                            .font(AppTypography.largeTitle)
                            .foregroundColor(.black)
                            .multilineTextAlignment(.center)
                        
                        Text("İki ürünün içerik listesini yan yana karşılaştır. Her iki ürünü de fotoğrafla veya galeriden yükle.")
                            .font(AppTypography.body)
                            .lineSpacing(AppTypography.lineSpacingBody)
                            .foregroundColor(.black.opacity(0.65))
                            .multilineTextAlignment(.center)
                            .fixedSize(horizontal: false, vertical: true)
                    }
                    .frame(maxWidth: .infinity, alignment: .center)
                    .padding(.horizontal, 24)
                    .padding(.top, 40)
                    
                    // Kategori seçici
                    Picker("", selection: $selectedCategory) {
                        Text("Gıda").tag(ScanCategory.food)
                        Text("Kozmetik").tag(ScanCategory.cosmetics)
                    }
                    .pickerStyle(.segmented)
                    .padding(.horizontal, 24)
                    .onChange(of: selectedCategory) { newCategory in
                        // Kategori değiştiğinde servisleri güncelle
                        let service: IngredientService = newCategory == .food ? .shared : .cosmetics
                        leftViewModel = ScannerViewModel(service: service)
                        rightViewModel = ScannerViewModel(service: service)
                        resetComparison()
                    }
                    
                    // İki ürün karşılaştırma alanı
                    HStack(spacing: 16) {
                        // Sol taraf - Ürün A
                        productCaptureArea(
                            label: "Ürün A",
                            cameraManager: leftCameraManager,
                            viewModel: leftViewModel,
                            category: selectedCategory
                        )
                        
                        // Sağ taraf - Ürün B
                        productCaptureArea(
                            label: "Ürün B",
                            cameraManager: rightCameraManager,
                            viewModel: rightViewModel,
                            category: selectedCategory
                        )
                    }
                    .padding(.horizontal, 24)
                    
                    // Karşılaştırma butonu (her iki ürün hazır olduğunda)
                    if canCompare {
                        Button {
                            showingComparisonResults = true
                        } label: {
                            HStack(spacing: 10) {
                                Image(systemName: "arrow.left.arrow.right")
                                    .font(.system(size: 16, weight: .semibold))
                                Text("Karşılaştırmayı Göster")
                                    .font(AppTypography.bodyBold)
                            }
                            .foregroundColor(.white)
                            .padding(.horizontal, 24)
                            .padding(.vertical, 14)
                            .background(
                                Capsule()
                                    .fill(selectedCategory.primaryAccent)
                            )
                            .shadow(color: selectedCategory.primaryAccent.opacity(0.3), radius: 12, x: 0, y: 6)
                        }
                        .padding(.horizontal, 24)
                        .transition(.scale.combined(with: .opacity))
                    }
                    
                    Spacer(minLength: 100) // Alt tab bar için boşluk
                }
            }
            .frame(maxWidth: 430, maxHeight: .infinity, alignment: .top)
        }
        .onAppear {
            leftCameraManager.start()
            rightCameraManager.start()
        }
        .onDisappear {
            leftCameraManager.stop()
            rightCameraManager.stop()
        }
        .sheet(isPresented: $showingComparisonResults) {
            if canCompare {
                ComparisonResultsView(
                    firstProduct: ScannedProduct(
                        image: leftViewModel.selectedImage,
                        ingredients: leftViewModel.detectedIngredients,
                        category: selectedCategory
                    ),
                    secondProduct: ScannedProduct(
                        image: rightViewModel.selectedImage,
                        ingredients: rightViewModel.detectedIngredients,
                        category: selectedCategory
                    ),
                    category: selectedCategory,
                    onReset: {
                        resetComparison()
                    }
                )
            }
        }
    }
    
    private func resetComparison() {
        leftViewModel.reset()
        rightViewModel.reset()
        leftCameraManager.start()
        rightCameraManager.start()
    }
    
    @ViewBuilder
    private func productCaptureArea(
        label: String,
        cameraManager: CameraManager,
        viewModel: ScannerViewModel,
        category: ScanCategory
    ) -> some View {
        VStack(spacing: 16) {
            // Ürün etiketi
            Text(label)
                .font(AppTypography.bodyBold)
                .foregroundColor(.black)
            
            // CameraPreview veya seçilen fotoğraf
            ZStack {
                if let image = viewModel.selectedImage {
                    // Fotoğraf seçildiyse göster
                    Image(uiImage: image)
                        .resizable()
                        .scaledToFill()
                        .frame(height: 200)
                        .clipped()
                        .clipShape(RoundedRectangle(cornerRadius: 24, style: .continuous))
                        .overlay(
                            RoundedRectangle(cornerRadius: 24, style: .continuous)
                                .stroke(Color.black.opacity(0.1), lineWidth: 1)
                        )
                } else {
                    // CameraPreview göster
                    AnimatedCameraPreviewFrame(category: category, session: cameraManager.captureSession)
                        .frame(height: 200)
                }
                
                // Analiz durumu overlay
                if viewModel.isScanning || viewModel.isAnalyzing {
                    ZStack {
                        RoundedRectangle(cornerRadius: 24, style: .continuous)
                            .fill(Color.black.opacity(0.5))
                        
                        VStack(spacing: 12) {
                            ProgressView()
                                .tint(.white)
                            Text(viewModel.isScanning ? "Metin okunuyor..." : "Analiz ediliyor...")
                                .font(AppTypography.captionBold)
                                .foregroundColor(.white)
                        }
                    }
                } else if !viewModel.detectedIngredients.isEmpty {
                    // Analiz tamamlandı - başarı badge
                    VStack {
                        Spacer()
                        HStack {
                            Spacer()
                            HStack(spacing: 6) {
                                Image(systemName: "checkmark.circle.fill")
                                    .font(.system(size: 14, weight: .semibold))
                                Text("\(viewModel.detectedIngredients.count) risk bulundu")
                                    .font(AppTypography.captionBold)
                            }
                            .foregroundColor(.white)
                            .padding(.horizontal, 12)
                            .padding(.vertical, 6)
                            .background(
                                Capsule()
                                    .fill(Color.black.opacity(0.7))
                            )
                            .padding(12)
                        }
                    }
                }
            }
            
            // Foto çekme ve galeri butonları
            HStack(spacing: 12) {
                // Galeri butonu
                PhotosPicker(selection: Binding(
                    get: { viewModel.selectedItem },
                    set: { viewModel.selectedItem = $0 }
                ), matching: .images) {
                    HStack(spacing: 6) {
                        Image(systemName: "photo.on.rectangle")
                            .font(.system(size: 14, weight: .bold, design: .rounded))
                        Text("Galeri")
                            .font(AppTypography.captionBold)
                    }
                    .foregroundColor(.black)
                    .padding(.horizontal, 14)
                    .padding(.vertical, 10)
                    .background(
                        Capsule()
                            .fill(Color.white)
                            .overlay(
                                Capsule()
                                    .stroke(Color.black.opacity(0.18), lineWidth: 1.2)
                            )
                    )
                    .shadow(color: Color.black.opacity(0.08), radius: 6, x: 0, y: 3)
                }
                .buttonStyle(.plain)
                .onChange(of: viewModel.selectedImage) { image in
                    if image != nil {
                        cameraManager.stop()
                    } else {
                        cameraManager.start()
                    }
                }
                
                // Temizle butonu (foto varsa)
                if viewModel.selectedImage != nil {
                    Button {
                        viewModel.reset()
                        cameraManager.start()
                    } label: {
                        HStack(spacing: 6) {
                            Image(systemName: "arrow.counterclockwise")
                                .font(.system(size: 14, weight: .bold, design: .rounded))
                            Text("Temizle")
                                .font(AppTypography.captionBold)
                        }
                        .foregroundColor(.black)
                        .padding(.horizontal, 14)
                        .padding(.vertical, 10)
                        .background(
                            Capsule()
                                .fill(Color.white)
                                .overlay(
                                    Capsule()
                                        .stroke(Color.black.opacity(0.18), lineWidth: 1.2)
                                )
                        )
                        .shadow(color: Color.black.opacity(0.08), radius: 6, x: 0, y: 3)
                    }
                    .buttonStyle(.plain)
                }
            }
        }
        .frame(maxWidth: .infinity)
    }
}

/// Karşılaştırma sonuçlarını gösteren ekran
struct ComparisonResultsView: View {
    let firstProduct: ScannedProduct
    let secondProduct: ScannedProduct
    let category: ScanCategory
    var onReset: () -> Void
    
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationStack {
            ScrollView(showsIndicators: false) {
                VStack(spacing: 24) {
                    // Ürün görselleri
                    HStack(alignment: .top, spacing: 16) {
                        productMiniCard(product: firstProduct, label: "Ürün A")
                        productMiniCard(product: secondProduct, label: "Ürün B")
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 24)
                    
                    // Skor karşılaştırması
                    scoreComparisonSection
                        .padding(.horizontal, 20)
                    
                    // İçerik karşılaştırması
                    ingredientsComparisonSection
                        .padding(.horizontal, 20)
                        .padding(.bottom, 32)
                }
            }
            .navigationTitle(category == .food ? "Gıda Karşılaştırma" : "Kozmetik Karşılaştırma")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Yeni Karşılaştırma") {
                        onReset()
                        dismiss()
                    }
                    .font(AppTypography.bodyBold)
                }
            }
        }
    }
    
    private func productMiniCard(product: ScannedProduct, label: String) -> some View {
        VStack(spacing: 8) {
            if let image = product.image {
                Image(uiImage: image)
                    .resizable()
                    .scaledToFill()
                    .frame(width: 90, height: 70)
                    .clipped()
                    .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
            } else {
                ZStack {
                    RoundedRectangle(cornerRadius: 18, style: .continuous)
                        .fill(Color(.secondarySystemBackground))
                    Image(systemName: "shippingbox")
                        .font(.system(size: 24, weight: .semibold))
                        .foregroundColor(.black.opacity(0.5))
                }
                .frame(width: 90, height: 70)
            }
            
            Text(label)
                .font(AppTypography.captionBold)
                .foregroundColor(.black.opacity(0.8))
        }
        .frame(maxWidth: .infinity)
    }
    
    private var scoreComparisonSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Güvenlik Skoru Karşılaştırması")
                .font(AppTypography.title3)
                .foregroundColor(.black)
            
            HStack(spacing: 16) {
                scoreCard(for: firstProduct, label: "Ürün A")
                scoreCard(for: secondProduct, label: "Ürün B")
            }
        }
    }
    
    private func scoreCard(for product: ScannedProduct, label: String) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(label)
                .font(AppTypography.captionBold)
                .foregroundColor(.black.opacity(0.7))
            
            HStack(alignment: .firstTextBaseline, spacing: 4) {
                Text("\(product.score)")
                    .font(AppTypography.score)
                    .foregroundColor(.black)
                Text("/100")
                    .font(AppTypography.body)
                    .foregroundColor(.black.opacity(0.5))
            }
            
            HStack(spacing: 6) {
                if product.avoidCount > 0 {
                    chip(text: "\(product.avoidCount) kaçın", color: Color(red: 0.82, green: 0.28, blue: 0.28))
                }
                if product.cautionCount > 0 {
                    chip(text: "\(product.cautionCount) dikkat", color: Color(red: 0.90, green: 0.58, blue: 0.22))
                }
                if product.safeCount > 0 {
                    chip(text: "\(product.safeCount) güvenli", color: Color(red: 0.22, green: 0.62, blue: 0.38))
                }
            }
        }
        .padding(16)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            RoundedRectangle(cornerRadius: 20, style: .continuous)
                .fill(Color.white)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 20, style: .continuous)
                .stroke(Color.black.opacity(0.06), lineWidth: 1)
        )
        .shadow(color: Color.black.opacity(0.04), radius: 8, x: 0, y: 4)
    }
    
    private func chip(text: String, color: Color) -> some View {
        Text(text)
            .font(AppTypography.caption)
            .padding(.horizontal, 8)
            .padding(.vertical, 4)
            .background(
                Capsule()
                    .fill(color.opacity(0.12))
            )
            .foregroundColor(color)
    }
    
    private var ingredientsComparisonSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("İçerik Karşılaştırması")
                .font(AppTypography.title3)
                .foregroundColor(.black)
            
            let firstSet = Set(firstProduct.ingredients.map { $0.id })
            let secondSet = Set(secondProduct.ingredients.map { $0.id })
            
            let commonIds = firstSet.intersection(secondSet)
            let onlyFirstIds = firstSet.subtracting(secondSet)
            let onlySecondIds = secondSet.subtracting(firstSet)
            
            if commonIds.isEmpty, onlyFirstIds.isEmpty, onlySecondIds.isEmpty {
                Text("Her iki üründe de analiz edilebilecek içerik bulunamadı.")
                    .font(AppTypography.caption)
                    .foregroundColor(.black.opacity(0.6))
            } else {
                VStack(alignment: .leading, spacing: 12) {
                    if !commonIds.isEmpty {
                        ingredientGroup(
                            title: "Ortak içerikler",
                            ingredients: firstProduct.ingredients.filter { commonIds.contains($0.id) }
                        )
                    }
                    
                    if !onlyFirstIds.isEmpty {
                        ingredientGroup(
                            title: "Sadece Ürün A'da",
                            ingredients: firstProduct.ingredients.filter { onlyFirstIds.contains($0.id) }
                        )
                    }
                    
                    if !onlySecondIds.isEmpty {
                        ingredientGroup(
                            title: "Sadece Ürün B'de",
                            ingredients: secondProduct.ingredients.filter { onlySecondIds.contains($0.id) }
                        )
                    }
                }
            }
        }
    }
    
    private func ingredientGroup(title: String, ingredients: [Ingredient]) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .font(AppTypography.bodyBold)
                .foregroundColor(.black)
            
            VStack(spacing: 6) {
                ForEach(ingredients) { ingredient in
                    HStack {
                        Text(ingredient.name)
                            .font(AppTypography.caption)
                            .foregroundColor(.black)
                        Spacer()
                        Text(ingredient.riskLabel)
                            .font(AppTypography.caption)
                            .foregroundColor(.black.opacity(0.6))
                    }
                    .padding(.horizontal, 10)
                    .padding(.vertical, 6)
                    .background(
                        RoundedRectangle(cornerRadius: 12, style: .continuous)
                            .fill(Color.white)
                    )
                }
            }
        }
        .padding(14)
        .background(
            RoundedRectangle(cornerRadius: 20, style: .continuous)
                .fill(Color(.secondarySystemBackground))
        )
    }
}
