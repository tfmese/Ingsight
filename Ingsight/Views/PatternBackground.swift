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
    
    // MARK: - Base (deep forest green + charcoal / midnight violet + anthracite)
    private var baseLayer: some View {
        switch category {
        case .food:
            LinearGradient(
                colors: [
                    Color(red: 0.06, green: 0.14, blue: 0.08),   // deep forest green
                    Color(red: 0.08, green: 0.12, blue: 0.10),
                    Color(red: 0.10, green: 0.11, blue: 0.10),  // charcoal
                    Color(red: 0.07, green: 0.10, blue: 0.08)
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        case .cosmetics:
            LinearGradient(
                colors: [
                    Color(red: 0.08, green: 0.04, blue: 0.14),  // midnight violet
                    Color(red: 0.06, green: 0.05, blue: 0.12),
                    Color(red: 0.12, green: 0.12, blue: 0.14),  // dark anthracite
                    Color(red: 0.09, green: 0.06, blue: 0.16)
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        }
    }
    
    // MARK: - Mesh gradients (sage, olive, champagne / rose gold, lilac, white) — heavily blurred
    @ViewBuilder
    private var meshGradientLayer: some View {
        GeometryReader { geo in
            let w = geo.size.width
            let h = geo.size.height
            let blur: CGFloat = 90
            
            switch category {
            case .food:
                // Sage green, muted olive, warm champagne gold — corners & edges
                ZStack {
                    Circle()
                        .fill(
                            RadialGradient(
                                colors: [
                                    Color(red: 0.55, green: 0.62, blue: 0.52).opacity(0.35),  // sage
                                    Color(red: 0.55, green: 0.62, blue: 0.52).opacity(0)
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
                                    Color(red: 0.48, green: 0.52, blue: 0.40).opacity(0.3),   // muted olive
                                    Color(red: 0.48, green: 0.52, blue: 0.40).opacity(0)
                                ],
                                center: .center,
                                startRadius: 0,
                                endRadius: w * 0.45
                            )
                        )
                        .frame(width: w * 1.1, height: w * 1.1)
                        .blur(radius: blur)
                        .offset(x: w * 0.4, y: h * 0.35)
                    
                    Circle()
                        .fill(
                            RadialGradient(
                                colors: [
                                    Color(red: 0.76, green: 0.72, blue: 0.62).opacity(0.25), // champagne gold
                                    Color(red: 0.76, green: 0.72, blue: 0.62).opacity(0)
                                ],
                                center: .center,
                                startRadius: 0,
                                endRadius: w * 0.4
                            )
                        )
                        .frame(width: w * 1.0, height: w * 1.0)
                        .blur(radius: blur)
                        .offset(x: w * 0.15, y: h * 0.55)
                    
                    Circle()
                        .fill(
                            RadialGradient(
                                colors: [
                                    Color(red: 0.50, green: 0.58, blue: 0.48).opacity(0.2),  // soft sage
                                    Color.clear
                                ],
                                center: .center,
                                startRadius: 0,
                                endRadius: w * 0.35
                            )
                        )
                        .frame(width: w * 0.9, height: w * 0.9)
                        .blur(radius: blur)
                        .offset(x: -w * 0.2, y: h * 0.4)
                }
                
            case .cosmetics:
                // Muted rose gold, soft lilac, cool white — bokeh feel
                ZStack {
                    Circle()
                        .fill(
                            RadialGradient(
                                colors: [
                                    Color(red: 0.72, green: 0.55, blue: 0.58).opacity(0.4),  // muted rose gold
                                    Color(red: 0.72, green: 0.55, blue: 0.58).opacity(0)
                                ],
                                center: .center,
                                startRadius: 0,
                                endRadius: w * 0.5
                            )
                        )
                        .frame(width: w * 1.2, height: w * 1.2)
                        .blur(radius: blur)
                        .offset(x: -w * 0.3, y: -h * 0.25)
                    
                    Circle()
                        .fill(
                            RadialGradient(
                                colors: [
                                    Color(red: 0.70, green: 0.62, blue: 0.82).opacity(0.35), // soft lilac
                                    Color(red: 0.70, green: 0.62, blue: 0.82).opacity(0)
                                ],
                                center: .center,
                                startRadius: 0,
                                endRadius: w * 0.45
                            )
                        )
                        .frame(width: w * 1.1, height: w * 1.1)
                        .blur(radius: blur)
                        .offset(x: w * 0.45, y: h * 0.3)
                    
                    Circle()
                        .fill(
                            RadialGradient(
                                colors: [
                                    Color(red: 0.92, green: 0.90, blue: 0.96).opacity(0.28), // cool white beam
                                    Color(red: 0.92, green: 0.90, blue: 0.96).opacity(0)
                                ],
                                center: .center,
                                startRadius: 0,
                                endRadius: w * 0.4
                            )
                        )
                        .frame(width: w * 1.0, height: w * 1.0)
                        .blur(radius: blur)
                        .offset(x: w * 0.1, y: h * 0.6)
                    
                    Circle()
                        .fill(
                            RadialGradient(
                                colors: [
                                    Color(red: 0.75, green: 0.58, blue: 0.75).opacity(0.22), // lilac
                                    Color.clear
                                ],
                                center: .center,
                                startRadius: 0,
                                endRadius: w * 0.35
                            )
                        )
                        .frame(width: w * 0.85, height: w * 0.85)
                        .blur(radius: blur)
                        .offset(x: -w * 0.25, y: h * 0.45)
                }
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
                .opacity(category == .food ? 0.18 : 0.2)
                .blendMode(.plusLighter)
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
                        .stroke(Color.white.opacity(0.6), lineWidth: 1.2)
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
                        .stroke(Color.white.opacity(0.55), lineWidth: 1.0)
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
