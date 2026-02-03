import SwiftUI

struct SafeIngredientCard: View {
    var body: some View {
        HStack(spacing: 16) {
            Circle()
                .fill(Color.green)
                .frame(width: 18, height: 18)
                .overlay(
                    Image(systemName: "checkmark")
                        .foregroundColor(.white)
                        .font(.system(size: 10, weight: .bold))
                )
                .shadow(radius: 3)

            VStack(alignment: .leading, spacing: 2) {
                Text("Riskli Madde Bulunamadı!")
                    .font(.headline)
                    .foregroundColor(.primary)
                Text("Bu üründe zararlı/şüpheli bir içerik bulunmuyor.")
                    .font(.subheadline)
                    .foregroundColor(.green)
            }
            Spacer()
        }
        .padding(.vertical, 18)
        .padding(.horizontal)
        .background(.ultraThinMaterial)
        .cornerRadius(18)
        .shadow(color: Color.green.opacity(0.2), radius: 3)
    }
}
