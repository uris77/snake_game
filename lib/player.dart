import 'package:flutter/material.dart';
import 'package:snake_game/game_parts.dart';


/// Player manages the state of the player's snake.
/// It knows its position, its direction, and its length.
/// It can move the snake, and it can grow the snake.
class Player {

  List<Point> snake = List.empty();
  var _movement = Movement.up;
  var points = 0;
  bool isAi = false;

  Player() {
    isAi = false;
  }

  Player.ai() {
    isAi = true;
  }

  Point getCurrentPosition() {
    final head = snake.first;
    switch (_movement) {
      case Movement.up:
        return Point(head.x, head.y - 1);
      case Movement.down:
        return Point(head.x, head.y + 1);
      case Movement.left:
        return Point(head.x - 1, head.y);
      case Movement.right:
        return Point(head.x + 1, head.y);
    }
  }

  Widget snakePart() {
    return Container(
      width: 20,
      height: 20,
      decoration: BoxDecoration(
        color: isAi ? Colors.blueAccent : Colors.green,
        shape: BoxShape.rectangle,
      ),
    );
  }

  void initiateSnake({required double width, required int factor}) {
    final midPoint = (width / factor / 2).roundToDouble();
    snake = [
      Point(midPoint, midPoint - 1),
      Point(midPoint, midPoint),
      Point(midPoint, midPoint + 1),
    ];
  }

  List<Positioned> advanceSnake() {
    List<Positioned> snakeWithNewPoints = List.empty(growable: true);
    for (var i = 0; i < snake.length; i++) {
      snakeWithNewPoints.add(Positioned(
        left: snake[i].x * 20,
        top: snake[i].y * 20,
        child: snakePart(),
      ));
    }
    return snakeWithNewPoints;
  }

  Point head() {
    return snake.first;
  }

  bool hasHitWall(
      {required double width, required double height, required int factor}) {
    final head = snake.first;
    return head.x < 0 ||
        head.x > width / factor ||
        head.y < 0 ||
        head.y >= height / factor;
  }

  bool canEat(Point point) {
    final head = snake.first;
    return head.x == point.x && head.y == point.y;
  }

  bool hasPoint(Point point) {
    return snake.contains(point);
  }

  bool hasHitSelf() {
    final head = snake.first;
    return snake.skip(1).any((point) => point == head);
  }

  set move (Movement move) {
    _movement = move;
  }

  void grow() {
    snake.insert(0, getCurrentPosition());
  }

  void shrink() {
    snake.removeLast();
  }
}

