import 'package:isar/isar.dart';

part 'score.g.dart';

@collection
class Score {
  Id id = Isar.autoIncrement;
  late int score;
  late DateTime date;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Score &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          score == other.score &&
          date == other.date;

  @override
  int get hashCode => id.hashCode ^ score.hashCode ^ date.hashCode;

  @override
  String toString() {
    return 'Score{id: $id, score: $score, date: $date}';
  }
}
