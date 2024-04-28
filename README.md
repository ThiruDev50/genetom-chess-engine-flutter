# Genetom Chess Engine - Flutter 🚀

Welcome to the Genetom Chess Engine project! This engine supports both player vs player and player vs computer modes, providing a seamless chess playing experience.


## Demo 🎥
Check out the demo of the Genetom Chess Engine in action: [Demo Link](demo.website.com)

![Chess Engine Demo](assets/chess_engine_demo.gif)

## Features 🌟
- Play chess against another player or challenge the computer.
- The computer evaluates all possible moves to provide a challenging opponent.
- Clean and intuitive user interface built with Flutter.

## Usage 🎮
``` dart
//Configuration for the Engine
ChessConfig config = ChessConfig(
        fenString: fenInput,
        isPlayerAWhite: isPlayerWhite,
        difficulty: Difficulty.medium);

//Initializing the Engine
ChessEngine chessEngine = ChessEngine(
      config,
      pawnPromotion: (isWhitePawn, targetPosition) {
        // This will trigger whenever a pawn promotion happens.
        piece = ChessPiece.queen;
        chessEngine.setPawnPromotion(targetPosition, piece);
      },
      boardChangeCallback: (newData) {
        // This will call whenever the boar data updates.
      },
      gameOverCallback: (gameStatus) {
        // This will trigger whenever the game ends (WhiteWins or BlackWins or Draw).
      },
    );
    
```

## Exposed Methods and Uses 📚
Here's a list of exposed methods along with their uses:

| Command | Description |
| --- | --- |
| git status | List all new or modified files |
| `git diff` | Show file differences that haven't been staged |
# Contact Me 📬

Feel free to reach out to me for any inquiries or collaborations:

🌐 [My Portfolio](https://thirudev50.github.io/portfolio/)

🔗 [My LinkedIn](https://www.linkedin.com/in/thirumoorthy-n/)

📧 Email: thiru.dev50@gmail.com

## Get Started 🚀
1. Clone this repository.
2. Open the project in your preferred Flutter development environment.
3. Run the project on your emulator or physical device.
4. Start playing chess!

## Contribution 🤝
Contributions are welcome! Feel free to submit issues, feature requests, or pull requests to help improve this project.

## License 📄
This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.
