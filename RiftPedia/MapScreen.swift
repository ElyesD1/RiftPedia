import SwiftUI
import CoreGraphics

// MARK: - Models
struct Region: Identifiable {
    let id = UUID()
    let name: String
    let iconName: String
    let coordinates: CGPoint
}

struct Champion: Identifiable {
    let id = UUID()
    let name: String
    let iconName: String
}
extension CGSize {
    static func +(lhs: CGSize, rhs: CGSize) -> CGSize {
        return CGSize(width: lhs.width + rhs.width, height: lhs.height + rhs.height)
    }
}
// MARK: - Main View
struct MapScreen: View {
    let mapSize = CGSize(width: 1421, height: 1100)
    let regions = [
        Region(name: "Freljord", iconName: "Freljord", coordinates: CGPoint(x: 359, y: 223)),
        Region(name: "Noxus", iconName: "Noxus", coordinates: CGPoint(x: 655, y: 352)),
        Region(name: "Demacia", iconName: "Demacia", coordinates: CGPoint(x: 298, y: 425)),
        Region(name: "Ionia", iconName: "Ionia", coordinates: CGPoint(x: 1129, y: 282)),
        Region(name: "Bilgewater", iconName: "Bilgewater", coordinates: CGPoint(x: 1113, y: 634)),
        Region(name: "Shadow Isles", iconName: "Shadow_Isles", coordinates: CGPoint(x: 1290, y: 824)),
        Region(name: "Ixtal", iconName: "Ixtal", coordinates: CGPoint(x: 906, y: 745)),
        Region(name: "Piltover", iconName: "Piltover", coordinates: CGPoint(x: 826, y: 535)),
        Region(name: "Zaun", iconName: "Zaun", coordinates: CGPoint(x: 826, y: 610)),
        Region(name: "Shurima", iconName: "Shurima", coordinates: CGPoint(x: 709, y: 793)),
        Region(name: "Targon", iconName: "Mount_Targon", coordinates: CGPoint(x: 457, y: 841)),
        Region(name: "The Void", iconName: "The Void", coordinates: CGPoint(x: 892, y: 920)),
        Region(name: "Bandle City", iconName: "Bandle city", coordinates: CGPoint(x: 832, y: 830))
    ]

    @State private var zoomScale: CGFloat = 1.0
    @State private var offset: CGSize = .zero
    @GestureState private var magnifyBy: CGFloat = 1.0
    @State private var selectedRegion: Region?

    var body: some View {
        VStack {
            ZStack {
                Color.gray.ignoresSafeArea()

                GeometryReader { geometry in
                    let screenSize = geometry.size
                    let maxOffset = calculateMaxOffset(screenSize: screenSize)

                    ZStack {
                        Image("runeterra")
                            .resizable()
                            .scaledToFit()
                            .frame(width: mapSize.width * zoomScale, height: mapSize.height * zoomScale)
                            .position(x: screenSize.width / 2 + offset.width,
                                      y: screenSize.height / 2 + offset.height)

                        ForEach(computedRegions(screenSize: screenSize)) { region in
                            RegionView(region: region)
                                .position(x: region.coordinates.x, y: region.coordinates.y)
                                .onTapGesture {
                                    selectedRegion = region
                                }
                        }
                    }
                    .gesture(dragGesture(screenSize: screenSize, maxOffset: maxOffset)
                                .simultaneously(with: magnificationGesture(screenSize: screenSize)))
                }
            }
            .sheet(item: $selectedRegion) { region in
                ChampionListView(region: region, champions: championsForRegion(region.name))
            }

            // Zoom Slider
            Slider(value: $zoomScale, in: 1.0...3.0, step: 0.1)
                .padding()
                .accentColor(Color("Button"))
                .onChange(of: zoomScale) { _ in
                    // Adjust offset when zoom scale changes
                    if let geometry = UIApplication.shared.windows.first?.rootViewController?.view {
                        let screenSize = geometry.bounds.size
                        offset = clampOffset(offset, maxOffset: calculateMaxOffset(screenSize: screenSize))
                    }
                }
        }
    }

