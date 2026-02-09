//
//  AppTypography.swift
//  Ingsight
//
//  Modern, bold, rounded — casual ve göze hoş.
//

import SwiftUI

enum AppTypography {
    /// Ana sayfa başlığı (Gıda Tarayıcı vb.)
    static let largeTitle = Font.system(size: 32, weight: .heavy, design: .rounded)
    /// Bölüm başlığı
    static let title = Font.system(size: 24, weight: .heavy, design: .rounded)
    /// Kart / alt başlık
    static let title3 = Font.system(size: 18, weight: .bold, design: .rounded)
    /// Vurgulu gövde
    static let bodyBold = Font.system(size: 16, weight: .bold, design: .rounded)
    /// Normal gövde
    static let body = Font.system(size: 15, weight: .medium, design: .rounded)
    /// Küçük etiket / caption
    static let caption = Font.system(size: 13, weight: .medium, design: .rounded)
    static let captionBold = Font.system(size: 12, weight: .bold, design: .rounded)
    /// Skor / büyük sayı
    static let score = Font.system(size: 42, weight: .heavy, design: .rounded)
    
    static let lineSpacingBody: CGFloat = 6
    static let lineSpacingCaption: CGFloat = 4
}
