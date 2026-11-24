import 'dart:async';
import 'package:flutter/material.dart';

// ---------- Colors ----------
const kPrimary = Color(0xFF6366F1);
const kBg = Color(0xFFEDE9FE);
const kSuccess = Color(0xFF10B981);
const kError = Color(0xFFEF4444);
const kWarning = Color(0xFFF59E0B);

class QuizApp extends StatelessWidget {
  const QuizApp({super.key});
  @override
  Widget build(BuildContext context) => MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'True or False',
        theme: ThemeData(
          useMaterial3: true,
          colorSchemeSeed: kPrimary,
          scaffoldBackgroundColor: const Color(0xFFF8F7FF),
        ),
        home: const SplashScreen(),
      );
}

// ---------- Models & in-memory data ----------
class Question {
  final String text;
  final bool answer;
  final String explain;
  const Question(this.text, this.answer, this.explain);
}

class Category {
  final String name;
  final IconData icon;
  final Color color;
  const Category(this.name, this.icon, this.color);
}

class HistoryItem {
  final String category, difficulty, date;
  final int score, total;
  HistoryItem(this.category, this.difficulty, this.score, this.total, this.date);
}

const categories = [
  Category('General Knowledge', Icons.public, Color(0xFF14B8A6)),
  Category('Science', Icons.science, Color(0xFF3B82F6)),
  Category('Technology', Icons.settings, Color(0xFF6366F1)),
  Category('Sports', Icons.sports_basketball, Color(0xFFEF4444)),
  Category('History', Icons.account_balance, Color(0xFF4F46E5)),
];

// Har category ke liye aur sawal yahan add karein (ya SQLite/API se load karein)
const questionBank = <String, List<Question>>{
  'General Knowledge': [
    Question('Mars is known as the Red Planet?', true, 'Mars is known as the Red Planet.'),
    Question('The Sahara is the largest ocean?', false, 'The Sahara is a desert, not an ocean.'),
    Question('Humans have 206 bones as adults?', true, 'Adults have 206 bones.'),
  ],
  'Science': [
    Question('Water boils at 100°C at sea level?', true, 'Water boils at 100°C.'),
    Question('Sound travels faster than light?', false, 'Light is much faster than sound.'),
    Question('The Sun is a star?', true, 'The Sun is a star.'),
  ],
  'Technology': [
    Question('Flutter uses the Dart language?', true, 'Flutter apps are written in Dart.'),
    Question('HTML is a programming language?', false, 'HTML is a markup language.'),
    Question('SQLite is a database?', true, 'SQLite is a lightweight database.'),
  ],
  'Sports': [
    Question('A football team has 11 players on the field?', true, 'Each side has 11 players.'),
    Question('Cricket is played with a racket?', false, 'Cricket uses a bat.'),
    Question('The Olympics happen every 4 years?', true, 'Summer Olympics are every 4 years.'),
  ],
  'History': [
    Question('Pakistan became independent in 1947?', true, 'Independence was in 1947.'),
    Question('The Great Wall is in Egypt?', false, 'The Great Wall is in China.'),
    Question('World War II ended in 1945?', true, 'It ended in 1945.'),
  ],
};

final List<HistoryItem> gameHistory = [];
bool soundOn = true, notificationsOn = true;

// ---------- Common widgets ----------
class BigButton extends StatelessWidget {
  final String label;
  final VoidCallback onTap;
  final Color color;
  final bool outlined;
  const BigButton(this.label, this.onTap,
      {super.key, this.color = kPrimary, this.outlined = false});
  @override
  Widget build(BuildContext context) => SizedBox(
        width: double.infinity,
        height: 52,
        child: ElevatedButton(
          onPressed: onTap,
          style: ElevatedButton.styleFrom(
            backgroundColor: outlined ? Colors.white : color,
            foregroundColor: outlined ? color : Colors.white,
            elevation: 0,
            side: outlined ? BorderSide(color: color) : null,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          ),
          child: Text(label, style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w600)),
        ),
      );
}

Widget bulb(double size) => Icon(Icons.lightbulb, size: size, color: kWarning);

Widget iconBadge(IconData i, Color c, {double size = 44}) => Container(
      width: size,
      height: size,
      decoration: BoxDecoration(color: c, shape: BoxShape.circle),
      child: Icon(i, color: Colors.white, size: size * 0.55),
    );

