import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flame/game.dart';
import '../game/ball_game.dart';
import '../game/models/game_state.dart';
import '../widgets/control_button.dart';
import '../widgets/game_header.dart';
import '../widgets/game_status_overlay.dart';
import 'game_over_screen.dart';

/// Экран игры
class GameScreen extends StatefulWidget {
  const GameScreen({super.key});

  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> {
  final FocusNode _focusNode = FocusNode();
  Key _gameKey = UniqueKey();
  BallGame? _game;
  GameState _gameState = GameState.playing;
  int _currentScore = 0;
  int _currentCollectedCoins = 0;
  int _totalCoins = 5; // Начальное значение, будет обновлено из игры

  @override
  void dispose() {
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: _buildBackgroundDecoration(),
        child: SafeArea(
          child: KeyboardListener(
            focusNode: _focusNode,
            autofocus: true,
            onKeyEvent: _handleKeyEvent,
            child: Column(
              children: [
                GameHeader(onRestart: _restartGame),
                Expanded(
                  child: Stack(
                    children: [
                      GameWidget<BallGame>.controlled(
                        key: _gameKey,
                        gameFactory: _createGame,
                      ),
                      if (_gameState == GameState.playing) ...[
                        GameStatusOverlay(
                          gameState: _gameState,
                          score: _currentScore,
                          collectedCoins: _currentCollectedCoins,
                          totalCoins: _totalCoins,
                        ),
                        _buildControlButtons(),
                      ],
                      if (_gameState == GameState.won ||
                          _gameState == GameState.lost)
                        GameOverScreen(
                          gameState: _gameState,
                          score: _currentScore,
                          onRestart: _restartGame,
                        ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  BoxDecoration _buildBackgroundDecoration() {
    return BoxDecoration(
      gradient: LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          Colors.deepPurple.shade900,
          Colors.blue.shade900,
          Colors.indigo.shade900,
        ],
      ),
    );
  }

  BallGame _createGame() {
    _game = BallGame(
      onStateChanged: (state) {
        setState(() {
          _gameState = state;
        });
      },
      onScoreChanged: (score, collectedCoins) {
        setState(() {
          _currentScore = score;
          _currentCollectedCoins = collectedCoins;
        });
      },
      onTotalCoinsChanged: (totalCoins) {
        setState(() {
          _totalCoins = totalCoins;
        });
      },
    );
    _gameState = GameState.playing;
    _currentScore = 0;
    _currentCollectedCoins = 0;
    _totalCoins = 5; // Сброс, будет обновлено из игры
    return _game!;
  }

  void _handleKeyEvent(KeyEvent event) {
    if (_game == null) return;
    if (event is KeyDownEvent) {
      _game!.handleKeyDown(event.logicalKey);
    } else if (event is KeyUpEvent) {
      _game!.handleKeyUp(event.logicalKey);
    }
  }

  Widget _buildControlButtons() {
    return Positioned(
      bottom: 20,
      left: 20,
      right: 20,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          ControlButton(
            icon: Icons.arrow_back,
            onPressedDown: () {
              _game?.isLeftPressed = true;
            },
            onPressedUp: () {
              _game?.isLeftPressed = false;
            },
          ),
          ControlButton(
            icon: Icons.arrow_upward,
            onPressed: () {
              _game?.isJumpPressed = true;
            },
          ),
          ControlButton(
            icon: Icons.arrow_forward,
            onPressedDown: () {
              _game?.isRightPressed = true;
            },
            onPressedUp: () {
              _game?.isRightPressed = false;
            },
          ),
        ],
      ),
    );
  }

  void _restartGame() {
    setState(() {
      _gameState = GameState.playing;
      _game = null;
      _currentScore = 0;
      _currentCollectedCoins = 0;
      _totalCoins = 5; // Сброс, будет обновлено из игры
      // Создаем новый ключ, чтобы пересоздать виджет игры
      _gameKey = UniqueKey();
    });
    // Игра перезапустится автоматически через gameFactory
  }
}
