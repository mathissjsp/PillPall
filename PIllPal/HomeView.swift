import SwiftUI

extension Color {
    static let pillPalBackground = Color(red: 238/255, green: 228/255, blue: 245/255)
}

struct HomeView: View {
    var body: some View {
        NavigationStack {
            ZStack {
                Color.pillPalBackground
                    .ignoresSafeArea()
                
                VStack(spacing: 40) {
                    
                    Image("logo")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 300, height: 300)

                        
                    
                    
                    
                    Text("Welkom bij PillPal bij deze app kan je een dagelijkse herinnering instellen om de anticonceptie pil te nemen")
                        .font(.title2)
                        .multilineTextAlignment(.center)
                        .foregroundColor(.purple)
                        .padding(40)
                        .background(Color.white)
                        .overlay(
                            RoundedRectangle(cornerRadius: 20)
                                .stroke(Color.gray.opacity(0.4), lineWidth: 2)
                        )
                        .cornerRadius(20)
                    
                    NavigationLink(destination: HerrineringView()) {
                        Text("Herinnering instellen")
                            .font(.headline)
                            .foregroundColor(.purple)
                            .multilineTextAlignment(.center)
                            .padding(.vertical, 20)
                            .padding(.horizontal, 30)
                            .background(Color.white)
                            .overlay(
                                RoundedRectangle(cornerRadius: 20)
                                    .stroke(Color.gray.opacity(0.4), lineWidth: 2)
                            )
                            .cornerRadius(20)
                    }
                }
                .padding()
            }
        }
    }
}

#Preview {
    HomeView()
}
