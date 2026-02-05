import SwiftUI

struct ImageWithFallback: View {
    var systemName: String
    
    var body: some View {
        ZStack {
            Circle()
                .fill(Color.white.opacity(0.14))
            Image(systemName: systemName)
                .resizable()
                .scaledToFit()
                .padding(12)
                .foregroundColor(.white)
        }
    }
    
}
