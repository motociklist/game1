import 'package:flutter/material.dart';
import '../../../core/models/game_state.dart';

/// Экран окончания игры (победа/поражение)
class GameOverScreen extends StatelessWidget {
  final GameState gameState;
  final int score;
  final VoidCallback onRestart;

  const GameOverScreen({
    super.key,
    required this.gameState,
    required this.score,
    required this.onRestart,
  });

  @override
  Widget build(BuildContext context) {
    final isWin = gameState == GameState.won;

    return Positioned.fill(
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: isWin
                ? [
                    Colors.green.shade900,
                    Colors.teal.shade900,
                    Colors.blue.shade900,
                  ]
                : [
                    Colors.red.shade900,
                    Colors.purple.shade900,
                    Colors.indigo.shade900,
                  ],
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: [
                  SizedBox(height: MediaQuery.of(context).size.height * 0.1),
                  // Иконка результата
                  Icon(
                    isWin ? Icons.celebration : Icons.sentiment_very_dissatisfied,
                    size: 120,
                    color: Colors.white,
                  ),
                  const SizedBox(height: 30),

                  // Заголовок
                  Text(
                    isWin ? 'ПОБЕДА!' : 'ПОРАЖЕНИЕ',
                    style: const TextStyle(
                      fontSize: 48,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      letterSpacing: 2,
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Сообщение
                  Text(
                    isWin
                        ? 'Вы собрали все монеты!'
                        : 'Мячик попал на шипы!',
                    style: const TextStyle(
                      fontSize: 20,
                      color: Colors.white70,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 30),

                  // Очки
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(15),
                      border: Border.all(
                        color: Colors.white.withValues(alpha: 0.3),
                        width: 2,
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.star, color: Colors.amber, size: 30),
                        const SizedBox(width: 10),
                        Text(
                          'Очки: $score',
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 50),

                  // Кнопка перезапуска
                  _buildButton(
                    text: 'Играть снова',
                    icon: Icons.refresh,
                    onPressed: onRestart,
                    color: Colors.green,
                  ),
                  SizedBox(height: MediaQuery.of(context).size.height * 0.1),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildButton({
    required String text,
    required IconData icon,
    required VoidCallback onPressed,
    required Color color,
  }) {
    return ElevatedButton.icon(
      onPressed: onPressed,
      icon: Icon(icon, size: 24),
      label: Text(
        text,
        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
      ),
      style: ElevatedButton.styleFrom(
        backgroundColor: color,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 15),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(25),
        ),
        elevation: 8,
      ),
    );
  }
}

