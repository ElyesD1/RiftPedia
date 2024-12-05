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

                    Spacer() // Adds space between the text and the button

                    // Single Button
                    NavigationLink(destination: GetStartedPage()) {
                        Text("Get Started")
                            .font(.title2) // Increase font size here
                            .foregroundColor(.appBackground)
                            .frame(width: 300, height: 60) // Increased button height
                            .background(Color.appButton)
                            .cornerRadius(10)
                    }
                    .padding(.bottom, 70) // Adjust bottom spacing for alignment
                }
                .padding()
            }
        }
    }
}
