import SwiftUI

// Data model for match participants, conforming to Identifiable for SwiftUI lists
struct Participant: Identifiable {
    let id = UUID() // Unique identifier for each participant
    let summonerName: String // Player's in-game name
    let championName: String // Name of the champion played
    let teamId: Int // Team identifier (100 for team 1, 200 for team 2)
    let teamPosition: String // Raw team position (e.g., "TOP", "JUNGLE")
    let kills: Int // Number of kills
    let deaths: Int // Number of deaths
    let assists: Int // Number of assists
    let champLevel: Int // Champion's level at the end of the game
    let totalDamageDealt: Int // Total damage dealt by the champion
    let visionScore: Int // Vision score (wards, map vision contributions)
    let goldEarned: Int // Total gold earned during the match
    let totalMinionsKilled: Int // Total minions killed
    let item0: Int? // ID of the first item
    let item1: Int? // ID of the second item
    let item2: Int? // ID of the third item
    let item3: Int? // ID of the fourth item
    let item4: Int? // ID of the fifth item
    let item5: Int? // ID of the sixth item
    let item6: Int? // ID of the trinket/ward item
    let neutralMinionsKilled: Int // Neutral monsters killed (jungle creeps)
    
    // Translates raw team position to a more readable form
    var displayPosition: String {
        switch teamPosition {
        case "TOP": return "Toplane"
        case "JUNGLE": return "Jungle"
        case "MIDDLE": return "Midlane"
        case "BOTTOM": return "Botlane"
        case "UTILITY": return "Support"
        default: return teamPosition
        }
    }

    // Determines the image name for the position
    var positionImageName: String {
        return displayPosition.lowercased() // Matches the image asset names
    }

    // Calculates Kill/Death/Assist ratio (KDA)
    var kda: String {
        String(format: "%.2f", Double(kills + assists) / max(1, Double(deaths))) // Avoids division by zero
    }
}

// Extend Participant to include performance score
extension Participant {
    var performanceScore: Double {
        let kdaScore = Double(kills + assists) / max(1, Double(deaths)) * 1.0
        let damageScore = Double(totalDamageDealt) * 0.001
        let visionScoreWeight = Double(visionScore) * 0.1
        let goldScore = Double(goldEarned) * 0.001
        return kdaScore + damageScore + visionScoreWeight + goldScore
    }
}

// SwiftUI view to display match details
struct FullMatchView: View {
    var matchId: String // ID of the match
    var region: String // Region of the match

    // Maps region names to API regions
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
    let queueMapping: [Int: String] = [
        420: "Ranked Solo/Duo",
        440: "Ranked Flex",
        450: "ARAM",
        400: "Normal Draft",
        430: "Normal Blind",
        700: "Clash",
        830: "Co-op vs AI Intro",
        840: "Co-op vs AI Beginner",
        850: "Co-op vs AI Intermediate"
        // Add more mappings if necessary
    ]

    @State private var participants: [Participant] = [] // List of participants in the match
    @State private var matchResult: [String: Bool] = [:] // Tracks which teams won
    @State private var gameMode: String = "" // Game mode (e.g., ARAM, Summoner's Rift)
    @State private var gameDuration: String = "" // Duration of the game in readable format
    @State private var team1Stats: (baronKills: Int, turretKills: Int, dragonKills: Int) = (0, 0, 0) // Stats for team 1
    @State private var team2Stats: (baronKills: Int, turretKills: Int, dragonKills: Int) = (0, 0, 0) // Stats for team 2
    @State private var isLoading = true // Indicates if data is still being loaded
    var body: some View {
        ZStack {
            // Background color
            Color("Background")
                .edgesIgnoringSafeArea(.all)

            VStack {
                if isLoading {
                    ProgressView("Loading match details...")
                } else {
                    List {
                        // Section for Team 1
                        Section(
                            header: teamHeader(
                                title: "Team 1",
                                stats: team1Stats,
                                isWinning: matchResult["team1"] == true
                            )
                        ) {
                            ForEach(participants.filter { $0.teamId == 100 }) { participant in
                                participantRow(for: participant)
                            }
                        }

                        // Game Metadata
                        VStack {
                            Text(gameMode)
                                .font(.headline)
                                .foregroundColor(.primary)

                            Text(gameDuration)
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                        }
                        .frame(maxWidth: .infinity, alignment: .center)
                        .padding()

                        // Section for Team 2
                        Section(
                            header: teamHeader(
                                title: "Team 2",
                                stats: team2Stats,
                                isWinning: matchResult["team2"] == true
                            )
                        ) {
                            ForEach(participants.filter { $0.teamId == 200 }) { participant in
                                participantRow(for: participant)
                            }
                        }
                    }
                    .listStyle(InsetGroupedListStyle())
                    .scrollContentBackground(.hidden)
                }
            }
            .padding()
        }
        .onAppear(perform: fetchMatchData)
    }

