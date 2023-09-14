import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

const width = 800.0;
const height = 500.0;

enum GameState { start, running, failure }

enum Movement { up, down, left, right }

class Game extends StatefulWidget {
  const Game({super.key});

  @override
  State<Game> createState() => _GameState();
}

class _GameState extends State<Game> {
  var gameState = GameState.start;
  Point newPointPosition = const Point(0, 0);
  List<Point> snakePosition = List.empty();
  Timer timer = Timer.periodic(Duration.zero, (_) {});
  var _movement = Movement.up;
  int points = 0;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        Center(
          child: Text(
            'Points: $points',
            style: const TextStyle(fontSize: 30),
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Focus(
            autofocus: true,
            onKeyEvent: _handleKeyEvent,
            child: Container(
              width: width,
              height: height,
              decoration: BoxDecoration(
                border: Border.all(color: Colors.red),
              ),
              child: GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTapDown: _handleTapDown,
                child: _buildChild(),
              ),
            ),
          ),
        ),
      ],
    );
  }

  KeyEventResult _handleKeyEvent(FocusNode node, KeyEvent event) {
    if (event is KeyDownEvent && event.logicalKey.keyLabel == 'Arrow Up') {
      setState(() {
        _movement = Movement.up;
      });
      return KeyEventResult.handled;
    }
    if (event is KeyDownEvent && event.logicalKey.keyLabel == 'Arrow Down') {
      setState(() {
        _movement = Movement.down;
      });
      return KeyEventResult.handled;
    }
    if (event is KeyDownEvent && event.logicalKey.keyLabel == 'Arrow Left') {
      setState(() {
        _movement = Movement.left;
      });
      return KeyEventResult.handled;
    }
    if (event is KeyDownEvent && event.logicalKey.keyLabel == 'Arrow Right') {
      setState(() {
        _movement = Movement.right;
      });
      return KeyEventResult.handled;
    }
    return KeyEventResult.ignored;
  }

  void _handleTapDown(TapDownDetails details) {
    setState(() {
      switch (gameState) {
        case GameState.start:
          startSnake();
          _newPoint();
          points = 0;
          gameState = GameState.running;
          _movement = Movement.up;
          timer = Timer.periodic(const Duration(milliseconds: 300), _onTick);
          break;
        case GameState.running:
          break;
        case GameState.failure:
          gameState = GameState.start;
          break;
      }
    });
  }

  Point _randomPoint() {
    Random range = Random();
    const factor = 20;
    const min = 0;
    const max = height ~/ factor;
    final nextY = min + range.nextInt(max - min);
    final nextX = min + range.nextInt(max - min);
    final isOutOfBounds = nextY.toDouble() > height ~/ factor || nextX.toDouble() > height ~/ factor;
    if(isOutOfBounds) {
      _randomPoint();
    }
    return Point(nextX.toDouble(), nextY.toDouble());
  }

  void _newPoint() {
    setState(() {
      final newPoint = _randomPoint();
      if (snakePosition.contains(newPoint) ) {
        _newPoint();
      } else {
        newPointPosition = newPoint;
      }
    });
  }

  void _onTick(Timer timer) {
    setState(() {
      snakePosition.insert(0, getCurrentSnakePosition());
      snakePosition.removeLast();
    });
    final currentPosition = snakePosition.first;
    if (currentPosition.x < 0 ||
        currentPosition.x > width / 20 ||
        currentPosition.y < 0 ||
        currentPosition.y >= height / 20) {
      setState(() {
        gameState = GameState.failure;
      });
      return;
    }
    final snakePositionCopy = List.of(snakePosition);
    snakePositionCopy.removeAt(0);
    if(snakePositionCopy.contains(currentPosition)){
      setState(() {
        gameState = GameState.failure;
      });
      return;
    }
    if (snakePosition.first.x == newPointPosition.x &&
        snakePosition.first.y == newPointPosition.y) {
      _newPoint();
      setState(() {
        points += 10;
        snakePosition.insert(0, getCurrentSnakePosition());
      });
    }
  }

  Point getCurrentSnakePosition() {
    final currentHead = snakePosition.first;
    switch (_movement) {
      case Movement.up:
        return Point(currentHead.x, currentHead.y - 1);
      case Movement.down:
        return Point(currentHead.x, currentHead.y + 1);
      case Movement.left:
        return Point(currentHead.x - 1, currentHead.y);
      case Movement.right:
        return Point(currentHead.x + 1, currentHead.y);
    }
  }

  Widget _startButton() {
    return Material(
      color: Colors.green[200],
      borderRadius: BorderRadius.circular(10.0),
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: InkWell(
          onTapDown: _handleTapDown,
          child:
              const Text('Start Game', style: TextStyle(color: Colors.brown)),
        ),
      ),
    );
  }

  Widget _buildChild() {
    if (gameState == GameState.start) {
      return startBoard;
    }
    if (gameState == GameState.running) {
      List<Positioned> snakeWithNewPoints = List.empty(growable: true);
      for (var i = 0; i < snakePosition.length; i++) {
        snakeWithNewPoints.add(Positioned(
          left: snakePosition[i].x * 20,
          top: snakePosition[i].y * 20,
          child: snakePart(),
        ));
      }
      final latestPoint = Positioned(
          left: newPointPosition.x * 20,
          top: newPointPosition.y * 20,
          child: pointDot());
      snakeWithNewPoints.add(latestPoint);
      return Stack(
        children: snakeWithNewPoints,
      );
    }
    timer.cancel();
    return Center(
      child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
        const Padding(padding: EdgeInsets.all(20.0), child: Text("Game Over")),
        _startButton()
      ]),
    );
  }

  void startSnake() {
    setState(() {
      final midPoint = (width / 20 / 2).roundToDouble();
      snakePosition = [
        Point(midPoint, midPoint - 1),
        Point(midPoint, midPoint),
        Point(midPoint, midPoint + 1),
      ];
    });
  }

  Widget snakePart() {
    return Container(
      width: 20,
      height: 20,
      decoration: const BoxDecoration(
        color: Colors.green,
        shape: BoxShape.rectangle,
      ),
    );
  }

  Widget pointDot() {
    return Container(
        width: 20,
        height: 20,
        decoration: const BoxDecoration(
          color: Colors.red,
          shape: BoxShape.rectangle,
        ));
  }
}

const Widget startBoard = Center(
  child: Text('Tap to start the game'),
);

class Point {
  final double x;
  final double y;

  const Point(this.x, this.y);

  @override
  String toString() => 'Point($x, $y)';
}
