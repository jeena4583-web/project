import 'dart:math';
import 'package:flutter/material.dart';


const Color kPurple = Color(0xFF5E3C9C);
const Color kGreen = Color(0xFF2E7D32);

const BoxDecoration kBackground = BoxDecoration(
  gradient: LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [Color(0xFF2A0A5E), Color(0xFF000000)],
  ),
);

class GuessApp extends StatelessWidget {
  const GuessApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData.dark(useMaterial3: true),
      home: const SplashScreen(),
    );
  }
}

// ---------------- Screen 1: Splash ----------------
class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(seconds: 2), () {
      if (!mounted) return;
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const StartScreen()),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: Color(0xFF151515),
      body: Center(
        child: Icon(Icons.casino_outlined, size: 120, color: Color(0xFFC77A10)),
      ),
    );
  }
}

// ---------------- Screen 2: Start ----------------
class StartScreen extends StatelessWidget {
  const StartScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: kBackground,
        padding: const EdgeInsets.all(24),
        child: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              IconButton(
                icon: const Icon(Icons.arrow_back),
                onPressed: () =>
                    Navigator.of(context, rootNavigator: true).pop(),
              ),
              const Spacer(),
              const Center(
                child: Icon(Icons.sports_esports,
                    size: 160, color: Color(0xFF8E6FE0)),
              ),
              const SizedBox(height: 40),
              const Text('Guess',
                  style: TextStyle(fontSize: 40, color: kPurple)),
              const Text('Number',
                  style: TextStyle(fontSize: 40, color: Colors.white)),
              const Spacer(),
              SizedBox(
                width: double.infinity,
                height: 64,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: kPurple,
                    foregroundColor: Colors.black,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20)),
                  ),
                  onPressed: () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const LevelScreen()),
                  ),
                  child: const Text('Start To Play',
                      style: TextStyle(fontSize: 22)),
                ),
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }
}

// ---------------- Screen 3: Level select ----------------
class LevelInfo {
  final int level;
  final String label;
  final int max;
  final Color color;
  const LevelInfo(this.level, this.label, this.max, this.color);
}

const List<LevelInfo> kLevels = [
  LevelInfo(1, 'Easy', 10, Colors.green),
  LevelInfo(2, 'Medium', 50, Colors.cyan),
  LevelInfo(3, 'Hard', 100, Colors.red),
];

class LevelScreen extends StatelessWidget {
  const LevelScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: kBackground,
        child: SafeArea(
          child: Column(
            children: [
              const Spacer(),
              const Icon(Icons.public, size: 180, color: Color(0xFFE0B84A)),
              const Spacer(),
              for (final l in kLevels)
                Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 36, vertical: 8),
                  child: InkWell(
                    borderRadius: BorderRadius.circular(20),
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => GameScreen(info: l)),
                    ),
                    child: Container(
                      height: 80,
                      decoration: BoxDecoration(
                        color: kPurple,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(
                        children: [
                          const SizedBox(width: 20),
                          Icon(Icons.diamond, size: 48, color: l.color),
                          const Spacer(),
                          Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text('level ${l.level}',
                                  style: const TextStyle(fontSize: 24)),
                              Text(l.label,
                                  style: const TextStyle(fontSize: 16)),
                            ],
                          ),
                          const Spacer(),
                          const SizedBox(width: 68),
                        ],
                      ),
                    ),
                  ),
                ),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }
}

// ---------------- Screen 4: Game ----------------
class GameScreen extends StatefulWidget {
  final LevelInfo info;
  const GameScreen({super.key, required this.info});

  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> {
  final Random _rnd = Random();
  late int _target;
  String _input = '';
  String _message = '';
  int _score = 0;

  @override
  void initState() {
    super.initState();
    _newTarget();
    _message = 'Number guess karo (1 - ${widget.info.max})';
  }

  void _newTarget() => _target = _rnd.nextInt(widget.info.max) + 1;

  void _press(String d) {
    final maxLen = widget.info.max.toString().length;
    if (_input.length >= maxLen) return;
    setState(() => _input += d);
  }

  void _clear() => setState(() => _input = '');

  void _check() {
    if (_input.isEmpty) return;
    final guess = int.parse(_input);
    setState(() {
      if (guess == _target) {
        _score += 10 * widget.info.level;
        _message = 'Sahi jawab! Naya number ban gaya';
        _newTarget();
      } else if (guess < _target) {
        _message = 'Thora bara number socho';
      } else {
        _message = 'Thora chhota number socho';
      }
      _input = '';
    });
  }

  Widget _key(String label,
      {VoidCallback? onTap, Color fill = const Color(0xFF0A0A0A), double fs = 28}) {
    return Padding(
      padding: const EdgeInsets.all(6),
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: onTap,
        child: Container(
          height: 56,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: fill,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: kGreen, width: 3),
            boxShadow: const [
              BoxShadow(color: Color(0x662E7D32), blurRadius: 10),
            ],
          ),
          child: Text(label, style: TextStyle(fontSize: fs)),
        ),
      ),
    );
  }

  Widget _num(String d) => Expanded(child: _key(d, onTap: () => _press(d)));

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: kBackground,
        child: SafeArea(
          child: Column(
            children: [
              const SizedBox(height: 10),
              Container(
                width: 160,
                height: 160,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(colors: [
                    const Color(0xFF1B5E20),
                    const Color(0xFF1B5E20).withOpacity(0.2),
                  ]),
                ),
                child: Text(_input.isEmpty ? '?' : _input,
                    style: const TextStyle(fontSize: 40)),
              ),
              const SizedBox(height: 16),
              Text(_message, style: const TextStyle(fontSize: 18)),
              const Spacer(),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 14),
                child: Column(
                  children: [
                    Row(children: [
                      _num('1'),
                      _num('2'),
                      _num('3'),
                      Expanded(child: _key('C', onTap: _clear)),
                    ]),
                    Row(children: [
                      _num('4'),
                      _num('5'),
                      _num('6'),
                      Expanded(
                        child: _key('Score',
                            fill: const Color(0xFF145A1E), fs: 16),
                      ),
                    ]),
                    Row(children: [
                      _num('7'),
                      _num('8'),
                      _num('9'),
                      Expanded(
                        child: _key('$_score',
                            fill: const Color(0xFF1F4D2A), fs: 26),
                      ),
                    ]),
                    Row(children: [
                      _num('0'),
                      Expanded(
                        flex: 3,
                        child: _key('Check', onTap: _check, fs: 22),
                      ),
                    ]),
                  ],
                ),
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }
}