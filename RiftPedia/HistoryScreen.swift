import SwiftUI
import Foundation
struct Rank: Decodable {
    let queueType: String
    let tier: String
    let rank: String
    let leaguePoints: Int
    let wins: Int
    let losses: Int
}


// MARK: - Rune Structure
struct Rune: Decodable {
    let id: Int
    let name: String
    let description: String
    let icon: String
}

// MARK: - Match Structure
struct Match: Identifiable, Decodable {
    let id: String
    let championName: String
    let championIcon: String
    let kills: Int
    let deaths: Int
    let assists: Int
    let isWin: Bool
    var gameMode: String
    let gameDate: Date
    let gameDuration: Int // Game duration in seconds
    let itemIcons: [String]
    let summonerSpellIcons: [String]
    let primaryRunes: [Rune]
    let secondaryRunes: [Rune]
    let damageDealt: Int // Added damage dealt
    let creepScore: Int // Added for total minions killed
    let visionScore: String // Optional because it might not be present for ARAM games
    let individualPosition: String // New field for individual position
    var wardIcon: String? // Holds the ward item's icon URL
    var csPerMinute: Double {
            // Convert gameDuration to minutes and calculate CS/min
            return gameDuration > 0 ? Double(creepScore) / (Double(gameDuration) / 60.0) : 0.0
        }
    enum CodingKeys: String, CodingKey {
        case metadata
        case info
    }

    enum MetadataKeys: String, CodingKey {
        case id = "matchId"
    }

    enum InfoKeys: String, CodingKey {
        case participants
        case gameMode
        case queueId
        case gameCreation
        case gameDuration
    }

    enum ParticipantKeys: String, CodingKey {
        case puuid
        case championName
        case kills
        case deaths
        case assists
        case win
        case championIcon
        case item0
        case item1
        case item2
        case item3
        case item4
        case item5
        case item6
        case summoner1Id
        case summoner2Id
        case perks
        case totalDamageDealtToChampions
        case individualPosition
        case neutralMinionsKilled
        case totalMinionsKilled
        case visionScore
        case wardIcon
    }

    enum PerksKeys: String, CodingKey {
        case styles
    }

    enum PerksStyleKeys: String, CodingKey {
        case selections
        case style
    }

    enum PerksSelectionKeys: String, CodingKey {
        case perk
    }
    static let wardItemIds: Set<Int> = [3340, 3363, 3364, 2055, 4642] // Example IDs for wards

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let metadata = try container.nestedContainer(keyedBy: MetadataKeys.self, forKey: .metadata)
        id = try metadata.decode(String.self, forKey: .id)

        let info = try container.nestedContainer(keyedBy: InfoKeys.self, forKey: .info)
        gameMode = try info.decode(String.self, forKey: .gameMode)
        let queueId = try info.decode(Int.self, forKey: .queueId)
        self.gameMode = Self.mapGameMode(queueId: queueId)

        let gameCreationTimestamp = try info.decode(Int.self, forKey: .gameCreation)
        gameDate = Date(timeIntervalSince1970: TimeInterval(gameCreationTimestamp) / 1000)

        // Decode game duration
        gameDuration = try info.decode(Int.self, forKey: .gameDuration)

        var participants = try info.nestedUnkeyedContainer(forKey: .participants)
        while !participants.isAtEnd {
            let participant = try participants.nestedContainer(keyedBy: ParticipantKeys.self)
            let puuid = try participant.decode(String.self, forKey: .puuid)
            if puuid == Config.puuid {
                championName = try participant.decode(String.self, forKey: .championName)
                kills = try participant.decode(Int.self, forKey: .kills)
                deaths = try participant.decode(Int.self, forKey: .deaths)
                assists = try participant.decode(Int.self, forKey: .assists)
                isWin = try participant.decode(Bool.self, forKey: .win)
                championIcon = "https://ddragon.leagueoflegends.com/cdn/15.3.1/img/champion/\(championName).png"
             
                if queueId != 450 {
                    if let score = try participant.decodeIfPresent(Int.self, forKey: .visionScore) {
                        visionScore = "Vision: \(score)"
                    } else {
                        visionScore = "" // Vision score is nil; set empty string
                    }
                } else {
                    visionScore = "" // ARAM queue; no vision score
                }
                // Decode items
                let itemIds = [
                    try participant.decode(Int.self, forKey: .item0),
                    try participant.decode(Int.self, forKey: .item1),
                    try participant.decode(Int.self, forKey: .item2),
                    try participant.decode(Int.self, forKey: .item3),
                    try participant.decode(Int.self, forKey: .item4),
                    try participant.decode(Int.self, forKey: .item5),
                    try participant.decode(Int.self, forKey: .item6)
                ]
                var regularItems: [String] = []
                            var wardItem: String? = nil

                            for itemId in itemIds {
                                if Self.wardItemIds.contains(itemId) {
                                    wardItem = "https://ddragon.leagueoflegends.com/cdn/15.3.1/img/item/\(itemId).png"
                                } else if itemId > 0 { // Filter out empty item slots (ID 0)
                                    regularItems.append("https://ddragon.leagueoflegends.com/cdn/15.3.1/img/item/\(itemId).png")
                                }
                            }

                            self.itemIcons = regularItems
                            self.wardIcon = wardItem
                // Decode summoner spells
                let summonerSpellIds = [
                    try participant.decode(Int.self, forKey: .summoner1Id),
                    try participant.decode(Int.self, forKey: .summoner2Id)
                ]
                summonerSpellIcons = summonerSpellIds.map { id in
                    return Self.mapSummonerSpellName(for: id)
                }

                // Decode runes
                let perksContainer = try participant.nestedContainer(keyedBy: PerksKeys.self, forKey: .perks)
                let styles = try perksContainer.decode([RuneStyle].self, forKey: .styles)
                primaryRunes = try Self.decodeRunes(from: styles, isPrimary: true)
                secondaryRunes = try Self.decodeRunes(from: styles, isPrimary: false)
                individualPosition = try participant.decode(String.self, forKey: .individualPosition)
                damageDealt = try participant.decode(Int.self, forKey: .totalDamageDealtToChampions)
                // Decode neutral and total minions killed
                           let neutralMinionsKilled = try participant.decode(Int.self, forKey: .neutralMinionsKilled)
                           let totalMinionsKilled = try participant.decode(Int.self, forKey: .totalMinionsKilled)
                           let creepScore = neutralMinionsKilled + totalMinionsKilled

                           // Store the calculated creep score
                           self.creepScore = creepScore
                               
              

                return
            }
        }
        

