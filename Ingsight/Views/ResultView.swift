//
//  ResultView.swift
//  Ingsight
//
//  Created by Talha Fırat on 9.02.2026.
//
import SwiftUI
import ColorSync
import Foundation

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

    /// Güvenlik skoru rengi — her iki sayfa (gıda/kozmetik) için yeşil / turuncu / kırmızı.
    private var scoreColor: Color {
        if score <= 40 {
            return Color(red: 0.82, green: 0.28, blue: 0.28)
        }
        if score <= 65 {
            return Color(red: 0.90, green: 0.58, blue: 0.22)
        }
        return Color(red: 0.22, green: 0.62, blue: 0.38)
    }

    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(spacing: 28) {
                headerSection

                HStack(alignment: .top, spacing: 20) {
                    scoreCard
                    productCard
                }
                .padding(.horizontal, 24)

                statsGrid
                    .padding(.horizontal, 24)

                VStack(alignment: .leading, spacing: 16) {
                    Text("İçindekiler Analizi")
                        .font(AppTypography.title3)
                        .foregroundColor(.black)

                    if ingredients.isEmpty {
                        SafeIngredientCard(category: category)
                    } else {
                        VStack(spacing: 12) {
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
                .padding(.horizontal, 24)
                .padding(.bottom, 48)
            }
        }
        .frame(maxWidth: 430, maxHeight: .infinity, alignment: .top)
    }

    private var headerSection: some View {
        HStack(alignment: .top) {
            VStack(alignment: .leading, spacing: 8) {
                Text(category.resultTitle)
                    .font(AppTypography.title)
                    .foregroundColor(.black)
                Text("Ürün içeriği, risk seviyesine göre analiz edildi.")
                    .font(AppTypography.caption)
                    .lineSpacing(AppTypography.lineSpacingCaption)
                    .foregroundColor(.black.opacity(0.65))
            }
            
            Spacer(minLength: 16)
            
            Button(action: onScanAgain) {
                HStack(spacing: 8) {
                    Image(systemName: "arrow.counterclockwise")
                        .font(.system(size: 14, weight: .semibold))
                    Text("Tekrar Tara")
                        .font(AppTypography.captionBold)
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 10)
                .background(
                    RoundedRectangle(cornerRadius: 20, style: .continuous)
                        .fill(Color.white)
                        .overlay(
                            RoundedRectangle(cornerRadius: 20, style: .continuous)
                                .stroke(Color.black.opacity(0.15), lineWidth: 1)
                        )
                )
                .foregroundColor(.black)
            }
        }
        .padding(.top, 40)
        .padding(.horizontal, 24)
    }

    private var scoreCard: some View {
        VStack(alignment: .leading, spacing: 18) {
            HStack(spacing: 12) {
                ZStack {
                    Circle()
                        .fill(category.primaryAccent.opacity(0.18))
                        .frame(width: 44, height: 44)
                    Image(systemName: category.headerIconName)
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundColor(category.primaryAccent)
                }

                VStack(alignment: .leading, spacing: 2) {
                    Text("Güvenlik Skoru")
                        .font(AppTypography.caption)
                        .foregroundColor(.black.opacity(0.6))
                    Text(scoreLabel)
                        .font(AppTypography.bodyBold)
                        .foregroundColor(scoreColor)
                }
            }

            HStack(alignment: .firstTextBaseline, spacing: 4) {
                Text("\(score)")
                    .font(AppTypography.score)
                    .foregroundColor(.black)
                Text("/100")
                    .font(AppTypography.body)
                    .foregroundColor(.black.opacity(0.5))
            }

            ZStack(alignment: .leading) {
                RoundedRectangle(cornerRadius: 999, style: .continuous)
                    .fill(Color.black.opacity(0.06))
                GeometryReader { proxy in
                    let width = proxy.size.width * CGFloat(score) / 100.0
                    RoundedRectangle(cornerRadius: 999, style: .continuous)
                        .fill(scoreColor)
                        .frame(width: width)
                }
            }
            .frame(height: 8)

            Text(hintText)
                .font(AppTypography.caption)
                .lineSpacing(AppTypography.lineSpacingCaption)
                .foregroundColor(.black.opacity(0.6))
                .fixedSize(horizontal: false, vertical: true)
        }
        .padding(22)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            RoundedRectangle(cornerRadius: 24, style: .continuous)
                .fill(Color.white)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 24, style: .continuous)
                .stroke(Color.black.opacity(0.06), lineWidth: 1)
        )
        .shadow(color: Color.black.opacity(0.05), radius: 12, x: 0, y: 6)
    }

    private var productCard: some View {
        VStack(alignment: .leading, spacing: 10) {
            ZStack {
                RoundedRectangle(cornerRadius: 24, style: .continuous)
                    .fill(Color(red: 0.98, green: 0.98, blue: 0.98))
                    .overlay(
                        RoundedRectangle(cornerRadius: 24, style: .continuous)
                            .stroke(Color.black.opacity(0.06), lineWidth: 1)
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
                                    .stroke(Color.black.opacity(0.1), lineWidth: 0.8)
                            )
                            .shadow(color: Color.black.opacity(0.12), radius: 8, x: 0, y: 4)
                    } else {
                        // Yedek ikon
                        ImageWithFallback(systemName: "shippingbox.and.arrow.backward")
                            .frame(width: 56, height: 56)
                    }
                    
                    Text("Taradığın Ürün")
                        .font(AppTypography.captionBold)
                        .foregroundColor(.black.opacity(0.75))
                        .lineLimit(1)
                }
                .padding(16)
            }

            Text(ingredients.isEmpty ? "Şüpheli içerik bulunamadı." : "İçerik listesi analizi tamamlandı.")
                .font(AppTypography.caption)
                .foregroundColor(.black.opacity(0.55))
        }
        .frame(width: 140)
    }

    private var statsGrid: some View {
        HStack(spacing: 12) {
            if safeCount > 0 {
                statItem(
                    title: "Güvenli",
                    value: safeCount,
                    icon: "arrow.up.right",
                    color: Color(red: 0.22, green: 0.62, blue: 0.38)
                )
            }
            statItem(
                title: "Dikkat",
                value: cautionCount,
                icon: "minus",
                color: Color(red: 0.90, green: 0.58, blue: 0.22)
            )
            statItem(
                title: "Kaçın",
                value: avoidCount,
                icon: "arrow.down.right",
                color: Color(red: 0.82, green: 0.28, blue: 0.28)
            )
        }
    }

    private func statItem(title: String, value: Int, icon: String, color: Color) -> some View {
        VStack(alignment: .center, spacing: 12) {
            Text(title)
                .font(.system(size: 13, weight: .bold, design: .rounded))
                .foregroundColor(.black)
                .lineLimit(1)
                .minimumScaleFactor(0.7)

            Text("\(value)")
                .font(.system(size: 28, weight: .bold, design: .rounded))
                .foregroundColor(.black)

            ZStack {
                Circle()
                    .fill(color.opacity(0.2))
                    .frame(width: 32, height: 32)
                Image(systemName: icon)
                    .font(.system(size: 14, weight: .bold, design: .rounded))
                    .foregroundColor(color)
            }
        }
        .frame(minWidth: 0, maxWidth: .infinity)
        .padding(.vertical, 20)
        .padding(.horizontal, 12)
        .background(
            RoundedRectangle(cornerRadius: 20, style: .continuous)
                .fill(Color.white)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 20, style: .continuous)
                .stroke(Color.black.opacity(0.08), lineWidth: 1)
        )
        .shadow(color: Color.black.opacity(0.06), radius: 8, x: 0, y: 4)
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
