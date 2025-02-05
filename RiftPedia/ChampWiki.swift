//
//  ChampWiki.swift
//  RiftPedia
//
//  Created by Elyes Darouich on 27/11/2024.
//
import SwiftUI
import Foundation
import Combine

struct ChampionData: Codable {
    let id: String
    let name: String
    let title: String
    let tags: [String]
}

struct ChampionsResponse: Codable {
    let data: [String: ChampionData]
}

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
        // Load champions from the local JSON file
        guard let url = Bundle.main.url(forResource: "champion", withExtension: "json") else {
            print("champion.json file not found")
            return
        }
        
        do {
            let data = try Data(contentsOf: url)
            let decodedResponse = try JSONDecoder().decode(ChampionsResponse.self, from: data)
            DispatchQueue.main.async {
                self.champions = Array(decodedResponse.data.values).sorted(by: { $0.name < $1.name })
            }
        } catch {
            print("Error loading champion data: \(error)")
        }
    }
}


struct SearchBar: View {
    @Binding var text: String
    
    var body: some View {
        HStack {
            TextField("Search champions...", text: $text)
                .padding(8)
                .padding(.horizontal, 24)
                .background(Color(UIColor.systemBackground))
                .cornerRadius(12)
                .shadow(color: Color.black.opacity(0.1), radius: 5, x: 0, y: 2)
                .overlay(
                    HStack {
                        Image(systemName: "magnifyingglass")
                            .foregroundColor(.gray)
                            .frame(minWidth: 0, maxWidth: .infinity, alignment: .leading)
                            .padding(.leading, 8)
                        
                        if !text.isEmpty {
                            Button(action: { text = "" }) {
                                Image(systemName: "xmark.circle.fill")
                                    .foregroundColor(.gray)
                                    .padding(.trailing, 8)
                            }
                        }
                    }
                )
                .padding(.horizontal, 16)
        }
        .padding(.vertical, 8)
    }
}

struct ChampionCards: View {
    let champion: ChampionData
    
    var body: some View {
        HStack(spacing: 12) {
            if let image = UIImage(named: "\(champion.id)") {
                Image(uiImage: image)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 60, height: 60)
                    .cornerRadius(12)
                    .shadow(color: Color.black.opacity(0.1), radius: 4, x: 0, y: 2)
            } else {
                ProgressView()
                    .frame(width: 60, height: 60)
            }
            
            VStack(alignment: .leading, spacing: 4) {
                Text(champion.name)
                    .font(.system(size: 18, weight: .bold))
                    .foregroundColor(Color(UIColor.label))
                
                Text(champion.title.capitalized)
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(Color(UIColor.secondaryLabel))
                
                HStack(spacing: 6) {
                    ForEach(champion.tags, id: \.self) { tag in
                        Text(tag)
                            .font(.system(size: 12, weight: .medium))
                            .padding(.horizontal, 8)
                            .padding(.vertical, 4)
                            .background(Color.blue.opacity(0.1))
                            .foregroundColor(.blue)
                            .cornerRadius(8)
                    }
                }
            }
            
            Spacer()
            
            Image(systemName: "chevron.right")
                .foregroundColor(Color(UIColor.tertiaryLabel))
                .font(.system(size: 14, weight: .bold))
        }
        .padding(.vertical, 12)
        .padding(.horizontal, 16)
        .background(Color(UIColor.secondarySystemBackground))
        .cornerRadius(16)
        .shadow(color: Color.black.opacity(0.05), radius: 8, x: 0, y: 4)
    }
}

struct ChampWiki: View {
    @StateObject private var viewModel = ChampionWikiViewModel()
    
    var body: some View {
        ZStack {
            Color(UIColor.systemBackground)
                .edgesIgnoringSafeArea(.all)
            
            VStack(spacing: 16) {
                Text("Champion Wiki")
                    .font(.system(size: 32, weight: .bold))
                    .foregroundColor(Color(UIColor.label))
                    .padding(.top, 24)
                
                SearchBar(text: $viewModel.searchText)
                
                ScrollView {
                    LazyVStack(spacing: 12) {
                        ForEach(viewModel.filteredChampions, id: \.id) { champion in
                            NavigationLink(destination: ChampDet(championId: champion.id, championName: champion.name)) {
                                ChampionCards(champion: champion)
                            }
                            .buttonStyle(PlainButtonStyle())
                        }
                    }
                    .padding(.horizontal, 16)
                    .padding(.bottom, 24)
                }
            }
        }
        .onAppear {
            viewModel.fetchChampions()
        }
    }
}
