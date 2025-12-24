import 'package:flutter/material.dart';

/// Заголовок игры с кнопкой перезапуска
class GameHeader extends StatelessWidget {
  final VoidCallback? onRestart;

  const GameHeader({
    super.key,
    this.onRestart,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Text(
            'Ball Game',
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.white),
            onPressed: onRestart,
          ),
        ],
      ),
    );
  }
}

