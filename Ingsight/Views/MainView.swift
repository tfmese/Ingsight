import SwiftUI

enum MainTab {
    case food
    case cosmetics
    case comparison
    
    var accentColor: Color {
        switch self {
        case .food:
            return ScanCategory.food.primaryAccent
        case .cosmetics:
            return ScanCategory.cosmetics.primaryAccent
        case .comparison:
            // İki kategorinin ortasında, hafif mor tonlu bir vurgu rengi
            return Color(red: 0.60, green: 0.40, blue: 0.80)
        }
    }
}

struct MainView: View {
    @State private var selectedTab: MainTab = .food
    
    var body: some View {
        ZStack(alignment: .bottom) {
            Color.white
                .ignoresSafeArea()
            
            // Ana içerik – mobil odaklı, max genişlik sınırlı
            Group {
                switch selectedTab {
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
                case .comparison:
                    ComparisonRootView()
                }
            }
            .frame(maxWidth: 430) // max-w-md benzeri
            .frame(maxHeight: .infinity, alignment: .top)
            .padding(.bottom, 96) // yüzen tab bar için boşluk
            .animation(.spring(response: 0.4, dampingFraction: 0.8), value: selectedTab)
            
            FloatingTabBar(selectedTab: $selectedTab)
                .padding(.horizontal, 16)
                .padding(.bottom, 16)
        }
    }
}

// MARK: - Floating Bottom Tab Navigation

struct FloatingTabBar: View {
    @Binding var selectedTab: MainTab
    @Namespace private var indicatorNamespace
    
    private func gradient(for tab: MainTab) -> LinearGradient {
        let accent = tab.accentColor.opacity(0.25)
        let base = Color(red: 0.97, green: 0.97, blue: 0.97)
        return LinearGradient(
            colors: [base, accent],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }
    
    var body: some View {
        HStack(spacing: 12) {
            tabButton(
                icon: "leaf.fill",
                label: "Gıda",
                tab: .food
            )
            tabButton(
                icon: "sparkles",
                label: "Kozmetik",
                tab: .cosmetics
            )
            tabButton(
                icon: "rectangle.3.group",
                label: "Karşılaştır",
                tab: .comparison
            )
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .background(
            RoundedRectangle(cornerRadius: 30, style: .continuous)
                .fill(Color.white)
                .shadow(color: Color.black.opacity(0.06), radius: 20, x: 0, y: 8)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 30, style: .continuous)
                .stroke(Color.black.opacity(0.08), lineWidth: 1)
        )
    }
    
    @ViewBuilder
    private func tabButton(icon: String, label: String, tab: MainTab) -> some View {
        let isActive = selectedTab == tab
        
        Button {
            withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
                selectedTab = tab
            }
        } label: {
            HStack(spacing: 8) {
                Image(systemName: icon)
                    .font(.system(size: 17, weight: .semibold))
                    .foregroundColor(isActive ? tab.accentColor : .black.opacity(0.45))
                Text(label)
                    .font(AppTypography.bodyBold)
                    .foregroundColor(isActive ? .black : .black.opacity(0.55))
                    .lineLimit(1)
                    .minimumScaleFactor(0.8)
            }
            .padding(.vertical, 10)
            .frame(maxWidth: .infinity)
            .background(
                ZStack {
                    if isActive {
                        gradient(for: tab)
                            .matchedGeometryEffect(id: "ACTIVE_TAB_BACKGROUND", in: indicatorNamespace)
                    } else {
                        Color.white.opacity(0.0001) // hit area
                    }
                }
            )
            .clipShape(RoundedRectangle(cornerRadius: 24, style: .continuous))
            .shadow(
                color: isActive ? Color.black.opacity(0.08) : Color.clear,
                radius: isActive ? 10 : 0,
                x: 0,
                y: isActive ? 4 : 0
            )
            .scaleEffect(isActive ? 1.03 : 1.0)
            .animation(.spring(response: 0.4, dampingFraction: 0.85), value: isActive)
        }
        .buttonStyle(.plain)
    }
}
