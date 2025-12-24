import 'package:flame/components.dart';
import 'package:flutter/material.dart';
import '../ball_game.dart';
import '../../../core/constants/game_constants.dart';

/// Компонент платформы
class PlatformComponent extends PositionComponent
    with HasGameReference<BallGame> {
  PlatformComponent({required Vector2 position, required Vector2 size})
      : super(position: position, size: size);

  @override
  void render(Canvas canvas) {
    // Красивый градиент для платформ
    final paint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          Colors.blue.shade400,
          Colors.purple.shade400,
          Colors.indigo.shade400,
        ],
      ).createShader(
        Rect.fromCenter(
          center: Offset.zero,
          width: size.x,
          height: size.y,
        ),
      );

    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromCenter(
          center: Offset.zero,
          width: size.x,
          height: size.y,
        ),
        const Radius.circular(8),
      ),
      paint,
    );

    // Свечение вокруг платформы
    final glowPaint = Paint()
      ..color = Color(GameConstants.platformGlowColor)
          .withValues(alpha: GameConstants.platformGlowOpacity)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3;
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromCenter(
          center: Offset.zero,
          width: size.x,
          height: size.y,
        ),
        const Radius.circular(8),
      ),
      glowPaint,
    );
  }
}

