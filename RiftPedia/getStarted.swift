import SwiftUI

struct GetStartedPage: View {
    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                // Enhanced Title Card
                ZStack {
                    LinearGradient(
                        gradient: Gradient(colors: [
                            Color.black.opacity(0.8),
                            Color.appAccent.opacity(0.3)
                        ]),
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                    .cornerRadius(20)
                    
                    Text("Riftpedia Overview")
                        .font(.system(size: 28, weight: .bold))
                        .foregroundColor(.white)
                        .padding(20)
                }
                .frame(maxWidth: .infinity)
                .shadow(color: Color.black.opacity(0.2), radius: 10, x: 0, y: 5)
                
                // Enhanced Navigation Cards
                VStack(spacing: 20) {
                    NavigationLink(destination: SearchScreen()) {
                        EnhancedCardView(imageName: "historyList", title: "Summoner Profile", subtitle: "View player statistics")
                    }
                    
                    NavigationLink(destination: MapScreen()) {
                        EnhancedCardView(imageName: "terraMap", title: "Runeterra Map", subtitle: "Explore the world")
                    }
                    
                    NavigationLink(destination: ChampWiki()) {
                        EnhancedCardView(imageName: "champList", title: "Champion Wiki", subtitle: "Learn about champions")
                    }
                    
                    NavigationLink(destination: ItemWiki()) {
                        EnhancedCardView(imageName: "itemList", title: "Items Wiki", subtitle: "Browse game items")
                    }
                    
                    NavigationLink(destination: TierlistView()) {
                        EnhancedCardView(imageName: "tier", title: "Tier List", subtitle: "Check meta rankings")
                    }
                }
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 25)
        }
        .background(
            LinearGradient(
                gradient: Gradient(colors: [
                    Color.appBackground,
                    Color.appBackground.opacity(0.9)
                ]),
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()
        )
    }
}

struct EnhancedCardView: View {
    let imageName: String
    let title: String
    let subtitle: String
    
    @State private var isPressed: Bool = false
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                // Enhanced Card Background
                Image(imageName)
                    .resizable()
                    .scaledToFill()
                    .frame(width: geometry.size.width, height: 180)
                    .clipped()
                    .overlay(
                        LinearGradient(
                            gradient: Gradient(colors: [
                                Color.black.opacity(0.2),
                                Color.black.opacity(0.7)
                            ]),
                            startPoint: .top,
                            endPoint: .bottom
                        )
                    )
                    .cornerRadius(20)
                
                // Enhanced Content Layout
                VStack {
                    Spacer()
                    
                    VStack(alignment: .leading, spacing: 4) {
                        Text(title)
                            .font(.title3)
                            .fontWeight(.bold)
                            .foregroundColor(.white)
                        
                        Text(subtitle)
                            .font(.subheadline)
                            .foregroundColor(.white.opacity(0.8))
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(15)
                    .background(
                        LinearGradient(
                            gradient: Gradient(colors: [
                                Color.black.opacity(0.5),
                                Color.black.opacity(0.8)
                            ]),
                            startPoint: .top,
                            endPoint: .bottom
                        )
                    )
                }
            }
            .frame(height: 180)
            .shadow(color: Color.black.opacity(0.3), radius: 8, x: 0, y: 4)
            .scaleEffect(isPressed ? 0.98 : 1.0)
            .animation(.spring(response: 0.3, dampingFraction: 0.6), value: isPressed)
        }
        .frame(height: 180)
    }
}
