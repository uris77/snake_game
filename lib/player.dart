import 'package:snake_game/base_player.dart';

/// Player manages the state of the player's snake.
/// It knows its position, its direction, and its length.
/// It can move the snake, and it can grow the snake.
class Player extends BasePlayer {
  Player() {
    isAi = false;
  }

}

