// Imposter Game Clone - Flutter (Black Theme + Smooth UI + External Topic Packs)
// Features:
// - Black minimalist UI (centered everything)
// - Flip animation when revealing word
// - Customizable topic packs via external JSON (assets or file path)
// - Simple imposter-style word assignment

import 'dart:convert';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

void main() {
  runApp(const ImposterApp());
}

class ImposterApp extends StatelessWidget {
  const ImposterApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData.dark().copyWith(
        scaffoldBackgroundColor: Colors.black,
        colorScheme: const ColorScheme.dark(
          primary: Colors.white,
          secondary: Colors.grey,
        ),
      ),
      home: const PlayerSetupScreen(),
    );
  }
}

// -------------------- DATA LOADER --------------------
class TopicPackService {
  static Future<Map<String, List<String>>> loadPacks() async {
    final String data = await rootBundle.loadString('assets/topic_packs.json');
    final decoded = jsonDecode(data);
    return Map<String, List<String>>.from(
      decoded.map((key, value) => MapEntry(key, List<String>.from(value))),
    );
  }
}

// -------------------- PLAYER SETUP --------------------
class PlayerSetupScreen extends StatefulWidget {
  const PlayerSetupScreen({super.key});

  @override
  State<PlayerSetupScreen> createState() => _PlayerSetupScreenState();
}

class _PlayerSetupScreenState extends State<PlayerSetupScreen> {
  final TextEditingController controller = TextEditingController();
  final List<String> players = [];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              "IMPOSTER",
              style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 30),

            SizedBox(
              width: 250,
              child: TextField(
                controller: controller,
                textAlign: TextAlign.center,
                decoration: const InputDecoration(
                  hintText: "Enter player name",
                  border: OutlineInputBorder(),
                ),
              ),
            ),

            const SizedBox(height: 10),

            ElevatedButton(
              onPressed: () {
                if (controller.text.isNotEmpty) {
                  setState(() {
                    players.add(controller.text);
                    controller.clear();
                  });
                }
              },
              child: const Text("Add Player"),
            ),

            const SizedBox(height: 20),

            Text("Players: ${players.length}"),

            const SizedBox(height: 30),

            ElevatedButton(
              onPressed: players.length >= 3
                  ? () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => TopicSelectScreen(players: players),
                        ),
                      );
                    }
                  : null,
              child: const Text("Start Game"),
            ),
          ],
        ),
      ),
    );
  }
}

// -------------------- TOPIC SELECT --------------------
class TopicSelectScreen extends StatefulWidget {
  final List<String> players;
  const TopicSelectScreen({super.key, required this.players});

  @override
  State<TopicSelectScreen> createState() => _TopicSelectScreenState();
}

class _TopicSelectScreenState extends State<TopicSelectScreen> {
  Map<String, List<String>> packs = {};
  String? selectedTopic;

  @override
  void initState() {
    super.initState();
    TopicPackService.loadPacks().then((value) {
      setState(() => packs = value);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: packs.isEmpty
            ? const CircularProgressIndicator()
            : Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text("Choose Topic"),
                  const SizedBox(height: 20),
                  ...packs.keys.map((topic) {
                    return ElevatedButton(
                      onPressed: () => setState(() => selectedTopic = topic),
                      child: Text(topic),
                    );
                  }),
                  const SizedBox(height: 30),
                  ElevatedButton(
                    onPressed: selectedTopic != null
                        ? () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => GameScreen(
                                  players: widget.players,
                                  words: packs[selectedTopic!]!,
                                ),
                              ),
                            );
                          }
                        : null,
                    child: const Text("Continue"),
                  )
                ],
              ),
      ),
    );
  }
}

// -------------------- GAME SCREEN --------------------
class GameScreen extends StatefulWidget {
  final List<String> players;
  final List<String> words;

