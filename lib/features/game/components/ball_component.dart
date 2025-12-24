import 'package:flame/components.dart';
import 'package:flutter/material.dart';
import '../ball_game.dart';
import '../../../core/constants/game_constants.dart';
import 'platform_component.dart';

/// Компонент мячика с физикой
class BallComponent extends PositionComponent with HasGameReference<BallGame> {
  Vector2 velocity = Vector2.zero();
  bool isOnGround = false;

  BallComponent({required Vector2 position})
      : super(
          position: position,
          size: Vector2.all(GameConstants.ballRadius * 2),
        );

  @override
  Future<void> onLoad() async {
    super.onLoad();
    // Устанавливаем начальную скорость в 0
    velocity = Vector2.zero();
    isOnGround = false;

    // Небольшая задержка, чтобы убедиться, что все платформы загружены
    await Future.delayed(const Duration(milliseconds: 20));

    // Проверяем и корректируем позицию после загрузки
    _checkInitialPosition();

    // Убеждаемся, что скорость равна 0 после проверки
    if (isOnGround) {
      velocity = Vector2.zero();
    }
  }

  @override
  void update(double dt) {
    super.update(dt);

    // Не применяем гравитацию, если мячик на земле и скорость равна 0 (начальное состояние)
    if (!isOnGround || velocity.y != 0) {
      // Применяем гравитацию
      velocity.y += GameConstants.gravity * dt;
    }

    // Применяем трение
    velocity *= GameConstants.ballFriction;

    // Обновляем позицию
    position += velocity * dt;

    // Проверяем столкновения со стенами
    _checkWallCollisions();

    // Проверяем столкновения с платформами
    for (var platform in game.platforms) {
      checkCollision(platform);
    }
  }

  void _checkInitialPosition() {
    // Проверяем, находится ли мячик на платформе при инициализации
    final radius = GameConstants.ballRadius;
    final ballCenterX = position.x;
    final ballCenterY = position.y;
    final ballBottom = ballCenterY + radius;

    for (var platform in game.platforms) {
      final platformTop = platform.position.y - platform.size.y / 2;
      final platformLeft = platform.position.x - platform.size.x / 2;
      final platformRight = platform.position.x + platform.size.x / 2;

      // Проверяем, находится ли мячик над платформой по X
      if (ballCenterX >= platformLeft && ballCenterX <= platformRight) {
        // Проверяем, находится ли мячик близко к верху платформы
        final distanceToTop = (ballBottom - platformTop).abs();

        if (distanceToTop <= 20) {
          // Мячик на платформе или очень близко
          isOnGround = true;
          velocity = Vector2.zero(); // Полностью останавливаем движение
          // Корректируем позицию, чтобы мячик точно стоял на платформе
          position.y = platformTop - radius;
          break;
        }
      }
    }
  }

  void _checkWallCollisions() {
    final radius = GameConstants.ballRadius;
    final wallThickness = GameConstants.wallThickness;

    if (position.x - radius < wallThickness) {
      position.x = wallThickness + radius;
      velocity.x *= -GameConstants.ballBounce;
    }
    if (position.x + radius > game.size.x - wallThickness) {
      position.x = game.size.x - wallThickness - radius;
      velocity.x *= -GameConstants.ballBounce;
    }
    if (position.y - radius < wallThickness) {
      position.y = wallThickness + radius;
      velocity.y *= -GameConstants.ballBounce;
    }
    // Не проверяем нижнюю границу - там шипы, мячик должен упасть на них
    // Проверяем только верхнюю и боковые границы

    // Проверяем, на земле ли мячик (для прыжка)
    // Но не ограничиваем движение вниз - пусть падает на шипы
    isOnGround = false;
  }

  void checkCollision(PlatformComponent platform) {
    final ballCenter = position;
    final radius = GameConstants.ballRadius;
    final platformRect = Rect.fromCenter(
      center: Offset(platform.position.x, platform.position.y),
      width: platform.size.x,
      height: platform.size.y,
    );

    // Находим ближайшую точку на платформе к центру мячика
    final closestX = ballCenter.x.clamp(platformRect.left, platformRect.right);
    final closestY = ballCenter.y.clamp(platformRect.top, platformRect.bottom);
    final closestPoint = Vector2(closestX, closestY);

    // Расстояние от центра мячика до ближайшей точки
    final distance = (ballCenter - closestPoint).length;

    if (distance < radius) {
      // Столкновение произошло
      final normal = (ballCenter - closestPoint).normalized();
      if (normal.length > 0) {
        // Отталкиваем мячик
        position = closestPoint + normal * (radius + 1);
        // Отражаем скорость
        velocity = velocity.reflected(normal) * GameConstants.ballBounce;

        // Проверяем, если мячик стоит на платформе сверху
        if (normal.y < -0.5 && velocity.y >= 0) {
          isOnGround = true;
        }
      }
    }
  }

  @override
  void render(Canvas canvas) {
    final radius = GameConstants.ballRadius;

    // Красивый градиент для мячика
    final paint = Paint()
      ..shader = RadialGradient(
        colors: GameConstants.ballColors.map((color) => Color(color)).toList(),
      ).createShader(Rect.fromCircle(center: Offset.zero, radius: radius));

    canvas.drawCircle(Offset.zero, radius, paint);

    // Блик на мячике
    final highlightPaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.6)
      ..style = PaintingStyle.fill;
    canvas.drawCircle(const Offset(-8, -8), 8, highlightPaint);

    // Внешнее свечение
    final glowPaint = Paint()
      ..color = Colors.orange.withValues(alpha: 0.3)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;
    canvas.drawCircle(Offset.zero, radius + 2, glowPaint);
  }

  void applyImpulse(Vector2 impulse) {
    velocity += impulse;
  }

  void moveLeft(double dt) {
    velocity.x -= GameConstants.ballMoveSpeed * dt;
  }

  void moveRight(double dt) {
    velocity.x += GameConstants.ballMoveSpeed * dt;
  }

  void jump() {
    // Прыжок возможен только если мячик на земле или близко к платформе
    if (isOnGround || velocity.y.abs() < 100) {
      velocity.y = -GameConstants.ballJumpForce;
      isOnGround = false;
    }
  }
}

