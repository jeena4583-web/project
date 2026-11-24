import 'package:flutter/material.dart';
import 'guess_number.dart' as guess;
import 'quiz_game.dart' as quiz;

void main() => runApp(const GameHubApp());

class GameHubApp extends StatelessWidget {
  const GameHubApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData.dark(useMaterial3: true),
      home: const MenuScreen(),
    );
  }
}

class MenuScreen extends StatelessWidget {
  const MenuScreen({super.key});

  Widget _card(BuildContext context,
      {required String title,
      required String subtitle,
      required IconData icon,
      required Color color,
      required Widget game}) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 10),
      child: InkWell(
        borderRadius: BorderRadius.circular(22),
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => game),
        ),
        child: Container(
          height: 110,
          padding: const EdgeInsets.symmetric(horizontal: 20),
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(22),
          ),
          child: Row(
            children: [
              Icon(icon, size: 52, color: Colors.white),
              const SizedBox(width: 18),
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title,
                        style: const TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: Colors.white)),
                    const SizedBox(height: 4),
                    Text(subtitle,
                        style: const TextStyle(
                            fontSize: 14, color: Colors.white70)),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right, color: Colors.white),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF2A0A5E), Color(0xFF000000)],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              const Spacer(),
              const Icon(Icons.videogame_asset,
                  size: 100, color: Color(0xFF8E6FE0)),
              const SizedBox(height: 12),
              const Text('My Games',
                  style: TextStyle(fontSize: 34, fontWeight: FontWeight.bold)),
              const SizedBox(height: 4),
              const Text('Ek game chuno',
                  style: TextStyle(fontSize: 16, color: Colors.white70)),
              const Spacer(),
              _card(
                context,
                title: 'Guess Number',
                subtitle: '3 levels, number guess karo',
                icon: Icons.casino,
                color: const Color(0xFF5E3C9C),
                game: const guess.GuessApp(),
              ),
              _card(
                context,
                title: 'True or False Quiz',
                subtitle: '5 categories, timer ke saath',
                icon: Icons.lightbulb,
                color: const Color(0xFF6366F1),
                game: const quiz.QuizApp(),
              ),
              const Spacer(),
            ],
          ),
        ),
      ),
    );
  }
}