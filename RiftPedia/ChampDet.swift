import SwiftUI
import Foundation

// MARK: - Champion Structs
struct ChampionsRespond: Codable {
    let data: [String: ChampionStruct]
}

struct ChampionStruct: Codable {
    let id: String
    let name: String
    let title: String
    let passive: Passive
    let spells: [Spell]
    let skins: [Skin] // Added to fetch skins and splash count
}

struct Passive: Codable {
    let name: String
    let description: String
    let image: ImageData
}

struct Spell: Codable {
    let name: String
    let description: String
    let image: ImageData
}

struct Skin: Codable {
    let id: String
    let num: Int // Skin number to generate splash URL
    let name: String
}

struct ImageData: Codable {
    let full: String
}

// MARK: - ChampDet View
struct ChampDet: View {
    var championId: String
    var championName: String
    @State private var championStruct: ChampionStruct?
    @State private var showAlert = false
    @State private var alertTitle = ""
    @State private var alertDescription = ""
    @State private var splashCount = 0 // Number of available splash arts

    func fetchChampionDetails(for championId: String, completion: @escaping (ChampionStruct?) -> Void) {
        let urlString = "https://ddragon.leagueoflegends.com/cdn/14.23.1/data/en_US/champion/\(championId).json"
        guard let url = URL(string: urlString) else {
            print("Invalid URL")
            completion(nil)
            return
        }

        URLSession.shared.dataTask(with: url) { data, response, error in
            guard let data = data, error == nil else {
                print("Error fetching data: \(error?.localizedDescription ?? "Unknown error")")
                completion(nil)
                return
            }

            do {
                let decoder = JSONDecoder()
                let championsResponse = try decoder.decode(ChampionsRespond.self, from: data)
                let champion = championsResponse.data[championId]
                completion(champion)
            } catch {
                print("Error decoding data: \(error.localizedDescription)")
                completion(nil)
            }
        }.resume()
    }

    var body: some View {
        ZStack {
            Color("Background")
                .ignoresSafeArea()

            VStack {
                Spacer().frame(height: 50) // Adjust this height to push the content lower

                if let detail = championStruct {
                    VStack(spacing: 16) {
                        // Top Section: Champion Image, Name, and Title
                        if let imageURL = URL(string: "https://ddragon.leagueoflegends.com/cdn/14.23.1/img/champion/\(detail.id).png") {
                            AsyncImage(url: imageURL) { image in
                                image
                                    .resizable()
                                    .scaledToFit()
                                    .frame(height: 130)
                                    .padding(.top)
                            } placeholder: {
                                ProgressView()
                            }
                        }

                        VStack(spacing: 4) {
                            Text(detail.name)
                                .font(.largeTitle)
                                .fontWeight(.bold)
                                .foregroundColor(.white)
                            Text(detail.title)
                                .font(.headline)
                                .foregroundColor(.gray)
                        }

                        // Add spacing here to create space between title and skins
                        Spacer().frame(height: 20) // Adjust this height to your preference

                        // Splash Art Section
                        VStack {
                            if splashCount > 0 {
                                ScrollView(.horizontal, showsIndicators: false) {
                                    HStack {
                                        ForEach(detail.skins, id: \.id) { skin in
                                            if let splashURL = URL(string: "https://ddragon.leagueoflegends.com/cdn/img/champion/splash/\(championId)_\(skin.num).jpg") {
                                                AsyncImage(url: splashURL) { image in
                                                    image
                                                        .resizable()
                                                        .scaledToFill()
                                                        .frame(width: UIScreen.main.bounds.width - 40, height: 200)
                                                        .cornerRadius(12)
                                                        .shadow(radius: 5)
                                                } placeholder: {
                                                    ProgressView()
                                                }
                                            }
                                        }
                                    }
                                    .padding(.horizontal)
                                }
                            }
                        }
                        .frame(height: 200)
                    
                        Spacer() // Push passive and spells to the bottom
                    }

                    // Bottom Section: Passive and Spells
                    GeometryReader { geometry in
                        VStack {
                            Spacer()
                            HStack(spacing: 20) {
                                Spacer()

                                // Passive
                                if let passiveImageURL = URL(string: "https://ddragon.leagueoflegends.com/cdn/14.23.1/img/passive/\(detail.passive.image.full)") {
                                    AsyncImage(url: passiveImageURL) { image in
                                        image
                                            .resizable()
                                            .frame(width: 48, height: 48)
                                            .onTapGesture {
                                                showAlert(name: detail.passive.name, description: detail.passive.description)
                                            }
                                    } placeholder: {
                                        ProgressView()
                                    }
                                }

                                // Spells
                                ForEach(detail.spells, id: \.name) { spell in
                                    if let spellImageURL = URL(string: "https://ddragon.leagueoflegends.com/cdn/14.23.1/img/spell/\(spell.image.full)") {
                                        AsyncImage(url: spellImageURL) { image in
                                            image
                                                .resizable()
                                                .frame(width: 48, height: 48)
                                                .onTapGesture {
                                                    showAlert(name: spell.name, description: spell.description)
                                                }
                                        } placeholder: {
                                            ProgressView()
                                        }
                                    }
                                }

                                Spacer()
                            }
                            .frame(maxWidth: geometry.size.width) // Center horizontally
                            .padding(.bottom, 16)
                        }
                    }
                } else {
                    Text("Loading...")
                        .font(.title)
                }
            }
            .padding(.horizontal)
        }
        .onAppear {
            fetchChampionDetails(for: championId) { detail in
                DispatchQueue.main.async {
                    self.championStruct = detail
                    self.splashCount = detail?.skins.count ?? 0
                }
            }
        }
        .alert(isPresented: $showAlert) {
            Alert(
                title: Text(alertTitle),
                message: Text(alertDescription),
                dismissButton: .default(Text("OK"))
            )
        }
    }

    // MARK: - Helper Methods

    private func showAlert(name: String, description: String) {
        alertTitle = name
        alertDescription = description
        showAlert = true
    }
}

// MARK: - Preview
struct ChampDet_Previews: PreviewProvider {
    static var previews: some View {
        ChampDet(championId: "Aatrox", championName: "Aatrox")
    }
}
