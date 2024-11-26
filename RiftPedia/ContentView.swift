//  ContentView.swift
//  RiftPedia
//
//  Created by Elyes Darouich on 23/11/2024.
//

import SwiftUI

extension Color {
    static let appAccent = Color("Accent")
    static let appBackground = Color("Background")
    static let appButton = Color("Button")
    static let appLabel = Color("Label")
}

struct ContentView: View {
    var body: some View {
        NavigationStack { // Use NavigationStack instead of NavigationView
            ZStack {
                // Background Color
                Color.appBackground
                    .ignoresSafeArea()

                VStack(spacing: 20) {
                    // Logo at the Top
                    Image("Logo")
                        .resizable()
                        .scaledToFit()
                        .frame(height: 300)
                        .padding(.top, 0)

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

                    Spacer()

                    // Navigation Button
                    NavigationLink(destination: SearchScreen()) {
                        Text("Get Started")
                            .foregroundColor(.appBackground) // Text color contrasts with the button color
                            .padding()
                            .frame(maxWidth: 200)
                            .background(Color.appButton)
                            .cornerRadius(10)
                    }
                    .padding(.bottom, 50) // Adjust this value to move the button higher
                }
                .padding()
            }
        }
    }
}
// Preview
#Preview {
    ContentView()
        .environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
}
