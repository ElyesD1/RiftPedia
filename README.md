# League of Legends Match Tracker

This project is a **League of Legends Match Tracker** application built using SwiftUI, which allows users to view detailed statistics about their recent matches. The app fetches match data from the League of Legends API and displays key information such as champion performance, match results, items, runes, and summoner spells used in the game.

## Features

- **Champion Performance**: View detailed statistics such as kills, deaths, assists, and win/loss status.
- **Champion Icon**: Displays the champion's icon for quick visual reference.
- **Game Mode**: Shows the type of game mode (e.g., Summoner’s Rift, ARAM, etc.).
- **Game Duration**: Displays the length of the match.
- **Item and Rune Information**: Shows items purchased during the match and the runes selected by the player.
- **Summoner Spells**: Displays the summoner spells used during the match.
- **Position Mapping**: Displays the individual position (Top, Jungle, Mid, etc.) of the player in the match.

## Technologies Used

- **SwiftUI**: Framework for building the user interface, providing a declarative Swift-based way to build the UI.
- **AsyncImage**: Used for loading images asynchronously, such as champion icons and item images.
- **Combine**: For reactive programming, allowing the app to respond to state changes in a declarative manner.
- **League of Legends API**: Used to fetch match statistics, champion details, and game data.

## Screenshots

Here are a few screenshots of the app in action:

![Champion Performance](assets/screenshot1.png)
![Game Overview](assets/screenshot2.png)

## Installation

To run this project locally, follow these steps:

1. **Clone the repository:**
   ```bash
   git clone [https://github.com/ElyesD1/RiftPedia/new/Elyes-Darouich.git]
   ```
2. **Open the project in Xcode:**
Navigate to the project folder and open the .xcodeproj file.
3. **Run the app:**
	•	Ensure that your Xcode is set up with the latest version of Swift.
	•	Select a simulator or connect your device.
	•	Click Run to build and launch the app.

API Integration

The app fetches data from the League of Legends API, specifically using the endpoint for retrieving match history and champion statistics. To use the app, ensure you have the following:
	•	An active League of Legends account.
	•	An API key from Riot Games. (Refer to the Riot Games API documentation to create an API key).

Add the API key in the appropriate configuration file (Config.swift).

How to Use

	1.	Login: Upon launching the app, enter your summoner name to fetch your recent matches.
	2.	Match Stats: After loading the data, the app will display the champion’s performance, including the KDA (Kills, Deaths, Assists), game mode, match duration, and more.
	3.	View Items and Runes: Scroll through to see the items used during the match, as well as the selected runes and summoner spells.

Customization

	•	Map Position: The map position of the champion is displayed on the right side of the match detail. It maps raw position values to readable strings such as “Top”, “Jungle”, “Mid”, etc.
	•	Color Themes: The app dynamically changes colors based on the match result (win or loss), with blue for a win and red for a loss.

Contributing

We welcome contributions to improve the app. If you’d like to contribute, please follow these steps:
	1.	Fork the repository.
	2.	Create a new branch.
	3.	Make your changes and commit them.
	4.	Push to your forked repository.
	5.	Open a pull request with a description of the changes.

License

This project is licensed under the MIT License - see the LICENSE file for details.

Acknowledgments

	•	Riot Games: For providing the League of Legends API.
	•	SwiftUI Documentation: For the official guide and examples on how to use SwiftUI.
	•	AsyncImage: For simplifying the asynchronous image loading process.


   
