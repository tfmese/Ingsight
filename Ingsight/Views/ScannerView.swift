//
//  ScannerView.swift
//  Ingsight
//
//  Created by Talha Fırat on 3.02.2026.
//

import SwiftUI
import PhotosUI // Galeri için gerekli

struct ScannerView: View {
    // 1. Canlı Kamera Yöneticisi
    @StateObject private var cameraManager = CameraManager()
    
    // 2. Galeri ve Statik Resim Yöneticisi (YENİ)
    @StateObject private var viewModel = ScannerViewModel()
    
    var body: some View {
        ZStack {
            // --- KATMAN 1: GÖRÜNTÜ KAYNAĞI ---
            if let image = viewModel.selectedImage {
                // A) Eğer galeriden resim seçildiyse onu göster
                Image(uiImage: image)
                    .resizable()
                    .scaledToFit()
                    .background(Color.black)
                    .ignoresSafeArea()
            } else {
                // B) Yoksa canlı kamerayı göster
                CameraPreview(session: cameraManager.captureSession)
                    .ignoresSafeArea()
            }
            
            // --- KATMAN 2: ARAYÜZ (OVERLAY) ---
            VStack {
                // Üst Kısım: Okunan Metin Alanı
                let textToShow = viewModel.selectedImage != nil ? viewModel.recognizedText : cameraManager.recognizedText
                
                if !textToShow.isEmpty {
                    // 👇 YENİ: Metin Alanını ve Kapat Butonunu kapsayan ZStack
                    ZStack(alignment: .topTrailing) {
                        
                        // Metin Kutusu
                        ScrollView {
                            Text(textToShow)
                                .padding()
                                .frame(maxWidth: .infinity, alignment: .leading) // Sola yasla
                        }
                        .frame(height: 150)
                        .background(.ultraThinMaterial)
                        .cornerRadius(12)
                        
                        // 👇 YENİ: Kapat (X) Butonu
                        Button(action: {
                            withAnimation {
                                // Galeri modundaysak metni temizle -> Kutu kapanır
                                if viewModel.selectedImage != nil {
                                    viewModel.recognizedText = ""
                                }
                                // Canlı kamera modundaysak da anlık temizleyelim
                                // (Not: Kamera sürekli okuma yaptığı için geri gelebilir, ama galeri için bu kesin çözüm)
                                else {
                                    // cameraManager içinde recognizedText @Published ise:
                                    // cameraManager.recognizedText = ""
                                }
                            }
                        }) {
                            Image(systemName: "xmark.circle.fill")
                                .font(.title2)
                                .foregroundColor(.gray)
                                .background(Color.white.clipShape(Circle()))
                                .padding(8) // Köşeden biraz boşluk
                        }
                    }
                    .padding() // Ekran kenarlarından boşluk
                    // Yükleniyor göstergesi (Loading)
                    .overlay(
                        Group {
                            if viewModel.isScanning {
                                ProgressView()
                                    .padding()
                                    .background(.white)
                                    .clipShape(Circle())
                            }
                        }
                    )
                }
                
                Spacer()
                
                // Alt Kısım: Butonlar
                HStack {
                    // GALERİ SEÇİM BUTONU
                    PhotosPicker(selection: $viewModel.selectedItem, matching: .images) {
                        Image(systemName: "photo.on.rectangle")
                            .font(.system(size: 24))
                            .foregroundColor(.white)
                            .padding()
                            .background(Circle().fill(.blue.opacity(0.8)))
                    }
                    
                    // KAMERAYA DÖN BUTONU (Sadece resim seçiliyse görünür)
                    if viewModel.selectedImage != nil {
                        Button(action: {
                            withAnimation {
                                viewModel.reset() // Resmi temizle, kameraya dön
                            }
                        }) {
                            Image(systemName: "camera.fill")
                                .font(.system(size: 24))
                                .foregroundColor(.white)
                                .padding()
                                .background(Circle().fill(.gray.opacity(0.8)))
                        }
                        .padding(.leading, 15)
                    }
                }
                .padding(.bottom, 30)
            }
        }
        .onAppear {
            cameraManager.start()
        }
        .onDisappear {
            cameraManager.stop()
        }
        .onChange(of: viewModel.selectedImage) { image in
            if image != nil {
                cameraManager.stop()
            } else {
                cameraManager.start()
            }
        }
    }
}