        throw DecodingError.dataCorrupted(DecodingError.Context(
            codingPath: [],
            debugDescription: "No participant data for the specified PUUID."
        ))
    }
    // Enum for mapping rune IDs to names
    private static let runeNames: [Int: String] = [
        8439: "Aftershock",
        8229: "Arcane Comet",
        8010: "Conqueror",
        8128: "Dark Harvest",
        8100: "Domination",
        8112: "Electrocute",
        8369: "First Strike",
        8021: "Fleet Footwork",
        8351: "Glacial Augment",
        8437: "Grasp of the Undying",
        8465: "Guardian",
        9923: "Hail of Blades",
        8300: "Inspiration",
        8008: "Lethal Tempo",
        8230: "Phase Rush",
        8000: "Precision",
        8005: "Press the Attack",
        8400: "Resolve",
        8200: "Sorcery",
        8214: "Summon Aery",
        8360: "Unsealed Spellbook"
    ]

    // Modify the decodeRunes function to extract only Keystone and secondary rune tree
    private static func decodeRunes(from styles: [RuneStyle], isPrimary: Bool) throws -> [Rune] {
        guard styles.count >= 2 else { return [] }  // Ensure there are at least 2 rune trees (primary + secondary)

        var runes: [Rune] = []

        // Extract Keystone rune (always in the first style)
        if let keystoneStyle = styles.first {
            if let keystoneSelection = keystoneStyle.selections.first {
                let runeId = keystoneSelection.perk
                if let runeName = runeNames[runeId] {
                    runes.append(Rune(id: runeId, name: runeName, description: "Keystone Perk", icon: Self.getRuneIcon(for: runeId)))
                }
            }
        }

        // Extract secondary rune tree (always in the second style)
        if let secondaryRuneStyle = styles.dropFirst().first {
            // Iterate over all selections in the secondary rune tree
            for selection in secondaryRuneStyle.selections {
                let runeId = selection.perk
                if let runeName = runeNames[runeId] {
                    runes.append(Rune(id: runeId, name: runeName, description: "Secondary Rune Tree", icon: Self.getRuneIcon(for: runeId)))
                }
            }
        }

        return runes
    }
    // Helper method for getting rune icon (to be replaced with actual logic)
    private static func getRuneIcon(for id: Int) -> String {
        return "https://example.com/rune/\(id).png"  // Placeholder
    }

    private static func mapGameMode(queueId: Int) -> String {
        switch queueId {
        case 420: return "Ranked solo/duo"
        case 440: return "Ranked flex"
        case 400: return "Normal"
        case 450: return "Aram"
        default: return "Normal"
        }
    }

    private static func mapSummonerSpellName(for id: Int) -> String {
        switch id {
        case 4: return "Flash"
        case 6: return "Ghost"
        case 14: return "Ignite"
        case 11: return "Smite"
        case 7: return "Heal"
        case 12: return "Teleport"
        case 3: return "Exhaust"
        case 21: return "Barrier"
        case 13: return "Clarity"
        case 1: return "Cleanse"
        case 32: return "Snowball"
        case 54: return "Placeholder"
        default:
            print("Unknown Summoner Spell ID: \(id)")
            return ""
        }
    }

    private static func getRuneName(for id: Int) -> String {
        // TODO: Implement logic to fetch rune names from a database or API
        return "Rune \(id)"
    }

    private static func getRuneDescription(for id: Int) -> String {
        // TODO: Implement logic to fetch rune descriptions
        return "Description for Rune \(id)"
    }

  

    // Converts game duration (seconds) to a formatted string like "30:45"
    func formattedGameDuration() -> String {
        let minutes = gameDuration / 60
        let seconds = gameDuration % 60
        return String(format: "%02d:%02d", minutes, seconds)
    }
}

