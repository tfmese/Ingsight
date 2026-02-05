import SwiftUI

struct SafeIngredientCard: View {
    var category: ScanCategory? = nil

    private var baseGradient: LinearGradient {
        if let category {
            return category.cardGradient(for: .low)
        } else {
            return LinearGradient(
                gradient: Gradient(colors: [Color.green, Color.green.opacity(0.7)]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        }
    }

    var body: some View {
        HStack(alignment: .center, spacing: 14) {
            ZStack {
                Circle()
                    .fill(Color.white.opacity(0.20))
                    .frame(width: 40, height: 40)
                Circle()
                    .fill(Color.white.opacity(0.30))
                    .frame(width: 26, height: 26)
                Image(systemName: "checkmark.seal.fill")
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(.white)
            }

            VStack(alignment: .leading, spacing: 4) {
                Text("Riskli madde bulunamadı")
                    .font(.subheadline.weight(.semibold))
                    .foregroundColor(.white)
                Text("Bu üründe bilinen zararlı veya tartışmalı bileşenlere rastlanmadı.")
                    .font(.caption2)
                    .foregroundColor(.white.opacity(0.9))
                    .fixedSize(horizontal: false, vertical: true)
            }

            Spacer()
        }
        .padding(.vertical, 14)
        .padding(.horizontal, 16)
        .background(
            RoundedRectangle(cornerRadius: 26, style: .continuous)
                .fill(self.baseGradient)
                .overlay(
                    RoundedRectangle(cornerRadius: 26, style: .continuous)
                        .stroke(Color.white.opacity(0.3), lineWidth: 0.8)
                )
                .shadow(color: Color.black.opacity(0.4), radius: 14, x: 0, y: 8)
        )
    }
}
