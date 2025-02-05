```markdown
<div align="center">
  <img src="assets/riftpedia_logo.png" alt="RiftPedia Logo" width="200"/>
  
  # RiftPedia: League of Legends Match Tracker
  
  [![Swift Version](https://img.shields.io/badge/Swift-5.0-orange.svg)](https://swift.org)
  [![Platform](https://img.shields.io/badge/Platform-iOS%2015.0+-blue.svg)](https://developer.apple.com/ios/)
  [![License](https://img.shields.io/badge/License-MIT-green.svg)](LICENSE)

  A comprehensive League of Legends companion app built with SwiftUI, featuring match tracking, an interactive Runeterra map, and detailed champion information.
</div>

---

## 📱 Preview

<div align="center">
  <table>
    <tr>
      <td><img src="assets/screenshot1.png" width="200"/></td>
      <td><img src="assets/screenshot2.png" width="200"/></td>
      <td><img src="assets/screenshot3.png" width="200"/></td>
    </tr>
  </table>
</div>

### 🎥 Live Demo

[![Watch Demo Video](assets/video_thumbnail.png)](https://files.fm/u/nuyr2a9vs7)

---

## ✨ Features

### 🎮 Match Tracking
- **Real-time Statistics**
  - Comprehensive KDA (Kills/Deaths/Assists) tracking
  - Detailed damage statistics
  - CS and vision score metrics
  - Gold earned and objective participation

- **Visual Match History**
  - Champion icons and played roles
  - Item builds with timestamps
  - Rune and summoner spell configurations
  - Team composition analysis

### 🗺️ Runeterra Map
- Interactive regional exploration
- Champion origin stories
- Regional lore and history
- Cultural insights and artwork

### 📚 Champion Wiki
- **Comprehensive Champion Details**
  - Ability descriptions and mechanics
  - Passive abilities and interactions
  - Role-specific strategies
  - Skin collections and previews

### 🎯 Advanced Features
- Position tracking and mapping
- Dynamic theming based on match results
- Customizable statistics display
- Intuitive navigation system

---

## 🛠️ Technical Implementation

### Architecture
```swift
// Core Architecture Pattern
MVVM + Combine
```

### Key Technologies
- **Frontend**
  - SwiftUI for UI components
  - Combine for reactive programming
  - MapKit for interactive maps
  - AsyncImage for optimized image loading

- **Backend Integration**
  - RESTful API communication
  - JSON parsing and modeling
  - Efficient caching system
  - Error handling and retry logic

### Performance Optimizations
- Lazy loading of images and content
- Efficient memory management
- Background data prefetching
- Smooth animations and transitions

---

## 📈 System Requirements

### Development Environment
- Xcode 14.0+
- iOS 15.0+
- Swift 5.0+
- macOS Ventura+

### Device Compatibility
- iPhone XS and newer
- iPad Air (4th generation) and newer
- Minimum iOS 15.0

---

## 🚀 Getting Started

### Installation Steps

1. **Clone the Repository**
   ```bash
   git clone https://github.com/ElyesD1/RiftPedia.git
   cd RiftPedia
   ```

2. **API Configuration**
   ```swift
   // Config.swift
   struct APIConfig {
       static let apiKey = "YOUR_RIOT_API_KEY"
       static let region = "YOUR_REGION"
   }
   ```

3. **Build and Run**
   - Open `RiftPedia.xcodeproj`
   - Select your target device
   - Press `Cmd + R` to build and run

---

## 🔧 Configuration

### API Setup
1. Visit [Riot Developer Portal](https://developer.riotgames.com)
2. Register and generate API key
3. Add key to `Config.swift`

### Customization Options
```swift
// Appearance.swift
struct AppTheme {
    static let winColor = Color("WinBlue")
    static let loseColor = Color("LoseRed")
    static let backgroundGradient = LinearGradient(...)
}
```

---

## 🤝 Contributing

We welcome contributions! Here's how you can help:

1. **Fork the Repository**
2. **Create Feature Branch**
   ```bash
   git checkout -b feature/AmazingFeature
   ```
3. **Commit Changes**
   ```bash
   git commit -m 'Add some AmazingFeature'
   ```
4. **Push to Branch**
   ```bash
   git push origin feature/AmazingFeature
   ```
5. **Open Pull Request**

---

## 📄 License

Distributed under the MIT License. See `LICENSE` for more information.

---

## 🙏 Acknowledgments

- [Riot Games API](https://developer.riotgames.com) for game data
- [SwiftUI](https://developer.apple.com/xcode/swiftui/) for the UI framework
- [Combine](https://developer.apple.com/documentation/combine) for reactive programming
- Community contributors and testers

---

<div align="center">
  
  **Made with ❤️ by [Elyes Darouich](https://github.com/ElyesD1)**
  
  [Report Bug](https://github.com/ElyesD1/RiftPedia/issues) · [Request Feature](https://github.com/ElyesD1/RiftPedia/issues)
</div>
```