// MARK: - RuneStyle for Decoding Perks
struct RuneStyle: Decodable {
    let style: Int
    let selections: [RuneSelection]
}

struct RuneSelection: Decodable {
    let perk: Int
}
// MARK: - MatchService
class MatchService {
    static let shared = MatchService()

    func fetchMatchHistory(puuid: String, region: String, completion: @escaping (Result<[Match], Error>) -> Void) {
        let apiKey = Config.riotAPIKey
        let urlString = "https://\(region).api.riotgames.com/lol/match/v5/matches/by-puuid/\(puuid)/ids?count=10&api_key=\(apiKey)"

        guard let url = URL(string: urlString) else {
            completion(.failure(NSError(domain: "Invalid URL", code: 0, userInfo: nil)))
            return
        }

        URLSession.shared.dataTask(with: url) { data, response, error in
            if let error = error {
                completion(.failure(error))
                return
            }

            guard let data = data else {
                completion(.failure(NSError(domain: "No data received", code: 0, userInfo: nil)))
                return
            }

            do {
                let matchIds = try JSONDecoder().decode([String].self, from: data)
                self.fetchMatchDetails(matchIds: matchIds, region: region, completion: completion)
            } catch {
                completion(.failure(error))
            }
        }.resume()
    }
    

    private func fetchMatchDetails(matchIds: [String], region: String, completion: @escaping (Result<[Match], Error>) -> Void) {
        let apiKey = Config.riotAPIKey
        var matches: [Match] = []
        let group = DispatchGroup()

        for matchId in matchIds {
            group.enter()
            let urlString = "https://\(region).api.riotgames.com/lol/match/v5/matches/\(matchId)?api_key=\(apiKey)"

            guard let url = URL(string: urlString) else {
                group.leave()
                continue
            }

            URLSession.shared.dataTask(with: url) { data, response, error in
                if let error = error {
                    group.leave()
                    return
                }

                guard let data = data else {
                    group.leave()
                    return
                }

                do {
                    let match = try JSONDecoder().decode(Match.self, from: data)
                    matches.append(match)
                } catch {
                    print("Error decoding match data: \(error.localizedDescription)")
                }
                group.leave()
            }.resume()
        }

        group.notify(queue: .main) {
            matches.sort { $0.gameDate > $1.gameDate }
            completion(.success(matches))
        }
    }
    func fetchMoreMatches(puuid: String, region: String, currentCount: Int, additionalCount: Int, completion: @escaping (Result<[Match], Error>) -> Void) {
        let apiKey = Config.riotAPIKey
        let urlString = "https://\(region).api.riotgames.com/lol/match/v5/matches/by-puuid/\(puuid)/ids?start=\(currentCount)&count=\(additionalCount)&api_key=\(apiKey)"

        guard let url = URL(string: urlString) else {
            completion(.failure(NSError(domain: "Invalid URL", code: 0, userInfo: nil)))
            return
        }

        URLSession.shared.dataTask(with: url) { data, response, error in
            if let error = error {
                completion(.failure(error))
                return
            }

            guard let data = data else {
                completion(.failure(NSError(domain: "No data received", code: 0, userInfo: nil)))
                return
            }

            do {
                let matchIds = try JSONDecoder().decode([String].self, from: data)
                self.fetchMatchDetails(matchIds: matchIds, region: region, completion: completion)
            } catch {
                completion(.failure(error))
            }
        }.resume()
    }
}

// MARK: - HistoryScreen View
struct HistoryScreen: View {
    var name: String
    var tag: String
    var region: String
    var mappedRegion: String
    @State private var winRate: Double? = nil
    @State private var summonerLevel: Int = 0
    @State private var summonerIconUrl: String? = nil
    @State private var matchHistory: [Match] = []
    @State private var isLoading = true
    @State private var errorMessage: String? = nil
    @State private var summonerRank: String? = nil
    @State private var summonerRankIconUrl: String? = nil
    @State private var games: Int = 10
    @State private var mostPerformingChampion: (championId: String, wins: Int)? = nil
    
    // Normalized region based on the mapped region
    var normalRegion: String {
        switch mappedRegion {
        case "euw1":
            return "Europe"
        case "eun1":
            return "Europe"
        case "na1":
            return "Americas"
        case "kr":
            return "Asia"
        case "jp1":
            return "Asia"
        case "br1":
            return "Americas"
        case "oc1":
            return "Sea"
        case "la1", "la2":
            return "Americas"
        case "tr1":
            return "Europe"
        case "ru":
            return "Europe"
        default:
            return "Unknown Region"
        }
    }

