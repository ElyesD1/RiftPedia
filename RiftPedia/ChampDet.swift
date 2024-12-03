import SwiftUI
import Foundation
import WebKit

// MARK: - Champion Structs
struct ChampionsRespond: Codable {
    let data: [String: ChampionStruct]
}

struct ChampionStruct: Codable {
    let id: String
    let name: String
    let title: String
    let passive: Passive
    let tags: [String]
    let spells: [Spell]
    let skins: [Skin]
    let stats: Stats // Add stats property
}

struct Stats: Codable {
    let hp: Double
    let hpperlevel: Double
    let mp: Double
    let mpperlevel: Double
    let movespeed: Double
    let armor: Double
    let armorperlevel: Double
    let spellblock: Double
    let spellblockperlevel: Double
    let attackrange: Double
    let hpregen: Double
    let hpregenperlevel: Double
    let mpregen: Double
    let mpregenperlevel: Double
    let crit: Double
    let critperlevel: Double
    let attackdamage: Double
    let attackdamageperlevel: Double
    let attackspeedperlevel: Double
    let attackspeed: Double
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
    @State private var isSpotlightActive = false // Flag to track spotlight view activation

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
    func removeHTMLTags(from string: String) -> String {
          let pattern = "<.*?>"
          let regex = try? NSRegularExpression(pattern: pattern, options: [])
          let range = NSRange(location: 0, length: string.utf16.count)
          let cleanString = regex?.stringByReplacingMatches(in: string, options: [], range: range, withTemplate: " ") ?? string
          return cleanString
      }
    var body: some View {
        ZStack {
            Color("Background")
                .ignoresSafeArea() // Ensures the background color covers the entire screen

            ScrollView { // Wrap the entire content in ScrollView to make it scrollable
                VStack {
                    Spacer().frame(height: 1) // Adjust this height to push the content lower

                    if let detail = championStruct {
                        VStack(spacing: 5) {
                            // Top Section: Champion Image, Name, and Title
                            if let imageURL = URL(string: "https://ddragon.leagueoflegends.com/cdn/14.23.1/img/champion/\(detail.id).png") {
                                AsyncImage(url: imageURL) { image in
                                    image
                                        .resizable()
                                        .scaledToFit()
                                        .frame(height: 130)
                                        .cornerRadius(10)
                                        .padding(.top)
                                } placeholder: {
                                    ProgressView()
                                }
                            }

                            // View Champion Spotlight Button
                            Button(action: {
                                isSpotlightActive.toggle() // Toggle spotlight view
                            }) {
                                Text("View Champion Spotlight")
                                    .font(.subheadline)
                                    .foregroundColor(Color("Button")) // Use "Button" color from your asset catalog
                                   // Add padding on top to match the overall layout
                            }
                            .buttonStyle(PlainButtonStyle()) // Use PlainButtonStyle to ensure no background or extra styling is applied
                            

                            VStack(spacing: 4) {
                                Text(detail.name)
                                    .font(.largeTitle)
                                    .fontWeight(.bold)
                                    .foregroundColor(.white)
                                Text(detail.title)
                                    .font(.headline)
                                    .foregroundColor(.gray)
                                if !detail.tags.isEmpty {
                                    Text(detail.tags.joined(separator: ", ")) // Join tags with commas
                                        .font(.headline)
                                        .foregroundColor(.gray) // Use a color that contrasts well
                                }
                            }
                            VStack(alignment: .center, spacing: 4) {
                                Text("Base stats")
                                    .font(.subheadline)
                                    .foregroundColor(.white)
                                    .bold()

                                HStack {
                                    VStack(alignment: .leading, spacing: 4) {
                                        Text("HP: \(detail.stats.hp, specifier: "%.0f")")
                                        Text("HP per Level: \(detail.stats.hpperlevel, specifier: "%.1f")")
                                        Text("MP: \(detail.stats.mp, specifier: "%.0f")")
                                        Text("MP per Level: \(detail.stats.mpperlevel, specifier: "%.1f")")
                                        Text("Move Speed: \(detail.stats.movespeed, specifier: "%.0f")")
                                        Text("Armor: \(detail.stats.armor, specifier: "%.1f")")
                                    }

                                    Spacer()

                                    VStack(alignment: .leading, spacing: 4) {
                                        Text("Spell Block: \(detail.stats.spellblock, specifier: "%.1f")")
                                        Text("Attack Damage: \(detail.stats.attackdamage, specifier: "%.1f")")
                                        Text("Attack Speed: \(detail.stats.attackspeed, specifier: "%.2f")")
                                        Text("Attack Range: \(detail.stats.attackrange, specifier: "%.0f")")
                                        Text("HP Regen: \(detail.stats.hpregen, specifier: "%.1f")")
                                        Text("MP Regen: \(detail.stats.mpregen, specifier: "%.1f")")
                                    }
                                }
                                .foregroundColor(.gray)
                                .font(.footnote)
                            }
                            .padding(.top, 8)

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

                                    if let passiveImageURL = URL(string: "https://ddragon.leagueoflegends.com/cdn/14.23.1/img/passive/\(detail.passive.image.full)") {
                                        AsyncImage(url: passiveImageURL) { image in
                                            image
                                                .resizable()
                                                .frame(width: 48, height: 48)
                                                .cornerRadius(10)
                                                .onTapGesture {
                                                    showAlert(name: detail.passive.name, description: removeHTMLTags(from: detail.passive.description))
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
                                                    .cornerRadius(10)
                                                    .onTapGesture {
                                                        showAlert(name: spell.name, description: removeHTMLTags(from: spell.description))
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
                Alert(title: Text(alertTitle), message: Text(alertDescription), dismissButton: .default(Text("OK")))
            }
            .fullScreenCover(isPresented: $isSpotlightActive) {
                // Champion spotlight WebView
                ChampionSpotlightView(championName: championName)
            }
        }
    }

    private func showAlert(name: String, description: String) {
        alertTitle = name
        alertDescription = description
        showAlert = true
    }
}
// MARK: - Champion Spotlight View
struct ChampionSpotlightView: View {
    var championName: String
    @Environment(\.presentationMode) var presentationMode

    var body: some View {
        NavigationView {
            VStack {
                // WebView to display YouTube results
                WebView(url: "https://www.youtube.com/results?search_query=\(championName)+champion+spotlight")
                    .edgesIgnoringSafeArea(.all)
                    .padding(.top, 20) // Adds some padding to lower the video
            }
            .navigationTitle("Champion Spotlight") // Set the title
            .navigationBarTitleDisplayMode(.inline) // Optional: To make the title inline
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button(action: {
                        self.presentationMode.wrappedValue.dismiss() // Dismiss the current view
                    }) {
                        HStack {
                            Image(systemName: "arrow.left") // Default back arrow icon
                                .foregroundColor(.blue) // Color same as default back button
                            Text("Back") // Optional text to match default behavior
                                .foregroundColor(.blue) // Same text color as default
                        }
                    }
                }
            }
        }
    }
}
// WebView to display YouTube results
struct WebView: UIViewRepresentable {
    var url: String

    func makeUIView(context: Context) -> WKWebView {
        let webView = WKWebView()
        webView.navigationDelegate = context.coordinator
        if let url = URL(string: url) {
            let request = URLRequest(url: url)
            webView.load(request)
        }
        return webView
    }

    func updateUIView(_ uiView: WKWebView, context: Context) {}

    func makeCoordinator() -> Coordinator {
        return Coordinator()
    }

    class Coordinator: NSObject, WKNavigationDelegate {}
}





