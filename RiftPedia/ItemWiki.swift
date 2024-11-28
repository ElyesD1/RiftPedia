import SwiftUI
import Foundation

// Updated ItemStruct with a description field
struct ItemStruct: Codable, Identifiable {
    let id: String?  // Make id optional
    let name: String
    let image: ImageDatas
    let gold: Gold
    let description: String?  // Add description field

    // Computed property to provide a unique id
    var uniqueId: String {
        id ?? UUID().uuidString
    }
    
    // Method to remove HTML tags from the name
    func cleanName() -> String {
        return name.replacingOccurrences(of: "<[^>]+>", with: "", options: .regularExpression)
    }
    
    // Function to remove HTML tags from description
    func cleanDescription() -> String {
        guard let description = description else { return "No description available." }
        let cleanedDescription = description.replacingOccurrences(of: "<[^>]+>", with: " ", options: .regularExpression)
        return cleanedDescription.trimmingCharacters(in: .whitespacesAndNewlines)
    }
}

struct ImageDatas: Codable {
    let full: String
}

struct Gold: Codable {
    let total: Int
}

struct ItemRespond: Codable {
    let data: [String: ItemStruct]
}

class ItemWikiViewModel: ObservableObject {
    @Published var items: [ItemStruct] = []
    @Published var searchText = ""
    @Published var selectedItem: ItemStruct? = nil  // Track the selected item
    
    private let baseUrl = "https://ddragon.leagueoflegends.com/cdn/14.23.1/data/en_US/item.json"
    
    func fetchItems() {
        guard let url = URL(string: baseUrl) else { return }
        URLSession.shared.dataTask(with: url) { data, response, error in
            guard let data = data, error == nil else {
                print("Error fetching data: \(String(describing: error))")
                return
            }
            
            do {
                let decodedResponse = try JSONDecoder().decode(ItemRespond.self, from: data)
                DispatchQueue.main.async {
                    // Group items by name and pick the one with the highest gold cost
                    var groupedItems = [String: ItemStruct]()
                    
                    for item in decodedResponse.data.values {
                        let existingItem = groupedItems[item.name]
                        if let existingItem = existingItem {
                            // Compare and keep the item with the higher gold cost
                            if item.gold.total > existingItem.gold.total {
                                groupedItems[item.name] = item
                            }
                        } else {
                            groupedItems[item.name] = item
                        }
                    }
                    
                    // Convert the grouped dictionary into an array and sort it by item name
                    self.items = Array(groupedItems.values).sorted { $0.name < $1.name }
                }
            } catch {
                print("Error decoding items: \(error)")
                if let stringData = String(data: data, encoding: .utf8) {
                    print("Raw JSON data: \(stringData)")
                }
            }
        }.resume()
    }
}

struct ItemWiki: View {
    @StateObject private var viewModel = ItemWikiViewModel()
    
    var filteredItems: [ItemStruct] {
        if viewModel.searchText.isEmpty {
            return viewModel.items
        } else {
            return viewModel.items.filter { $0.cleanName().localizedCaseInsensitiveContains(viewModel.searchText) }
        }
    }
    
    var body: some View {
        NavigationView {
            VStack {
                // Title as normal text centered on top
                Text("Item Wiki")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .padding()
                    .frame(maxWidth: .infinity, alignment: .center)
                    .foregroundColor(.white)  // Adjust text color if needed
                
                // Search Bar
                TextField("Search items...", text: $viewModel.searchText)
                    .padding()
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .onChange(of: viewModel.searchText) { _ in }
                
                List(filteredItems, id: \.uniqueId) { item in
                    HStack {
                        AsyncImage(
                            url: URL(string: "https://ddragon.leagueoflegends.com/cdn/14.23.1/img/item/\(item.image.full)")
                        ) { image in
                            image
                                .resizable()
                                .scaledToFit()
                                .frame(width: 50, height: 50)
                        } placeholder: {
                            ProgressView()
                        }
                        
                        VStack(alignment: .leading) {
                            Text(item.cleanName())  // Use cleaned-up name
                                .font(.headline)
                            Text("Cost: \(item.gold.total)")
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                        }
                    }
                    .onTapGesture {
                        // Set the selected item when the cell is tapped
                        viewModel.selectedItem = item
                    }
                }
                .background(Color("Background"))  // Set the background color for the list
            }
            .background(Color("Background"))  // Set the background color for the entire view
            .onAppear {
                viewModel.fetchItems()
            }
            .alert(item: $viewModel.selectedItem) { item in
                Alert(
                    title: Text(item.cleanName()),
                    message: Text(item.cleanDescription()),  // Use cleaned description
                    dismissButton: .default(Text("OK"))
                )
            }
        }
    }
}

#Preview {
    ItemWiki()
}
