import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../audio/audio_service.dart';
import '../settings/app_settings.dart';
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
    // Tarayıcılar ses için kullanıcı dokunuşu ister; müziği burada başlatıyoruz.
    if (AppSettings.instance.musicOn) AudioService.instance.playMusic();
    await Navigator.of(context).push(
      MaterialPageRoute<void>(builder: (_) => const GameScreen()),
    );
    _loadBest();
  }

  @override
  Widget build(BuildContext context) {
    final settings = SettingsScope.of(context);
    final t = settings.t;

    return Scaffold(
      body: SafeArea(
        child: Stack(
          children: [
            Center(
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
                    Text(
                      t.appName,
                      style: const TextStyle(
                        fontSize: 34,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 0.5,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      t.tagline,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        color: AppColors.textDim,
                        fontSize: 15,
                        height: 1.4,
                      ),
                    ),
                    const SizedBox(height: 32),
                    SizedBox(
                      width: 220,
                      height: 56,
                      child: FilledButton(
                        style: FilledButton.styleFrom(
                          backgroundColor: AppColors.accent,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(28),
                          ),
                        ),
                        onPressed: _play,
                        child: Text(
                          t.play,
                          style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w700),
                        ),
                      ),
                    ),
                    const SizedBox(height: 28),
                    if (_bestScore > 0)
                      Text(
                        t.bestLine(_bestScore, _bestLevel),
                        style: const TextStyle(color: AppColors.textDim, fontSize: 14),
                      ),
                    const SizedBox(height: 20),
                    Text(
                      t.howTo,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        color: AppColors.textDim,
                        fontSize: 13,
                        height: 1.5,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            // Sağ üst: dil ve müzik
            Positioned(
              top: 4,
              right: 8,
              child: Row(
                children: [
                  _LangButton(
                    label: 'EN',
                    selected: settings.lang == 'en',
                    onTap: () => settings.setLang('en'),
                  ),
                  _LangButton(
                    label: 'TR',
                    selected: settings.lang == 'tr',
                    onTap: () => settings.setLang('tr'),
                  ),
                  IconButton(
                    tooltip: t.musicTooltip,
                    onPressed: () => settings.setMusic(!settings.musicOn),
                    icon: Icon(
                      settings.musicOn ? Icons.music_note_rounded : Icons.music_off_rounded,
                      color: AppColors.textDim,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _LangButton extends StatelessWidget {
  const _LangButton({required this.label, required this.selected, required this.onTap});

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return TextButton(
      onPressed: onTap,
      style: TextButton.styleFrom(
        minimumSize: const Size(44, 40),
        padding: const EdgeInsets.symmetric(horizontal: 10),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontWeight: FontWeight.w800,
          color: selected ? AppColors.accent : AppColors.textDim,
        ),
      ),
    );
  }
}
