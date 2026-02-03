import SwiftUI

struct RiskIngredientCard: View {
    let ingredient: Ingredient

    var body: some View {
        HStack(spacing: 16) {
            Circle()
                .fill(ingredient.riskColor)
                .frame(width: 18, height: 18)
                .shadow(radius: 3)

            VStack(alignment: .leading, spacing: 2) {
                Text(ingredient.name)
                    .font(.headline)
                    .foregroundColor(.primary)
                Text(ingredient.riskLabel)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                Text(ingredient.description)
                    .font(.caption2)
                    .foregroundColor(.gray)
                    .lineLimit(2)
            }
            Spacer()
            if ingredient.riskLevel == .high {
                Image(systemName: "exclamationmark.triangle.fill")
                    .foregroundColor(.red)
            }
        }
        .padding(.vertical, 10)
        .padding(.horizontal)
        .background(.ultraThinMaterial)
        .cornerRadius(12)
        .shadow(color: ingredient.riskColor.opacity(0.2), radius: 2)
        .onTapGesture {
            let generator = UIImpactFeedbackGenerator(style: .medium)
            generator.impactOccurred()
        }
    }
}
