import 'dart:math';

import 'package:flutter/material.dart';
import 'package:xo_game/database.dart';
import 'package:xo_game/replay_screen.dart';

class GameScreen extends StatefulWidget {
  @override
  _GameScreenState createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> {
  int gridSize = 3;
  List<List<String?>> board = [];
  String currentPlayer = 'X';

  @override
  void initState() {
    super.initState();
    _initializeBoard();
  }

  void _initializeBoard() {
    board = List.generate(gridSize, (_) => List.filled(gridSize, null));
  }

  void _botMove() {
    // Find an empty spot on the board
    List<int> emptySpots = [];
    for (int row = 0; row < gridSize; row++) {
      for (int col = 0; col < gridSize; col++) {
        if (board[row][col] == null) {
          emptySpots.add(row * gridSize + col);
        }
      }
    }

    // Choose a random empty spot
    if (emptySpots.isNotEmpty) {
      int randomMove = emptySpots[Random().nextInt(emptySpots.length)];
      int row = randomMove ~/ gridSize;
      int col = randomMove % gridSize;

      setState(() {
        board[row][col] = currentPlayer;
        if (_checkWinner(currentPlayer)) {
          _showGameEndDialog('$currentPlayer Wins!');
        } else if (_isBoardFull()) {
          _showGameEndDialog('It\'s a Draw!');
        } else {
          currentPlayer = 'X'; // Switch back to Player X after bot's move
        }
      });
    }
  }

  void _handleTap(int row, int col) {
    if (board[row][col] == null && currentPlayer == 'X') {
      setState(() {
        board[row][col] = currentPlayer;
        if (_checkWinner(currentPlayer)) {
          _showGameEndDialog('$currentPlayer Wins!');
        } else if (_isBoardFull()) {
          _showGameEndDialog('It\'s a Draw!');
        } else {
          currentPlayer = 'O'; // Switch to Bot after Player X's move
        }
      });

      // If it’s Bot’s turn, make the bot move
      if (currentPlayer == 'O') {
        _botMove(); // Bot makes its move
      }
    }
  }

  bool _checkWinner(String player) {
    // Check rows and columns
    for (int i = 0; i < gridSize; i++) {
      if (board[i].every((cell) => cell == player) ||
          List.generate(gridSize, (index) => board[index][i])
              .every((cell) => cell == player)) {
        return true;
      }
    }
    // Check diagonals
    if (List.generate(gridSize, (index) => board[index][index])
            .every((cell) => cell == player) ||
        List.generate(gridSize, (index) => board[index][gridSize - index - 1])
            .every((cell) => cell == player)) {
      return true;
    }
    return false;
  }

  bool _isBoardFull() {
    return board.every((row) => row.every((cell) => cell != null));
  }

  void _showGameEndDialog(String message) async {
    await _saveGameHistory(currentPlayer == 'X' ? 'Player X' : 'Player O');
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text('Game Over'),
        content: Text(message),
        actions: [
          IconButton(
            icon: Icon(Icons.history),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => ReplayScreen()),
              );
            },
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              setState(() {
                _initializeBoard();
                currentPlayer = 'X';
              });
            },
            child: Text('Play Again'),
          ),
        ],
      ),
    );
  }

  Future<void> _saveGameHistory(String winner) async {
    String moves = board.map((row) => row.join(',')).join(';');
    await DatabaseHelper.instance.insertGame({
      'grid_size': gridSize,
      'moves': moves,
      'winner': winner,
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('XO Game'),
        actions: [
          IconButton(
            icon: Icon(Icons.grid_on),
            onPressed: () {
              showDialog(
                context: context,
                builder: (_) => AlertDialog(
                  title: Text('Set Grid Size'),
                  content: TextField(
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                        hintText: 'Enter grid size (e.g., 3, 4, 5)'),
                    onSubmitted: (value) {
                      int? newSize = int.tryParse(value);
                      if (newSize != null && newSize > 2) {
                        setState(() {
                          gridSize = newSize; // Update grid size
                          _initializeBoard(); // Reset the board with new size
                        });
                        Navigator.of(context).pop(); // Close dialog
                      }
                    },
                  ),
                ),
              );
            },
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: GridView.builder(
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: gridSize,
              ),
              itemCount: gridSize * gridSize,
              itemBuilder: (context, index) {
                int row = index ~/ gridSize;
                int col = index % gridSize;
                return GestureDetector(
                  onTap: () => _handleTap(row, col),
                  child: Container(
                    margin: EdgeInsets.all(4.0),
                    decoration: BoxDecoration(
                      color: Colors.grey[200],
                      border: Border.all(color: Colors.black),
                    ),
                    child: Center(
                      child: Text(
                        board[row][col] ?? '',
                        style: const TextStyle(
                            fontSize: 32, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
