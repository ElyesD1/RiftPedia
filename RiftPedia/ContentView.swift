import SwiftUI

extension Color {
    static let appAccent = Color("Accent")
    static let appBackground = Color("Background")
    static let appButton = Color("Button")
    static let appLabel = Color("Label")
}

struct ContentView: View {
    var body: some View {
        NavigationStack {
            ZStack {
                // Background Color
                Color.appBackground
                    .ignoresSafeArea()

                VStack(spacing: 10) { // Adjusted spacing for closer elements
                    // Logo at the Top
                    Image("Logo")
                        .resizable()
                        .scaledToFit()
                        .frame(height: 300)
                        .padding(.top, 20)

                    // Welcome Title
                    Text("Welcome to RiftPedia")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                        .foregroundColor(.appLabel)

                    // Description
                    Text("Explore League of Legends lore, champions, and player stats all in one place!")
                        .font(.body)
                        .multilineTextAlignment(.center)
                        .foregroundColor(.appLabel)
                        .padding(.horizontal, 20)

                    Spacer() // Adds space between the text and the buttons

                    // Buttons inside a Card
                    ZStack {
                        // Card Background
                        RoundedRectangle(cornerRadius: 20)
                            .fill(Color.appBackground.opacity(10)) // Semi-transparent card
                            .shadow(radius: 5)

                        // Buttons
                        VStack(spacing: 15) {
                            let buttonWidth: CGFloat = 300 // Set a fixed width for uniformity

                            // Search Account Navigation Button
                            NavigationLink(destination: SearchScreen()) {
                                Text("Look up your Summoner Profile")
                                    .foregroundColor(.appBackground)
                                    .frame(width: buttonWidth, height: 50)
                                    .background(Color.appButton)
                                    .cornerRadius(10)
                            }

                            // Map Navigation Button
                            NavigationLink(destination: MapScreen()) {
                                Text("Explore the Runeterra Map")
                                    .foregroundColor(.appBackground)
                                    .frame(width: buttonWidth, height: 50)
                                    .background(Color.appButton)
                                    .cornerRadius(10)
                            }

                            // New Champion Wiki Button
                            NavigationLink(destination: ChampWiki()) {
                                Text("Explore our Champion Wiki")
                                    .foregroundColor(.appBackground)
                                    .frame(width: buttonWidth, height: 50)
                                    .background(Color.appButton)
                                    .cornerRadius(10)
                            }

                            // New Items Wiki Button
                            NavigationLink(destination: ItemWiki()) {
                                Text("Explore our Items Wiki")
                                    .foregroundColor(.appBackground)
                                    .frame(width: buttonWidth, height: 50)
                                    .background(Color.appButton)
                                    .cornerRadius(10)
                            }
                        }
                        .padding(20) // Add padding inside the card
                    }
                    .padding(.horizontal, 20) // Adjust card's width relative to screen
                    .padding(.bottom, 70) // Adjust this value for spacing
                }
                .padding()
            }
        }
    }
}

#Preview {
    ContentView()
}
