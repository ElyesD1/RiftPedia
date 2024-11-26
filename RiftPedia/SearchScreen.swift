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
        "Europe Nordic & East": "eune1",
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
                Color.appBackground.ignoresSafeArea()
                
                VStack(spacing: 30) {
                    // Search Bar
                    HStack {
                        VStack(alignment: .leading, spacing: 10) {
                            Text("Search for Player Stats")
                                .font(.headline)
                                .foregroundColor(.appLabel)

                            HStack {
                                TextField("Enter Riot ID (e.g., Player#1234)", text: $searchQuery)
                                    .padding()
                                    .background(Color(UIColor.secondarySystemBackground))
                                    .cornerRadius(10)
                                    .foregroundColor(.primary)

                                Button(action: performSearch) {
                                    Image(systemName: "magnifyingglass")
                                        .foregroundColor(.appButton)
                                        .padding()
                                }
                                .background(Color.white.opacity(0.2))
                                .cornerRadius(10)
                            }
                        }
                        .padding(.horizontal)

                        Spacer()
                    }

                    // Error Message
                    if let errorMessage = errorMessage {
                        Text(errorMessage)
                            .foregroundColor(.red)
                            .font(.subheadline)
                            .padding(.horizontal)
                    }

                    // Picker for Regions
                    VStack(alignment: .leading, spacing: 10) {
                        Text("Select Region")
                            .font(.headline)
                            .foregroundColor(.appLabel)

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
                        .background(Color.white.opacity(0.1))
                        .cornerRadius(10)
                    }
                    .padding(.horizontal)

                    // Logo and Description
                    VStack(alignment: .center, spacing: 0) {
                        Image("Logo")
                            .resizable()
                            .frame(width: 200, height: 200)
                            .cornerRadius(10)
                            .shadow(radius: 3)

                        Text("RiftPedia")
                            .font(.title2)
                            .fontWeight(.bold)
                            .foregroundColor(.appLabel)

                        Text("Your Ultimate League of Legends Companion")
                            .font(.subheadline)
                            .foregroundColor(.appLabel.opacity(0.7))
                            .multilineTextAlignment(.center)
                    }

                    Spacer()
                }
                .padding(.top, 20)
                .alert(isPresented: $showAlert) {
                    Alert(title: Text("Error"), message: Text(alertMessage), dismissButton: .default(Text(" OK")))
                }

                // Navigation for History Screen
                NavigationLink(
                    destination: HistoryScreen(
                        name: name,
                        tag: tag,
                        region: selectedRegion,
                        mappedRegion: mappedRegion
                    ),
                    isActive: $isNavigationActive  // Bind the navigation state
                ) {
                    EmptyView()  // Empty View to trigger navigation manually
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