    var body: some View {
        NavigationStack {
            VStack {
                ZStack {
                    // Enhanced background with gradient
                    LinearGradient(
                        gradient: Gradient(colors: [
                            Color("Background"),
                            Color("Background").opacity(0.85)
                        ]),
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                    .ignoresSafeArea()

                    VStack(spacing: 20) {
                        // Enhanced Profile Card Section
                        VStack {
                            HStack(alignment: .center, spacing: 20) {
                                // Profile Image
                                if let iconUrl = summonerIconUrl {
                                    AsyncImage(url: URL(string: iconUrl)) { image in
                                        image
                                            .resizable()
                                            .scaledToFit()
                                            .frame(width: 100, height: 100)
                                            .clipShape(Circle())
                                            .overlay(
                                                Circle()
                                                    .stroke(Color.white.opacity(0.3), lineWidth: 3)
                                            )
                                            .shadow(color: .black.opacity(0.3), radius: 8, x: 0, y: 4)
                                    } placeholder: {
                                        ProgressView()
                                            .progressViewStyle(CircularProgressViewStyle(tint: .white))
                                            .scaleEffect(2)
                                            .frame(width: 100, height: 100)
                                    }
                                } else {
                                    Image(systemName: "person.circle.fill")
                                        .resizable()
                                        .frame(width: 100, height: 100)
                                        .clipShape(Circle())
                                        .overlay(
                                            Circle()
                                                .stroke(Color.white.opacity(0.3), lineWidth: 3)
                                        )
                                        .shadow(color: .black.opacity(0.3), radius: 8, x: 0, y: 4)
                                }

                                // Profile Info
                                VStack(alignment: .leading, spacing: 8) {
                                    Text("\(name)#\(tag)")
                                        .font(.system(size: 24, weight: .bold))
                                        .foregroundColor(.white)
                                        .shadow(color: .black.opacity(0.3), radius: 2)

                                    if isLoading {
                                        Text("Loading...")
                                            .font(.subheadline)
                                            .foregroundColor(.white.opacity(0.8))
                                    } else {
                                        Text("Level \(summonerLevel)")
                                            .font(.system(size: 16, weight: .medium))
                                            .foregroundColor(.white.opacity(0.9))
                                    }

                                    if let rank = summonerRank {
                                        HStack(spacing: 12) {
                                            if let rankIconName = summonerRankIconUrl {
                                                Image(rankIconName)
                                                    .resizable()
                                                    .scaledToFit()
                                                    .frame(width: 45, height: 45)
                                                    .shadow(radius: 5)
                                            }

                                            Text(rank)
                                                .font(.system(size: 16, weight: .semibold))
                                                .foregroundColor(.white)
                                        }
                                        .padding(.vertical, 4)
                                    }

                                    if let wr = winRate {
                                        // Enhanced Win Rate Display
                                        HStack(spacing: 15) {
                                            VStack(alignment: .leading, spacing: 4) {
                                                Text("\(String(format: "%.1f", wr))%")
                                                    .font(.system(size: 20, weight: .bold))
                                                    .foregroundColor(winRateColor(wr))
                                                
                                                Text("Win Rate")
                                                    .font(.system(size: 12, weight: .medium))
                                                    .foregroundColor(.white.opacity(0.7))
                                            }

                                            Rectangle()
                                                .frame(width: 2, height: 40)
                                                .foregroundColor(winRateColor(wr))

                                            VStack(alignment: .leading, spacing: 4) {
                                                Text("\(games)")
                                                    .font(.system(size: 20, weight: .bold))
                                                    .foregroundColor(.white)
                                                
                                                Text("Games")
                                                    .font(.system(size: 12, weight: .medium))
                                                    .foregroundColor(.white.opacity(0.7))
                                            }
                                        }
                                        .padding(.vertical, 4)
                                    }

                                    if let errorMessage = errorMessage {
                                        Text("Error: \(errorMessage)")
                                            .font(.system(size: 14, weight: .medium))
                                            .foregroundColor(.red)
                                            .padding(.vertical, 4)
                                    }
                                }
                            }
                            .padding(20)
                            .background(
                                RoundedRectangle(cornerRadius: 20)
                                    .fill(Color.white.opacity(0.1))
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 20)
                                            .stroke(Color.white.opacity(0.1), lineWidth: 1)
                                    )
                            )
                            .shadow(color: .black.opacity(0.2), radius: 10, x: 0, y: 5)
                        }
                        .padding(.horizontal)

                        // Enhanced Champion Section
                        if let mostChampion = mostPerformingChampion {
                            HStack(spacing: 20) {
                                Text("Top Champion")
                                    .font(.system(size: 16, weight: .semibold))
                                    .foregroundColor(.white)

                                AsyncImage(url: URL(string: "https://ddragon.leagueoflegends.com/cdn/15.3.1/img/champion/\(mostChampion.championId).png")) { image in
                                    image
                                        .resizable()
                                        .scaledToFit()
                                        .frame(width: 50, height: 50)
                                        .clipShape(Circle())
                                        .overlay(
                                            Circle()
                                                .stroke(Color.white.opacity(0.2), lineWidth: 2)
                                        )
                                        .shadow(radius: 5)
                                } placeholder: {
                                    ProgressView()
                                        .progressViewStyle(CircularProgressViewStyle(tint: .white))
                                }

                                VStack(alignment: .leading, spacing: 4) {
                                    Text(mostChampion.championId)
                                        .font(.system(size: 16, weight: .bold))
                                        .foregroundColor(.white)
                                    
                                    Text("Wins: \(mostChampion.wins)")
                                        .font(.system(size: 14, weight: .medium))
                                        .foregroundColor(.white.opacity(0.8))
                                }

                                Spacer()

                                Text("Last \(games) games")
                                    .font(.system(size: 12, weight: .medium))
                                    .foregroundColor(.white.opacity(0.7))
                            }
                            .padding(.vertical, 15)
                            .padding(.horizontal, 20)
                            .background(
                                RoundedRectangle(cornerRadius: 16)
                                    .fill(Color.white.opacity(0.1))
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 16)
                                            .stroke(Color.white.opacity(0.1), lineWidth: 1)
                                    )
                            )
                            .shadow(color: .black.opacity(0.1), radius: 8, x: 0, y: 4)
                            .padding(.horizontal)
                        }

                        // Enhanced Load Games Button
                        Button(action: loadMoreMatches) {
                            HStack {
                                Image(systemName: "arrow.clockwise.circle.fill")
                                    .font(.system(size: 20))
                                Text("Load More Games")
                                    .font(.system(size: 16, weight: .semibold))
                            }
                            .foregroundColor(Color("Background"))
                            .padding(.vertical, 15)
                            .frame(maxWidth: .infinity)
                            .background(
                                RoundedRectangle(cornerRadius: 12)
                                    .fill(Color("Button"))
                                    .shadow(color: .black.opacity(0.2), radius: 8, x: 0, y: 4)
                            )
                        }
                        .padding(.horizontal)

                        // Enhanced Match List
                        List(matchHistory) { match in
                            MatchCell(match: match, region: region)
                                .listRowInsets(EdgeInsets())
                                .listRowBackground(Color.clear)
                                .background(
                                    RoundedRectangle(cornerRadius: 12)
                                        .fill(Color.white.opacity(0.05))
                                )
                        }
                        .listStyle(PlainListStyle())
                        .background(Color.clear)
                        .padding(.horizontal)

                        Spacer()
                    }
                    .padding(.top, 20)
                    .onAppear {
                        fetchSummonerData()
                        fetchMatchHistory()
                    }
                }
            }
        }
    }

    // Helper function for win rate color
    private func winRateColor(_ winRate: Double) -> Color {
        switch winRate {
        case 60...:
            return Color.green
        case 50...:
            return Color.green.opacity(0.8)
        case 40...:
            return Color.yellow
        case 30...:
            return Color.orange
        default:
            return Color.red
        }
    }

    

    private func fetchSummonerData() {
        let puuid = Config.puuid
        guard !puuid.isEmpty else {
            errorMessage = "PUUID is empty"
            isLoading = false
            return
        }

        // Step 1: Fetch Summoner Data (to get `summonerId`)
        let summonerEndpoint = "https://\(mappedRegion).api.riotgames.com/lol/summoner/v4/summoners/by-puuid/\(puuid)"
        let apiKeyParameter = "?api_key=\(Config.riotAPIKey)"
        let summonerRequestUrl = summonerEndpoint + apiKeyParameter

        guard let summonerUrl = URL(string: summonerRequestUrl) else {
            errorMessage = "Invalid URL"
            isLoading = false
            return
        }

        URLSession.shared.dataTask(with: summonerUrl) { data, response, error in
            if let error = error {
                DispatchQueue.main.async {
                    errorMessage = "Error fetching summoner data: \(error.localizedDescription)"
                    isLoading = false
                }
                return
            }

            guard let data = data else {
                DispatchQueue.main.async {
                    errorMessage = "No data received from the API."
                    isLoading = false
                }
                return
            }

            do {
                if let json = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any],
                   let level = json["summonerLevel"] as? Int,
                   let profileIconId = json["profileIconId"] as? Int,
                   let summonerId = json["id"] as? String {
                    let iconUrl = "https://ddragon.leagueoflegends.com/cdn/15.3.1/img/profileicon/\(profileIconId).png"

                    DispatchQueue.main.async {
                        summonerLevel = level
                        summonerIconUrl = iconUrl
                    }

                    // Step 2: Fetch Ranked Data using `summonerId`
                    fetchRankData(summonerId: summonerId)
                } else {
                    DispatchQueue.main.async {
                        errorMessage = "Invalid data format."
                        isLoading = false
                    }
                }
            } catch {
                DispatchQueue.main.async {
                    errorMessage = "Error parsing response: \(error.localizedDescription)"
                    isLoading = false
                }
            }
        }.resume()
    }

    private func fetchRankData(summonerId: String) {
        // Correct API endpoint (check the API version)
        let rankEndpoint = "https://\(mappedRegion).api.riotgames.com/lol/league/v4/entries/by-summoner/\(summonerId)"
        let apiKeyParameter = "?api_key=\(Config.riotAPIKey)"
        let rankRequestUrl = rankEndpoint + apiKeyParameter

        guard let rankUrl = URL(string: rankRequestUrl) else {
            DispatchQueue.main.async {
                errorMessage = "Invalid rank URL"
            }
            return
        }

        URLSession.shared.dataTask(with: rankUrl) { data, response, error in
            if let error = error {
                DispatchQueue.main.async {
                    errorMessage = "Error fetching rank data: \(error.localizedDescription)"
                }
                return
            }

            guard let data = data else {
                DispatchQueue.main.async {
                    errorMessage = "No data received for rank data."
                }
                return
            }

            do {
                let rankData = try JSONDecoder().decode([Rank].self, from: data)

                // Find the solo rank if available
                if let soloRank = rankData.first(where: { $0.queueType == "RANKED_SOLO_5x5" }) {
                    DispatchQueue.main.async {
                        // Display rank information
                        summonerRank = "\(soloRank.tier.capitalized) \(soloRank.rank) (\(soloRank.leaguePoints) LP)"
                        // Fetch the local rank icon name
                        summonerRankIconUrl = getRankIconName(tier: soloRank.tier)
                    }
                } else {
                    DispatchQueue.main.async {
                        summonerRank = "Unranked"
                        summonerRankIconUrl = nil
                    }
                }
            } catch {
                DispatchQueue.main.async {
                    errorMessage = "Error parsing rank data: \(error.localizedDescription)"
                }
            }
        }.resume()
    }

    private func getRankIconName(tier: String) -> String? {
        // Map the rank tier to the corresponding asset name
        switch tier.lowercased() {
        case "iron":
            return "iron"
        case "bronze":
            return "bronze"
        case "silver":
            return "silver"
        case "gold":
            return "gold"
        case "platinum":
            return "platinum"
        case "emerald":
            return "emerald"
        case "diamond":
            return "diamond"
        case "master":
            return "master"
        case "grandmaster":
            return "grandmaster"
        case "challenger":
            return "challenger"
        default:
            return nil
        }
    }
    private func fetchMatchHistory() {
        let puuid = Config.puuid
        guard !puuid.isEmpty else {
            errorMessage = "PUUID is empty"
            isLoading = false
            return
        }

        MatchService.shared.fetchMatchHistory(puuid: puuid, region: normalRegion) { result in
            DispatchQueue.main.async {
                switch result {
                case .success(let matches):
                    matchHistory = matches
                    calculateWinRate(matches: matches) // Calculate WR after fetching matches
                    calculateMostPerformingChampion(matches: matches) // Calculate most performing champion
                case .failure(let error):
                    errorMessage = "Error fetching match history: \(error.localizedDescription)"
                }
                isLoading = false
            }
        }
    }

    private func loadMoreMatches() {
        let puuid = Config.puuid
        guard !puuid.isEmpty else {
            errorMessage = "PUUID is empty"
            return
        }

        MatchService.shared.fetchMoreMatches(puuid: puuid, region: normalRegion, currentCount: matchHistory.count, additionalCount: 5) { result in
            DispatchQueue.main.async {
                switch result {
                case .success(let newMatches):
                    matchHistory.append(contentsOf: newMatches)
                    calculateWinRate(matches: matchHistory) // Recalculate WR after adding new matches
                    calculateMostPerformingChampion(matches: matchHistory) // Recalculate most performing champion
                    // Increment the games count by 5
                    games += 5

                case .failure(let error):
                    errorMessage = "Error fetching additional matches: \(error.localizedDescription)"
                }
            }
        }
    }
    private func calculateMostPerformingChampion(matches: [Match]) {
        var championWins: [String: Int] = [:]

        for match in matches {
            if match.isWin {
                championWins[match.championName, default: 0] += 1
            }
        }

        // Find the champion with the most wins
        if let mostWinsChampion = championWins.max(by: { $0.value < $1.value }) {
            mostPerformingChampion = (championId: mostWinsChampion.key, wins: mostWinsChampion.value)
        } else {
            mostPerformingChampion = nil // No wins found
        }
    }
    private func calculateWinRate(matches: [Match]) {
        let totalMatches = matches.count
        let wins = matches.filter { $0.isWin }.count

        if totalMatches > 0 {
            winRate = Double(wins) / Double(totalMatches) * 100
        } else {
            winRate = nil // No matches available
        }
    }
}