    // MARK: - Gestures
    private func dragGesture(screenSize: CGSize, maxOffset: CGSize) -> some Gesture {
        DragGesture()
            .onChanged { value in
                let scaledTranslation = CGSize(
                    width: value.translation.width * 0.2,
                    height: value.translation.height * 0.2
                )
                offset = clampOffset(offset + scaledTranslation, maxOffset: maxOffset)
            }
    }

    private func magnificationGesture(screenSize: CGSize) -> some Gesture {
        MagnificationGesture()
            .updating($magnifyBy) { value, state, _ in
                state = value
            }
            .onEnded { value in
                zoomScale = min(max(zoomScale * value, 1.0), 3.0)
                offset = clampOffset(offset, maxOffset: calculateMaxOffset(screenSize: screenSize))
            }
    }

    // MARK: - Helpers
    private func computedRegions(screenSize: CGSize) -> [Region] {
        regions.map { region in
            let x = region.coordinates.x * zoomScale + offset.width + screenSize.width / 2 - (mapSize.width * zoomScale / 2)
            let y = region.coordinates.y * zoomScale + offset.height + screenSize.height / 2 - (mapSize.height * zoomScale / 2)
            return Region(name: region.name, iconName: region.iconName, coordinates: CGPoint(x: x, y: y))
        }
    }

    private func calculateMaxOffset(screenSize: CGSize) -> CGSize {
        let scaledWidth = mapSize.width * zoomScale
        let scaledHeight = mapSize.height * zoomScale
        let maxWidth = max((scaledWidth - screenSize.width) / 2, 0)
        let maxHeight = max((scaledHeight - screenSize.height) / 2, 0)
        return CGSize(width: maxWidth, height: maxHeight)
    }

    private func clampOffset(_ offset: CGSize, maxOffset: CGSize) -> CGSize {
        CGSize(
            width: max(-maxOffset.width, min(maxOffset.width, offset.width)),
            height: max(-maxOffset.height, min(maxOffset.height, offset.height))
        )
    }


