import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:snake_game/db_provider.dart';
import 'package:snake_game/game.dart';
import 'package:snake_game/persistence/repository.dart';
import 'package:window_manager/window_manager.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  if (!kIsWeb) {
    await windowManager.ensureInitialized();
    const windowOptions = WindowOptions(
      size: Size(800, 800),
      center: false,
      backgroundColor: Colors.transparent,
    );
    windowManager.setResizable(false);
    windowManager.waitUntilReadyToShow(windowOptions, () async {
      await windowManager.show();
      await windowManager.focus();
    });
  }
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Snake Game',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      debugShowCheckedModeBanner: false,
      home: Home(),
    );
  }
}

class Home extends StatefulWidget {
  Home({super.key});

  final repository = Repository();

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Snake Game"),
        centerTitle: true,
      ),
      backgroundColor: Colors.brown[700],
      body: FutureBuilder(
        future: widget.repository.getInitData(),
        builder: (context, snapshot) {
         if(snapshot.hasData && snapshot.data != null) {
           final data = snapshot.data;
           return ScoresStateWidget(
             repository: widget.repository,
             initialState: ScoresState(latestScore: data?.latestScore, maxScore: data?.maxScore ),
             child: const Game(),);
         }
         return const Center(child: CircularProgressIndicator());
        },
      ),
    );
  }
}
