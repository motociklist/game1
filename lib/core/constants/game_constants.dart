/// Константы игры
class GameConstants {
  // Физика мячика
  static const double ballRadius = 25.0;
  static const double ballFriction = 0.98;
  static const double ballBounce = 0.8;
  static const double ballMoveSpeed = 200.0;
  static const double ballJumpForce = 400.0;
  static const double gravity = 500.0;

  // Границы мира
  static const double wallThickness = 20.0;
  static const double platformThickness = 40.0;

  // Импульс от тапа
  static const double tapImpulse = 300.0;

  // Цвета мячика
  static const ballColors = [
    0xFFFF6B6B,
    0xFFFF8E53,
    0xFFFFA07A,
  ];

  // Цвета платформ
  static const platformGlowColor = 0xFF00FFFF; // Cyan
  static const double platformGlowOpacity = 0.3;

  // Игровые условия
  static const int totalCoins = 5; // Количество монет для победы
  static const double deathZone = 50.0; // Зона за пределами экрана для поражения
}