    private func championsForRegion(_ region: String) -> [Champion] {
        switch region {
        case "Freljord":
               return [
                   Champion(name: "Ashe", iconName: "Ashe"),
                   Champion(name: "Anivia", iconName: "Anivia"),
                   Champion(name: "Aurora", iconName: "Aurora"),
                   Champion(name: "Braum", iconName: "Braum"),
                   Champion(name: "Gnar", iconName: "Gnar"),
                   Champion(name: "Gragas", iconName: "Gragas"),
                   Champion(name: "Lissandra", iconName: "Lissandra"),
                   Champion(name: "Nunu", iconName: "Nunu"),
                   Champion(name: "Olaf", iconName: "Olaf"),
                   Champion(name: "Ornn", iconName: "Ornn"),
                   Champion(name: "Sejuani", iconName: "Sejuani"),
                   Champion(name: "Trundle", iconName: "Trundle"),
                   Champion(name: "Tryndamere", iconName: "Tryndamere"),
                   Champion(name: "Udyr", iconName: "Udyr"),
                   Champion(name: "Volibear", iconName: "Volibear")
               ]      case "Noxus":
            return [
                Champion(name: "Ambessa", iconName: "Ambessa"),
                Champion(name: "Briar", iconName: "Briar"),
                Champion(name: "Cassiopeia", iconName: "Cassiopeia"),
                Champion(name: "Darius", iconName: "Darius"),
                Champion(name: "Draven", iconName: "Draven"),
                Champion(name: "Elise", iconName: "Elise"),
                Champion(name: "Katarina", iconName: "Katarina"),
                Champion(name: "Kled", iconName: "Kled"),
                Champion(name: "Leblanc", iconName: "LeBlanc"),
                Champion(name: "Mordekaiser", iconName: "Mordekaiser"),
                Champion(name: "Rell", iconName: "Rell"),
                Champion(name: "Riven", iconName: "Riven"),
                Champion(name: "Samira", iconName: "Samira"),
                Champion(name: "Sion", iconName: "Sion"),
                Champion(name: "Smolder", iconName: "Smolder"),
                Champion(name: "Swain", iconName: "Swain"),
                Champion(name: "Talon", iconName: "Talon"),
                Champion(name: "Vladimir", iconName: "Vladimir")
            ]
        case "Ionia":
            return [
                Champion(name: "Ahri", iconName: "Ahri"),
                Champion(name: "Akali", iconName: "Akali"),
                Champion(name: "Hwei", iconName: "Hwei"),
                Champion(name: "Irelia", iconName: "Irelia"),
                Champion(name: "Ivern", iconName: "Ivern"),
                Champion(name: "Jhin", iconName: "Jhin"),
                Champion(name: "Karma", iconName: "Karma"),
                Champion(name: "Kayn", iconName: "Kayn"),
                Champion(name: "Kennen", iconName: "Kennen"),
                Champion(name: "LeeSin", iconName: "Lee Sin"),
                Champion(name: "Lillia", iconName: "Lillia"),
                Champion(name: "MasterYi", iconName: "Master Yi"),
                Champion(name: "Rakan", iconName: "Rakan"),
                Champion(name: "Sett", iconName: "Sett"),
                Champion(name: "Shen", iconName: "Shen"),
                Champion(name: "Syndra", iconName: "Syndra"),
                Champion(name: "Varus", iconName: "Varus"),
                Champion(name: "MonkeyKing", iconName: "Wukong"),
                Champion(name: "Xayah", iconName: "Xayah"),
                Champion(name: "Yasuo", iconName: "Yasuo"),
                Champion(name: "Yone", iconName: "Yone"),
                Champion(name: "Zed", iconName: "Zed")
            ]
        case "Shurima":
            return [
                Champion(name: "Akshan", iconName: "Akshan"),
                Champion(name: "Amumu", iconName: "Amumu"),
                Champion(name: "Azir", iconName: "Azir"),
                Champion(name: "Naafiri", iconName: "Naafiri"),
                Champion(name: "Nasus", iconName: "Nasus"),
                Champion(name: "Rammus", iconName: "Rammus"),
                Champion(name: "Renekton", iconName: "Renekton"),
                Champion(name: "Rengar", iconName: "Rengar"),
                Champion(name: "Sivir", iconName: "Sivir"),
                Champion(name: "Taliyah", iconName: "Taliyah"),
                Champion(name: "Xerath", iconName: "Xerath"),
                Champion(name: "Zilean", iconName: "Zilean")
            ]
        case "The Void":
            return [
                Champion(name: "Belveth", iconName: "Bel'Veth"),
                Champion(name: "Chogath", iconName: "Cho'Gath"),
                Champion(name: "Kaisa", iconName: "Kai'Sa"),
                Champion(name: "Kassadin", iconName: "Kassadin"),
                Champion(name: "Khazix", iconName: "Kha'Zix"),
                Champion(name: "KogMaw", iconName: "Kog'Maw"),
                Champion(name: "Malzahar", iconName: "Malzahar"),
                Champion(name: "RekSai", iconName: "Rek'Sai"),
                Champion(name: "Velkoz", iconName: "Vel'Koz")
            ]
        case "Targon":
            return [
                Champion(name: "Aphelios", iconName: "Aphelios"),
                Champion(name: "AurelionSol", iconName: "Aurelion Sol"),
                Champion(name: "Diana", iconName: "Diana"),
                Champion(name: "Leona", iconName: "Leona"),
                Champion(name: "Pantheon", iconName: "Pantheon"),
                Champion(name: "Soraka", iconName: "Soraka"),
                Champion(name: "Taric", iconName: "Taric"),
                Champion(name: "Zoe", iconName: "Zoe")
            ]
        case "Ixtal":
            return [
                Champion(name: "Malphite", iconName: "Malphite"),
                Champion(name: "Milio", iconName: "Milio"),
                Champion(name: "Neeko", iconName: "Neeko"),
                Champion(name: "Nidalee", iconName: "Nidalee"),
                Champion(name: "Qiyana", iconName: "Qiyana"),
                Champion(name: "Rengar", iconName: "Rengar"),
                Champion(name: "Skarner", iconName: "Skarner"),
                Champion(name: "Zyra", iconName: "Zyra")
            ]
        case "Piltover":
            return [
                Champion(name: "Caitlyn", iconName: "Caitlyn"),
                Champion(name: "Camille", iconName: "Camille"),
                Champion(name: "Ezreal", iconName: "Ezreal"),
                Champion(name: "Heimerdinger", iconName: "Heimerdinger"),
                Champion(name: "Jayce", iconName: "Jayce"),
                Champion(name: "Orianna", iconName: "Orianna"),
                Champion(name: "Seraphine", iconName: "Seraphine"),
                Champion(name: "Vi", iconName: "Vi")
            ]
        case "Bandle City":
            return [
                Champion(name: "Corki", iconName: "Corki"),
                Champion(name: "Lulu", iconName: "Lulu"),
                Champion(name: "Rumble", iconName: "Rumble"),
                Champion(name: "Teemo", iconName: "Teemo"),
                Champion(name: "Tristana", iconName: "Tristana"),
                Champion(name: "Veigar", iconName: "Veigar"),
                Champion(name: "Yuumi", iconName: "Yuumi")
            ]
        case "Shadow Isles":
            return [
                Champion(name: "Gwen", iconName: "Gwen"),
                Champion(name: "Hecarim", iconName: "Hecarim"),
                Champion(name: "Kalista", iconName: "Kalista"),
                Champion(name: "Karthus", iconName: "Karthus"),
                Champion(name: "Maokai", iconName: "Maokai"),
                Champion(name: "Senna", iconName: "Senna"),
                Champion(name: "Thresh", iconName: "Thresh"),
                Champion(name: "Vex", iconName: "Vex"),
                Champion(name: "Viego", iconName: "Viego"),
                Champion(name: "Yorick", iconName: "Yorick")
            ]
        case "Bilgewater":
            return [
                Champion(name: "Fizz", iconName: "Fizz"),
                Champion(name: "Gangplank", iconName: "Gangplank"),
                Champion(name: "Graves", iconName: "Graves"),
                Champion(name: "Illaoi", iconName: "Illaoi"),
                Champion(name: "MissFortune", iconName: "Miss Fortune"),
                Champion(name: "Nautilus", iconName: "Nautilus"),
                Champion(name: "TahmKench", iconName: "Tahm Kench"),
                Champion(name: "Pyke", iconName: "Pyke"),
                Champion(name: "TwistedFate", iconName: "Twisted Fate")
            ]
        case "Zaun":
            return [
                Champion(name: "Blitzcrank", iconName: "Blitzcrank"),
                Champion(name: "DrMundo", iconName: "Dr Mundo"),
                Champion(name: "Ekko", iconName: "Ekko"),
                Champion(name: "Janna", iconName: "Janna"),
                Champion(name: "Jinx", iconName: "Jinx"),
                Champion(name: "Renata", iconName: "Renata Glasc"),
                Champion(name: "Singed", iconName: "Singed"),
                Champion(name: "Twitch", iconName: "Twitch"),
                Champion(name: "Urgot", iconName: "Urgot"),
                Champion(name: "Viktor", iconName: "Viktor"),
                Champion(name: "Warwick", iconName: "Warwick"),
                Champion(name: "Zac", iconName: "Zac"),
                Champion(name: "Zeri", iconName: "Zeri"),
                Champion(name: "Ziggs", iconName: "Ziggs")
            ]
        case "Demacia":
                return [
                    Champion(name: "Fiora", iconName: "Fiora"),
                    Champion(name: "Galio", iconName: "Galio"),
                    Champion(name: "Garen", iconName: "Garen"),
                    Champion(name: "JarvanIV", iconName: "Jarvan IV"),
                    Champion(name: "Kayle", iconName: "Kayle"),
                    Champion(name: "Lucian", iconName: "Lucian"),
                    Champion(name: "Lux", iconName: "Lux"),
                    Champion(name: "Morgana", iconName: "Morgana"),
                    Champion(name: "Poppy", iconName: "Poppy"),
                    Champion(name: "Quinn", iconName: "Quinn"),
                    Champion(name: "Shyvana", iconName: "Shyvana"),
                    Champion(name: "Sona", iconName: "Sona"),
                    Champion(name: "Sylas", iconName: "Sylas"),
                    Champion(name: "Vayne", iconName: "Vayne"),
                    Champion(name: "XinZhao", iconName: "Xin Zhao")
                ]
        default:
            return []
        }
    }
}