  const GameScreen({super.key, required this.players, required this.words});

  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> {
  int index = 0;
  late List<String> assignedWords;
  bool revealed = false;

  @override
  void initState() {
    super.initState();
    assignedWords = _generateWords();
  }

  List<String> _generateWords() {
    final word = widget.words[Random().nextInt(widget.words.length)];
    final imposterIndex = Random().nextInt(widget.players.length);

    return List.generate(widget.players.length, (i) {
      return i == imposterIndex ? "IMPOSTER" : word;
    });
  }

  void nextPlayer() {
    setState(() {
      revealed = false;
      index++;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (index >= widget.players.length) {
      return const Scaffold(
        body: Center(child: Text("Game Complete")),
      );
    }

    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              widget.players[index],
              style: const TextStyle(fontSize: 22),
            ),

            const SizedBox(height: 30),

            AnimatedContainer(
              duration: const Duration(milliseconds: 500),
              width: 200,
              height: 200,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: revealed ? Colors.white : Colors.grey[900],
                borderRadius: BorderRadius.circular(16),
              ),
              child: revealed
                  ? Text(
                      assignedWords[index],
                      style: TextStyle(
                        color: assignedWords[index] == "IMPOSTER"
                            ? Colors.red
                            : Colors.black,
                        fontSize: 20,
                      ),
                    )
                  : const Text("Tap to Reveal"),
            ),

            const SizedBox(height: 20),

            ElevatedButton(
              onPressed: () {
                setState(() => revealed = !revealed);
              },
              child: Text(revealed ? "Hide" : "Reveal"),
            ),

            const SizedBox(height: 10),

            ElevatedButton(
              onPressed: revealed ? nextPlayer : null,
              child: const Text("Next Player"),
            ),
          ],
        ),
      ),
    );
  }
}

