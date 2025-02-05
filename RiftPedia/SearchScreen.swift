import SwiftUI
struct SearchScreen: View {
    @State private var searchQuery: String = ""
    @State private var selectedRegion: String = "na1"
    @State private var apiUrl: String = ""
    @State private var name: String = ""
    @State private var tag: String = ""
    @State private var errorMessage: String? = nil
    @State private var showAlert: Bool = false
    @State private var alertMessage: String = ""
    @State private var isNavigationActive: Bool = false
    @State private var mappedRegion: String = ""

    let regions = [
        "North America": "na1",
        "Europe West": "euw1",
        "Europe Nordic & East": "eun1",
        "Korea": "kr",
        "China": "cn",
        "Japan": "jp1",
        "Oceania": "oc1",
        "Brazil": "br1",
        "Turkey": "tr1",
        "Russia": "ru"
    ]
    
    let accountRegions = [
        "North America": "americas",
        "Europe West": "europe",
        "Europe Nordic & East": "europe",
        "Korea": "asia",
        "China": "asia",
        "Japan": "asia",
        "Oceania": "sea",
        "Brazil": "americas",
        "Turkey": "europe",
        "Russia": "europe"
    ]
    
    var body: some View {
            NavigationStack {
                ZStack {
                    // Enhanced background with gradient
                    LinearGradient(
                        gradient: Gradient(colors: [
                            Color.appBackground,
                            Color.appBackground.opacity(0.8),
                            Color.appBackground.opacity(0.6)
                        ]),
                        startPoint: .top,
                        endPoint: .bottom
                    )
                    .ignoresSafeArea()
                    
                    VStack(spacing: 30) {
                        // Enhanced Search Bar Section
                        VStack(alignment: .leading, spacing: 15) {
                            Text("Search for Player Stats")
                                .font(.title2)
                                .fontWeight(.bold)
                                .foregroundColor(.appLabel)
                                .shadow(radius: 2)

                            HStack(spacing: 12) {
                                HStack {
                                    Image(systemName: "magnifyingglass")
                                        .foregroundColor(.gray)
                                        .padding(.leading, 12)
                                    
                                    TextField("Enter Riot ID (e.g., Player#1234)", text: $searchQuery)
                                        .padding()
                                        .autocapitalization(.none)
                                }
                                .background(
                                    RoundedRectangle(cornerRadius: 15)
                                        .fill(Color(UIColor.secondarySystemBackground))
                                        .shadow(color: Color.black.opacity(0.1), radius: 5, x: 0, y: 2)
                                )

                                Button(action: performSearch) {
                                    Image(systemName: "arrow.right.circle.fill")
                                        .font(.system(size: 24))
                                        .foregroundColor(.appButton)
                                }
                                .buttonStyle(BouncyButtonStyle())
                            }
                        }
                        .padding(.horizontal, 20)
                        .padding(.top, 20)

                        // Enhanced Error Message
                        if let errorMessage = errorMessage {
                            Text(errorMessage)
                                .foregroundColor(.red)
                                .font(.subheadline)
                                .padding(12)
                                .background(
                                    RoundedRectangle(cornerRadius: 10)
                                        .fill(Color.red.opacity(0.1))
                                )
                                .padding(.horizontal)
                        }

                        // Enhanced Region Selector
                        VStack(alignment: .leading, spacing: 15) {
                            Text("Select Region")
                                .font(.title3)
                                .fontWeight(.semibold)
                                .foregroundColor(.appLabel)
                                .shadow(radius: 2)

                            ZStack {
                                RoundedRectangle(cornerRadius: 20)
                                    .fill(Color.white.opacity(0.1))
                                    .shadow(color: Color.black.opacity(0.1), radius: 10, x: 0, y: 5)
                                
                                Picker("Select Region", selection: $selectedRegion) {
                                    ForEach(regions.keys.sorted(), id: \.self) { region in
                                        Text(region)
                                            .foregroundColor(.appLabel)
                                            .tag(region)
                                    }
                                }
                                .pickerStyle(WheelPickerStyle())
                                .frame(height: 150)
                                .clipped()
                            }
                            .padding(.horizontal, 5)
                        }
                        .padding(.horizontal, 20)

                        Spacer()

                        // Enhanced Background Image
                        Image("bg")
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                            .frame(width: UIScreen.main.bounds.width * 0.95, height: UIScreen.main.bounds.height * 0.3)
                            .clipShape(RoundedRectangle(cornerRadius: 25))
                            .shadow(color: Color.black.opacity(0.2), radius: 15, x: 0, y: 10)
                            .overlay(
                                RoundedRectangle(cornerRadius: 25)
                                    .stroke(Color.white.opacity(0.2), lineWidth: 1)
                            )

                        Spacer()
                    }
                    .padding(.top, 20)
                    .alert(isPresented: $showAlert) {
                        Alert(
                            title: Text("Error"),
                            message: Text(alertMessage),
                            dismissButton: .default(Text("OK"))
                        )
                    }

                    NavigationLink(
                        destination: HistoryScreen(
                            name: name,
                            tag: tag,
                            region: selectedRegion,
                            mappedRegion: mappedRegion
                        ),
                        isActive: $isNavigationActive
                    ) {
                        EmptyView()
                    }
                }
            }
        }

