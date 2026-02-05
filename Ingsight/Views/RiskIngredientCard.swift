import SwiftUI

struct RiskIngredientCard: View {
    let ingredient: Ingredient
    var category: ScanCategory? = nil
    var contextLabel: String? = nil
    
    @State private var isPressed: Bool = false

    var body: some View {
        let accentGradient = category?.cardGradient(for: ingredient.riskLevel) ??
            LinearGradient(
                gradient: Gradient(colors: [ingredient.riskColor.opacity(0.9), ingredient.riskColor.opacity(0.6)]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )

        HStack(alignment: .top, spacing: 14) {
            ZStack {
                Circle()
                    .fill(Color.white.opacity(0.18))
                    .frame(width: 40, height: 40)
                Circle()
                    .fill(Color.white.opacity(0.26))
                    .frame(width: 28, height: 28)
                Image(systemName: iconName)
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(.white)
            }

            VStack(alignment: .leading, spacing: 6) {
                HStack(alignment: .firstTextBaseline, spacing: 6) {
                    Text(ingredient.name)
                        .font(.subheadline.weight(.semibold))
                        .foregroundColor(.white)
                        .lineLimit(2)

                    if let contextLabel {
                        Text(contextLabel.uppercased())
                            .font(.system(size: 9, weight: .black, design: .rounded))
                            .padding(.horizontal, 8)
                            .padding(.vertical, 4)
                            .background(Color.white.opacity(0.14))
                            .foregroundColor(.white.opacity(0.9))
                            .clipShape(Capsule())
                    }
                }

                Text(ingredient.riskLabel)
                    .font(.caption2.weight(.semibold))
                    .foregroundColor(riskColor)

                Text(ingredient.description)
                    .font(.caption2)
                    .foregroundColor(.white.opacity(0.8))
                    .lineLimit(3)
            }

            Spacer(minLength: 4)

            if ingredient.riskLevel == .high {
                Image(systemName: "exclamationmark.triangle.fill")
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(.white)
                    .shadow(color: .red.opacity(0.9), radius: 10)
            }
        }
        .padding(.vertical, 12)
        .padding(.horizontal, 14)
        .background(
            RoundedRectangle(cornerRadius: 24, style: .continuous)
                .fill(accentGradient)
                .overlay(
                    RoundedRectangle(cornerRadius: 24, style: .continuous)
                        .stroke(Color.white.opacity(0.28), lineWidth: 0.8)
                )
                .shadow(color: Color.black.opacity(0.55), radius: 14, x: 0, y: 10)
        )
        .scaleEffect(isPressed ? 0.97 : 1.0)
        .animation(.spring(response: 0.25, dampingFraction: 0.7), value: isPressed)
        .onTapGesture {
            let generator = UIImpactFeedbackGenerator(style: .medium)
            generator.impactOccurred()
            isPressed = true
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.15) {
                isPressed = false
            }
        }
    }

    private var riskColor: Color {
        switch ingredient.riskLevel {
        case .high: return .white
        case .medium: return .white.opacity(0.94)
        case .low: return .white.opacity(0.92)
        }
    }

    private var iconName: String {
        switch ingredient.riskLevel {
        case .high: return "flame.fill"
        case .medium: return "exclamationmark.triangle.fill"
        case .low: return "checkmark.seal.fill"
        }
    }
}
