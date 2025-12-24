import 'package:flame/components.dart';
import '../ball_game.dart';
import 'package:flutter/material.dart';

/// Компонент монеты для сбора
class CoinComponent extends PositionComponent with HasGameReference<BallGame> {
  bool isCollected = false;
  final double radius = 15.0;
  double _rotation = 0.0;

  CoinComponent({required Vector2 position})
    : super(position: position, size: Vector2.all(30));

  @override
  void update(double dt) {
    super.update(dt);
    if (!isCollected) {
      _rotation += dt * 3; // Вращение монеты
    }
  }

  @override
  void render(Canvas canvas) {
    if (isCollected) return;

    canvas.save();
    canvas.translate(size.x / 2, size.y / 2);
    canvas.rotate(_rotation);

    // Внешний круг (золотой)
    final outerPaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          Colors.amber.shade400,
          Colors.orange.shade600,
          Colors.amber.shade700,
        ],
      ).createShader(Rect.fromCircle(center: Offset.zero, radius: radius));

    canvas.drawCircle(Offset.zero, radius, outerPaint);

    // Внутренний круг
    final innerPaint = Paint()
      ..color = Colors.amber.shade200
      ..style = PaintingStyle.fill;
    canvas.drawCircle(Offset.zero, radius * 0.6, innerPaint);

    // Блик
    final highlightPaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.8)
      ..style = PaintingStyle.fill;
    canvas.drawCircle(
      Offset(-radius * 0.3, -radius * 0.3),
      radius * 0.2,
      highlightPaint,
    );

    // Свечение
    final glowPaint = Paint()
      ..color = Colors.amber.withValues(alpha: 0.4)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;
    canvas.drawCircle(Offset.zero, radius + 2, glowPaint);

    canvas.restore();
  }

  bool checkCollision(Vector2 ballPosition, double ballRadius) {
    if (isCollected) return false;

    final distance = (position + size / 2 - ballPosition).length;
    return distance < (radius + ballRadius);
  }

  void collect() {
    isCollected = true;
    removeFromParent();
  }
}