// MARK: - Region View
struct RegionView: View {
    let region: Region

    var body: some View {
        VStack {
            Image(region.iconName)
                .resizable()
                .scaledToFit()
                .frame(width: 28, height: 28) // Icon size
                .background(Circle().fill(Color("Background")).frame(width: 50, height: 50)) // Larger circle than the icon
                 // Circle border
                 // Ensures the image stays within the circular border
            
            Text(region.name)
                .font(.headline)
                .foregroundColor(.white)
        }
    }
}
// MARK: - Champion List View




struct ChampionListView: View {
    let region: Region
    let champions: [Champion]
    
    @Environment(\.dismiss) var dismiss
    @StateObject private var viewModel = ChampionListViewModel()

    var body: some View {
        VStack(spacing: 20) {
            Text(region.name)
                .font(.largeTitle)
                .bold()
                .foregroundColor(Color("Button"))
                .padding(.top)

            ScrollView {
                VStack(spacing: 15) {
                    ForEach(champions) { champion in
                        VStack(alignment: .leading, spacing: 8) { // Dynamic vertical alignment
                            HStack {
                                Image(champion.iconName)
                                    .resizable()
                                    .frame(width: 60, height: 60)
                                
                                VStack(alignment: .leading, spacing: 4) {
                                    Text(champion.name)
                                        .font(.headline)
                                        .foregroundColor(.white)
                                    
                                    if let details = viewModel.championDetails[champion.name] {
                                        Text(details.title)
                                            .font(.subheadline)
                                            .foregroundColor(.gray)
                                        
                                        Text(details.tags.joined(separator: ", "))
                                            .font(.subheadline)
                                            .foregroundColor(.gray)
                                    } else {
                                        Text("Loading details...")
                                            .font(.subheadline)
                                            .foregroundColor(.gray)
                                    }
                                }
                                Spacer()
                            }

                            if let details = viewModel.championDetails[champion.name] {
                                Text(details.blurb)
                                    .font(.footnote)
                                    .foregroundColor(.gray)
                                    .multilineTextAlignment(.leading) // Ensure multi-line rendering
                            }
                        }
                        .padding()
                        .background(Color.appBackground.opacity(10)) // Optional for better appearance
                        .cornerRadius(10) // Rounded corners
                        .shadow(color: .black.opacity(0.2), radius: 4, x: 0, y: 2)
                    }
                }
                .padding(.horizontal)
            }

            Button(action: {
                dismiss()
            }) {
                Text("Return")
                    .font(.headline)
                    .foregroundColor(.black)
                    .padding()
                    .background(Color("Button"))
                    .cornerRadius(10)
            }
            .padding(.bottom)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color("Background").ignoresSafeArea())
        .onAppear {
            viewModel.fetchChampionDetails(champions: champions)
        }
    }
}
import Foundation

class ChampionListViewModel: ObservableObject {
    @Published var championDetails: [String: ChampionDetails] = [:]
    
    // Replace the network call with a local file read
    func fetchChampionDetails(champions: [Champion]) {
        guard let url = Bundle.main.url(forResource: "champion", withExtension: "json") else {
            print("champion.json file not found in the bundle")
            return
        }
        
        do {
            let data = try Data(contentsOf: url)
            let decoded = try JSONDecoder().decode(ChampionAPIResponse.self, from: data)
            
            // Now, filter and load only the champions we are interested in
            DispatchQueue.main.async {
                for champion in champions {
                    if let championData = decoded.data[champion.name] {
                        self.championDetails[champion.name] = championData
                    }
                }
            }
        } catch {
            print("Error reading or decoding champion.json: \(error)")
        }
    }
}


// MARK: - Models
struct ChampionAPIResponse: Codable {
    let data: [String: ChampionDetails]
}

struct ChampionDetails: Codable {
    let title: String
    let tags: [String]
    let blurb: String // Champion description
}