// MARK: - MatchCell View

struct MatchCell: View {
    let match: Match
    var region: String
    // Map rune IDs to names
    private static let runeNames: [Int: String] = [
        8439: "Aftershock",
        8229: "Arcane Comet",
        8010: "Conqueror",
        8128: "Dark Harvest",
        8100: "Domination",
        8112: "Electrocute",
        8369: "First Strike",
        8021: "Fleet Footwork",
        8351: "Glacial Augment",
        8437: "Grasp of the Undying",
        8465: "Guardian",
        9923: "Hail of Blades",
        8300: "Inspiration",
        8008: "Lethal Tempo",
        8230: "Phase Rush",
        8000: "Precision",
        8005: "Press the Attack",
        8400: "Resolve",
        8200: "Sorcery",
        8214: "Summon Aery",
        8360: "Unsealed Spellbook"
    ]

    // Function to map a rune ID to its corresponding rune name
    private func runeName(for runeId: Int) -> String {
        return Self.runeNames[runeId] ?? "Unknown Rune" // Return the mapped name or default to "Unknown Rune"
    }

    private func summonerSpellImage(for spellName: String) -> String {
        switch spellName {
        case "Ignite": return "ignite"
        case "Flash": return "flash"
        case "Ghost": return "ghost"
        case "Snowball": return "snowball"
        case "Smite": return "smite"
        case "Teleport": return "teleport"
        case "Exhaust": return "exhaust"
        case "Barrier": return "barrier"
        case "Heal": return "heal"
        case "Cleanse": return "cleanse"
        case "Clarity": return "clarity"
        case "Placeholder": return "placeHolder"
        default: return "" // Fallback if spell is unknown
        }
    }