// ---------- 1. Splash ----------
class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});
  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    Timer(const Duration(seconds: 2), () {
      if (!mounted) return;
      Navigator.pushReplacement(
          context, MaterialPageRoute(builder: (_) => const WelcomeScreen()));
    });
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        body: Container(
          width: double.infinity,
          decoration: const BoxDecoration(
            gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [Color(0xFF4338CA), Color(0xFF312E81)]),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              bulb(110),
              const SizedBox(height: 16),
              const Text('True or False',
                  style: TextStyle(color: Colors.white, fontSize: 34, fontWeight: FontWeight.bold)),
              const Text('Quiz Game', style: TextStyle(color: Colors.white, fontSize: 22)),
              const SizedBox(height: 16),
              const Text('Test your knowledge\nwith simple questions!',
                  textAlign: TextAlign.center, style: TextStyle(color: Colors.white70)),
              const SizedBox(height: 70),
              const CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
              const SizedBox(height: 10),
              const Text('Loading...', style: TextStyle(color: Colors.white70)),
            ],
          ),
        ),
      );
}

// ---------- 2. Welcome ----------
class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});
  @override
  Widget build(BuildContext context) => Scaffold(
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              children: [
                Row(mainAxisAlignment: MainAxisAlignment.end, children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back, color: kPrimary),
                    onPressed: () =>
                        Navigator.of(context, rootNavigator: true).pop(),
                  ),
                  const Spacer(),
                  IconButton(
                    icon: const Icon(Icons.history, color: kPrimary),
                    onPressed: () => Navigator.push(context,
                        MaterialPageRoute(builder: (_) => const HistoryScreen())),
                  ),
                  IconButton(
                    icon: const Icon(Icons.settings, color: kPrimary),
                    onPressed: () => Navigator.push(context,
                        MaterialPageRoute(builder: (_) => const SettingsScreen())),
                  ),
                ]),
                const Spacer(),
                bulb(110),
                const SizedBox(height: 12),
                const Text('True or False',
                    style: TextStyle(fontSize: 34, fontWeight: FontWeight.bold)),
                const Text('Quiz Game',
                    style: TextStyle(fontSize: 22, fontWeight: FontWeight.w600)),
                const SizedBox(height: 16),
                const Text('Choose a category and\nstart your quiz journey!',
                    textAlign: TextAlign.center),
                const SizedBox(height: 28),
                BigButton('Get Started', () => Navigator.push(context,
                    MaterialPageRoute(builder: (_) => const CategoryScreen()))),
                const Spacer(),
              ],
            ),
          ),
        ),
      );
}

// ---------- 3. Category ----------
class CategoryScreen extends StatelessWidget {
  const CategoryScreen({super.key});
  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(title: const Text('Select Category'), centerTitle: true),
        body: ListView.separated(
          padding: const EdgeInsets.all(16),
          itemCount: categories.length,
          separatorBuilder: (_, __) => const SizedBox(height: 12),
          itemBuilder: (_, i) {
            final c = categories[i];
            return InkWell(
              borderRadius: BorderRadius.circular(16),
              onTap: () => Navigator.push(context,
                  MaterialPageRoute(builder: (_) => DifficultyScreen(category: c))),
              child: Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                    color: c.color.withOpacity(0.08),
                    borderRadius: BorderRadius.circular(16)),
                child: Row(children: [
                  iconBadge(c.icon, c.color, size: 48),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      Text(c.name, style: const TextStyle(fontWeight: FontWeight.w600)),
                      const Text('10 questions',
                          style: TextStyle(fontSize: 12, color: Colors.grey)),
                    ]),
                  ),
                  const Icon(Icons.chevron_right, color: Colors.grey),
                ]),
              ),
            );
          },
        ),
      );
}

// ---------- 4. Difficulty ----------
class DifficultyScreen extends StatelessWidget {
  final Category category;
  const DifficultyScreen({super.key, required this.category});
  @override
  Widget build(BuildContext context) {
    final levels = [
      ['Easy', Icons.eco, kSuccess],
      ['Medium', Icons.local_fire_department, kWarning],
      ['Hard', Icons.star, kError],
    ];
    return Scaffold(
      appBar: AppBar(title: const Text('Select Difficulty'), centerTitle: true),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          for (final l in levels)
            Padding(
              padding: const EdgeInsets.only(bottom: 14),
              child: InkWell(
                borderRadius: BorderRadius.circular(16),
                onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (_) => QuizScreen(
                            category: category, difficulty: l[0] as String))),
                child: Container(
                  padding: const EdgeInsets.all(18),
                  decoration: BoxDecoration(
                      color: (l[2] as Color).withOpacity(0.15),
                      borderRadius: BorderRadius.circular(16)),
                  child: Row(children: [
                    iconBadge(l[1] as IconData, l[2] as Color, size: 46),
                    const SizedBox(width: 14),
                    Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      Text(l[0] as String,
                          style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 16)),
                      const Text('10 questions',
                          style: TextStyle(fontSize: 12, color: Colors.grey)),
                    ]),
                  ]),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

// ---------- 5. Quiz Question ----------
class QuizScreen extends StatefulWidget {
  final Category category;
  final String difficulty;
  const QuizScreen({super.key, required this.category, required this.difficulty});
  @override
  State<QuizScreen> createState() => _QuizScreenState();
}

class _QuizScreenState extends State<QuizScreen> {
  late final List<Question> questions = questionBank[widget.category.name]!;
  int index = 0, score = 0, seconds = 25;
  Timer? timer;

