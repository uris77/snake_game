import 'package:flutter/material.dart';
import 'package:snake_game/game_play.dart';
import 'package:snake_game/points.dart';


class Game extends StatelessWidget {
  const Game({super.key});

  @override
  Widget build(BuildContext context) {
    return const Column(
      children: [
        Padding(
          padding: EdgeInsets.all(20),
            child: Points()),
        GamePlay(),
      ],
    );
  }
}

