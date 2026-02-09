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

    private var accent: Color {
        category?.primaryAccent ?? Color(red: 0.4, green: 0.65, blue: 0.4)
    }

    var body: some View {
        HStack(alignment: .center, spacing: 16) {
            ZStack {
                Circle()
                    .fill(accent.opacity(0.2))
                    .frame(width: 52, height: 52)
                Image(systemName: "checkmark.seal.fill")
                    .font(.system(size: 20, weight: .bold, design: .rounded))
                    .foregroundColor(accent)
            }

            VStack(alignment: .leading, spacing: 8) {
                Text("Riskli madde bulunamadı")
                    .font(AppTypography.title3)
                    .foregroundColor(.black)
                Text("Bu üründe bilinen zararlı veya tartışmalı bileşenlere rastlanmadı.")
                    .font(AppTypography.body)
                    .lineSpacing(AppTypography.lineSpacingBody)
                    .foregroundColor(.black.opacity(0.65))
                    .fixedSize(horizontal: false, vertical: true)
            }

            Spacer()
        }
        .padding(.vertical, 20)
        .padding(.horizontal, 22)
        .background(
            RoundedRectangle(cornerRadius: 22, style: .continuous)
                .fill(self.baseGradient)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 22, style: .continuous)
                .stroke(Color.black.opacity(0.06), lineWidth: 1)
        )
        .shadow(color: Color.black.opacity(0.05), radius: 12, x: 0, y: 6)
    }
}