  @override
  void initState() {
    super.initState();
    startTimer();
  }

  void startTimer() {
    timer?.cancel();
    seconds = 25;
    timer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (seconds <= 1) {
        t.cancel();
        answer(null); // time up = wrong
      } else {
        setState(() => seconds--);
      }
    });
  }

  Future<void> answer(bool? choice) async {
    timer?.cancel();
    final q = questions[index];
    final correct = choice == q.answer;
    if (correct) score++;
    await Navigator.push(context,
        MaterialPageRoute(builder: (_) => FeedbackScreen(correct: correct, question: q)));
    if (!mounted) return;
    if (index + 1 >= questions.length) {
      final now = DateTime.now();
      String two(int n) => n.toString().padLeft(2, '0');
      gameHistory.insert(
          0,
          HistoryItem(widget.category.name, widget.difficulty, score, questions.length,
              '${now.year}-${two(now.month)}-${two(now.day)} ${two(now.hour)}:${two(now.minute)}'));
      Navigator.pushReplacement(
          context,
          MaterialPageRoute(
              builder: (_) => ResultScreen(
                  score: score,
                  total: questions.length,
                  category: widget.category,
                  difficulty: widget.difficulty)));
    } else {
      setState(() => index++);
      startTimer();
    }
  }

  @override
  void dispose() {
    timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(
          leading: IconButton(icon: const Icon(Icons.close), onPressed: () => Navigator.pop(context)),
          title: Text('${index + 1}/${questions.length}'),
          centerTitle: true,
          actions: [
            Padding(
              padding: const EdgeInsets.only(right: 16),
              child: Row(children: [
                const Icon(Icons.timer_outlined, size: 20, color: kPrimary),
                const SizedBox(width: 4),
                Text('$seconds', style: const TextStyle(fontWeight: FontWeight.bold)),
              ]),
            ),
          ],
        ),
        body: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(18)),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                      color: kBg, borderRadius: BorderRadius.circular(20)),
                  child: Text(widget.category.name,
                      style: const TextStyle(fontSize: 11, color: kPrimary)),
                ),
                const SizedBox(height: 16),
                Text(questions[index].text,
                    style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                const SizedBox(height: 40),
              ]),
            ),
            const SizedBox(height: 20),
            BigButton('True', () => answer(true), color: kSuccess),
            const SizedBox(height: 14),
            BigButton('False', () => answer(false), color: kError),
          ]),
        ),
      );
}

// ---------- 6 & 7. Correct / Wrong ----------
class FeedbackScreen extends StatelessWidget {
  final bool correct;
  final Question question;
  const FeedbackScreen({super.key, required this.correct, required this.question});
  @override
  Widget build(BuildContext context) {
    final c = correct ? kSuccess : kError;
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(children: [
            const Spacer(),
            Container(
              padding: const EdgeInsets.all(26),
              decoration: BoxDecoration(color: c.withOpacity(0.12), shape: BoxShape.circle),
              child: iconBadge(correct ? Icons.check : Icons.close, c, size: 90),
            ),
            const SizedBox(height: 24),
            Text(correct ? 'Correct!' : 'Wrong!',
                style: const TextStyle(fontSize: 30, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            Text(
              correct
                  ? question.explain
                  : 'The correct answer is\n${question.answer ? 'True' : 'False'}.',
              textAlign: TextAlign.center,
            ),
            const Spacer(),
            BigButton('Next', () => Navigator.pop(context)),
          ]),
        ),
      ),
    );
  }
}

// ---------- 8. Result ----------
class ResultScreen extends StatelessWidget {
  final int score, total;
  final Category category;
  final String difficulty;
  const ResultScreen(
      {super.key,
      required this.score,
      required this.total,
      required this.category,
      required this.difficulty});

