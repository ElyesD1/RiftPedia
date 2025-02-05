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
                  
                  VStack(spacing: 16) {
                      // Enhanced Search Bar
                      HStack {
                          Image(systemName: "magnifyingglass")
                              .foregroundColor(.gray)
                              .font(.system(size: 18))
                          
                          TextField("Search items...", text: $viewModel.searchQuery)
                              .font(.system(size: 16))
                      }
                      .padding(12)
                      .background(
                          RoundedRectangle(cornerRadius: 15)
                              .fill(Color.white.opacity(0.95))
                              .shadow(color: .black.opacity(0.1), radius: 5, x: 0, y: 2)
                      )
                      .padding(.horizontal)
                      
                      // Enhanced Title
                      Text("Item Wiki")
                          .font(.system(size: 36, weight: .bold))
                          .foregroundColor(.white)
                          .shadow(color: Color("Button").opacity(0.5), radius: 2)
                      
                      // Enhanced ScrollView
                      ScrollView {
                          LazyVStack(alignment: .leading, spacing: 24) {
                              ForEach(categoryOrder, id: \.self) { category in
                                  if let itemIds = viewModel.categorizedItems[category], !itemIds.isEmpty {
                                      CategorySection(
                                          category: category,
                                          itemIds: itemIds,
                                          viewModel: viewModel,
                                          gridColumns: gridColumns
                                      )
                                  }
                              }
                          }
                          .padding(.bottom, 20)
                      }
                  }
                  .padding(.top, 8)
              }
              .onAppear {
                  viewModel.fetchItemsAndCategories()
              }
          }
      }
  }

  // Helper Views
  struct CategorySection: View {
      let category: String
      let itemIds: [String]
      let viewModel: ItemWikiViewModel
      let gridColumns: [GridItem]
      
      var body: some View {
          VStack(alignment: .leading, spacing: 12) {
              // Enhanced Category Header
              Text(category)
                  .font(.system(size: 20, weight: .bold))
                  .foregroundColor(.white)
                  .padding(.horizontal)
                  .padding(.vertical, 8)
                  .background(
                      RoundedRectangle(cornerRadius: 12)
                          .fill(Color("Button").opacity(0.2))
                  )
                  .padding(.leading)
              
              // Enhanced Grid
              LazyVGrid(columns: gridColumns, spacing: 12) {
                  ForEach(viewModel.filteredItems.keys.filter { itemIds.contains($0) }, id: \.self) { itemId in
                      if let item = viewModel.filteredItems[itemId] {
                          NavigationLink(destination: ItemDetailView(item: item, items: viewModel.items)) {
                              ItemGridCell(item: item)
                          }
                      }
                  }
              }
              .padding(.horizontal)
          }
          .padding(.vertical, 8)
      }
  }

  struct ItemGridCell: View {
      let item: ItemStruct
      @State private var isHovered = false
      
      var body: some View {
          VStack(spacing: 6) {
              Image(item.id)
                  .resizable()
                  .scaledToFit()
                  .frame(width: 55, height: 55)
                  .padding(8)
                  .background(
                      RoundedRectangle(cornerRadius: 12)
                          .fill(Color.black.opacity(0.6))
                          .shadow(color: Color("Button").opacity(0.3), radius: 5)
                  )
                  .overlay(
                      RoundedRectangle(cornerRadius: 12)
                          .stroke(Color("Button").opacity(0.3), lineWidth: 1)
                  )
              
              Text(item.cleanName())
                  .font(.system(size: 12, weight: .medium))
                  .foregroundColor(.white)
                  .lineLimit(2)
                  .multilineTextAlignment(.center)
          }
          .frame(width: 80)
          .padding(8)
          .background(
              RoundedRectangle(cornerRadius: 15)
                  .fill(Color.black.opacity(0.3))
          )
          .scaleEffect(isHovered ? 1.05 : 1.0)
          .animation(.spring(response: 0.3, dampingFraction: 0.6), value: isHovered)
          .onHover { hovering in
              isHovered = hovering
          }
      }
  }

  struct ItemDetailView: View {
      let item: ItemStruct
      let items: [String: ItemStruct]
      
      var body: some View {
          ZStack {
              // Enhanced background
              LinearGradient(
                  gradient: Gradient(colors: [
                      Color("Background"),
                      Color("Background").opacity(0.9)
                  ]),
                  startPoint: .top,
                  endPoint: .bottom
              )
              .ignoresSafeArea()
              
              ScrollView {
                  VStack(spacing: 24) {
                      // Enhanced Item Header
                      VStack(spacing: 16) {
                          Image(item.id)
                              .resizable()
                              .scaledToFit()
                              .frame(width: 120, height: 120)
                              .padding(20)
                              .background(
                                  Circle()
                                      .fill(Color.black.opacity(0.6))
                                      .shadow(color: Color("Button").opacity(0.3), radius: 15)
                              )
                              .overlay(
                                  Circle()
                                      .stroke(Color("Button").opacity(0.3), lineWidth: 2)
                              )
                          
                          Text(item.cleanName())
                              .font(.system(size: 28, weight: .bold))
                              .foregroundColor(.white)
                              .multilineTextAlignment(.center)
                          
                          Text(item.cleanDescription)
                              .font(.system(size: 16))
                              .foregroundColor(.gray)
                              .multilineTextAlignment(.center)
                              .padding(.horizontal)
                      }
                      .padding(24)
                      .background(
                          RoundedRectangle(cornerRadius: 20)
                              .fill(Color.black.opacity(0.5))
                              .shadow(color: .black.opacity(0.2), radius: 10)
                      )
                      
                      // Enhanced Gold Info
                      if let gold = item.gold {
                          HStack(spacing: 30) {
                              VStack(spacing: 8) {
                                  Text("Buy Price")
                                      .font(.subheadline)
                                      .foregroundColor(.gray)
                                  Text("\(gold.total)")
                                      .font(.title2.bold())
                                      .foregroundColor(.yellow)
                              }
                              
                              Divider()
                                  .background(Color.gray)
                                  .frame(height: 40)
                              
                              VStack(spacing: 8) {
                                  Text("Sell Value")
                                      .font(.subheadline)
                                      .foregroundColor(.gray)
                                  Text("\(gold.sell)")
                                      .font(.title2.bold())
                                      .foregroundColor(.yellow)
                              }
                          }
                          .padding(20)
                          .background(
                              RoundedRectangle(cornerRadius: 20)
                                  .fill(Color.black.opacity(0.5))
                                  .shadow(color: .black.opacity(0.2), radius: 10)
                          )
                      }
                      
                      // Recipe Sections
                      if let from = item.from, !from.isEmpty {
                          RecipeSection(title: "Built From", items: from.compactMap { items[$0] })
                      }
                      
                      if let into = item.into, !into.isEmpty {
                          RecipeSection(title: "Builds Into", items: into.compactMap { items[$0] })
                      }
                  }
                  .padding()
              }
          }
      }
  }

