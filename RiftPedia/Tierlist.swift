import SwiftUI

struct ChampionTier: Identifiable, Decodable {
    var id: String { championId }
    let championId: String
    let pickRate: Double?
    let championTier: String
    let tier: String
    let winRate: Double?
    let banRate: Double?
    let role: String
}

struct TierlistView: View {
    let roles = ["Select a role", "Top", "Jungle", "Mid", "Bot", "Support"]
    let tiers = ["Select a tier", "Iron", "Bronze", "Silver", "Gold", "Platinum", "Emerald", "Diamond", "Master", "Grandmaster", "Challenger"]
    
    @State private var selectedRole = "Select a role"
    @State private var selectedTier = "Select a tier"
    @State private var champions: [ChampionTier] = []
    @State private var isLoading = true
    
    var body: some View {
        ZStack {
            // Enhanced gradient background
            LinearGradient(
                gradient: Gradient(colors: [
                    Color("Background").opacity(0.9),
                    Color("Background").opacity(0.7)
                ]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .edgesIgnoringSafeArea(.all)
            
            VStack(spacing: 20) {
                // Enhanced header section
                VStack(alignment: .leading, spacing: 15) {
                    Text("Champion Tierlist")
                        .font(.system(size: 40, weight: .bold, design: .rounded))
                        .foregroundColor(.white)
                        .shadow(color: .black.opacity(0.3), radius: 5, x: 0, y: 2)
                    
                    // Enhanced filter section
                    HStack(spacing: 15) {
                        CustomPicker(
                            selection: $selectedRole,
                            options: roles,
                            icon: "gamecontroller.fill",
                            placeholder: "Select Role"
                        )
                        
                        CustomPicker(
                            selection: $selectedTier,
                            options: tiers,
                            icon: "trophy.fill",
                            placeholder: "Select Tier"
                        )
                    }
                }
                .padding(.horizontal)
                .padding(.top)
                
                // Enhanced content section
                if isLoading {
                    ProgressView()
                        .scaleEffect(1.5)
                        .foregroundColor(.white)
                } else if filteredChampions.isEmpty {
                    EmptyStateView()
                } else {
                    ChampionListViews(champions: filteredChampions)
                }
                
                Spacer()
            }
        }
        .onAppear {
            loadChampions()
        }
    }
    
    var filteredChampions: [ChampionTier] {
        champions
            .filter { championTier in
                selectedRole != "Select a role" &&
                selectedTier != "Select a tier" &&
                championTier.role == selectedRole &&
                championTier.tier == selectedTier
            }
            .sorted { ($0.winRate ?? 0) > ($1.winRate ?? 0) }
    }
    
    func loadChampions() {
        isLoading = true
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            guard let url = Bundle.main.url(forResource: "TierList", withExtension: "json"),
                  let data = try? Data(contentsOf: url),
                  let decodedChampions = try? JSONDecoder().decode([ChampionTier].self, from: data) else {
                isLoading = false
                return
            }
            champions = decodedChampions
            isLoading = false
        }
    }
}

// Custom Picker Component
struct CustomPicker: View {
    @Binding var selection: String
    let options: [String]
    let icon: String
    let placeholder: String
    
    var body: some View {
        Menu {
            ForEach(options, id: \.self) { option in
                Button(action: { selection = option }) {
                    Text(option)
                        .foregroundColor(selection == option ? .blue : .primary)
                }
            }
        } label: {
            HStack {
                Image(systemName: icon)
                    .foregroundColor(.white)
                Text(selection)
                    .foregroundColor(.white)
                Spacer()
                Image(systemName: "chevron.down")
                    .foregroundColor(.white)
            }
            .padding()
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color.black.opacity(0.6))
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(Color.white.opacity(0.2), lineWidth: 1)
                    )
            )
        }
    }
}

// Empty State View
struct EmptyStateView: View {
    var body: some View {
        VStack(spacing: 20) {
            Image(systemName: "shield.slash.fill")
                .font(.system(size: 60))
                .foregroundColor(.white.opacity(0.7))
            
            Text("Select a role and tier to view champions")
                .font(.headline)
                .foregroundColor(.white.opacity(0.7))
                .multilineTextAlignment(.center)
        }
        .padding(.top, 50)
    }
}

