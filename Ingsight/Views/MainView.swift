import SwiftUI

struct MainView: View {
    @State private var selectedCategory: ScanCategory = .food
    
    var body: some View {
        ZStack(alignment: .bottom) {
            Color.white
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
        let accent = category.primaryAccent.opacity(0.25)
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
    private func tabButton(icon: String, label: String, category: ScanCategory) -> some View {
        let isActive = selectedCategory == category
        
        Button {
            withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
                selectedCategory = category
            }
        } label: {
            HStack(spacing: 10) {
                Image(systemName: icon)
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundColor(isActive ? category.primaryAccent : .black.opacity(0.45))
                Text(label)
                    .font(AppTypography.bodyBold)
                    .foregroundColor(isActive ? .black : .black.opacity(0.55))
            }
            .padding(.horizontal, isActive ? 18 : 14)
            .padding(.vertical, 12)
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
                color: isActive ? Color.black.opacity(0.08) : Color.clear,
                radius: isActive ? 12 : 0,
                x: 0,
                y: isActive ? 4 : 0
            )
            .scaleEffect(isActive ? 1.05 : 1.0)
            .animation(.spring(response: 0.4, dampingFraction: 0.8), value: isActive)
        }
        .buttonStyle(.plain)
    }
}
