import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../theme.dart';
import 'game_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _bestScore = 0;
  int _bestLevel = 0;

  @override
  void initState() {
    super.initState();
    _loadBest();
  }

  Future<void> _loadBest() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      if (!mounted) return;
      setState(() {
        _bestScore = prefs.getInt('best_score') ?? 0;
        _bestLevel = prefs.getInt('best_level') ?? 0;
      });
    } catch (_) {}
  }

  Future<void> _play() async {
    await Navigator.of(context).push(
      MaterialPageRoute<void>(builder: (_) => const GameScreen()),
    );
    _loadBest();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(32),
                  child: Image.asset('assets/logo/logo.png', width: 144, height: 144),
                ),
                const SizedBox(height: 24),
                const Text(
                  'Color Match',
                  style: TextStyle(fontSize: 34, fontWeight: FontWeight.w800, letterSpacing: 0.5),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Rengi aklında tut, birbirine çok benzeyen\nkartlar arasından aynısını bul.',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: AppColors.textDim, fontSize: 15, height: 1.4),
                ),
                const SizedBox(height: 32),
                SizedBox(
                  width: 220,
                  height: 56,
                  child: FilledButton(
                    style: FilledButton.styleFrom(
                      backgroundColor: AppColors.accent,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
                    ),
                    onPressed: _play,
                    child: const Text(
                      'Oyna',
                      style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700),
                    ),
                  ),
                ),
                const SizedBox(height: 28),
                if (_bestScore > 0)
                  Text(
                    'En yüksek skor: $_bestScore  ·  Seviye $_bestLevel',
                    style: const TextStyle(color: AppColors.textDim, fontSize: 14),
                  ),
                const SizedBox(height: 20),
                const Text(
                  '10 saniye bakabilirsin, hazırsan erken geç.\n3 canın var, oyun sonsuz.',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: AppColors.textDim, fontSize: 13, height: 1.5),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
