import 'package:flutter/material.dart';
import 'package:xo_game/database.dart';

class ReplayScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Replay History')),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: DatabaseHelper.instance.fetchAllGames(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return Center(child: CircularProgressIndicator());
          }

          final games = snapshot.data!;
          if (games.isEmpty) {
            return Center(child: Text('No game history available.'));
          }

          return ListView.builder(
            itemCount: games.length,
            itemBuilder: (context, index) {
              final game = games[index];
              return ListTile(
                title:
                    Text('Grid: ${game['grid_size']} x ${game['grid_size']}'),
                subtitle: Text('Winner: ${game['winner']}'),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => GameReplayScreen(
                        moves: game['moves'],
                        gridSize: game['grid_size'],
                      ),
                    ),
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}

class GameReplayScreen extends StatelessWidget {
  final String moves;
  final int gridSize;

  GameReplayScreen({required this.moves, required this.gridSize});

  @override
  Widget build(BuildContext context) {
    final board = moves
        .split(';')
        .map((row) =>
            row.split(',').map((cell) => cell == '' ? null : cell).toList())
        .toList();

    return Scaffold(
      appBar: AppBar(title: Text('Game Replay')),
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
                return Container(
                  margin: EdgeInsets.all(4.0),
                  decoration: BoxDecoration(
                    color: Colors.grey[200],
                    border: Border.all(color: Colors.black),
                  ),
                  child: Center(
                    child: Text(
                      board[row][col] ?? '',
                      style:
                          TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
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
