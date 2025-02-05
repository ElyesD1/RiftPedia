# League of Legends Match Tracker 🎮

[![MIT License](https://img.shields.io/badge/License-MIT-blue.svg)](LICENSE)
[![Swift](https://img.shields.io/badge/Swift-5.0-orange.svg)](https://swift.org)
[![SwiftUI](https://img.shields.io/badge/SwiftUI-3.0-blue.svg)](https://developer.apple.com/xcode/swiftui)

A powerful match tracking application for League of Legends built with SwiftUI. View detailed match statistics, explore Runeterra's regions, and dive deep into champion lore.

[Watch Demo](https://vimeo.com/1053796377/b0f02dfc44?share=copy)

## ✨ Features

### Core Functionality
- 📊 **Match Statistics** - Comprehensive performance metrics (KDA, win/loss, etc.)
- 🎯 **Position Tracking** - Visual representation of player positions
- 🛠️ **Build Analysis** - Detailed item builds, runes, and summoner spells

### Advanced Features
- 🗺️ **Runeterra Map View** - Interactive regional exploration
- 📚 **Champion Wiki** - In-depth champion information and lore
- 🎨 **Dynamic Theming** - Color schemes based on match results

## 🚀 Quick Start

### Prerequisites
- Latest version of Xcode
- League of Legends Account
- Riot Games API Key

### Installation

```bash
# Clone the repository
git clone https://github.com/ElyesD1/RiftPedia/new/Elyes-Darouich.git

# Navigate to project directory
cd RiftPedia

# Open in Xcode
open RiftPedia.xcodeproj
```

## 🔧 Configuration

1. Create `Config.swift` in the project root
2. Add your Riot Games API key:
```swift
struct Config {
    static let apiKey = "YOUR-API-KEY-HERE"
}
```

## 🛠️ Tech Stack

- **Frontend**: SwiftUI
- **Networking**: Combine Framework
- **Image Handling**: AsyncImage
- **Mapping**: MapKit
- **API**: Riot Games API

## 📱 Usage Guide

1. **Login**: Enter your summoner name
2. **Browse Matches**: View recent game history
3. **Analyze Performance**: Check detailed match statistics
4. **Explore Regions**: Use the interactive Runeterra map
5. **Study Champions**: Access the comprehensive wiki

## 🤝 Contributing

We encourage contributions! Here's how:

1. Fork the repository
2. Create your feature branch (`git checkout -b feature/AmazingFeature`)
3. Commit changes (`git commit -m 'Add AmazingFeature'`)
4. Push to branch (`git push origin feature/AmazingFeature`)
5. Open a Pull Request

## 📜 License

Distributed under the MIT License. See `LICENSE` for more information.

## 🙏 Acknowledgments

- [Riot Games API](https://developer.riotgames.com/)
- [SwiftUI Documentation](https://developer.apple.com/documentation/swiftui)
- [MapKit Documentation](https://developer.apple.com/documentation/mapkit)

---
Built with ❤️ by [ElyesD1](https://github.com/ElyesD1)
