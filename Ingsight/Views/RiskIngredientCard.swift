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

        HStack(alignment: .top, spacing: 16) {
            ZStack {
                Circle()
                    .fill(iconBgColor.opacity(0.2))
                    .frame(width: 48, height: 48)
                Image(systemName: iconName)
                    .font(.system(size: 16, weight: .bold, design: .rounded))
                    .foregroundColor(iconBgColor)
            }

            VStack(alignment: .leading, spacing: 10) {
                HStack(alignment: .firstTextBaseline, spacing: 10) {
                    Text(ingredient.name)
                        .font(AppTypography.bodyBold)
                        .foregroundColor(.black)
                        .lineLimit(2)
                        .lineSpacing(2)

                    if let contextLabel {
                        Text(contextLabel.uppercased())
                            .font(AppTypography.captionBold)
                            .padding(.horizontal, 10)
                            .padding(.vertical, 5)
                            .background(
                                Capsule()
                                    .fill(Color.black.opacity(0.06))
                                    .overlay(
                                        Capsule()
                                            .stroke(Color.black.opacity(0.1), lineWidth: 0.8)
                                    )
                            )
                            .foregroundColor(.black.opacity(0.75))
                    }
                }

                Text(ingredient.riskLabel)
                    .font(AppTypography.captionBold)
                    .foregroundColor(riskColor)
                    .padding(.top, 2)

                Text(ingredient.description)
                    .font(AppTypography.caption)
                    .lineSpacing(AppTypography.lineSpacingCaption)
                    .foregroundColor(.black.opacity(0.65))
                    .lineLimit(3)
                    .padding(.top, 2)
            }

            Spacer(minLength: 4)

            if ingredient.riskLevel == .high {
                Image(systemName: "exclamationmark.triangle.fill")
                    .font(.system(size: 18, weight: .bold, design: .rounded))
                    .foregroundColor(Color(red: 0.85, green: 0.35, blue: 0.38))
            }
        }
        .padding(.vertical, 18)
        .padding(.horizontal, 20)
        .background(
            RoundedRectangle(cornerRadius: 22, style: .continuous)
                .fill(accentGradient)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 22, style: .continuous)
                .stroke(Color.black.opacity(0.06), lineWidth: 1)
        )
        .shadow(color: Color.black.opacity(0.05), radius: 12, x: 0, y: 6)
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
        case .high: return Color(red: 0.85, green: 0.35, blue: 0.38)
        case .medium: return Color(red: 0.88, green: 0.62, blue: 0.32)
        case .low: return .black.opacity(0.75)
        }
    }

    private var iconBgColor: Color {
        switch ingredient.riskLevel {
        case .high: return Color(red: 0.85, green: 0.35, blue: 0.38)
        case .medium: return Color(red: 0.90, green: 0.65, blue: 0.35)
        case .low:
            return (category?.primaryAccent) ?? Color(red: 0.4, green: 0.65, blue: 0.4)
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
