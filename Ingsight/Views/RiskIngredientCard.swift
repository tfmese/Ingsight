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
            // Modern icon container
            ZStack {
                Circle()
                    .fill(
                        LinearGradient(
                            colors: [
                                Color.white.opacity(0.25),
                                Color.white.opacity(0.15)
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 48, height: 48)
                Circle()
                    .fill(Color.white.opacity(0.3))
                    .frame(width: 32, height: 32)
                Image(systemName: iconName)
                    .font(.system(size: 16, weight: .bold, design: .rounded))
                    .foregroundColor(.white)
            }
            .shadow(color: Color.black.opacity(0.2), radius: 8, x: 0, y: 4)

            VStack(alignment: .leading, spacing: 8) {
                HStack(alignment: .firstTextBaseline, spacing: 8) {
                    Text(ingredient.name)
                        .font(.system(size: 17, weight: .bold, design: .rounded))
                        .foregroundColor(.white)
                        .lineLimit(2)

                    if let contextLabel {
                        Text(contextLabel.uppercased())
                            .font(.system(size: 10, weight: .black, design: .rounded))
                            .padding(.horizontal, 10)
                            .padding(.vertical, 5)
                            .background(
                                Capsule()
                                    .fill(Color.white.opacity(0.2))
                                    .overlay(
                                        Capsule()
                                            .stroke(Color.white.opacity(0.3), lineWidth: 0.8)
                                    )
                            )
                            .foregroundColor(.white.opacity(0.95))
                    }
                }

                Text(ingredient.riskLabel)
                    .font(.system(size: 13, weight: .bold, design: .rounded))
                    .foregroundColor(riskColor)
                    .padding(.top, 2)

                Text(ingredient.description)
                    .font(.system(size: 13, weight: .medium, design: .rounded))
                    .foregroundColor(.white.opacity(0.9))
                    .lineLimit(3)
                    .padding(.top, 2)
            }

            Spacer(minLength: 4)

            if ingredient.riskLevel == .high {
                ZStack {
                    Circle()
                        .fill(Color.red.opacity(0.3))
                        .frame(width: 36, height: 36)
                        .blur(radius: 8)
                    Image(systemName: "exclamationmark.triangle.fill")
                        .font(.system(size: 18, weight: .bold, design: .rounded))
                        .foregroundColor(.white)
                }
                .shadow(color: .red.opacity(0.6), radius: 12, x: 0, y: 6)
            }
        }
        .padding(.vertical, 16)
        .padding(.horizontal, 18)
        .background(
            // Modern glassmorphism card
            RoundedRectangle(cornerRadius: 26, style: .continuous)
                .fill(accentGradient)
                .background(
                    RoundedRectangle(cornerRadius: 26, style: .continuous)
                        .fill(
                            LinearGradient(
                                colors: [
                                    Color.white.opacity(0.15),
                                    Color.white.opacity(0.05)
                                ],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                )
        )
        .overlay(
            RoundedRectangle(cornerRadius: 26, style: .continuous)
                .stroke(
                    LinearGradient(
                        colors: [
                            Color.white.opacity(0.4),
                            Color.white.opacity(0.15)
                        ],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    ),
                    lineWidth: 1.2
                )
        )
        .shadow(color: Color.black.opacity(0.4), radius: 24, x: 0, y: 16)
        .shadow(color: Color.black.opacity(0.2), radius: 8, x: 0, y: 4)
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
