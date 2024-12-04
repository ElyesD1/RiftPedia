import SwiftUI
struct GetStartedPage: View {
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 15) { // Adjust spacing between cards
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
        ZStack {
            // Card Background Image
            Image(imageName)
                .resizable()
                .scaledToFill()
                .frame(height: 180) // Fixed height
                .frame(maxWidth: .infinity) // Full width
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
            }
            .padding(10)
        }
        .frame(height: 180) // Ensure consistent height for the card
        .shadow(radius: 5)
    }
}


