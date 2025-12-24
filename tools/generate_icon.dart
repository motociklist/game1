import 'dart:io';
import 'package:image/image.dart' as img;

void main() {
  // Создаем иконку 1024x1024 (максимальный размер для всех платформ)
  final size = 1024;
  final image = img.Image(width: size, height: size);

  // Фон - градиент от фиолетового к синему
  final bgColor1 = img.ColorRgb8(108, 92, 231); // #6C5CE7
  final bgColor2 = img.ColorRgb8(52, 73, 94); // #34495e

  // Рисуем градиентный фон
  for (int y = 0; y < size; y++) {
    final ratio = y / size;
    final r = (bgColor1.r * (1 - ratio) + bgColor2.r * ratio).round();
    final g = (bgColor1.g * (1 - ratio) + bgColor2.g * ratio).round();
    final b = (bgColor1.b * (1 - ratio) + bgColor2.b * ratio).round();
    final color = img.ColorRgb8(r, g, b);
    for (int x = 0; x < size; x++) {
      image.setPixel(x, y, color);
    }
  }

  // Рисуем мячик в центре
  final centerX = size ~/ 2;
  final centerY = size ~/ 2;
  final ballRadius = (size * 0.35).round();

  // Основной цвет мячика - оранжево-красный градиент
  final ballColor1 = img.ColorRgb8(255, 107, 107); // #FF6B6B
  final ballColor2 = img.ColorRgb8(255, 142, 83); // #FF8E53

  // Рисуем мячик с градиентом
  for (int y = 0; y < size; y++) {
    for (int x = 0; x < size; x++) {
      final dx = x - centerX;
      final dy = y - centerY;
      final distance = (dx * dx + dy * dy);
      final radiusSquared = ballRadius * ballRadius;

      if (distance <= radiusSquared) {
        // Вычисляем градиент от центра к краю
        final distFromCenter = (distance / radiusSquared).clamp(0.0, 1.0);
        final r = (ballColor1.r * (1 - distFromCenter) + ballColor2.r * distFromCenter).round();
        final g = (ballColor1.g * (1 - distFromCenter) + ballColor2.g * distFromCenter).round();
        final b = (ballColor1.b * (1 - distFromCenter) + ballColor2.b * distFromCenter).round();

        // Добавляем блик (светлое пятно)
        final highlightX = centerX - ballRadius ~/ 3;
        final highlightY = centerY - ballRadius ~/ 3;
        final highlightDist = ((x - highlightX) * (x - highlightX) + (y - highlightY) * (y - highlightY));
        final highlightRadius = (ballRadius * 0.3) * (ballRadius * 0.3);

        if (highlightDist < highlightRadius) {
          final highlightIntensity = 1.0 - (highlightDist / highlightRadius);
          final highlight = (255 * highlightIntensity * 0.3).round();
          image.setPixel(x, y, img.ColorRgb8(
            (r + highlight).clamp(0, 255),
            (g + highlight).clamp(0, 255),
            (b + highlight).clamp(0, 255),
          ));
        } else {
          image.setPixel(x, y, img.ColorRgb8(r, g, b));
        }
      }
    }
  }

  // Сохраняем иконку
  final file = File('assets/icon/ball_icon.png');
  file.parent.createSync(recursive: true);
  file.writeAsBytesSync(img.encodePng(image));

  // ignore: avoid_print
  print('✅ Иконка создана: ${file.path}');
}

