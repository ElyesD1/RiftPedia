import SwiftUI

struct GetStartedPage: View {
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 15) { // Adjust spacing between cards
                    // Title Card
                    ZStack {
                        Color.black.opacity(0.7)
                            .cornerRadius(15)
                        
                        Text("Riftpedia Overview")
                            .font(.title)
                            .fontWeight(.bold)
                            .foregroundColor(.white)
                            .padding(16) // Dynamic height based on text size
                    }
                    .frame(maxWidth: .infinity) // Full width like the cards
                    .shadow(radius: 5)

                    // Card 1: Search Account
                    NavigationLink(destination: SearchScreen()) {
                        CardView(imageName: "historyList", title: "Summoner Profile")
                    }

                    // Card 2: Map of Runeterra
                    NavigationLink(destination: MapScreen()) {
                        CardView(imageName: "terraMap", title: "Runeterra Map")
                    }

                    // Card 3: Champion Wiki
                    NavigationLink(destination: ChampWiki()) {
                        CardView(imageName: "champList", title: "Champion Wiki")
                    }

                    // Card 4: Items Wiki
                    NavigationLink(destination: ItemWiki()) {
                        CardView(imageName: "itemList", title: "Items Wiki")
                    }

                    // Card 5: Tier List
                    NavigationLink(destination: TierlistView()) {
                        CardView(imageName: "tier", title: "Tier List")
                    }
                }
                .padding(.horizontal, 20) // Padding for the layout
                .padding(.bottom, 40) // Adjust spacing at the bottom
            }
            .background(Color.appBackground.ignoresSafeArea()) // Full-page background
        }
    }
}

struct CardView: View {
    let imageName: String
    let title: String

    var body: some View {
        GeometryReader { geometry in
            ZStack {
                // Card Background Image
                Image(imageName)
                    .resizable()
                    .scaledToFill()
                    .frame(width: geometry.size.width * 0.95, height: 180) // 90% of screen width
                    .cornerRadius(15)
                    .clipped()

                // Card Title Overlay
                VStack {
                    Spacer()
                    Text(title)
                        .font(.headline)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                        .padding(8)
                        .background(Color.black.opacity(0.7))
                        .cornerRadius(10)
                        .frame(width: geometry.size.width * 0.95) // Text width takes 90% of screen width
                }
                .padding(10)
            }
            .frame(height: 180) // Ensure consistent height for the card
            .shadow(radius: 5)
        }
        .frame(height: 180) // Ensure the card's overall height is consistent
    }
}

struct GetStartedPage_Previews: PreviewProvider {
    static var previews: some View {
        GetStartedPage()
    }
}
