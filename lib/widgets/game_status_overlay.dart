import 'package:flutter/material.dart';
import '../game/models/game_state.dart';

/// Оверлей для отображения статуса игры
class GameStatusOverlay extends StatelessWidget {
  final GameState gameState;
  final int score;
  final int collectedCoins;
  final int totalCoins;

  const GameStatusOverlay({
    super.key,
    required this.gameState,
    required this.score,
    required this.collectedCoins,
    required this.totalCoins,
  });

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: 60,
      left: 20,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildScore(),
          const SizedBox(height: 10),
          _buildCoinsProgress(),
        ],
      ),
    );
  }

  Widget _buildScore() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.3),
          width: 2,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.star, color: Colors.amber, size: 20),
          const SizedBox(width: 8),
          Text(
            'Очки: $score',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCoinsProgress() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.3),
          width: 2,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.monetization_on, color: Colors.amber, size: 20),
          const SizedBox(width: 8),
          Text(
            'Монеты: $collectedCoins/$totalCoins',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}

