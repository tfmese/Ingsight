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
            let unit = min(w, h) * 0.12  // birim boyut — ekrana göre ölçeklenir
            
            switch category {
            case .food:
                foodOrganicTexture(w: w, h: h, unit: unit)
                    .frame(width: w, height: h)
                    .clipped()
                    .opacity(0.18)
                    .blendMode(.plusLighter)
            case .cosmetics:
                cosmeticsSilkTexture(w: w, h: h, unit: unit)
                    .frame(width: w, height: h)
                    .clipped()
                    .opacity(0.2)
                    .blendMode(.plusLighter)
            }
        }
    }
    
    // Leaf veins / cellular — koordinatlar w,h içinde, görünür stroke
    private func foodOrganicTexture(w: CGFloat, h: CGFloat, unit: CGFloat) -> some View {
        let cellSize = unit * 0.7
        let cols = 6
        let rowCount = max(4, min(8, Int(h / (unit * 2.0))))
        return ZStack(alignment: .topLeading) {
            // Hücresel yapılar — grid, ekranı kaplar
            ForEach(0..<(cols * rowCount), id: \.self) { i in
                let col = i % cols
                let row = i / cols
                let x = w * (0.08 + CGFloat(col) * 0.17)
                let y = h * (0.06 + CGFloat(row) * 0.11)
                organicCellShape(size: cellSize)
                    .stroke(Color.white.opacity(0.6), lineWidth: 1.2)
                    .frame(width: cellSize, height: cellSize * 0.95)
                    .position(x: x, y: y)
            }
            // Yaprak damarı formları — oranlı, ekranda dağılmış
            ForEach(0..<12, id: \.self) { i in
                let veinSize = unit * (1.2 + CGFloat(i % 3) * 0.8)
                let x = w * (0.15 + CGFloat(i % 4) * 0.24)
                let y = h * (0.18 + CGFloat(i / 4) * 0.24)
                leafVeinPath(size: veinSize)
                    .stroke(Color.white.opacity(0.5), lineWidth: 1.0)
                    .frame(width: veinSize, height: veinSize)
                    .position(x: x, y: y)
            }
        }
    }
    
    private func organicCellShape(size: CGFloat) -> Path {
        let s = size
        var p = Path()
        p.addEllipse(in: CGRect(x: 0, y: 0, width: s, height: s * 0.92))
        p.move(to: CGPoint(x: s * 0.5, y: 0))
        p.addLine(to: CGPoint(x: s * 0.5, y: s * 0.92))
        p.move(to: CGPoint(x: 0, y: s * 0.46))
        p.addLine(to: CGPoint(x: s, y: s * 0.46))
        return p
    }
    
    private func leafVeinPath(size: CGFloat) -> Path {
        let s = size
        var p = Path()
        p.move(to: CGPoint(x: s * 0.5, y: 0))
        p.addQuadCurve(to: CGPoint(x: s, y: s * 0.5), control: CGPoint(x: s * 0.72, y: s * 0.18))
        p.addQuadCurve(to: CGPoint(x: s * 0.5, y: s), control: CGPoint(x: s * 0.82, y: s * 0.72))
        p.addQuadCurve(to: CGPoint(x: 0, y: s * 0.5), control: CGPoint(x: s * 0.28, y: s * 0.72))
        p.addQuadCurve(to: CGPoint(x: s * 0.5, y: 0), control: CGPoint(x: s * 0.18, y: s * 0.18))
        p.closeSubpath()
        return p
    }
    
    // Silk curves / molecular — w,h içinde konumlar
    private func cosmeticsSilkTexture(w: CGFloat, h: CGFloat, unit: CGFloat) -> some View {
        let curveSize = unit * 1.0
        let hexSize = unit * 0.55
        return ZStack(alignment: .topLeading) {
            ForEach(0..<24, id: \.self) { i in
                let x = w * (0.06 + CGFloat(i % 6) * 0.18)
                let y = h * (0.08 + CGFloat(i / 6) * 0.2)
                silkCurveShape(size: curveSize)
                    .stroke(Color.white.opacity(0.55), lineWidth: 1.0)
                    .frame(width: curveSize, height: curveSize)
                    .position(x: x, y: y)
            }
            ForEach(0..<15, id: \.self) { i in
                let x = w * (0.18 + CGFloat(i % 5) * 0.2)
                let y = h * (0.32 + CGFloat(i / 5) * 0.22)
                molecularHexagon(size: hexSize)
                    .stroke(Color.white.opacity(0.4), lineWidth: 0.9)
                    .frame(width: hexSize * 2, height: hexSize * 2)
                    .position(x: x, y: y)
            }
        }
    }
    
    private func silkCurveShape(size: CGFloat) -> Path {
        let s = size
        var p = Path()
        p.move(to: CGPoint(x: 0, y: s * 0.5))
        p.addCurve(
            to: CGPoint(x: s, y: s * 0.5),
            control1: CGPoint(x: s * 0.35, y: 0),
            control2: CGPoint(x: s * 0.65, y: s)
        )
        p.addCurve(
            to: CGPoint(x: 0, y: s * 0.5),
            control1: CGPoint(x: s * 0.65, y: 0),
            control2: CGPoint(x: s * 0.35, y: s)
        )
        return p
    }
    
    private func molecularHexagon(size: CGFloat) -> Path {
        let s = size
        var p = Path()
        for i in 0..<6 {
            let angle = CGFloat(i) * .pi / 3 - .pi / 6
            let x = s + s * CGFloat(cos(Double(angle)))
            let y = s + s * CGFloat(sin(Double(angle)))
            if i == 0 { p.move(to: CGPoint(x: x, y: y)) }
            else { p.addLine(to: CGPoint(x: x, y: y)) }
        }
        p.closeSubpath()
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
