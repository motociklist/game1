import 'package:flutter/services.dart';
import 'package:flame/game.dart';
import 'package:flame/events.dart';
import 'package:flame/components.dart';
import 'dart:math' as math;
import '../../core/constants/game_constants.dart';
import '../../core/models/game_state.dart';
import 'components/ball_component.dart';
import 'components/platform_component.dart';
import 'components/coin_component.dart';
import 'components/spike_component.dart';

/// Основной класс игры
class BallGame extends FlameGame
    with TapCallbacks, HasKeyboardHandlerComponents {
  BallGame({this.onStateChanged, this.onScoreChanged, this.onTotalCoinsChanged})
      : super();

  late BallComponent ball;
  late List<PlatformComponent> platforms;
  late List<CoinComponent> coins;
  late SpikeComponent spikes;
  int score = 0;
  int collectedCoins = 0;
  int totalCoins =
      0; // Динамическое количество монет (равно количеству платформ)
  GameState gameState = GameState.playing;

  // Callback для уведомления об изменении состояния
  final void Function(GameState)? onStateChanged;
  // Callback для обновления очков
  final void Function(int score, int collectedCoins)? onScoreChanged;
  // Callback для обновления общего количества монет
  final void Function(int totalCoins)? onTotalCoinsChanged;

  // Состояние нажатых клавиш
  bool isLeftPressed = false;
  bool isRightPressed = false;
  bool isJumpPressed = false;

  @override
  Future<void> onLoad() async {
    super.onLoad();

    // Сбрасываем состояние игры
    score = 0;
    collectedCoins = 0;
    gameState = GameState.playing;

    // Устанавливаем размер мира
    camera.viewfinder.visibleGameSize = size;
    camera.viewfinder.anchor = Anchor.topLeft;

    // Создаем платформы
    platforms = _createPlatforms();

    // СНАЧАЛА добавляем все платформы в игру
    for (var platform in platforms) {
      await add(platform);
    }

    // Ждем, чтобы убедиться, что все платформы полностью загружены
    await Future.delayed(const Duration(milliseconds: 50));

    // ПОТОМ создаем мячик на второй платформе сверху (после того как платформы полностью загружены)
    final ballPosition = _getInitialBallPosition();
    ball = BallComponent(position: ballPosition);
    await add(ball);
    // Ждем загрузки мячика и проверки позиции
    await Future.delayed(const Duration(milliseconds: 50));

    // Создаем монеты (после платформ, чтобы разместить их рядом)
    // Количество монет равно количеству обычных платформ (без стен)
    coins = _createCoins();
    totalCoins = coins.length; // Устанавливаем общее количество монет
    onTotalCoinsChanged?.call(totalCoins); // Уведомляем UI о количестве монет
    for (var coin in coins) {
      await add(coin);
    }

    // Создаем шипы внизу (прямо внизу экрана)
    spikes = SpikeComponent(
      position: Vector2(0, size.y - 30),
      size: Vector2(size.x, 30),
    );
    await add(spikes);

    // Уведомляем о начальных значениях
    onScoreChanged?.call(score, collectedCoins);
  }

  List<PlatformComponent> _createPlatforms() {
    final wallThickness = GameConstants.wallThickness;
    final platformThickness = GameConstants.platformThickness;
    final random = math.Random();
    final platforms = <PlatformComponent>[];

    // Левая стена (всегда есть)
    platforms.add(
      PlatformComponent(
        position: Vector2(wallThickness, size.y / 2),
        size: Vector2(platformThickness, size.y),
      ),
    );

    // Правая стена (всегда есть)
    platforms.add(
      PlatformComponent(
        position: Vector2(size.x - wallThickness, size.y / 2),
        size: Vector2(platformThickness, size.y),
      ),
    );

    // Верхняя платформа (всегда есть)
    platforms.add(
      PlatformComponent(
        position: Vector2(size.x / 2, wallThickness),
        size: Vector2(size.x - wallThickness * 2, platformThickness),
      ),
    );

    // Создаем 5 случайных платформ
    final minPlatformWidth = 100.0;
    final maxPlatformWidth = 200.0;
    final minPlatformHeight = 25.0;
    final maxPlatformHeight = 35.0;
    // Расстояние между платформами равно минимальной ширине платформы
    final platformSpacing = minPlatformWidth;

    final minX = wallThickness + platformThickness + platformSpacing;
    final maxX = size.x - wallThickness - platformThickness - platformSpacing;
    final minY = wallThickness + platformThickness + platformSpacing;
    final maxY = size.y - wallThickness - 100; // Оставляем место для шипов

    for (int i = 0; i < 5; i++) {
      bool validPosition = false;
      Vector2? position;
      Vector2? platformSize;

      // Пытаемся найти валидную позицию (не пересекается с другими платформами)
      int attempts = 0;
      while (!validPosition && attempts < 50) {
        final width =
            minPlatformWidth +
            random.nextDouble() * (maxPlatformWidth - minPlatformWidth);
        final height =
            minPlatformHeight +
            random.nextDouble() * (maxPlatformHeight - minPlatformHeight);
        final x = minX + random.nextDouble() * (maxX - minX);
        final y = minY + random.nextDouble() * (maxY - minY);

        position = Vector2(x, y);
        platformSize = Vector2(width, height);

        // Проверяем, не пересекается ли с существующими платформами
        validPosition = true;
        for (var existingPlatform in platforms) {
          final existingRect = Rect.fromCenter(
            center: Offset(
              existingPlatform.position.x,
              existingPlatform.position.y,
            ),
            width: existingPlatform.size.x,
            height: existingPlatform.size.y,
          );
          final newRect = Rect.fromCenter(
            center: Offset(position.x, position.y),
            width: platformSize.x,
            height: platformSize.y,
          );

          // Добавляем отступ между платформами
          // Расширяем существующую платформу на расстояние равное минимальной ширине
          final expandedExisting = existingRect.inflate(minPlatformWidth);
          if (expandedExisting.overlaps(newRect)) {
            validPosition = false;
            break;
          }
        }
        attempts++;
      }

      if (validPosition && position != null && platformSize != null) {
        platforms.add(
          PlatformComponent(position: position, size: platformSize),
        );
      }
    }

    return platforms;
  }

  /// Получает начальную позицию мячика на второй платформе сверху
  Vector2 _getInitialBallPosition() {
    final wallThickness = GameConstants.wallThickness;
    final ballRadius = GameConstants.ballRadius;

    // Фильтруем платформы: исключаем стены (вертикальные и очень широкие горизонтальные)
    final horizontalPlatforms = platforms.where((platform) {
      // Исключаем стены: очень высокие (вертикальные) или очень широкие (верхняя стена)
      return platform.size.x < size.x * 0.8 && platform.size.y < size.y * 0.5;
    }).toList();

    if (horizontalPlatforms.isEmpty) {
      // Fallback: если нет подходящих платформ
      return Vector2(size.x / 2, wallThickness - ballRadius);
    }

    // Сортируем платформы по Y координате (от меньшего к большему - сверху вниз)
    horizontalPlatforms.sort((a, b) => a.position.y.compareTo(b.position.y));

    // Берем вторую платформу сверху (индекс 1)
    final targetPlatform = horizontalPlatforms.length >= 2
        ? horizontalPlatforms[1] // Вторая платформа
        : horizontalPlatforms[0]; // Если платформ меньше двух, берем первую доступную

    // Размещаем мячик на платформе
    // position компонента - это его центр
    // В системе координат Flame: Y=0 вверху, Y увеличивается вниз
    // Чтобы мячик стоял на платформе, его центр должен быть:
    // - X: центр платформы
    // - Y: верх платформы - радиус мячика (чтобы нижняя часть мячика касалась верха платформы)
    final platformTop = targetPlatform.position.y - targetPlatform.size.y / 2;
    // Центр мячика = верх платформы - радиус
    // Низ мячика (position.y + radius) должен быть на верху платформы (platformTop)
    // Значит: position.y + radius = platformTop
    // position.y = platformTop - radius
    final ballPosition = Vector2(
      targetPlatform.position.x, // Центр платформы по X
      platformTop - ballRadius, // Верх платформы - радиус (центр мячика)
    );

    return ballPosition;
  }

  List<CoinComponent> _createCoins() {
    final coins = <CoinComponent>[];
    final random = math.Random();

    // Создаем монеты рядом с платформами (кроме стен)
    // Фильтруем платформы: исключаем стены (вертикальные и очень широкие горизонтальные)
    final horizontalPlatforms = platforms.where((platform) {
      // Исключаем стены: очень высокие (вертикальные) или очень широкие (верхняя стена)
      return platform.size.x < size.x * 0.8 && platform.size.y < size.y * 0.5;
    }).toList();

    // Создаем по одной монете для каждой обычной платформы
    for (var platform in horizontalPlatforms) {
      // Размещаем монету над платформой или рядом с ней
      final coinX =
          platform.position.x +
          (random.nextDouble() - 0.5) * platform.size.x * 0.8;
      final coinY = platform.position.y - 40 - random.nextDouble() * 20;

      // Проверяем, что монета не выходит за границы экрана
      if (coinX > 50 &&
          coinX < size.x - 50 &&
          coinY > 50 &&
          coinY < size.y - 100) {
        coins.add(CoinComponent(position: Vector2(coinX, coinY)));
      }
    }

    return coins;
  }

  @override
  bool onTapDown(TapDownEvent event) {
    final tapPosition = event.localPosition;
    ball.applyImpulse(
      (tapPosition - ball.position).normalized() * GameConstants.tapImpulse,
    );
    return true;
  }

  @override
  void update(double dt) {
    super.update(dt);

    // Не обновляем игру, если она завершена
    if (gameState != GameState.playing) {
      return;
    }

    // Применяем управление
    if (isLeftPressed) {
      ball.moveLeft(dt);
    }
    if (isRightPressed) {
      ball.moveRight(dt);
    }
    if (isJumpPressed) {
      ball.jump();
      isJumpPressed = false; // Прыжок одноразовый
    }

    // Проверяем сбор монет
    _checkCoinCollection();

    // Проверяем условия победы
    _checkWinCondition();

    // Проверяем условия поражения
    _checkLoseCondition();

    // Проверяем столкновение с шипами
    _checkSpikeCollision();
  }

  void _checkCoinCollection() {
    final ballRadius = GameConstants.ballRadius;
    for (var coin in coins) {
      if (!coin.isCollected && coin.checkCollision(ball.position, ballRadius)) {
        coin.collect();
        collectedCoins++;
        score += 10;
        // Уведомляем об изменении очков
        onScoreChanged?.call(score, collectedCoins);
      }
    }
  }

  void _checkWinCondition() {
    // Проверяем победу: собраны все монеты (количество монет = количеству платформ)
    if (totalCoins > 0 &&
        collectedCoins >= totalCoins &&
        gameState == GameState.playing) {
      gameState = GameState.won;
      onStateChanged?.call(gameState);
    }
  }

  void _checkLoseCondition() {
    // Мячик упал за пределы экрана
    if (ball.position.y > size.y + GameConstants.deathZone) {
      if (gameState == GameState.playing) {
        gameState = GameState.lost;
        onStateChanged?.call(gameState);
      }
    }
  }

  void _checkSpikeCollision() {
    if (gameState != GameState.playing) return;

    final ballRadius = GameConstants.ballRadius;
    // Проверяем столкновение с шипами
    if (spikes.checkCollision(ball.position, ballRadius)) {
      gameState = GameState.lost;
      onStateChanged?.call(gameState);
    }
  }

  void handleKeyDown(LogicalKeyboardKey key) {
    if (key == LogicalKeyboardKey.arrowLeft || key == LogicalKeyboardKey.keyA) {
      isLeftPressed = true;
    } else if (key == LogicalKeyboardKey.arrowRight ||
        key == LogicalKeyboardKey.keyD) {
      isRightPressed = true;
    } else if (key == LogicalKeyboardKey.space ||
        key == LogicalKeyboardKey.arrowUp ||
        key == LogicalKeyboardKey.keyW) {
      isJumpPressed = true;
    }
  }

  void handleKeyUp(LogicalKeyboardKey key) {
    if (key == LogicalKeyboardKey.arrowLeft || key == LogicalKeyboardKey.keyA) {
      isLeftPressed = false;
    } else if (key == LogicalKeyboardKey.arrowRight ||
        key == LogicalKeyboardKey.keyD) {
      isRightPressed = false;
    }
  }
}