struct RecipeSection: View {
    let title: String
    let items: [ItemStruct]
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text(title)
                .font(.title3.bold())
                .foregroundColor(.white)
            
            LazyVGrid(columns: [GridItem(.adaptive(minimum: 80))], spacing: 16) {
                // Create enumerated array to use index in identifier
                ForEach(Array(zip(items.indices, items)), id: \.0) { index, item in
                    VStack(spacing: 8) {
                        Image(item.id)
                            .resizable()
                            .scaledToFit()
                            .frame(width: 50, height: 50)
                            .padding(8)
                            .background(
                                RoundedRectangle(cornerRadius: 12)
                                    .fill(Color.black.opacity(0.4))
                            )
                            .overlay(
                                RoundedRectangle(cornerRadius: 12)
                                    .stroke(Color("Button").opacity(0.3), lineWidth: 1)
                            )
                        
                        Text(item.cleanName())
                            .font(.caption)
                            .foregroundColor(.white)
                            .multilineTextAlignment(.center)
                            
                       
                    }
                }
            }
        }
        .padding(20)
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(Color.black.opacity(0.5))
                .shadow(color: .black.opacity(0.2), radius: 10)
        )
    }
    
    // Helper function to count occurrences of an item
    private func countOccurrences(of item: ItemStruct, in items: [ItemStruct]) -> Int {
        items.filter { $0.id == item.id }.count
    }
}
