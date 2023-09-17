import 'package:isar/isar.dart';
import 'package:snake_game/persistence/entities/score.dart';

class Repository {
  late Future<Isar> db;

  Repository() {
    db = openDB();
  }

  Future<int> saveScore(Score score) async {
    final isar = await db;
    return await isar.writeTxn(() => isar.scores.put(score));
  }


  Future<int?> getMaxScore() async {
    final isar = await db;
    return await isar.scores.where().scoreProperty().max();
  }

  Future<Score?> getLatestScore() async {
    final isar = await db;
    final latestDate = await isar.scores.where().dateProperty().max();
    if(latestDate == null) {
      return null;
    }
    return await isar.scores.filter().dateEqualTo(latestDate).findFirst();
  }

  Future<({int? maxScore, Score? latestScore})> getInitData() async {
    final latestScore = await getLatestScore();
    final maxScore = await getMaxScore();
    return (maxScore: maxScore, latestScore: latestScore);
  }

  Future<void> cleanDb() async {
    final isar = await db;
    await isar.writeTxn(() => isar.clear());
  }

  Future<Isar> openDB() async {
    if (Isar.instanceNames.isEmpty) {
      return await Isar.open([ ScoreSchema], inspector: true, directory: './');
    }

    return Future.value(Isar.getInstance());
  }
}