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
        let urlString = "https://ddragon.leagueoflegends.com/cdn/15.3.1/data/en_US/champion/\(championId).json"
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
    private func showAlert(name: String, description: String) {
        alertTitle = name
        alertDescription = description
        showAlert = true
    }
    var body: some View {
           ZStack {
               // Enhanced background with gradient
               LinearGradient(
                   gradient: Gradient(colors: [
                       Color("Background"),
                       Color("Background").opacity(0.9),
                       Color("Background").opacity(0.8)
                   ]),
                   startPoint: .top,
                   endPoint: .bottom
               )
               .ignoresSafeArea()
               
               ScrollView {
                   VStack(spacing: 20) {
                       if let detail = championStruct {
                           // Champion Header Section
                           VStack(spacing: 15) {
                               // Champion Image with enhanced styling
                               if let imageURL = URL(string: "https://ddragon.leagueoflegends.com/cdn/15.3.1/img/champion/\(detail.id).png") {
                                   AsyncImage(url: imageURL) { image in
                                       image
                                           .resizable()
                                           .scaledToFit()
                                           .frame(height: 150)
                                           .cornerRadius(20)
                                           .shadow(color: Color("Button").opacity(0.5), radius: 10, x: 0, y: 5)
                                           .overlay(
                                               RoundedRectangle(cornerRadius: 20)
                                                   .stroke(Color.white.opacity(0.2), lineWidth: 1)
                                           )
                                   } placeholder: {
                                       ProgressView()
                                           .frame(height: 150)
                                   }
                               }
                               
                               // Enhanced Spotlight Button
                               Button(action: { isSpotlightActive.toggle() }) {
                                   HStack {
                                       Image(systemName: "play.circle.fill")
                                           .font(.title2)
                                       Text("Watch Champion Spotlight")
                                           .fontWeight(.semibold)
                                   }
                                   .foregroundColor(Color("Button"))
                                   .padding(.vertical, 10)
                                   .padding(.horizontal, 20)
                                   .background(
                                       RoundedRectangle(cornerRadius: 15)
                                           .fill(Color("Button").opacity(0.15))
                                   )
                                   .overlay(
                                       RoundedRectangle(cornerRadius: 15)
                                           .stroke(Color("Button").opacity(0.3), lineWidth: 1)
                                   )
                               }
                               
                               // Champion Info Section
                               VStack(spacing: 8) {
                                   Text(detail.name)
                                       .font(.system(size: 32, weight: .bold))
                                       .foregroundColor(.white)
                                   
                                   Text(detail.title)
                                       .font(.title3)
                                       .foregroundColor(.gray)
                                   
                                   // Tags with pills design
                                   if !detail.tags.isEmpty {
                                       HStack(spacing: 10) {
                                           ForEach(detail.tags, id: \.self) { tag in
                                               Text(tag)
                                                   .font(.caption)
                                                   .fontWeight(.medium)
                                                   .foregroundColor(.white)
                                                   .padding(.horizontal, 12)
                                                   .padding(.vertical, 6)
                                                   .background(
                                                       Capsule()
                                                           .fill(Color("Button").opacity(0.3))
                                                   )
                                           }
                                       }
                                   }
                               }
                               
                               // Enhanced Stats Section
                               VStack(spacing: 15) {
                                   Text("Base Statistics")
                                       .font(.title3)
                                       .fontWeight(.bold)
                                       .foregroundColor(.white)
                                   
                                   // Stats Grid
                                   LazyVGrid(columns: [
                                       GridItem(.flexible()),
                                       GridItem(.flexible())
                                   ], spacing: 15) {
                                       StatView(title: "HP", value: "\(Int(detail.stats.hp))")
                                       StatView(title: "MP", value: "\(Int(detail.stats.mp))")
                                       StatView(title: "Armor", value: String(format: "%.1f", detail.stats.armor))
                                       StatView(title: "Magic Resist", value: String(format: "%.1f", detail.stats.spellblock))
                                       StatView(title: "Attack Damage", value: String(format: "%.1f", detail.stats.attackdamage))
                                       StatView(title: "Attack Speed", value: String(format: "%.2f", detail.stats.attackspeed))
                                   }
                                   .padding()
                                   .background(Color.black.opacity(0.2))
                                   .cornerRadius(15)
                               }
                               
                               // Enhanced Splash Art Section
                               if splashCount > 0 {
                                   VStack(alignment: .leading) {
                                       Text("Available Skins")
                                           .font(.title3)
                                           .fontWeight(.bold)
                                           .foregroundColor(.white)
                                           .padding(.horizontal)
                                       
                                       ScrollView(.horizontal, showsIndicators: false) {
                                           HStack(spacing: 15) {
                                               ForEach(detail.skins, id: \.id) { skin in
                                                   if let splashURL = URL(string: "https://ddragon.leagueoflegends.com/cdn/img/champion/splash/\(championId)_\(skin.num).jpg") {
                                                       AsyncImage(url: splashURL) { image in
                                                           image
                                                               .resizable()
                                                               .scaledToFill()
                                                               .frame(width: UIScreen.main.bounds.width - 60, height: 200)
                                                               .cornerRadius(20)
                                                               .shadow(color: .black.opacity(0.3), radius: 10, x: 0, y: 5)
                                                               .overlay(
                                                                   VStack {
                                                                       Spacer()
                                                                       Text(skin.name)
                                                                           .font(.caption)
                                                                           .fontWeight(.medium)
                                                                           .foregroundColor(.white)
                                                                           .padding(.vertical, 8)
                                                                           .frame(maxWidth: .infinity)
                                                                           .background(
                                                                               LinearGradient(
                                                                                   colors: [.black.opacity(0.7), .clear],
                                                                                   startPoint: .bottom,
                                                                                   endPoint: .top
                                                                               )
                                                                           )
                                                                   }
                                                                       .cornerRadius(20)
                                                               )
                                                       } placeholder: {
                                                           ProgressView()
                                                               .frame(width: UIScreen.main.bounds.width - 60, height: 200)
                                                       }
                                                   }
                                               }
                                           }
                                           .padding(.horizontal)
                                       }
                                   }
                               }
                               
                               // Enhanced Abilities Section
                               VStack(spacing: 15) {
                                   Text("Abilities")
                                       .font(.title3)
                                       .fontWeight(.bold)
                                       .foregroundColor(.white)
                                   
                                   HStack(spacing: 15) {
                                       // Passive
                                       if let passiveImageURL = URL(string: "https://ddragon.leagueoflegends.com/cdn/15.3.1/img/passive/\(detail.passive.image.full)") {
                                           AbilityButton(imageURL: passiveImageURL, name: detail.passive.name) {
                                               showAlert(name: detail.passive.name, description: removeHTMLTags(from: detail.passive.description))
                                           }
                                       }
                                       
                                       // Active abilities
                                       ForEach(detail.spells, id: \.name) { spell in
                                           if let spellImageURL = URL(string: "https://ddragon.leagueoflegends.com/cdn/15.3.1/img/spell/\(spell.image.full)") {
                                               AbilityButton(imageURL: spellImageURL, name: spell.name) {
                                                   showAlert(name: spell.name, description: removeHTMLTags(from: spell.description))
                                               }
                                           }
                                       }
                                   }
                                   .padding(.horizontal)
                               }
                           }
                           .padding(.bottom, 30)
                       } else {
                           // Enhanced Loading View
                           VStack(spacing: 20) {
                               ProgressView()
                                   .scaleEffect(1.5)
                               Text("Loading Champion Details...")
                                   .font(.headline)
                                   .foregroundColor(.gray)
                           }
                           .frame(maxWidth: .infinity, maxHeight: .infinity)
                           .padding()
                       }
                   }
                   .padding()
               }
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
struct StatView: View {
    let title: String
    let value: String
    
    var body: some View {
        VStack(spacing: 5) {
            Text(title)
                .font(.caption)
                .foregroundColor(.gray)
            Text(value)
                .font(.system(.body, design: .rounded))
                .fontWeight(.semibold)
                .foregroundColor(.white)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 8)
    }
}

struct AbilityButton: View {
    let imageURL: URL
    let name: String
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            AsyncImage(url: imageURL) { image in
                image
                    .resizable()
                    .scaledToFit()
                    .frame(width: 60, height: 60)
                    .cornerRadius(12)
                    .shadow(color: Color("Button").opacity(0.5), radius: 5, x: 0, y: 2)
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(Color.white.opacity(0.2), lineWidth: 1)
                    )
            } placeholder: {
                ProgressView()
                    .frame(width: 60, height: 60)
            }
        }
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
// MARK: - WebView
struct WebView: UIViewRepresentable {
    var url: String

    func makeUIView(context: Context) -> WKWebView {
        let webView = WKWebView()
        if let url = URL(string: url) {
            webView.load(URLRequest(url: url))
        }
        return webView
    }

    func updateUIView(_ uiView: WKWebView, context: Context) {}

    func makeCoordinator() -> Coordinator {
        Coordinator()
    }

    class Coordinator: NSObject, WKNavigationDelegate {}
}