  Widget stat(IconData i, Color c, String label, int v) => Column(children: [
        Row(mainAxisSize: MainAxisSize.min, children: [
          Icon(i, color: c, size: 20),
          const SizedBox(width: 6),
          Text(label, style: const TextStyle(fontSize: 12)),
        ]),
        const SizedBox(height: 4),
        Text('$v', style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
      ]);

  @override
  Widget build(BuildContext context) => Scaffold(
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(children: [
              const Spacer(),
              const Icon(Icons.emoji_events, size: 80, color: kWarning),
              const SizedBox(height: 8),
              const Text('Quiz Completed!',
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
              const SizedBox(height: 20),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                    color: Colors.white, borderRadius: BorderRadius.circular(16)),
                child: Column(children: [
                  const Text('Your Score'),
                  Text('$score / $total',
                      style: const TextStyle(fontSize: 40, fontWeight: FontWeight.bold)),
                  const Divider(height: 28),
                  Row(mainAxisAlignment: MainAxisAlignment.spaceEvenly, children: [
                    stat(Icons.check_circle, kSuccess, 'Correct', score),
                    stat(Icons.cancel, kError, 'Wrong', total - score),
                  ]),
                ]),
              ),
              const Spacer(),
              BigButton(
                  'Play Again',
                  () => Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                          builder: (_) =>
                              QuizScreen(category: category, difficulty: difficulty)))),
              const SizedBox(height: 12),
              BigButton(
                  'Back to Home',
                  () => Navigator.pushAndRemoveUntil(
                      context,
                      MaterialPageRoute(builder: (_) => const WelcomeScreen()),
                      (r) => false),
                  outlined: true),
            ]),
          ),
        ),
      );
}

// ---------- 9. History ----------
class HistoryScreen extends StatelessWidget {
  const HistoryScreen({super.key});
  Color diffColor(String d) =>
      d == 'Easy' ? kSuccess : (d == 'Medium' ? kWarning : kError);

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(
          backgroundColor: kPrimary,
          foregroundColor: Colors.white,
          title: const Text('Game History'),
          centerTitle: true,
        ),
        body: gameHistory.isEmpty
            ? const Center(child: Text('No games played yet'))
            : ListView.separated(
                padding: const EdgeInsets.all(16),
                itemCount: gameHistory.length,
                separatorBuilder: (_, __) => const SizedBox(height: 10),
                itemBuilder: (_, i) {
                  final h = gameHistory[i];
                  final cat = categories.firstWhere((c) => c.name == h.category);
                  return Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                        color: Colors.white, borderRadius: BorderRadius.circular(14)),
                    child: Row(children: [
                      iconBadge(cat.icon, cat.color),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                          Text(h.category,
                              style: const TextStyle(fontWeight: FontWeight.w600)),
                          Text(h.difficulty,
                              style: TextStyle(fontSize: 12, color: diffColor(h.difficulty))),
                          Row(children: [
                            Text('${h.score}/${h.total}',
                                style: const TextStyle(fontWeight: FontWeight.bold)),
                            const SizedBox(width: 10),
                            Text(h.date,
                                style: const TextStyle(fontSize: 11, color: Colors.grey)),
                          ]),
                        ]),
                      ),
                      const Icon(Icons.chevron_right, color: Colors.grey),
                    ]),
                  );
                },
              ),
      );
}

// ---------- 10. Settings ----------
class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});
  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(title: const Text('Settings'), centerTitle: true),
        body: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(children: [
            Container(
              decoration: BoxDecoration(
                  color: Colors.white, borderRadius: BorderRadius.circular(16)),
              child: Column(children: [
                SwitchListTile(
                  secondary: const Icon(Icons.volume_up, color: kPrimary),
                  title: const Text('Sound'),
                  value: soundOn,
                  onChanged: (v) => setState(() => soundOn = v),
                ),
                SwitchListTile(
                  secondary: const Icon(Icons.notifications, color: kPrimary),
                  title: const Text('Notifications'),
                  value: notificationsOn,
                  onChanged: (v) => setState(() => notificationsOn = v),
                ),
                const ListTile(
                  leading: Icon(Icons.brightness_6, color: kPrimary),
                  title: Text('Theme'),
                  trailing: Text('Light  >'),
                ),
                const ListTile(
                  leading: Icon(Icons.info, color: kPrimary),
                  title: Text('About'),
                  trailing: Icon(Icons.chevron_right),
                ),
              ]),
            ),
            const Spacer(),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: const BoxDecoration(color: kBg, shape: BoxShape.circle),
              child: const Icon(Icons.lightbulb_outline, size: 44, color: kPrimary),
            ),
            const SizedBox(height: 10),
            const Text('Keep Learning\nKeep Growing',
                textAlign: TextAlign.center, style: TextStyle(color: kPrimary)),
            const Spacer(),
          ]),
        ),
      );
}