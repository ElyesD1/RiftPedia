import SwiftUI

// Data model for match participants, conforming to Identifiable for SwiftUI lists
struct Participant: Identifiable {
    // All original properties remain unchanged
    let id = UUID()
    let summonerName: String
    let championName: String
    let teamId: Int
    let teamPosition: String
    let kills: Int
    let deaths: Int
    let assists: Int
    let champLevel: Int
    let totalDamageDealt: Int
    let visionScore: Int
    let goldEarned: Int
    let totalMinionsKilled: Int
    let item0: Int?
    let item1: Int?
    let item2: Int?
    let item3: Int?
    let item4: Int?
    let item5: Int?
    let item6: Int?
    let neutralMinionsKilled: Int
    
    // Original computed properties remain unchanged
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

    var positionImageName: String {
        return displayPosition.lowercased()
    }

    var kda: String {
        String(format: "%.2f", Double(kills + assists) / max(1, Double(deaths)))
    }
}

// Original extension remains unchanged
extension Participant {
    var performanceScore: Double {
        let kdaScore = Double(kills + assists) / max(1, Double(deaths)) * 1.0
        let damageScore = Double(totalDamageDealt) * 0.001
        let visionScoreWeight = Double(visionScore) * 0.1
        let goldScore = Double(goldEarned) * 0.001
        return kdaScore + damageScore + visionScoreWeight + goldScore
    }
}

