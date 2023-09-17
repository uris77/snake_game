import 'package:flutter/cupertino.dart';
import 'package:snake_game/persistence/entities/score.dart';
import 'package:snake_game/persistence/repository.dart';

class ScoresStateScope extends InheritedWidget {
  const ScoresStateScope(
      {Key? key, required this.scoresState, required Widget child})
      : super(key: key, child: child);

  final ScoresState scoresState;

  static ScoresState of(BuildContext context) {
    return context
        .dependOnInheritedWidgetOfExactType<ScoresStateScope>()!
        .scoresState;
  }

  @override
  bool updateShouldNotify(ScoresStateScope oldWidget) {
    return true;
  }
}

class ScoresState {
  ScoresState({required this.latestScore, required this.maxScore});

  final Score? latestScore;
  final int? maxScore;

  ScoresState copyWith({Score? latestScore, int? maxScore}) {
    return ScoresState(
      latestScore: latestScore ?? this.latestScore,
      maxScore: maxScore ?? this.maxScore,
    );
  }

  @override
  String toString() {
    return 'ScoresState{latestScore: $latestScore, maxScore: $maxScore}';
  }
}

class ScoresStateWidget extends StatefulWidget {
  const ScoresStateWidget(
      {super.key,
      required this.repository,
      required this.child,
      required this.initialState});

  final Widget child;
  final Repository repository;
  final ScoresState initialState;

  static ScoresStateWidgetState of(BuildContext context) {
    return context.findAncestorStateOfType<ScoresStateWidgetState>()!;
  }

  @override
  State<ScoresStateWidget> createState() => ScoresStateWidgetState();
}

class ScoresStateWidgetState extends State<ScoresStateWidget> {
  ScoresState _data = ScoresState(latestScore: null, maxScore: null);

  @override
  void initState() {
    super.initState();
    setState(() {
      _data = _data.copyWith(
          latestScore: widget.initialState.latestScore,
          maxScore: widget.initialState.maxScore);
    });
  }

  @override
  Widget build(BuildContext context) {
    return ScoresStateScope(
      scoresState: _data,
      child: widget.child,
    );
  }

  ScoresState get data => _data;

  void setScore(Score score) async {
    await widget.repository.saveScore(score);
    final latestScore = await widget.repository.getLatestScore();
    final maxScore = await widget.repository.getMaxScore();
    setState(() {
      _data = _data.copyWith(latestScore: latestScore, maxScore: maxScore);
    });
  }
}