    private func runeImage(for runeName: String) -> String {
        // Convert the rune name to lowercase and replace spaces with underscores to match asset naming
        let formattedRuneName = runeName.lowercased().replacingOccurrences(of: " ", with: "_")
        return formattedRuneName
    }

    func mapPositionToLabel(position: String) -> (label: String, imageName: String) {
        switch position.uppercased() {
        case "MIDDLE":
            return ("Midlane", "midlane")
        case "JUNGLE":
            return ("Jungle", "jungle")
        case "UTILITY":
            return ("Support", "support")
        case "TOP":
            return ("Toplane", "toplane")
        case "BOTTOM":
            return ("Botlane", "botlane")
        case "INVALID":
            return ("N/A", "aram")
        default:
            return (position, "aram") // Default to "aram" for unexpected values
        }
    }

    var body: some View {
        NavigationLink(destination: FullMatchView(matchId: match.id, region: region)) {
            VStack(alignment: .leading, spacing: 12) {
                // Top section with enhanced design
                HStack(spacing: 15) {
                    // Champion Icon with enhanced presentation
                    AsyncImage(url: URL(string: match.championIcon)) { image in
                        image.resizable()
                            .scaledToFit()
                            .frame(width: 65, height: 65)
                            .clipShape(Circle())
                            .overlay(
                                Circle()
                                    .stroke(match.isWin ? Color.blue.opacity(0.6) : Color.red.opacity(0.6), lineWidth: 2)
                            )
                            .shadow(color: match.isWin ? .blue.opacity(0.3) : .red.opacity(0.3), radius: 4)
                    } placeholder: {
                        ProgressView()
                            .frame(width: 65, height: 65)
                    }

                    // Vertical Divider with gradient
                    Rectangle()
                        .fill(
                            LinearGradient(
                                colors: [
                                    match.isWin ? .blue.opacity(0.1) : .red.opacity(0.1),
                                    match.isWin ? .blue.opacity(0.3) : .red.opacity(0.3),
                                    match.isWin ? .blue.opacity(0.1) : .red.opacity(0.1)
                                ],
                                startPoint: .top,
                                endPoint: .bottom
                            )
                        )
                        .frame(width: 2, height: 80)

                    // Champion Details with enhanced typography
                    VStack(alignment: .leading, spacing: 6) {
                        Text(match.championName)
                            .font(.system(size: 16, weight: .bold))
                            .foregroundColor(.white)
                        
                        HStack(spacing: 4) {
                            Text("\(match.kills)")
                                .foregroundColor(.green)
                            Text("/")
                                .foregroundColor(.gray)
                            Text("\(match.deaths)")
                                .foregroundColor(.red)
                            Text("/")
                                .foregroundColor(.gray)
                            Text("\(match.assists)")
                                .foregroundColor(.blue)
                        }
                        .font(.system(size: 14, weight: .medium))
                        
                        Text(match.gameMode)
                            .font(.system(size: 14, weight: .semibold))
                            .foregroundColor(match.isWin ? .blue.opacity(0.8) : .red.opacity(0.8))
                        
                        Text(match.formattedGameDuration())
                            .font(.system(size: 12, weight: .medium))
                            .foregroundColor(.gray.opacity(0.8))
                    }

                    // Vertical Divider with gradient
                    Rectangle()
                        .fill(
                            LinearGradient(
                                colors: [
                                    match.isWin ? .blue.opacity(0.1) : .red.opacity(0.1),
                                    match.isWin ? .blue.opacity(0.3) : .red.opacity(0.3),
                                    match.isWin ? .blue.opacity(0.1) : .red.opacity(0.1)
                                ],
                                startPoint: .top,
                                endPoint: .bottom
                            )
                        )
                        .frame(width: 2, height: 80)

                    // Position and Stats with enhanced layout
                    let positionData = mapPositionToLabel(position: match.individualPosition)
                    
                    HStack(spacing: 12) {
                        VStack(spacing: 6) {
                            Text(positionData.label)
                                .font(.system(size: 14, weight: .medium))
                                .foregroundColor(.white)
                            
                            Image(positionData.imageName)
                                .resizable()
                                .scaledToFit()
                                .frame(width: 35, height: 35)
                                .clipShape(Circle())
                                .overlay(
                                    Circle()
                                        .stroke(Color.white.opacity(0.2), lineWidth: 1)
                                )
                        }
                        
                        // Stats with enhanced presentation
                        VStack(alignment: .trailing, spacing: 6) {
                            Text("DMG: \(match.damageDealt)")
                                .font(.system(size: 12, weight: .medium))
                                .foregroundColor(.white.opacity(0.9))
                            
                            Text("CS: \(match.creepScore)")
                                .font(.system(size: 12, weight: .medium))
                                .foregroundColor(.white.opacity(0.9))
                            
                            Text("(\(String(format: "%.1f", match.csPerMinute))/min)")
                                .font(.system(size: 11, weight: .medium))
                                .foregroundColor(.gray)
                            
                            if !match.visionScore.isEmpty {
                                Text(match.visionScore)
                                    .font(.system(size: 12, weight: .medium))
                                    .foregroundColor(.white.opacity(0.9))
                            }
                        }
                    }
                }

                // Enhanced horizontal divider
                Rectangle()
                    .fill(
                        LinearGradient(
                            colors: [
                                match.isWin ? .blue.opacity(0.1) : .red.opacity(0.1),
                                match.isWin ? .blue.opacity(0.4) : .red.opacity(0.4),
                                match.isWin ? .blue.opacity(0.1) : .red.opacity(0.1)
                            ],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .frame(height: 2)

                // Bottom section with enhanced layout
                HStack(spacing: 15) {
                    // Enhanced Items ScrollView
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 4) {
                            let uniqueItemIcons = Array(Set(match.itemIcons))
                                .filter { $0 != "https://ddragon.leagueoflegends.com/cdn/15.3.1/img/item/0.png" }
                            
                            ForEach(uniqueItemIcons, id: \.self) { itemIcon in
                                AsyncImage(url: URL(string: itemIcon)) { image in
                                    image.resizable()
                                        .scaledToFit()
                                        .frame(width: 35, height: 35)
                                        .clipShape(RoundedRectangle(cornerRadius: 6))
                                        .overlay(
                                            RoundedRectangle(cornerRadius: 6)
                                                .stroke(Color.white.opacity(0.2), lineWidth: 1)
                                        )
                                } placeholder: {
                                    ProgressView()
                                        .frame(width: 35, height: 35)
                                }
                            }
                        }
                        .padding(.horizontal, 4)
                    }

                    // Vertical Divider
                    Rectangle()
                        .fill(
                            LinearGradient(
                                colors: [
                                    match.isWin ? .blue.opacity(0.1) : .red.opacity(0.1),
                                    match.isWin ? .blue.opacity(0.3) : .red.opacity(0.3),
                                    match.isWin ? .blue.opacity(0.1) : .red.opacity(0.1)
                                ],
                                startPoint: .top,
                                endPoint: .bottom
                            )
                        )
                        .frame(width: 2, height: 80)

                    // Enhanced Ward Icon
                    if match.gameMode != "Aram" {
                        if let wardIcon = match.wardIcon {
                            AsyncImage(url: URL(string: wardIcon)) { image in
                                image.resizable()
                                    .scaledToFit()
                                    .frame(width: 32, height: 32)
                                    .clipShape(RoundedRectangle(cornerRadius: 6))
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 6)
                                            .stroke(Color.white.opacity(0.2), lineWidth: 1)
                                    )
                            } placeholder: {
                                ProgressView()
                                    .frame(width: 32, height: 32)
                            }
                        }
                    } else {
                        Image("placeHolder")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 22, height: 22)
                            .clipShape(RoundedRectangle(cornerRadius: 4))
                    }

                    // Vertical Divider
                    Rectangle()
                        .fill(
                            LinearGradient(
                                colors: [
                                    match.isWin ? .blue.opacity(0.1) : .red.opacity(0.1),
                                    match.isWin ? .blue.opacity(0.3) : .red.opacity(0.3),
                                    match.isWin ? .blue.opacity(0.1) : .red.opacity(0.1)
                                ],
                                startPoint: .top,
                                endPoint: .bottom
                            )
                        )
                        .frame(width: 2, height: 80)

                    // Enhanced Runes and Summoner Spells
                    VStack(spacing: 10) {
                        HStack(spacing: 10) {
                            ForEach(match.primaryRunes, id: \.id) { rune in
                                let runeName = runeName(for: rune.id)
                                Image(runeImage(for: runeName))
                                    .resizable()
                                    .scaledToFit()
                                    .frame(width: 34, height: 34)
                                    .shadow(color: .black.opacity(0.3), radius: 2)
                            }
                        }

                        Rectangle()
                            .fill(
                                LinearGradient(
                                    colors: [
                                        match.isWin ? .blue.opacity(0.1) : .red.opacity(0.1),
                                        match.isWin ? .blue.opacity(0.3) : .red.opacity(0.3),
                                        match.isWin ? .blue.opacity(0.1) : .red.opacity(0.1)
                                    ],
                                    startPoint: .leading,
                                    endPoint: .trailing
                                )
                            )
                            .frame(width: 60, height: 2)

                        HStack(spacing: 10) {
                            ForEach(match.summonerSpellIcons, id: \.self) { spellName in
                                Image(summonerSpellImage(for: spellName))
                                    .resizable()
                                    .scaledToFit()
                                    .frame(width: 30, height: 30)
                                    .clipShape(RoundedRectangle(cornerRadius: 6))
                                    .shadow(color: .black.opacity(0.3), radius: 2)
                            }
                        }
                    }
                }
            }
            .padding(.vertical, 12)
            .padding(.horizontal, 15)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(
                        match.isWin ?
                        Color.blue.opacity(0.15) :
                        Color.red.opacity(0.15)
                    )
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(
                                match.isWin ?
                                Color.blue.opacity(0.3) :
                                Color.red.opacity(0.3),
                                lineWidth: 1
                            )
                    )
            )
            .shadow(
                color: match.isWin ? .blue.opacity(0.1) : .red.opacity(0.1),
                radius: 8,
                x: 0,
                y: 4
            )
            .padding(.horizontal, 12)
        }
    }
}
