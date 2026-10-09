import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'choice_builder.dart';
import 'color_utils.dart';
import 'difficulty.dart';

enum GamePhase { show, choose, reveal, over }

class GameController extends ChangeNotifier {
  GameController({ChoiceBuilder? builder}) : _builder = builder ?? ChoiceBuilder();

  static const int viewSeconds = 10;
  static const int startLives = 3;
  static const String _bestScoreKey = 'best_score';
  static const String _bestLevelKey = 'best_level';

  final ChoiceBuilder _builder;

  GamePhase phase = GamePhase.show;
  int level = 1;
  int lives = startLives;
  int score = 0;
  int streak = 0;
  int bestScore = 0;
  int bestLevel = 1;
  bool isNewBest = false;

  late Round round;
  late Difficulty difficulty;

  int? selectedIndex;
  int lastGain = 0;
  bool lastCorrect = false;

  /// Hedef renk görünme süresinden kalan milisaniye.
  int remainingMs = viewSeconds * 1000;

  Timer? _viewTimer;
  Timer? _revealTimer;
  bool _disposed = false;

  Future<void> init() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      bestScore = prefs.getInt(_bestScoreKey) ?? 0;
      bestLevel = prefs.getInt(_bestLevelKey) ?? 1;
    } catch (_) {
      // Kayıt okunamazsa oyun yine de çalışsın.
    }
    _safeNotify();
  }

  void start() {
    _cancelTimers();
    level = 1;
    lives = startLives;
    score = 0;
    streak = 0;
    isNewBest = false;
    _startRound();
  }

  void _startRound() {
    difficulty = Difficulty.forLevel(level);
    round = _builder.buildWithRetry(
      cardCount: difficulty.cardCount,
      deltaE: difficulty.deltaE,
    );
    selectedIndex = null;
    remainingMs = viewSeconds * 1000;
    phase = GamePhase.show;
    _safeNotify();

    _viewTimer?.cancel();
    _viewTimer = Timer.periodic(const Duration(milliseconds: 100), (t) {
      remainingMs -= 100;
      if (remainingMs <= 0) {
        remainingMs = 0;
        t.cancel();
        _goChoose();
      } else {
        _safeNotify();
      }
    });
  }

  /// Oyuncu "Hazırım" der; kalan süre bonus puana dönüşür.
  void skipView() {
    if (phase != GamePhase.show) return;
    _viewTimer?.cancel();
    _goChoose();
  }

  void _goChoose() {
    phase = GamePhase.choose;
    _safeNotify();
  }

  void pick(int index) {
    if (phase != GamePhase.choose) return;
    _revealTimer?.cancel();
    selectedIndex = index;
    lastCorrect = index == round.correctIndex;

    if (lastCorrect) {
      streak++;
      final skipBonus = (remainingMs / 1000).floor() * 5;
      final streakBonus = (streak - 1) * 10;
      lastGain = 100 + (level - 1) * 10 + skipBonus + streakBonus;
      score += lastGain;
      HapticFeedback.lightImpact();
    } else {
      streak = 0;
      lastGain = 0;
      lives--;
      HapticFeedback.heavyImpact();
    }

    phase = GamePhase.reveal;
    _safeNotify();

    _revealTimer = Timer(const Duration(milliseconds: 1400), () async {
      if (lives <= 0) {
        await _finish();
      } else {
        if (lastCorrect) level++;
        _startRound();
      }
    });
  }

  Future<void> _finish() async {
    if (score > bestScore) {
      bestScore = score;
      isNewBest = true;
    }
    if (level > bestLevel) bestLevel = level;
    phase = GamePhase.over;
    _safeNotify();
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt(_bestScoreKey, bestScore);
      await prefs.setInt(_bestLevelKey, bestLevel);
    } catch (_) {}
  }

  Rgb get target => round.target;

  void _cancelTimers() {
    _viewTimer?.cancel();
    _revealTimer?.cancel();
  }

  void _safeNotify() {
    if (!_disposed) notifyListeners();
  }

  @override
  void dispose() {
    _disposed = true;
    _cancelTimers();
    super.dispose();
  }
}
