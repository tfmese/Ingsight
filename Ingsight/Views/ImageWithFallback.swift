import SwiftUI

struct ImageWithFallback: View {
    var systemName: String
    
    var body: some View {
        ZStack {
            Circle()
                .fill(Color.black.opacity(0.06))
            Image(systemName: systemName)
                .resizable()
                .scaledToFit()
                .padding(12)
                .foregroundColor(.black.opacity(0.5))
        }
    }
    
}
