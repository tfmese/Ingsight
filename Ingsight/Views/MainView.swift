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
            let c = Color(red: 0.52, green: 0.58, blue: 0.48)  // sage / olive
            return LinearGradient(colors: [c, c.opacity(0.9)], startPoint: .topLeading, endPoint: .bottomTrailing)
        case .cosmetics:
            let c = Color(red: 0.68, green: 0.55, blue: 0.75)  // muted lilac / rose
            return LinearGradient(colors: [c, c.opacity(0.9)], startPoint: .topLeading, endPoint: .bottomTrailing)
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
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .background(
            // Modern glassmorphism tab bar - iOS 18+
            RoundedRectangle(cornerRadius: 30, style: .continuous)
                .fill(.ultraThinMaterial)
                .background(
                    RoundedRectangle(cornerRadius: 30, style: .continuous)
                        .fill(
                            LinearGradient(
                                colors: [
                                    Color.white.opacity(0.2),
                                    Color.white.opacity(0.1)
                                ],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                )
                .shadow(color: Color.black.opacity(0.4), radius: 30, x: 0, y: 20)
                .shadow(color: Color.black.opacity(0.2), radius: 10, x: 0, y: 5)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 30, style: .continuous)
                .stroke(
                    LinearGradient(
                        gradient: Gradient(colors: [
                            Color.white.opacity(0.7),
                            Color.white.opacity(0.2)
                        ]),
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    ),
                    lineWidth: 1.2
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
                    .font(.system(size: 19, weight: .bold, design: .rounded))
                Text(label)
                    .font(.system(size: 15, weight: .bold, design: .rounded))
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
