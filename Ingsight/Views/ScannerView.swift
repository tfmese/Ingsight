//
//  ScannerView.swift
//  Ingsight
//

import SwiftUI
import PhotosUI

struct ScannerView: View {
    // 1. Canlı Kamera Yöneticisi
    @StateObject private var cameraManager = CameraManager()
    
    // 2. Galeri ve Statik Resim Yöneticisi
    @StateObject private var viewModel = ScannerViewModel()
    
    var body: some View {
        ZStack(alignment: .bottom) {
            // ARKA PLAN
            LinearGradient(
                colors: [Color.black, Color.blue.opacity(0.8)],
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()
            
            VStack(spacing: 24) {
                // ÜST BAŞLIK / BRANDING
                VStack(spacing: 4) {
                    Text("Ingsight")
                        .font(.system(size: 32, weight: .bold, design: .rounded))
                        .foregroundStyle(
                            LinearGradient(
                                colors: [.white, .blue.opacity(0.7)],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                    Text("Ürün içeriklerini akıllıca tara")
                        .font(.subheadline)
                        .foregroundColor(.white.opacity(0.7))
                }
                .padding(.top, 24)
                
                // ÖNİZLEME KARTI
                ZStack {
                    RoundedRectangle(cornerRadius: 20)
                        .fill(Color.white.opacity(0.06))
                        .overlay(
                            RoundedRectangle(cornerRadius: 20)
                                .stroke(Color.white.opacity(0.15), lineWidth: 1)
                        )
                        .shadow(color: .black.opacity(0.4), radius: 12, x: 0, y: 10)
                    
                    Group {
                        if let image = viewModel.selectedImage {
                            Image(uiImage: image)
                                .resizable()
                                .scaledToFit()
                                .frame(maxHeight: 220)
                                .clipShape(RoundedRectangle(cornerRadius: 16))
                        } else {
                            ZStack {
                                CameraPreview(session: cameraManager.captureSession)
                                    .clipShape(RoundedRectangle(cornerRadius: 16))
                                
                                VStack(spacing: 8) {
                                    Image(systemName: "viewfinder")
                                        .font(.system(size: 32))
                                        .foregroundColor(.white.opacity(0.9))
                                    Text("Ürünün içindekiler kısmını hizala")
                                        .font(.footnote)
                                        .foregroundColor(.white.opacity(0.8))
                                }
                                .padding()
                                .background(
                                    RoundedRectangle(cornerRadius: 14)
                                        .fill(Color.black.opacity(0.4))
                                )
                                .padding()
                            }
                        }
                    }
                    .padding(10)
                }
                .frame(maxHeight: 260)
                .padding(.horizontal)
                
                Spacer()
                
                // ALT BUTONLAR
                VStack(spacing: 12) {
                    HStack(spacing: 18) {
                        PhotosPicker(selection: $viewModel.selectedItem, matching: .images) {
                            HStack(spacing: 8) {
                                Image(systemName: "photo.on.rectangle")
                                    .font(.system(size: 18, weight: .semibold))
                                Text("Galeriden Yükle")
                                    .font(.callout.bold())
                            }
                            .padding(.horizontal, 16)
                            .padding(.vertical, 10)
                            .background(
                                Capsule()
                                    .fill(Color.white.opacity(0.12))
                            )
                            .foregroundColor(.white)
                        }
                        
                        Button(action: {
                            withAnimation(.spring()) {
                                viewModel.reset()
                            }
                        }) {
                            HStack(spacing: 8) {
                                Image(systemName: "camera.fill")
                                    .font(.system(size: 18, weight: .semibold))
                                Text(viewModel.selectedImage == nil ? "Canlı Kamera" : "Yeniden Tara")
                                    .font(.callout.bold())
                            }
                            .padding(.horizontal, 16)
                            .padding(.vertical, 10)
                            .background(
                                Capsule()
                                    .fill(Color.blue.opacity(0.9))
                            )
                            .foregroundColor(.white)
                        }
                    }
                    
                    Text("Tüm analizler cihazında, tamamen offline gerçekleşir.")
                        .font(.caption)
                        .foregroundColor(.white.opacity(0.6))
                        .padding(.top, 4)
                }
                .padding(.bottom, 32)
            }
            
            // ANALİZ SONUÇ KARTI (ALT SHEET)
            if viewModel.isAnalysisScreenPresented {
                Color.black.opacity(0.35)
                    .ignoresSafeArea()
                
                AnalysisResultView(ingredients: viewModel.detectedIngredients) {
                    withAnimation(.spring()) {
                        viewModel.resetAnalysis()
                        viewModel.reset()
                    }
                }
                .zIndex(2)
            }
        }
        .onAppear { cameraManager.start() }
        .onDisappear { cameraManager.stop() }
        .onChange(of: viewModel.selectedImage) { image in
            image != nil ? cameraManager.stop() : cameraManager.start()
        }
        .animation(.spring(), value: viewModel.detectedIngredients.isEmpty)
    }
}

struct AnalysisResultView: View {
    let ingredients: [Ingredient]
    var onClose: () -> Void
    
    var body: some View {
        VStack(spacing: 0) {
            // Tutma Çubuğu (Handle)
            Capsule()
                .fill(Color.secondary.opacity(0.5))
                .frame(width: 40, height: 5)
                .padding(.top, 10)
                .padding(.bottom, 15)
            
            // Başlık
            HStack {
                VStack(alignment: .leading) {
                    Text("Analiz Sonucu")
                        .font(.headline)
                    Text("\(ingredients.count) Riskli Madde")
                        .font(.subheadline)
                        .foregroundColor(.red)
                }
                Spacer()
                // Kapat Butonu
                Button(action: onClose) {
                    Image(systemName: "xmark.circle.fill")
                        .font(.title2)
                        .foregroundColor(.gray.opacity(0.8))
                }
            }
            .padding(.horizontal)
            
            Divider().padding(.vertical, 10)
            
            // Liste
if ingredients.isEmpty {
    SafeIngredientCard()
        .padding(.horizontal)
        .padding(.vertical, 20)
} else {
    List(ingredients) { ingredient in
        RiskIngredientCard(ingredient: ingredient)
            .listRowBackground(Color.clear)
    }
    .listStyle(.plain)
    .frame(maxHeight: 220)
}
        }
        .background(.regularMaterial) // Buzlu cam efekti
        .cornerRadius(20, corners: [.topLeft, .topRight])
        .shadow(radius: 10)
        .frame(height: 350) // Yükseklik sınırı
        .transition(.move(edge: .bottom)) // Alttan gelme animasyonu
    }
}

// Köşe yuvarlama eklentisi
extension View {
    func cornerRadius(_ radius: CGFloat, corners: UIRectCorner) -> some View {
        clipShape(RoundedCorner(radius: radius, corners: corners))
    }
}

struct RoundedCorner: Shape {
    var radius: CGFloat = .infinity
    var corners: UIRectCorner = .allCorners
    func path(in rect: CGRect) -> Path {
        let path = UIBezierPath(roundedRect: rect, byRoundingCorners: corners, cornerRadii: CGSize(width: radius, height: radius))
        return Path(path.cgPath)
    }
}
