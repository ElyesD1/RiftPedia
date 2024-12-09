import SwiftUI

// Define the ChampionTier struct to conform to Decodable
struct ChampionTier: Identifiable, Decodable {
    var id: String { championId } // Use championId as the identifier
    let championId: String
    let pickRate: Double?
    let championTier: String
    let tier: String
    let winRate: Double?
    let banRate: Double?
    let role: String
}

struct TierlistView: View {
    // Define the possible roles and tiers
    let roles = ["Select a role", "Top", "Jungle", "Mid", "Bot", "Support"]
    let tiers = ["Select a tier", "Iron", "Bronze", "Silver", "Gold", "Platinum", "Emerald", "Diamond", "Master", "Grandmaster", "Challenger"]

    // State variables to hold the selected role and tier
    @State private var selectedRole = "Select a role"
    @State private var selectedTier = "Select a tier"
    @State private var champions: [ChampionTier] = []

    var body: some View {
        ZStack { // Use ZStack to ensure the background fills the entire screen
            Color("Background") // Use the single Background color
                .edgesIgnoringSafeArea(.all) // Ensure the color covers the entire screen
            
            VStack {
                // Header Section with dropdowns
                VStack(alignment: .leading, spacing: 10) {
                    Text("Champion Tierlist")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                        .foregroundColor(.white)

                    HStack {
                        // Dropdown for Role selection
                        Picker("Role", selection: $selectedRole) {
                            ForEach(roles, id: \.self) { role in
                                Text(role)
                            }
                        }
                        .pickerStyle(MenuPickerStyle())
                        .padding()
                        .background(Color.black.opacity(0.5))
                        .cornerRadius(10)
                        .foregroundColor(.white)

                        // Spacer between dropdowns
                        Spacer().frame(width: 20)

                        // Dropdown for Tier selection
                        Picker("Tier", selection: $selectedTier) {
                            ForEach(tiers, id: \.self) { tier in
                                Text(tier)
                            }
                        }
                        .pickerStyle(MenuPickerStyle())
                        .padding()
                        .background(Color.black.opacity(0.5))
                        .cornerRadius(10)
                        .foregroundColor(.white)
                    }
                }
                .padding()

                // Champion list section
                if filteredChampions.isEmpty {
                    Text("Please select a role and tier.")
                        .foregroundColor(.white.opacity(0.7))
                        .padding(.top, 50)
                } else {
                    ScrollView {
                        LazyVStack(spacing: 15) {
                            ForEach(filteredChampions) { championTier in
                                ChampionCard(championTier: championTier)
                            }
                        }
                        .padding(.horizontal)
                    }
                }

                Spacer() // Push content to the top
            }
        }
        .onAppear {
            loadChampions() // Load champions when the view appears
        }
    }
    
    // Computed property to filter and sort champions based on selected role and tier
    var filteredChampions: [ChampionTier] {
        champions
            .filter { championTier in
                selectedRole != "Select a role" &&
                selectedTier != "Select a tier" &&
                championTier.role == selectedRole &&
                championTier.tier == selectedTier
            }
            .sorted { ($0.winRate ?? 0) > ($1.winRate ?? 0) } // Sort by win rate descending
    }

    // Load the champions from a local JSON file
    func loadChampions() {
        guard let url = Bundle.main.url(forResource: "TierList", withExtension: "json"),
              let data = try? Data(contentsOf: url),
              let decodedChampions = try? JSONDecoder().decode([ChampionTier].self, from: data) else {
            return
        }
        champions = decodedChampions
    }
}

// ChampionCard view to display individual champion details
struct ChampionCard: View {
    let championTier: ChampionTier

    var body: some View {
        HStack {
            if let image = UIImage(named: championTier.championId) {
                Image(uiImage: image)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 60, height: 60)
                    .clipShape(Circle())
                    .shadow(radius: 5)
            } else {
                Circle()
                    .frame(width: 60, height: 60)
                    .foregroundColor(.gray)
                    .overlay(Text("?").font(.headline).foregroundColor(.white))
            }

            VStack(alignment: .leading, spacing: 5) {
                Text(championTier.championId)
                    .font(.headline)
                    .fontWeight(.bold)
                    .foregroundColor(.white)

                if let winRate = championTier.winRate {
                    Text("Win Rate: \(winRate, specifier: "%.2f")%")
                        .foregroundColor(.white.opacity(0.8))
                }
                if let pickRate = championTier.pickRate {
                    Text("Pick Rate: \(pickRate, specifier: "%.2f")%")
                        .foregroundColor(.white.opacity(0.8))
                }
                if let banRate = championTier.banRate {
                    Text("Ban Rate: \(banRate, specifier: "%.2f")%")
                        .foregroundColor(.white.opacity(0.8))
                }
            }
            Spacer()
            Text(championTier.tier)
                .font(.caption)
                .fontWeight(.bold)
                .padding(8)
                .background(tierColor(for: championTier.tier))
                .cornerRadius(8)
                .foregroundColor(.white)
        }
        .padding()
        .background(Color.black.opacity(0.8))
        .cornerRadius(15)
        .shadow(radius: 5)
    }

    /// Helper function to determine the background color for each tier
    func tierColor(for tier: String) -> Color {
        switch tier {
        case "Iron": return Color.gray
        case "Bronze": return Color(red: 205/255, green: 127/255, blue: 50/255) // Bronze-like color
        case "Silver": return Color.gray.opacity(0.8)
        case "Gold": return Color.yellow
        case "Platinum": return Color.green.opacity(0.8)
        case "Emerald": return Color.green
        case "Diamond": return Color.blue.opacity(0.7)
        case "Master": return Color.purple.opacity(0.8)
        case "Grandmaster": return Color.red.opacity(0.8)
        case "Challenger": return Color.cyan
        default: return Color.black // Default color for unknown tiers
        }
    }
}



