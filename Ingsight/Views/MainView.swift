import SwiftUI

struct MainView: View {
    @State private var selectedCategory: ScanCategory = .food
    
    var body: some View {
        ZStack(alignment: .bottom) {
            // Kök arka plan – modern iOS hissi için koyu
            Color.black
                .ignoresSafeArea()
            
            // Ana içerik – mobil odaklı, max genişlik sınırlı
            Group {
                switch selectedCategory {
                case .food:
                    ScannerView(
                        category: .food,
                        viewModel: ScannerViewModel(service: .shared)
                    )
                case .cosmetics:
                    ScannerView(
                        category: .cosmetics,
                        viewModel: ScannerViewModel(service: .cosmetics)
                    )
                }
            }
            .frame(maxWidth: 430) // max-w-md benzeri
            .frame(maxHeight: .infinity, alignment: .top)
            .padding(.bottom, 96) // yüzen tab bar için boşluk
            .animation(.spring(response: 0.4, dampingFraction: 0.8), value: selectedCategory)
            
            FloatingTabBar(selectedCategory: $selectedCategory)
                .padding(.horizontal, 16)
                .padding(.bottom, 16)
        }
    }
}

// MARK: - Floating Bottom Tab Navigation

struct FloatingTabBar: View {
    @Binding var selectedCategory: ScanCategory
    @Namespace private var indicatorNamespace
    
    private func gradient(for category: ScanCategory) -> LinearGradient {
        switch category {
        case .food:
            // from-green-400 via-emerald-500 to-teal-600
            return LinearGradient(
                gradient: Gradient(colors: [
                    Color(.systemGreen),
                    Color(.systemTeal),
                    Color(.systemTeal).opacity(0.9)
                ]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        case .cosmetics:
            // from-pink-400 via-rose-500 to-purple-600
            return LinearGradient(
                gradient: Gradient(colors: [
                    Color(.systemPink),
                    Color(.systemPink).opacity(0.9),
                    Color(.systemPurple)
                ]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        }
    }
    
    var body: some View {
        HStack(spacing: 12) {
            tabButton(
                icon: "leaf.fill",
                label: "Gıda",
                category: .food
            )
            tabButton(
                icon: "sparkles",
                label: "Kozmetik",
                category: .cosmetics
            )
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 10)
        .background(
            // Daha kompakt, cam efektli tab bar
            RoundedRectangle(cornerRadius: 32, style: .continuous)
                .fill(.ultraThinMaterial)
                .background(
                    RoundedRectangle(cornerRadius: 32, style: .continuous)
                        .fill(Color.white.opacity(0.15))
                )
                .shadow(color: Color.black.opacity(0.35), radius: 24, x: 0, y: 18)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 32, style: .continuous)
                .stroke(
                    LinearGradient(
                        gradient: Gradient(colors: [
                            Color.white.opacity(0.6),
                            Color.white.opacity(0.15)
                        ]),
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    ),
                    lineWidth: 0.9
                )
        )
    }
    
    @ViewBuilder
    private func tabButton(icon: String, label: String, category: ScanCategory) -> some View {
        let isActive = selectedCategory == category
        
        Button {
            withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
                selectedCategory = category
            }
        } label: {
            HStack(spacing: 8) {
                Image(systemName: icon)
                    .font(.system(size: 18, weight: .semibold))
                Text(label)
                    .font(.system(size: 14, weight: .semibold, design: .rounded))
            }
            .foregroundColor(.white)
            .padding(.horizontal, isActive ? 16 : 12)
            .padding(.vertical, 10)
            .background(
                ZStack {
                    if isActive {
                        gradient(for: category)
                            .matchedGeometryEffect(id: "ACTIVE_TAB_BACKGROUND", in: indicatorNamespace)
                    } else {
                        Color.white.opacity(0.0001) // hit area
                    }
                }
            )
            .clipShape(RoundedRectangle(cornerRadius: 28, style: .continuous))
            .shadow(
                color: isActive ? Color.black.opacity(0.35) : Color.clear,
                radius: isActive ? 18 : 0,
                x: 0,
                y: isActive ? 12 : 0
            )
            .scaleEffect(isActive ? 1.05 : 1.0)
            .animation(.spring(response: 0.4, dampingFraction: 0.8), value: isActive)
        }
        .buttonStyle(.plain)
    }
}