// Champion List View
struct ChampionListViews: View {
    let champions: [ChampionTier]
    
    var body: some View {
        ScrollView {
            LazyVStack(spacing: 15) {
                ForEach(champions) { champion in
                    ChampionCard(championTier: champion)
                        .transition(.scale)
                }
            }
            .padding(.horizontal)
        }
    }
}

struct ChampionCard: View {
    let championTier: ChampionTier
    
    var body: some View {
        HStack(spacing: 15) {
            // Champion Image
            ChampionImage(championId: championTier.championId)
            
            // Champion Details
            VStack(alignment: .leading, spacing: 5) {
                Text(championTier.championId)
                    .font(.system(size: 18, weight: .bold))
                    .foregroundColor(.white)
                
                StatsView(championTier: championTier)
            }
            
            Spacer()
            
            // Tier Badge
            TierBadge(tier: championTier.tier)
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 15)
                .fill(Color.black.opacity(0.7))
                .overlay(
                    RoundedRectangle(cornerRadius: 15)
                        .stroke(Color.white.opacity(0.1), lineWidth: 1)
                )
        )
        .shadow(color: .black.opacity(0.2), radius: 10, x: 0, y: 5)
    }
}

// Champion Image Component
struct ChampionImage: View {
    let championId: String
    
    var body: some View {
        Group {
            if let image = UIImage(named: championId) {
                Image(uiImage: image)
                    .resizable()
                    .scaledToFill()
                    .frame(width: 70, height: 70)
                    .clipShape(Circle())
                    .overlay(
                        Circle()
                            .stroke(Color.white.opacity(0.2), lineWidth: 2)
                    )
                    .shadow(color: .black.opacity(0.3), radius: 5)
            } else {
                Circle()
                    .fill(Color.gray.opacity(0.3))
                    .frame(width: 70, height: 70)
                    .overlay(
                        Text("?")
                            .font(.title2)
                            .foregroundColor(.white)
                    )
            }
        }
    }
}

// Stats View Component
struct StatsView: View {
    let championTier: ChampionTier
    
    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            StatRow(title: "Win Rate", value: championTier.winRate, color: .green)
            StatRow(title: "Pick Rate", value: championTier.pickRate, color: .blue)
            StatRow(title: "Ban Rate", value: championTier.banRate, color: .red)
        }
    }
}

// Stat Row Component
struct StatRow: View {
    let title: String
    let value: Double?
    let color: Color
    
    var body: some View {
        if let value = value {
            HStack(spacing: 5) {
                Text(title)
                    .font(.subheadline)
                    .foregroundColor(.white.opacity(0.7))
                Text(String(format: "%.1f%%", value))
                    .font(.subheadline)
                    .foregroundColor(color)
            }
        }
    }
}

// Tier Badge Component
struct TierBadge: View {
    let tier: String
    
    var body: some View {
        Text(tier)
            .font(.system(size: 14, weight: .bold))
            .padding(.horizontal, 12)
            .padding(.vertical, 6)
            .background(
                RoundedRectangle(cornerRadius: 8)
                    .fill(tierColor(for: tier))
                    .shadow(color: .black.opacity(0.2), radius: 3)
            )
            .foregroundColor(.white)
    }
    
    func tierColor(for tier: String) -> Color {
        switch tier {
        case "Iron": return Color.gray
        case "Bronze": return Color(red: 205/255, green: 127/255, blue: 50/255)
        case "Silver": return Color.gray.opacity(0.8)
        case "Gold": return Color(red: 255/255, green: 215/255, blue: 0/255)
        case "Platinum": return Color(red: 0/255, green: 200/255, blue: 150/255)
        case "Emerald": return Color(red: 50/255, green: 205/255, blue: 50/255)
        case "Diamond": return Color(red: 100/255, green: 149/255, blue: 237/255)
        case "Master": return Color(red: 147/255, green: 112/255, blue: 219/255)
        case "Grandmaster": return Color(red: 220/255, green: 20/255, blue: 60/255)
        case "Challenger": return Color(red: 0/255, green: 255/255, blue: 255/255)
        default: return Color.black
        }
    }
}
