# XO Game

This is a simple Flutter-based XO game with a bot opponent that can be played against the user.

# Algorithm Used (AI for Bot)

The bot is designed to simulate a random opponent, making moves by selecting one of the available empty spots on the board.
1.After each human player move, the bot randomly selects an empty spot on the grid.
2.The bot checks if it has won after each move.
3.If the board is full and there’s no winner, the game ends in a draw.

## Setup and Run

1. Clone the repository:

   ```bash
   git clone https://github.com/่jibpreeya/xo-game.git

   ```

2. Navigate to the project directory:

   ```bash
   cd xo-game

   ```

3. Install dependencies:

   ```bash
   flutter pub get

   ```

4. Run the app:
   ```bash
   flutter run
   ```
