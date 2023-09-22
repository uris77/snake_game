import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:snake_game/db_provider.dart';
import 'package:snake_game/game_parts.dart';
import 'package:snake_game/persistence/entities/score.dart';
import 'package:snake_game/player.dart';

const width = 800.0;
const height = 500.0;

enum GameState { start, running, failure }

class GamePlay extends StatefulWidget {
  const GamePlay({super.key});

  @override
  State<GamePlay> createState() => _GamePlayState();
}

class _GamePlayState extends State<GamePlay> {
  var gameState = GameState.start;
  Point newPointPosition = const Point(0, 0);
  Timer timer = Timer.periodic(Duration.zero, (_) {});
  var _movement = Movement.up;
  int points = 0;
  Player playerSnake = Player();
  Player aiSnake = Player.ai();

  @override
  Widget build(BuildContext context) {
    final provider = ScoresStateWidget.of(context);
    return Column(
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
                onTapDown: (_) => _handleTapDown(provider),
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
        playerSnake.move = _movement;
      });
      return KeyEventResult.handled;
    }
    if (event is KeyDownEvent && event.logicalKey.keyLabel == 'Arrow Down') {
      setState(() {
        _movement = Movement.down;
        playerSnake.move = _movement;
      });
      return KeyEventResult.handled;
    }
    if (event is KeyDownEvent && event.logicalKey.keyLabel == 'Arrow Left') {
      setState(() {
        _movement = Movement.left;
        playerSnake.move = _movement;
      });
      return KeyEventResult.handled;
    }
    if (event is KeyDownEvent && event.logicalKey.keyLabel == 'Arrow Right') {
      setState(() {
        _movement = Movement.right;
        playerSnake.move = _movement;
      });
      return KeyEventResult.handled;
    }
    return KeyEventResult.ignored;
  }

  void _handleTapDown(DbProvider provider) {
    setState(() {
      switch (gameState) {
        case GameState.start:
          playerSnake.initiateSnake(width: width, factor: 20);
          aiSnake.initiateSnake(width: width, factor: 25);
          _newPoint();
          points = 0;
          gameState = GameState.running;
          _movement = Movement.up;
          playerSnake.move = _movement;
          aiSnake.move = _randomMovement();
          timer = Timer.periodic(const Duration(milliseconds: 300),
              (timer) => _onTick(timer, provider));
          break;
        case GameState.running:
          break;
        case GameState.failure:
          gameState = GameState.start;
          break;
      }
    });
  }

  Movement _randomMovement() {
    final range = Random();
    final idx = range.nextInt(3);
    return Movement.values[idx];
  }

  Point _randomPoint() {
    Random range = Random();
    const factor = 20;
    const min = 0;
    const max = height ~/ factor;
    final nextY = min + range.nextInt(max - min);
    final nextX = min + range.nextInt(max - min);
    final isOutOfBounds = nextY.toDouble() > height ~/ factor ||
        nextX.toDouble() > height ~/ factor;
    if (isOutOfBounds) {
      _randomPoint();
    }
    return Point(nextX.toDouble(), nextY.toDouble());
  }

  void _newPoint() {
    setState(() {
      final newPoint = _randomPoint();
      if (playerSnake.hasPoint(newPoint) || aiSnake.hasPoint(newPoint)) {
        _newPoint();
      } else {
        newPointPosition = newPoint;
      }
    });
  }

  void _onTick(Timer timer, DbProvider provider) {
    setState(() {
      playerSnake.grow();
      playerSnake.shrink();
      aiSnake.grow();
      aiSnake.shrink();
      aiSnake.move = _randomMovement();
    });
    if (playerSnake.hasHitWall(width: width, height: height, factor: 20)) {
      setState(() {
        gameState = GameState.failure;
      });
      final score = Score()
        ..score = points
        ..date = DateTime.now();
      provider.setScore(score);
      return;
    }
    if(aiSnake.hasHitWall(width: width, height: height, factor: 20)){
      setState((){
        aiSnake.initiateSnake(width: width, factor: 25);
        final mv = _randomMovement();
        aiSnake.move = mv;
      });
    }
    if (playerSnake.hasHitSelf()) {
      setState(() {
        gameState = GameState.failure;
      });
      final score = Score()
        ..score = points
        ..date = DateTime.now();
      provider.setScore(score);
      return;
    }
    if (playerSnake.canEat(newPointPosition)) {
      _newPoint();
      setState(() {
        points += 10;
        playerSnake.grow();
        aiSnake.move = _randomMovement();
      });
    }
    if(aiSnake.canEat(newPointPosition)) {
      _newPoint();
      setState(() {
        aiSnake.grow();
        aiSnake.move = _randomMovement();
      });
    }
  }

  Widget _startButton() {
    return Material(
      color: Colors.green[200],
      borderRadius: BorderRadius.circular(10.0),
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: InkWell(
          onTapDown: (_) {
            setState(() {
              gameState = GameState.start;
            });
          },
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
      final snakeWithNewPoints = playerSnake.advanceSnake();
      final aiSnakeWithNewPoints = aiSnake.advanceSnake();
      final latestPoint = Positioned(
          left: newPointPosition.x * 20,
          top: newPointPosition.y * 20,
          child: pointDot());
      snakeWithNewPoints.add(latestPoint);
      snakeWithNewPoints.addAll(aiSnakeWithNewPoints);
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
