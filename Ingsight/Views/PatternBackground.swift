//
//  PatternBackground.swift
//  Ingsight
//
//  Premium abstract background — Food: deep forest + sage/olive/champagne mesh, organic texture.
//  Cosmetics: midnight violet + anthracite, rose gold/lilac/white mesh, silk/molecular texture.
//

import SwiftUI

struct PatternBackground: View {
    let category: ScanCategory
    let animationOffset: CGFloat
    
    var body: some View {
        ZStack {
            // 1. Dark base
            baseLayer
                .ignoresSafeArea()
            
            // 2. Soft mesh gradients — heavily blurred light spots in corners
            meshGradientLayer
                .ignoresSafeArea()
            
            // 3. Barely visible translucent overlay pattern
            textureOverlay
                .ignoresSafeArea()
        }
    }
    
    init(category: ScanCategory, animationOffset: CGFloat = 0) {
        self.category = category
        self.animationOffset = animationOffset
    }
    
    // MARK: - Base (beyaz arka plan – kategoriye göre çok hafif ton farkı)
    private var baseLayer: some View {
        switch category {
        case .food:
            LinearGradient(
                colors: [
                    Color.white,
                    Color(red: 0.99, green: 0.99, blue: 0.98),
                    Color(red: 0.98, green: 0.98, blue: 0.97)
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        case .cosmetics:
            LinearGradient(
                colors: [
                    Color.white,
                    Color(red: 0.99, green: 0.98, blue: 0.99),
                    Color(red: 0.98, green: 0.97, blue: 0.98)
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        }
    }
    
    // MARK: - Mesh (çok hafif gri + sarı/pembe detay)
    @ViewBuilder
    private var meshGradientLayer: some View {
        GeometryReader { geo in
            let w = geo.size.width
            let h = geo.size.height
            let blur: CGFloat = 100
            let accent = category.primaryAccent
            
            ZStack {
                Circle()
                    .fill(
                        RadialGradient(
                            colors: [
                                Color.black.opacity(0.03),
                                Color.clear
                            ],
                            center: .center,
                            startRadius: 0,
                            endRadius: w * 0.5
                        )
                    )
                    .frame(width: w * 1.2, height: w * 1.2)
                    .blur(radius: blur)
                    .offset(x: -w * 0.35, y: -h * 0.3)
                
                Circle()
                    .fill(
                        RadialGradient(
                            colors: [
                                accent.opacity(0.08),
                                Color.clear
                            ],
                            center: .center,
                            startRadius: 0,
                            endRadius: w * 0.45
                        )
                    )
                    .frame(width: w * 1.1, height: w * 1.1)
                    .blur(radius: blur)
                    .offset(x: w * 0.4, y: h * 0.4)
            }
        }
    }
    
    @ViewBuilder
    private var textureOverlay: some View {
        GeometryReader { geo in
            let w = geo.size.width
            let h = geo.size.height
            let unit = min(w, h) * 0.12
            
            Group {
                if category == .food {
                    foodOrganicTexture(w: w, h: h, unit: unit)
                } else {
                    cosmeticsSilkTexture(w: w, h: h, unit: unit)
                }
            }
            .frame(width: w, height: h)
            .clipped()
            .opacity(0.06)
        }
    }
        
        // MARK: - Helper Shapes
        private func foodOrganicTexture(w: CGFloat, h: CGFloat, unit: CGFloat) -> some View {
            let cellSize = unit * 0.7
            // Ekranı dolduracak kadar döngü
            let cols = 6
            let rows = Int(h / (unit * 1.5)) + 2
            
            return ZStack(alignment: .topLeading) {
                // Hücresel ızgara
                ForEach(0..<(cols * rows), id: \.self) { i in
                    let col = CGFloat(i % cols)
                    let row = CGFloat(i / cols)
                    let x = w * (0.05 + col * 0.18)
                    let y = h * (0.05 + row * 0.12)
                    
                    OrganicCellShape()
                        .stroke(Color.black.opacity(0.12), lineWidth: 1.0)
                        .frame(width: cellSize, height: cellSize * 0.95)
                        .position(x: x, y: y)
                }
                
                
            }
        }
        
        private func cosmeticsSilkTexture(w: CGFloat, h: CGFloat, unit: CGFloat) -> some View {
            let curveSize = unit * 1.2
            let rows = Int(h / (unit * 2)) + 2
            
            return ZStack(alignment: .topLeading) {
                // İpek eğrileri
                ForEach(0..<(4 * rows), id: \.self) { i in
                    let col = CGFloat(i % 4)
                    let row = CGFloat(i / 4)
                    let x = w * (0.1 + col * 0.25)
                    let y = h * (0.1 + row * 0.2)
                    
                    SilkCurveShape()
                        .stroke(Color.black.opacity(0.10), lineWidth: 1.0)
                        .frame(width: curveSize, height: curveSize)
                        .position(x: x, y: y)
                }
                
                
            }
        }
    }

    // MARK: - Shape Definitions
    struct OrganicCellShape: Shape {
        func path(in rect: CGRect) -> Path {
            var p = Path()
            let w = rect.width
            let h = rect.height
            // Basit bir organik hücre formu
            p.addEllipse(in: CGRect(x: 0, y: 0, width: w, height: h * 0.9))
            p.move(to: CGPoint(x: w * 0.5, y: 0))
            p.addLine(to: CGPoint(x: w * 0.5, y: h * 0.9))
            return p
        }
    }

    struct LeafVeinShape: Shape {
        func path(in rect: CGRect) -> Path {
            let w = rect.width
            let h = rect.height
            var p = Path()
            p.move(to: CGPoint(x: w * 0.5, y: 0))
            p.addQuadCurve(to: CGPoint(x: w, y: h * 0.5), control: CGPoint(x: w * 0.7, y: h * 0.2))
            p.addQuadCurve(to: CGPoint(x: w * 0.5, y: h), control: CGPoint(x: w * 0.8, y: h * 0.7))
            p.addQuadCurve(to: CGPoint(x: 0, y: h * 0.5), control: CGPoint(x: w * 0.3, y: h * 0.7))
            p.addQuadCurve(to: CGPoint(x: w * 0.5, y: 0), control: CGPoint(x: w * 0.2, y: h * 0.2))
            return p
        }
    }

    struct SilkCurveShape: Shape {
        func path(in rect: CGRect) -> Path {
            let w = rect.width
            let h = rect.height
            var p = Path()
            p.move(to: CGPoint(x: 0, y: h * 0.5))
            p.addCurve(to: CGPoint(x: w, y: h * 0.5), control1: CGPoint(x: w * 0.35, y: 0), control2: CGPoint(x: w * 0.65, y: h))
            return p
        }
    }

   


// MARK: - Animated wrapper (optional subtle motion)
struct AnimatedPatternBackground: View {
    let category: ScanCategory
    @State private var animationOffset: CGFloat = 0
    
    var body: some View {
        PatternBackground(category: category, animationOffset: animationOffset)
            .onAppear {
                withAnimation(
                    Animation.linear(duration: 25)
                        .repeatForever(autoreverses: false)
                ) {
                    animationOffset = .pi * 2
                }
            }
    }
}
