// lib/screens/game_screen.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/game_provider.dart';
import '../widgets/memory_card.dart';

class GameScreen extends StatefulWidget {
  @override
  _GameScreenState createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> {
  @override
  void initState() {
    super.initState();
    final gameProvider = Provider.of<GameProvider>(context, listen: false);
    gameProvider.onVictory = _showVictoryDialog;
  }

  void _showVictoryDialog() {
    final gameProvider = Provider.of<GameProvider>(context, listen: false);
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Congratulations!'),
        content: Text(
            'You completed the game in ${_formatTime(gameProvider.elapsedSeconds)} with a score of ${gameProvider.score}.'),
        actions: [
          TextButton(
            onPressed: () {
              gameProvider.restartGame();
              Navigator.of(context).pop();
            },
            child: Text('Play Again'),
          ),
        ],
      ),
    );
  }

  String _formatTime(int seconds) {
    final minutes = seconds ~/ 60;
    final remainingSeconds = seconds % 60;
    return '${_twoDigits(minutes)}:${_twoDigits(remainingSeconds)}';
  }

  String _twoDigits(int n) => n.toString().padLeft(2, '0');

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Victory message is handled via a dialog
      appBar: AppBar(
        title: Text('Card Matching Game'),
      ),
      body: Column(
        children: [
          _buildStatusBar(context),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Consumer<GameProvider>(
                builder: (context, gameProvider, child) {
                  return GridView.builder(
                    itemCount: gameProvider.cards.length,
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 4, // 4x4 grid
                      crossAxisSpacing: 8.0,
                      mainAxisSpacing: 8.0,
                    ),
                    itemBuilder: (context, index) {
                      final card = gameProvider.cards[index];
                      return MemoryCard(
                        card: card,
                        onTap: () => gameProvider.flipCard(index),
                      );
                    },
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusBar(BuildContext context) {
    return Consumer<GameProvider>(
      builder: (context, gameProvider, child) {
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 8.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Time: ${_formatTime(gameProvider.elapsedSeconds)}',
                style: TextStyle(fontSize: 18.0),
              ),
              Text(
                'Score: ${gameProvider.score}',
                style: TextStyle(fontSize: 18.0),
              ),
              IconButton(
                icon: Icon(Icons.refresh),
                onPressed: () {
                  gameProvider.restartGame();
                },
              ),
            ],
          ),
        );
      },
    );
  }
}
