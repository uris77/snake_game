import 'package:flutter/material.dart';
import 'package:snake_game/db_provider.dart';

class Points extends StatelessWidget {
  const Points({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
        color: Colors.white24,
        child: const Padding(
          padding: EdgeInsets.all(8.0),
          child: _Scores(),
        ));
  }
}

class _Scores extends StatelessWidget {
  const _Scores();

  @override
  Widget build(BuildContext context) {
    return const Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Padding(
            padding: EdgeInsets.all(8.0),
            child: Padding(
              padding: EdgeInsets.all(8.0),
              child: _HighScores(),
            ),
          ),
          _LatestScore()
        ]);
  }
}

class _HighScores extends StatelessWidget {
  const _HighScores();

  @override
  Widget build(BuildContext context) {
    final provider = ScoresStateScope.of(context);
    final highScore = provider.maxScore;
    return Text(
      'High Score: ${highScore ?? 0}',
    );
  }
}

class _LatestScore extends StatelessWidget {
  const _LatestScore();

  @override
  Widget build(BuildContext context) {
    final provider = ScoresStateScope.of(context);
    final latestScore = provider.latestScore;
    return Text(
      'Latest Score: ${latestScore?.score ?? 0}',
    );
  }
}