    private func performSearch() {
        errorMessage = nil
        
        let components = searchQuery.split(separator: "#", omittingEmptySubsequences: false)
        guard components.count == 2 else {
            errorMessage = "Invalid format! Use the format: name#tag"
            return
        }
        
        name = String(components[0])
        tag = String(components[1])

        // No longer restricting tag length or characters
        updateApiUrl()
        fetchAccountData()
    }

    private func updateApiUrl() {
        guard let platformRegion = accountRegions[selectedRegion] else {
            apiUrl = ""
            return
        }

        mappedRegion = regions[selectedRegion] ?? ""
        apiUrl = "https://\(platformRegion).api.riotgames.com/riot/account/v1/accounts/by-riot-id/\(name)/\(tag)?api_key=\(Config.riotAPIKey)"
    }
    struct GlassBackground: ViewModifier {
        func body(content: Content) -> some View {
            content
                .background(
                    RoundedRectangle(cornerRadius: 20)
                        .fill(Color.white.opacity(0.1))
                        .background(
                            RoundedRectangle(cornerRadius: 20)
                                .fill(Color.white.opacity(0.08))
                                .blur(radius: 10)
                        )
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 20)
                        .stroke(Color.white.opacity(0.2), lineWidth: 1)
                )
        }
    }
    struct BouncyButtonStyle: ButtonStyle {
        func makeBody(configuration: Configuration) -> some View {
            configuration.label
                .scaleEffect(configuration.isPressed ? 0.9 : 1.0)
                .animation(.spring(response: 0.3, dampingFraction: 0.6), value: configuration.isPressed)
        }
    }
    // Extension for custom modifiers
    
    private func fetchAccountData() {
        guard !apiUrl.isEmpty else { return }

        guard let url = URL(string: apiUrl) else { return }

        var request = URLRequest(url: url)
        request.httpMethod = "GET"

        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                DispatchQueue.main.async {
                    self.errorMessage = "Error fetching account data: \(error.localizedDescription)"
                    self.showAlert = true
                }
                return
            }

            guard let data = data else {
                DispatchQueue.main.async {
                    self.errorMessage = "No data received."
                    self.showAlert = true
                }
                return
            }

            do {
                if let json = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any] {
                    print("JSON Response: \(json)")

                    if let puuid = json["puuid"] as? String {
                        DispatchQueue.main.async {
                            print("Retrieved PUUID: \(puuid)")
                            Config.puuid = puuid  // Store PUUID in Config
                            self.isNavigationActive = true  // Trigger navigation after data is fetched
                        }
                    } else {
                        DispatchQueue.main.async {
                            self.errorMessage = "PUUID not found in response."
                            self.showAlert = true
                        }
                    }
                }
            } catch {
                DispatchQueue.main.async {
                    self.errorMessage = "Error decoding response: \(error.localizedDescription)"
                    self.showAlert = true
                }
            }
        }.resume()
    }
    
}
