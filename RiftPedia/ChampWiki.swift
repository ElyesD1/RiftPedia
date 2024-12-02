//
//  ChampWiki.swift
//  RiftPedia
//
//  Created by Elyes Darouich on 27/11/2024.
//

import SwiftUI
import Foundation

struct ChampionData: Codable {
    let id: String
    let name: String
    let title: String
    let tags: [String]
}

struct ChampionsResponse: Codable {
    let data: [String: ChampionData]
}
import Combine

class ChampionWikiViewModel: ObservableObject {
    @Published var champions: [ChampionData] = []
    @Published var searchText: String = ""
    
    var filteredChampions: [ChampionData] {
        if searchText.isEmpty {
            return champions
        } else {
            return champions.filter { $0.name.localizedCaseInsensitiveContains(searchText) }
        }
    }
    
    func fetchChampions() {
        let version = "14.23.1" // Replace with the latest patch version
        let urlString = "https://ddragon.leagueoflegends.com/cdn/\(version)/data/en_US/champion.json"
        
        guard let url = URL(string: urlString) else {
            print("Invalid URL")
            return
        }
        
        URLSession.shared.dataTask(with: url) { [weak self] data, _, error in
            guard let data = data, error == nil else {
                print("Error fetching data: \(error?.localizedDescription ?? "Unknown error")")
                return
            }
            
            do {
                let decodedResponse = try JSONDecoder().decode(ChampionsResponse.self, from: data)
                DispatchQueue.main.async {
                    self?.champions = Array(decodedResponse.data.values).sorted(by: { $0.name < $1.name })
                }
            } catch {
                print("Error decoding JSON: \(error)")
            }
        }.resume()
    }
}




struct SearchBar: View {
    @Binding var text: String
    
    var body: some View {
        HStack {
            TextField("Search champions...", text: $text)
                .padding(8)
                .padding(.horizontal, 24)
                .background(Color.white) // Background color
                .cornerRadius(8)
                .foregroundColor(.black) // Ensures the text typed is black
                .overlay(
                    HStack {
                        Image(systemName: "magnifyingglass")
                            .foregroundColor(.gray) // Icon color
                            .frame(minWidth: 0, maxWidth: .infinity, alignment: .leading)
                            .padding(.leading, 8)
                        
                        if !text.isEmpty {
                            Button(action: {
                                text = ""
                            }) {
                                Image(systemName: "xmark.circle.fill")
                                    .foregroundColor(.gray) // Clear button color
                                    .padding(.trailing, 8)
                            }
                        }
                    }
                )
                .padding(.horizontal, 10)
        }
        .padding(.vertical, 5)
        .onAppear {
            UITextField.appearance().tintColor = .gray // Placeholder text color
        }
    }
}

struct ChampWiki: View {
    @StateObject private var viewModel = ChampionWikiViewModel()
    
    var body: some View {
        ZStack {
            Color("Background") // Background color for the entire screen
                .edgesIgnoringSafeArea(.all)
            
            VStack {
                // Title Text
                Text("Champion Wiki")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .foregroundColor(Color.white)
                    .padding(.top, 20)
                
                // Search Bar
                SearchBar(text: $viewModel.searchText)
                
                // List of champions
                List(viewModel.filteredChampions, id: \.id) { champion in
                    NavigationLink(destination: ChampDet(championId: champion.id, championName: champion.name)) {
                        HStack(spacing: 8) { // Reduced spacing from 16 to 8
                            // Champion Image
                            AsyncImage(url: URL(string: "https://ddragon.leagueoflegends.com/cdn/14.23.1/img/champion/\(champion.id).png")) { image in
                                image.resizable()
                                    .scaledToFit()
                                    .frame(width: 50, height: 50)
                                    .cornerRadius(8)
                                    .frame(maxWidth: 50, alignment: .leading) // Ensure the image stays at the left
                            } placeholder: {
                                ProgressView()
                            }
                            
                            VStack(alignment: .leading, spacing: 4) {
                                Text(champion.name)
                                    .font(.headline)
                                    .foregroundColor(.black)
                                    .frame(maxWidth: .infinity, alignment: .leading) // Ensure name is aligned left

                                Text(champion.title.capitalized)
                                    .font(.subheadline)
                                    .foregroundColor(.gray)
                                    .frame(maxWidth: .infinity, alignment: .leading) // Ensure title is aligned left
                                
                                Text(champion.tags.joined(separator: ", "))
                                    .font(.subheadline)
                                    .foregroundColor(.gray)
                                    .frame(maxWidth: .infinity, alignment: .leading) // Ensure tags are aligned left
                            }
                            .padding(.leading, 8) // Add padding to the left side of the text container to move it slightly to the right
                        }
                        .padding(.vertical, 8) // Vertical padding to add spacing between rows
                        .frame(maxWidth: .infinity, alignment: .leading) // Ensures background fills the whole row
                         // Set cell background color to "Background"
                        .cornerRadius(8) // Optional rounded corners
                       
                        .padding(.horizontal, 8) // Padding to avoid content hitting the edges
                    }
                   
                }
               
            }
        }
        .onAppear {
            viewModel.fetchChampions()
        }
    }
}

#Preview {
    ChampWiki()
}