struct FullMatchView: View {
    // Original properties remain unchanged
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
    ]

    @State private var participants: [Participant] = []
    @State private var matchResult: [String: Bool] = [:]
    @State private var gameMode: String = ""
    @State private var gameDuration: String = ""
    @State private var team1Stats: (baronKills: Int, turretKills: Int, dragonKills: Int) = (0, 0, 0)
    @State private var team2Stats: (baronKills: Int, turretKills: Int, dragonKills: Int) = (0, 0, 0)
    @State private var isLoading = true

    var body: some View {
        ZStack {
            // Enhanced background
            Color("Background")
                .edgesIgnoringSafeArea(.all)
                .overlay(
                    LinearGradient(
                        gradient: Gradient(colors: [Color.blue.opacity(0.1), Color.purple.opacity(0.1)]),
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )

            VStack {
                if isLoading {
                    VStack {
                        ProgressView()
                            .scaleEffect(1.5)
                            .progressViewStyle(CircularProgressViewStyle(tint: Color.blue))
                        Text("Loading match details...")
                            .foregroundColor(.secondary)
                            .padding(.top, 10)
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
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
                                participantRow(
                                    for: participant,
                                    teamTotalPerformance: totalPerformance(for: 100)
                                )
                            }
                        }

                        // Game Metadata
                        VStack {
                            Text(gameMode)
                                .font(.title3)
                                .fontWeight(.semibold)
                                .foregroundColor(.primary)
                            
                            Text(gameDuration)
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                        }
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(
                            RoundedRectangle(cornerRadius: 12)
                                .fill(Color.secondary.opacity(0.1))
                        )
                        .padding(.vertical, 8)

                        // Section for Team 2
                        Section(
                            header: teamHeader(
                                title: "Team 2",
                                stats: team2Stats,
                                isWinning: matchResult["team2"] == true
                            )
                        ) {
                            ForEach(participants.filter { $0.teamId == 200 }) { participant in
                                participantRow(
                                    for: participant,
                                    teamTotalPerformance: totalPerformance(for: 200)
                                )
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

    func participantRow(for participant: Participant, teamTotalPerformance: Double) -> some View {
        let carryScore = normalizedCarryScore(for: participant, teamTotalPerformance: teamTotalPerformance)

        return VStack {
            HStack(alignment: .top, spacing: 12) {
                // Enhanced Champion Image and Level
                ZStack {
                    Image(participant.championName)
                        .resizable()
                        .scaledToFit()
                        .frame(width: 50, height: 50)
                        .clipShape(Circle())
                        .overlay(
                            Circle()
                                .stroke(Color.white, lineWidth: 2)
                                .shadow(radius: 2)
                        )

                    Text("\(participant.champLevel)")
                        .font(.system(size: 12, weight: .bold))
                        .foregroundColor(.white)
                        .padding(6)
                        .background(
                            Circle()
                                .fill(Color.black.opacity(0.8))
                                .shadow(radius: 2)
                        )
                        .offset(x: -20, y: -20)
                }

                VStack(alignment: .leading, spacing: 6) {
                    HStack {
                        Text(participant.summonerName)
                            .font(.headline)

                        Text("Carry: \(Int(carryScore))%")
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

                    HStack {
                        Text("\(participant.kills)/\(participant.deaths)/\(participant.assists) (\(participant.kda))")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                        Spacer()
                        Text("Damage: \(participant.totalDamageDealt)")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }

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

            // Enhanced Items and Ward
            HStack {
                ForEach([participant.item0, participant.item1, participant.item2, participant.item3, participant.item4, participant.item5], id: \.self) { item in
                    if let item = item {
                        Image("\(item)")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 30, height: 30)
                            .clipShape(RoundedRectangle(cornerRadius: 6))
                            .overlay(
                                RoundedRectangle(cornerRadius: 6)
                                    .stroke(Color.gray.opacity(0.3), lineWidth: 1)
                            )
                            .shadow(radius: 2)
                    }
                }

                Spacer()

                if let ward = participant.item6 {
                    ZStack {
                        Image("\(ward)")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 30, height: 30)
                            .clipShape(RoundedRectangle(cornerRadius: 6))
                            .overlay(
                                RoundedRectangle(cornerRadius: 6)
                                    .stroke(Color.gray.opacity(0.3), lineWidth: 1)
                            )
                            .shadow(radius: 2)

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
            RoundedRectangle(cornerRadius: 15)
                .fill(
                    Color(matchResult[participant.teamId == 100 ? "team1" : "team2"] == true ?
                        .blue : .red)
                        .opacity(0.1)
                )
                .shadow(
                    color: Color(matchResult[participant.teamId == 100 ? "team1" : "team2"] == true ?
                        .blue : .red).opacity(0.3),
                    radius: 5,
                    x: 0,
                    y: 2
                )
        )
        .overlay(
            RoundedRectangle(cornerRadius: 15)
                .stroke(
                    Color(matchResult[participant.teamId == 100 ? "team1" : "team2"] == true ?
                        .blue : .red).opacity(0.2),
                    lineWidth: 1
                )
        )
    }

    func teamHeader(title: String, stats: (baronKills: Int, turretKills: Int, dragonKills: Int), isWinning: Bool?) -> some View {
        HStack {
            Text(title)
                .font(.title2)
                .fontWeight(.bold)
                .foregroundColor(isWinning == true ? .blue : .red)
                .padding(.vertical, 8)
            
            Spacer()
            
            HStack(spacing: 20) {
                statView(stat: "Turrets", value: stats.turretKills, color: isWinning == true ? .blue : .red)
                statView(stat: "Dragons", value: stats.dragonKills, color: isWinning == true ? .blue : .red)
                statView(stat: "Barons", value: stats.baronKills, color: isWinning == true ? .blue : .red)
            }
        }
        .padding(.horizontal)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color(isWinning == true ? .blue : .red).opacity(0.1))
        )
    }

    func statView(stat: String, value: Int, color: Color) -> some View {
        VStack(spacing: 4) {
            Text("\(value)")
                .font(.system(size: 16, weight: .bold))
                .foregroundColor(color)
            
            Text(stat)
                .font(.system(size: 12))
                .foregroundColor(color.opacity(0.8))
        }
        .padding(.vertical, 6)
        .padding(.horizontal, 10)
        .background(
            RoundedRectangle(cornerRadius: 8)
                .fill(color.opacity(0.1))
        )
    }

    // Original helper functions remain unchanged
    func totalPerformance(for teamId: Int) -> Double {
        return participants.filter { $0.teamId == teamId }
            .map { $0.performanceScore }
            .reduce(0, +)
    }

    func normalizedCarryScore(for participant: Participant, teamTotalPerformance: Double) -> Double {
        return teamTotalPerformance > 0 ? (participant.performanceScore / teamTotalPerformance) * 100 : 0
    }

    // Original fetchMatchData function remains unchanged
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