/*
import 'dart:convert';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  runApp(const MyApp());
}

// ================= APP =================

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Impostor',
      theme: ThemeData(fontFamily: 'Arial'),
      home: const MenuScreen(),
    );
  }
}

// ================= GLOBAL STYLE =================

BoxDecoration gradientBG = const BoxDecoration(
  gradient: LinearGradient(
    colors: [
      Color(0xFFFFFFFF), // white
      Color(0xFF4A90E2), // soft blue
    ],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  ),
);
// ================= MODEL =================

class TopicPack {
  String name;
  List<String> topics;

  TopicPack({required this.name, required this.topics});

  Map<String, dynamic> toJson() => {
        "name": name,
        "topics": topics,
      };

  static TopicPack fromJson(Map<String, dynamic> json) {
    return TopicPack(
      name: json["name"],
      topics: List<String>.from(json["topics"]),
    );
  }
}

// ================= STORAGE =================

class Storage {
  static const key = "packs";

  static Future<List<TopicPack>> load() async {
    final prefs = await SharedPreferences.getInstance();
    final data = prefs.getString(key);

    if (data == null) return [];

    List decoded = jsonDecode(data);
    return decoded.map((e) => TopicPack.fromJson(e)).toList();
  }

  static Future save(List<TopicPack> packs) async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setString(key, jsonEncode(packs));
  }
}

// ================= MENU =================

class MenuScreen extends StatelessWidget {
  const MenuScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
  decoration: gradientBG,
  child: Center(
    child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        const Text(
          "Impostor",
          style: TextStyle(
            fontSize: 48,
            fontWeight: FontWeight.bold,
            color: Colors.blue,
          ),
        ),

        const SizedBox(height: 40),

        ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.blue,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 16),
          ),
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const PlayerScreen()),
            );
          },
          child: const Text("Play"),
        ),
      ],
    ),
  ),
),
    );
  }
}

// ================= PLAYER SCREEN =================

class PlayerScreen extends StatefulWidget {
  const PlayerScreen({super.key});

  @override
  State<PlayerScreen> createState() => _PlayerScreenState();
}

class _PlayerScreenState extends State<PlayerScreen> {
  List<String> players = [];
  final controller = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
  decoration: gradientBG,
  child: Center(
    child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Text(
          "Players",
          style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
        ),

        Padding(
          padding: const EdgeInsets.all(16),
          child: TextField(
            controller: controller,
            textAlign: TextAlign.center,
            decoration: const InputDecoration(
              filled: true,
              fillColor: Colors.white,
              hintText: "Enter player name",
              border: OutlineInputBorder(),
            ),
          ),
        ),

        ElevatedButton(
          onPressed: () {
            setState(() {
              players.add(controller.text);
              controller.clear();
            });
          },
          child: const Text("Add Player"),
        ),
        const SizedBox(height: 20),

ElevatedButton(
  onPressed: players.length >= 3
      ? () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => TopicScreen(players: players),
            ),
          );
        }
      : null,
  style: ElevatedButton.styleFrom(
    backgroundColor: Colors.blue,
    foregroundColor: Colors.white,
  ),
  child: const Text("Start Game"),
),
        const SizedBox(height: 20),

        Column(
          children: players
              .map((p) => Text(p, style: const TextStyle(fontSize: 18)))
              .toList(),
        ),
      ],
    ),
  ),
),
    );
  }
}

// ================= TOPIC SCREEN =================

class TopicScreen extends StatefulWidget {
  final List<String> players;

  const TopicScreen({super.key, required this.players});

  @override
  State<TopicScreen> createState() => _TopicScreenState();
}

class _TopicScreenState extends State<TopicScreen> {
  List<TopicPack> packs = [
    TopicPack(name: "Default", topics: ["Pizza", "Beach", "Car"])
  ];

  List<TopicPack> custom = [];

  @override
  void initState() {
    super.initState();
    load();
  }

  void load() async {
    custom = await Storage.load();
    setState(() {});
  }

  void startGame(String topic) {
    final impostor = widget.players[Random().nextInt(widget.players.length)];

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => RevealScreen(
          players: widget.players,
          topic: topic,
          impostor: impostor,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: gradientBG,
        child: ListView(
          children: [
            ...packs,
            ...custom,
          ].map((pack) {
            return Column(
              children: [
                Text(pack.name, style: const TextStyle(color: Colors.white)),
                ...pack.topics.map((t) => ElevatedButton(
                      onPressed: () => startGame(t),
                      child: Text(t),
                    ))
              ],
            );
          }).toList(),
        ),
      ),
    );
  }
}

// ================= REVEAL (FLIP CARD) =================

class RevealScreen extends StatefulWidget {
  final List<String> players;
  final String topic;
  final String impostor;

  const RevealScreen({
    super.key,
    required this.players,
    required this.topic,
    required this.impostor,
  });

  @override
  State<RevealScreen> createState() => _RevealScreenState();
}

class _RevealScreenState extends State<RevealScreen> {
  int index = 0;
  bool flipped = false;

  @override
  Widget build(BuildContext context) {
final player = widget.players[index.clamp(0, widget.players.length - 1)];
    final role = player == widget.impostor ? "Impostor" : widget.topic;
    
    return Scaffold(
      body: Container(
  decoration: gradientBG,
  child: Center(
    child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          player,
          style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        ),

        const SizedBox(height: 30),

        FlipCard(
          front: "Tap to Reveal",
          back: role,
        ),

        const SizedBox(height: 30),

        ElevatedButton(
          onPressed: () {
  setState(() {
    flipped = false;

    if (index < widget.players.length - 1) {
      index++;
    } else {
      // 🚨 GAME ENDS HERE
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => VoteScreen(
            players: widget.players,
            impostor: widget.impostor,
          ),
        ),
      );
    }
  });
},
  
          child: const Text("Next Player"),
        ),
      ],
    ),
  ),
),
    );
  }
}

// ================= VOTING =================

class VoteScreen extends StatefulWidget {
  final String impostor;
  final List<String> players;

  const VoteScreen({super.key, required this.impostor, required this.players});

  @override
  State<VoteScreen> createState() => _VoteScreenState();
}

class _VoteScreenState extends State<VoteScreen> {
  String selected = "";
  bool reveal = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
  decoration: gradientBG,
  child: Center(
    child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Text(
          "Who is the Impostor?",
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        ),

        const SizedBox(height: 20),

        ...widget.players.map(
          (p) => Padding(
            padding: const EdgeInsets.all(6),
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                foregroundColor: Colors.white,
              ),
              onPressed: () {
                setState(() => selected = p);
              },
              child: Text(p),
            ),
          ),
        ),

        const SizedBox(height: 20),

        ElevatedButton(
          onPressed: selected.isEmpty
              ? null
              : () => setState(() => reveal = true),
          child: const Text("Reveal"),
        ),
      ],
    ),
  ),
),
    );
  }
}

class FlipCard extends StatefulWidget {
  final String front;
  final String back;

  const FlipCard({super.key, required this.front, required this.back});

  @override
  State<FlipCard> createState() => _FlipCardState();
}

class _FlipCardState extends State<FlipCard>
    with SingleTickerProviderStateMixin {
  late AnimationController controller;

@override
void initState() {
  super.initState();
  
  controller = AnimationController(
    duration: const Duration(milliseconds: 600),
    vsync: this,
    
  );

  controller.reset(); // 🔥 ensures fresh start
}
  void toggle() {
    if (controller.isCompleted) {
      controller.reverse();
    } else {
      controller.forward();
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: toggle,
      child: AnimatedBuilder(
        animation: controller,
        builder: (context, child) {
          final angle = controller.value * 3.1416;
          final isFront = controller.value < 0.5;

          return Transform(
            transform: Matrix4.identity()
              ..setEntry(3, 2, 0.001)
              ..rotateY(angle),
            alignment: Alignment.center,
            child: isFront
                ? buildCard(widget.front)
                : Transform(
                    transform: Matrix4.identity()..rotateY(3.1416),
                    alignment: Alignment.center,
                    child: buildCard(widget.back),
                  ),
          );
        },
      ),
    );
  }

  Widget buildCard(String text) {
    return Container(
      height: 220,
      width: 300,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        color: Colors.white.withOpacity(0.2),
      ),
      child: Center(
        child: Text(
          text,
          style: const TextStyle(
            fontSize: 26,
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}

*/