    // Row for each participant
    func participantRow(for participant: Participant) -> some View {
        VStack {
            HStack(alignment: .top, spacing: 12) {
                // Champion Image and Level
                ZStack {
                    Image(participant.championName)
                        .resizable()
                        .scaledToFit()
                        .frame(width: 50, height: 50)
                        .clipShape(Circle())

                    Text("\(participant.champLevel)")
                        .font(.caption)
                        .bold()
                        .foregroundColor(.white)
                        .padding(4)
                        .background(Color.black.opacity(0.7))
                        .clipShape(Circle())
                        .offset(x: -20, y: -20)
                }

                VStack(alignment: .leading, spacing: 6) {
                    // Summoner Name and Rank
                    HStack {
                        let rankedParticipants = participants.sorted { $0.performanceScore > $1.performanceScore }
                                             let rank = rankedParticipants.firstIndex(where: { $0.id == participant.id }) ?? 0
                    
                                        Text(participant.summonerName)
                                                .font(.headline)
                    
                                          // Display rank in a circular badge
                        Text("Rank:\(rank + 1)")
                            .font(.caption)
                            .bold()
                            .padding(6)
                            .background(
                                RoundedRectangle(cornerRadius: 12)
                                    .fill(Color.black)
                            )
                            .foregroundColor(.white)
                            .padding(.leading, 5)
                
                    }

                    // KDA and Damage
                    HStack {
                        Text("\(participant.kills)/\(participant.deaths)/\(participant.assists) (\(participant.kda))")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                        Spacer()
                        Text("Damage: \(participant.totalDamageDealt)")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }

                    // Gold and CS
                    HStack {
                        Text("Gold: \(participant.goldEarned)")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                        Spacer()
                        Text("CS: \(participant.totalMinionsKilled + participant.neutralMinionsKilled)")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                }
            }

            // Items and Ward
            HStack {
                ForEach([participant.item0, participant.item1, participant.item2, participant.item3, participant.item4, participant.item5], id: \.self) { item in
                    if let item = item {
                        Image("\(item)")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 30, height: 30)
                            .clipShape(RoundedRectangle(cornerRadius: 4))
                    }
                }

                Spacer()

                if let ward = participant.item6 {
                    ZStack {
                        Image("\(ward)")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 30, height: 30)
                            .clipShape(RoundedRectangle(cornerRadius: 4))

                        Text("\(participant.visionScore)")
                            .font(.caption)
                            .bold()
                            .foregroundColor(.white)
                            .padding(4)
                            .background(Color.black.opacity(0.7))
                            .clipShape(Circle())
                            .offset(x: -15, y: -15)
                    }
                }
            }
            .padding(.top, 8)
        }
        .padding()
        .background(
            Color(matchResult[participant.teamId == 100 ? "team1" : "team2"] == true ? .blue : .red)
                .opacity(0.1)
        )
        .cornerRadius(10)
        .shadow(radius: 2)
    }

    // Team Header
    func teamHeader(title: String, stats: (baronKills: Int, turretKills: Int, dragonKills: Int), isWinning: Bool?) -> some View {
        HStack {
            Text(title)
                .font(.headline)
                .foregroundColor(isWinning == true ? .blue : .red)

            Spacer()

            HStack(spacing: 15) {
                statView(stat: "Turrets", value: stats.turretKills, color: isWinning == true ? .blue : .red)
                statView(stat: "Dragons", value: stats.dragonKills, color: isWinning == true ? .blue : .red)
                statView(stat: "Barons", value: stats.baronKills, color: isWinning == true ? .blue : .red)
            }
        }
    }

    func statView(stat: String, value: Int, color: Color) -> some View {
        VStack {
            Text("\(value)")
                .font(.headline)
                .foregroundColor(color) // Dynamic color
            Text(stat)
                .font(.caption)
                .foregroundColor(color) // Dynamic color
        }
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
                        if let queueId = info["queueId"] as? Int {
                            self.gameMode = queueMapping[queueId] ?? "Unknown Game Mode"
                        } else {
                            self.gameMode = "Unknown Game Mode"
                        }
                        

                        if let duration = info["gameDuration"] as? Int {
                            let seconds = duration % 60
                            let minutes = duration / 60
                            self.gameDuration = String(format: "%02d:%02d", minutes, seconds)
                        }

                        self.participants = participantsArray.compactMap { participant in
                            if let summonerName = participant["summonerName"] as? String,
                               let championName = participant["championName"] as? String,
                               let teamId = participant["teamId"] as? Int,
                               let teamPosition = participant["teamPosition"] as? String,
                               let kills = participant["kills"] as? Int,
                               let deaths = participant["deaths"] as? Int,
                               let assists = participant["assists"] as? Int,
                               let champLevel = participant["champLevel"] as? Int,
                               let totalDamageDealt = participant["totalDamageDealtToChampions"] as? Int,
                               let visionScore = participant["visionScore"] as? Int,
                               let goldEarned = participant["goldEarned"] as? Int,
                               let totalMinionsKilled = participant["totalMinionsKilled"] as? Int,
                               let neutralMinionsKilled = participant["neutralMinionsKilled"] as? Int{ // Added logic for totalMinionsKilled
                                
                                return Participant(
                                    summonerName: summonerName,
                                    championName: championName,
                                    teamId: teamId,
                                    teamPosition: teamPosition,
                                    kills: kills,
                                    deaths: deaths,
                                    assists: assists,
                                    champLevel: champLevel,
                                    totalDamageDealt: totalDamageDealt,
                                    visionScore: visionScore,
                                    goldEarned: goldEarned,
                                    totalMinionsKilled: totalMinionsKilled, // Added totalMinionsKilled
                                    item0: participant["item0"] as? Int,
                                    item1: participant["item1"] as? Int,
                                    item2: participant["item2"] as? Int,
                                    item3: participant["item3"] as? Int,
                                    item4: participant["item4"] as? Int,
                                    item5: participant["item5"] as? Int,
                                    item6: participant["item6"] as? Int,
                                    neutralMinionsKilled: neutralMinionsKilled
                                )
                            }
                            return nil
                        }

                        if teamsArray.count >= 2 {
                            if let objectives1 = teamsArray[0]["objectives"] as? [String: Any] {
                                self.team1Stats = (
                                    baronKills: (objectives1["baron"] as? [String: Any])?["kills"] as? Int ?? 0,
                                    turretKills: (objectives1["tower"] as? [String: Any])?["kills"] as? Int ?? 0,
                                    dragonKills: (objectives1["dragon"] as? [String: Any])?["kills"] as? Int ?? 0
                                )
                            }

                            if let objectives2 = teamsArray[1]["objectives"] as? [String: Any] {
                                self.team2Stats = (
                                    baronKills: (objectives2["baron"] as? [String: Any])?["kills"] as? Int ?? 0,
                                    turretKills: (objectives2["tower"] as? [String: Any])?["kills"] as? Int ?? 0,
                                    dragonKills: (objectives2["dragon"] as? [String: Any])?["kills"] as? Int ?? 0
                                )
                            }
                            self.matchResult = [
                                "team1": teamsArray[0]["win"] as? Bool ?? false,
                                "team2": teamsArray[1]["win"] as? Bool ?? false
                            ]
                        }

                        self.isLoading = false
                    }
                }
            } catch {
                print("Error decoding JSON: \(error.localizedDescription)")
            }
        }
        .resume()
    }
}
