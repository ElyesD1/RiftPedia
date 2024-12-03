import SwiftUI

struct Participant: Identifiable {
    let id = UUID()
    let summonerName: String
    let championName: String
    let teamId: Int
    let teamPosition: String // Raw team position

    // Computed property to map teamPosition to display names
    var displayPosition: String {
        switch teamPosition {
        case "TOP": return "Toplane"
        case "JUNGLE": return "Jungle"
        case "MIDDLE": return "Midlane"
        case "BOTTOM": return "Botlane"
        case "UTILITY": return "Support"
        default: return teamPosition // Fallback to raw value if unrecognized
        }
    }
    
    // Computed property to get the image name for the position
    var positionImageName: String {
        return displayPosition.lowercased() // Position image is named in lowercase
    }
}

struct FullMatchView: View {
    var matchId: String
    var region: String

    var normalRegion: String {
        switch region {
        case "Europe West", "Europe Nordic & East", "Turkey", "Russia":
            return "europe"
        case "North America", "Brazil", "la1", "la2":
            return "americas"
        case "Korea", "China", "Japan":
            return "asia"
        case "Oceania":
            return "sea"
        default:
            return "Unknown Region"
        }
    }

    @State private var participants: [Participant] = []
    @State private var matchResult: [String: Bool] = [:] // Track the winning teams
    @State private var isLoading = true

    var body: some View {
        ZStack {
            // Set the background color for the entire view
            Color("Background")
                .edgesIgnoringSafeArea(.all)

            VStack {
                if isLoading {
                    ProgressView("Loading match details...")
                } else {
                    List {
                        Section(header: Text("Team 1")
                                    .font(.subheadline)
                                    .foregroundColor(.gray)) {
                            ForEach(participants.filter { $0.teamId == 100 }) { participant in
                                participantRow(for: participant)
                            }
                        }

                        Section(header: Text("Team 2")
                                    .font(.subheadline)
                                    .foregroundColor(.gray)) {
                            ForEach(participants.filter { $0.teamId == 200 }) { participant in
                                participantRow(for: participant)
                            }
                        }
                    }
                    .listStyle(InsetGroupedListStyle())
                }
            }
            .padding()
        }
        .onAppear(perform: fetchMatchData)
    }

    func participantRow(for participant: Participant) -> some View {
        HStack {
            Image(participant.championName) // Champion image
                .resizable()
                .scaledToFit()
                .frame(width: 40, height: 40)
                .clipShape(Circle())

            HStack {
                Image(participant.positionImageName) // Position image based on the lowercase position name
                    .resizable()
                    .scaledToFit()
                    .frame(width: 30, height: 30)

                VStack(alignment: .leading) {
                    Text(participant.summonerName)
                        .font(.headline)
                }
            }

            Spacer() // Push content to the left
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(
            // Background color based on the win/lose status
            Color(matchResult[participant.teamId == 100 ? "team1" : "team2"] == true ? .blue : .red)
                .opacity(0.4)
        )
        .cornerRadius(8)
    }

    func fetchMatchData() {
        let apiKey = Config.riotAPIKey
        let urlString = "https://\(normalRegion).api.riotgames.com/lol/match/v5/matches/\(matchId)?api_key=\(apiKey)"
        
        guard let url = URL(string: urlString) else { return }
        
        URLSession.shared.dataTask(with: url) { data, response, error in
            guard let data = data, error == nil else {
                print("Error fetching match data: \(error?.localizedDescription ?? "Unknown error")")
                return
            }

            do {
                if let json = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any],
                   let info = json["info"] as? [String: Any],
                   let participantsArray = info["participants"] as? [[String: Any]],
                   let teamsArray = info["teams"] as? [[String: Any]] {
                    
                    DispatchQueue.main.async {
                        self.participants = participantsArray.compactMap { participant in
                            guard let summonerName = participant["summonerName"] as? String,
                                  let championName = participant["championName"] as? String,
                                  let teamId = participant["teamId"] as? Int,
                                  let teamPosition = participant["teamPosition"] as? String else {
                                return nil
                            }
                            return Participant(
                                summonerName: summonerName,
                                championName: championName,
                                teamId: teamId,
                                teamPosition: teamPosition
                            )
                        }
                        
                        // Process match result (winning team)
                        if let team1 = teamsArray.first(where: { $0["teamId"] as? Int == 100 }),
                           let team2 = teamsArray.first(where: { $0["teamId"] as? Int == 200 }) {
                            if let team1Win = team1["win"] as? Bool,
                               let team2Win = team2["win"] as? Bool {
                                self.matchResult = [
                                    "team1": team1Win,
                                    "team2": team2Win
                                ]
                            }
                        }

                        self.participants.sort { $0.teamId < $1.teamId } // Ensures Team 1 appears first
                        self.isLoading = false
                    }
                }
            } catch {
                print("Error parsing JSON: \(error.localizedDescription)")
            }
        }.resume()
    }
}
