import SwiftUI
import Foundation

// Item structure (Updated to include "from" and "into" properties)
struct ItemStruct: Codable, Identifiable {
    let name: String
    let description: String?
    let image: ImageData
    let gold: Gold?
    let from: [String]?
    let into: [String]?

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
        NavigationView {
            ZStack {
                Color("Background")
                    .ignoresSafeArea()

                VStack(spacing: 10) {
                    TextField("Search items...", text: $viewModel.searchQuery)
                        .padding()
                        .background(Color.white)
                        .cornerRadius(10)
                        .foregroundColor(.black)
                        .padding(.horizontal)

                    Text("Item Wiki")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                        .foregroundColor(.white)

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
                                                    NavigationLink(destination: ItemDetailView(item: item, items: viewModel.items)) {
                                                        VStack(spacing: 4) {
                                                            Image(item.id)
                                                                .resizable()
                                                                .scaledToFit()
                                                                .frame(width: 50, height: 50)
                                                                .cornerRadius(10)

                                                            Text(item.cleanName())
                                                                .font(.caption)
                                                                .foregroundColor(.white)
                                                        }
                                                        .padding(5)
                                                        .background(Color.black.opacity(0.8))
                                                        .cornerRadius(8)
                                                    }
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
            }
            .onAppear {
                viewModel.fetchItemsAndCategories()
            }
        }
    }
}

// Item Detail View
struct ItemDetailView: View {
    let item: ItemStruct
    let items: [String: ItemStruct]

    var body: some View {
        ZStack {
            Color("Background")
                .ignoresSafeArea()

            ScrollView {
                VStack(spacing: 20) {
                    // Card for Item Details
                    VStack(spacing: 10) {
                        Image(item.id)
                            .resizable()
                            .scaledToFit()
                            .frame(width: 100, height: 100)
                            .cornerRadius(10)

                        Text(item.cleanName())
                            .font(.title)
                            .foregroundColor(.white)

                        Text(item.cleanDescription)
                            .foregroundColor(.white)
                    }
                    .padding()
                    .background(Color.black.opacity(0.8))
                    .cornerRadius(15)
                    .shadow(radius: 10)

                    // Card for Gold Details
                    if let gold = item.gold {
                        VStack(alignment: .leading, spacing: 10) {
                            HStack {
                                Text("Price: ")
                                    .font(.headline)
                                    .foregroundColor(.yellow)
                                Text("\(gold.total)")
                                    .font(.headline)
                                    .foregroundColor(.yellow)
                            }

                            HStack {
                                Text("Sell: ")
                                    .font(.headline)
                                    .foregroundColor(.yellow)
                                Text("\(gold.sell)")
                                    .font(.headline)
                                    .foregroundColor(.yellow)
                            }
                        }
                        .padding()
                        .background(Color.black.opacity(0.8))
                        .cornerRadius(15)
                        .shadow(radius: 10)
                    }

                    // Built From Section inside a card
                    if let from = item.from, !from.isEmpty {
                        VStack(alignment: .leading, spacing: 10) {
                            Text("Built From:")
                                .font(.headline)
                                .foregroundColor(.white)

                            LazyVGrid(columns: [GridItem(.adaptive(minimum: 80))], spacing: 10) {
                                ForEach(from.indices, id: \.self) { index in
                                    let itemId = from[index]
                                    if let fromItem = items[itemId] {
                                        VStack {
                                            Image(fromItem.id)
                                                .resizable()
                                                .scaledToFit()
                                                .frame(width: 50, height: 50)

                                            Text(fromItem.cleanName())
                                                .font(.caption)
                                                .foregroundColor(.white)
                                        }
                                    }
                                }
                            }
                        }
                        .padding()
                        .background(Color.black.opacity(0.8))
                        .cornerRadius(15)
                        .shadow(radius: 10)
                    }

                    // Builds Into Section inside a card
                    if let into = item.into, !into.isEmpty {
                        VStack(alignment: .leading, spacing: 10) {
                            Text("Builds Into:")
                                .font(.headline)
                                .foregroundColor(.white)

                            LazyVGrid(columns: [GridItem(.adaptive(minimum: 80))], spacing: 10) {
                                ForEach(into.indices, id: \.self) { index in
                                    let itemId = into[index]
                                    if let intoItem = items[itemId] {
                                        VStack {
                                            Image(intoItem.id)
                                                .resizable()
                                                .scaledToFit()
                                                .frame(width: 50, height: 50)

                                            Text(intoItem.cleanName())
                                                .font(.caption)
                                                .foregroundColor(.white)
                                        }
                                    }
                                }
                            }
                        }
                        .padding()
                        .background(Color.black.opacity(0.8))
                        .cornerRadius(15)
                        .shadow(radius: 10)
                    }
                }
                .padding()
            }
        }
        .navigationBarBackButtonHidden(false) // Ensures the back button is visible
    }
}
