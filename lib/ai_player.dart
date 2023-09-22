import 'package:snake_game/base_player.dart';
import 'package:snake_game/game_parts.dart';
import 'package:snake_game/player.dart';

class AIPlayer extends BasePlayer {

    AIPlayer() {
      isAi = true;
    }

    List<Movement> findRoute(Point target) {
      final currentPosition = getCurrentPosition();
      if (currentPosition.x == target.x && currentPosition.y == target.y) {
        return [];
      }

      // determine if the target is to the left or right
      final xDirection = currentPosition.x > target.x ? Movement.left : Movement.right;
      final xDistance = (currentPosition.x - target.x).abs();
      // determine if the target is up or down
      final yDirection = currentPosition.y > target.y ? Movement.up : Movement.down;
      final yDistance = (currentPosition.y - target.y).abs();

      final movements= List<Movement>.empty(growable: true);
      for (var i = 0; i < xDistance; i++) {
        movements.add(xDirection);
      }
      for (var i = 0; i <= yDistance; i++) {
        movements.add(yDirection);
      }

      return movements;
    }

    bool hasHitOther(Player player) {
      final head = snake.first;
      return player.snake.any((point) => point == head);
    }

}