import 'package:flame/components.dart';
import 'package:flutter/material.dart';
import '../ball_game.dart';

/// Компонент шипов
class SpikeComponent extends PositionComponent
    with HasGameReference<BallGame> {
  final double spikeHeight = 20.0;

  SpikeComponent({required Vector2 position, required Vector2 size})
      : super(position: position, size: size);

  @override
  void render(Canvas canvas) {
    final spikeWidth = size.x;
    final spikeCount = (spikeWidth / 15).floor(); // Количество шипов

    // Фон шипов (темный)
    final backgroundPaint = Paint()
      ..color = Colors.grey.shade900
      ..style = PaintingStyle.fill;
    canvas.drawRect(
      Rect.fromLTWH(0, 0, size.x, size.y),
      backgroundPaint,
    );

    // Рисуем шипы
    final spikePaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          Colors.red.shade700,
          Colors.red.shade900,
          Colors.red.shade900,
        ],
      ).createShader(
        Rect.fromLTWH(0, 0, size.x, spikeHeight),
      );

    for (int i = 0; i < spikeCount; i++) {
      final x = (i * spikeWidth / spikeCount) + (spikeWidth / spikeCount / 2);
      final path = Path()
        ..moveTo(x - 7, size.y)
        ..lineTo(x, size.y - spikeHeight)
        ..lineTo(x + 7, size.y)
        ..close();
      canvas.drawPath(path, spikePaint);
    }

    // Свечение шипов
    final glowPaint = Paint()
      ..color = Colors.red.withValues(alpha: 0.5)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;
    canvas.drawRect(
      Rect.fromLTWH(0, size.y - spikeHeight, size.x, spikeHeight),
      glowPaint,
    );
  }

  /// Проверяет столкновение мячика с шипами
  bool checkCollision(Vector2 ballPosition, double ballRadius) {
    // Область шипов - верхняя часть компонента (где нарисованы шипы)
    final spikeTop = position.y;
    final spikeLeft = position.x;
    final spikeRight = position.x + size.x;

    // Проверяем столкновение круга мячика с прямоугольником шипов
    final ballCenter = ballPosition;

    // Нижняя точка мячика
    final ballBottom = ballCenter.y + ballRadius;

    // Если нижняя часть мячика достигла области шипов
    if (ballBottom >= spikeTop) {
      // Проверяем горизонтальное пересечение
      final ballLeft = ballCenter.x - ballRadius;
      final ballRight = ballCenter.x + ballRadius;

      // Если есть пересечение по горизонтали
      if (ballRight >= spikeLeft && ballLeft <= spikeRight) {
        return true;
      }
    }

    return false;
  }
}

