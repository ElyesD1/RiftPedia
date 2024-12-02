import SwiftUI
import Foundation

// Item structure (Updated to clean HTML tags in description)
struct ItemStruct: Codable, Identifiable {
    let name: String
    let description: String?
    let image: ImageData
    let gold: Gold?

    // Nested structure for gold details
    struct Gold: Codable {
        let total: Int
        let sell: Int
    }

    struct ImageData: Codable {
        let full: String
    }

    var id: String {
        return image.full.replacingOccurrences(of: ".png", with: "")
    }

    func cleanName() -> String {
        return name.replacingOccurrences(of: "<[^>]+>", with: "", options: .regularExpression)
    }

    var cleanDescription: String {
        guard let description = description else { return "" }
        return description.replacingOccurrences(of: "<[^>]+>", with: " ", options: .regularExpression)
    }
}

// Response structure to handle the data format with items by their ID
struct ItemRespond: Codable {
    let data: [String: ItemStruct]
}

// ViewModel to handle item fetching and state
class ItemWikiViewModel: ObservableObject {
    @Published var categorizedItems: [String: [String]] = [:]
    @Published var items: [String: ItemStruct] = [:]
    @Published var searchQuery: String = ""
    @Published var selectedItem: ItemStruct? // For presenting item details

    var filteredItems: [String: ItemStruct] {
        if searchQuery.isEmpty {
            return items
        } else {
            return items.filter { $0.value.name.lowercased().contains(searchQuery.lowercased()) }
        }
    }

    func fetchItemsAndCategories() {
        loadItems {
            self.loadCategories()
        }
    }

    private func loadItems(completion: @escaping () -> Void) {
        guard let path = Bundle.main.path(forResource: "item", ofType: "json"),
              let data = try? Data(contentsOf: URL(fileURLWithPath: path)) else {
            print("Failed to locate item.json")
            return
        }

        do {
            let decodedResponse = try JSONDecoder().decode(ItemRespond.self, from: data)
            DispatchQueue.main.async {
                self.items = decodedResponse.data
                completion()
            }
        } catch {
            print("Error decoding item.json: \(error)")
        }
    }

    private func loadCategories() {
        guard let path = Bundle.main.path(forResource: "itemsByCategory", ofType: "json"),
              let data = try? Data(contentsOf: URL(fileURLWithPath: path)) else {
            print("Failed to locate itemsByCategory.json")
            return
        }

        do {
            self.categorizedItems = try JSONDecoder().decode([String: [String]].self, from: data)
        } catch {
            print("Error decoding itemsByCategory.json: \(error)")
        }
    }
}

// Main Wiki View
struct ItemWiki: View {
    @StateObject private var viewModel = ItemWikiViewModel()

    let categoryOrder: [String] = [
        "Starter Items", "Potions and Consumables", "Trinkets", "Distributed items",
        "Boots", "Basic items", "Epic Items", "Legendary Items",
        "Champion exclusive items", "Minion and Turret items",
        "Arena Prismatic items", "Arena exclusive items"
    ]

    let gridColumns = [GridItem(.adaptive(minimum: 80), spacing: 8)]

    var body: some View {
        ZStack {
            Color("Background")
                .ignoresSafeArea()

            VStack(spacing: 10) {
                HStack {
                    TextField("Search items...", text: $viewModel.searchQuery)
                        .padding()
                        .background(Color.white)
                        .cornerRadius(10)
                        .foregroundColor(.black)
                        .textFieldStyle(PlainTextFieldStyle())
                        .padding(.horizontal)
                }
                .padding(.top, 20)

                Text("Item Wiki")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .foregroundColor(.white)
                    .padding(.top, 20)

                ScrollView {
                    LazyVStack(alignment: .leading, spacing: 20) {
                        ForEach(categoryOrder, id: \.self) { category in
                            if let itemIds = viewModel.categorizedItems[category], !itemIds.isEmpty {
                                VStack(alignment: .leading, spacing: 10) {
                                    Text(category)
                                        .font(.headline)
                                        .foregroundColor(.white)
                                        .padding(.leading)

                                    LazyVGrid(columns: gridColumns, spacing: 10) {
                                        ForEach(viewModel.filteredItems.keys.filter { itemIds.contains($0) }, id: \.self) { itemId in
                                            if let item = viewModel.filteredItems[itemId] {
                                                VStack(spacing: 4) {
                                                    Image(item.id) // Using the item id for image reference
                                                        .resizable()
                                                        .scaledToFit()
                                                        .frame(width: 50, height: 50)
                                                        .cornerRadius(10) // Rounded edges for images
                                                        .onTapGesture {
                                                            viewModel.selectedItem = item
                                                        }

                                                    Text(item.cleanName())
                                                        .font(.caption)
                                                        .foregroundColor(.white)
                                                        .multilineTextAlignment(.center)
                                                }
                                                .padding(5)
                                                .background(Color.black.opacity(0.8))
                                                .cornerRadius(8)
                                            }
                                        }
                                    }
                                    .padding(.horizontal)
                                }
                            }
                        }
                    }
                }
            }

            if let selectedItem = viewModel.selectedItem {
                ItemDetailView(item: selectedItem, isPresented: $viewModel.selectedItem)
            }
        }
        .onAppear {
            viewModel.fetchItemsAndCategories()
        }
    }
}

// Item Detail View
struct ItemDetailView: View {
    let item: ItemStruct
    @Binding var isPresented: ItemStruct?

    // Consistent gold color
    private var goldColor: Color {
        Color(red: 255 / 255, green: 215 / 255, blue: 0 / 255) // Gold color in RGB
    }

    var body: some View {
        ZStack {
            Color("Background")
                .ignoresSafeArea()

            ScrollView {
                VStack(spacing: 20) {
                    // Card View
                    VStack(spacing: 20) {
                        Image(item.id) // Using item id to load the image
                            .resizable()
                            .scaledToFit()
                            .frame(width: 100, height: 100)
                            .cornerRadius(10)

                        Text(item.cleanName())
                            .font(.title)
                            .fontWeight(.bold)
                            .foregroundColor(.white)

                        if let gold = item.gold {
                            VStack(spacing: 10) {
                                HStack {
                                    Text("Cost:")
                                        .foregroundColor(.white)
                                    Text("\(gold.total)")
                                        .foregroundColor(goldColor)
                                        .fontWeight(.bold)
                                }

                                HStack {
                                    Text("Sell:")
                                        .foregroundColor(.white)
                                    Text("\(gold.sell)")
                                        .foregroundColor(goldColor)
                                        .fontWeight(.bold)
                                }
                            }
                        }

                        Text(item.cleanDescription)
                            .font(.body)
                            .foregroundColor(.white)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal)
                    }
                    .padding()
                    .background(Color.black.opacity(0.8)) // Card background color
                    .cornerRadius(15) // Rounded corners
                    .shadow(color: .black.opacity(0.4), radius: 10, x: 0, y: 5) // Shadow effect

                    // Close Button
                    Button(action: {
                        isPresented = nil
                    }) {
                        Text("Close")
                            .foregroundColor(.white)
                            .padding()
                            .background(Color.red)
                            .cornerRadius(10)
                    }
                }
                .padding()
            }
        }
    }
}
