import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../game/color_utils.dart';
import '../game/game_controller.dart';
import '../theme.dart';
import '../widgets/hud.dart';

const double _lumaThreshold = 0.179;

class GameScreen extends StatefulWidget {
  const GameScreen({super.key});

  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> {
  final GameController _game = GameController();

  @override
  void initState() {
    super.initState();
    _game.init();
    _game.start();
  }

  @override
  void dispose() {
    _game.dispose();
    super.dispose();
  }

  void _close() => Navigator.of(context).pop();

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _game,
      builder: (context, _) {
        final g = _game;
        final isShow = g.phase == GamePhase.show;
        final bg = isShow ? g.target.toColor() : AppColors.bg;

        return Scaffold(
          backgroundColor: Colors.transparent,
          body: AnimatedContainer(
            duration: const Duration(milliseconds: 250),
            color: bg,
            child: SafeArea(
              child: switch (g.phase) {
                GamePhase.show => _ShowView(game: g, onClose: _close),
                GamePhase.choose || GamePhase.reveal => _ChooseView(game: g, onClose: _close),
                GamePhase.over => _OverView(game: g, onClose: _close),
              },
            ),
          ),
        );
      },
    );
  }
}

// ───────────────────────── Renk gösterimi ─────────────────────────

class _ShowView extends StatelessWidget {
  const _ShowView({required this.game, required this.onClose});

  final GameController game;
  final VoidCallback onClose;

  @override
  Widget build(BuildContext context) {
    final target = game.target;
    final fg = target.luminance > _lumaThreshold ? AppColors.bg : Colors.white;
    final seconds = (game.remainingMs / 1000).ceil();
    final bonus = (game.remainingMs / 1000).floor() * 5;

    return Column(
      children: [
        Hud(
          level: game.level,
          lives: game.lives,
          score: game.score,
          color: fg,
          onClose: onClose,
        ),
        Expanded(
          child: Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Bu rengi aklında tut',
                  style: TextStyle(color: fg, fontSize: 20, fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 28),
                SizedBox(
                  width: 120,
                  height: 120,
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      SizedBox(
                        width: 120,
                        height: 120,
                        child: CircularProgressIndicator(
                          value: game.remainingMs / (GameController.viewSeconds * 1000),
                          strokeWidth: 6,
                          color: fg,
                          backgroundColor: fg.withAlpha(50),
                        ),
                      ),
                      Text(
                        '$seconds',
                        style: TextStyle(color: fg, fontSize: 44, fontWeight: FontWeight.w800),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                Text(
                  'Hazırsan geç: +$bonus bonus',
                  style: TextStyle(color: fg.withAlpha(200), fontSize: 14),
                ),
              ],
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(32, 0, 32, 32),
          child: SizedBox(
            width: double.infinity,
            height: 58,
            child: FilledButton(
              style: FilledButton.styleFrom(
                backgroundColor: fg,
                foregroundColor: target.toColor(),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(29)),
              ),
              onPressed: game.skipView,
              child: const Text(
                'Hazırım',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

// ───────────────────────── Kart seçimi ─────────────────────────

class _ChooseView extends StatelessWidget {
  const _ChooseView({required this.game, required this.onClose});

  final GameController game;
  final VoidCallback onClose;

  @override
  Widget build(BuildContext context) {
    final revealing = game.phase == GamePhase.reveal;

    String headline;
    Color headlineColor = Colors.white;
    if (!revealing) {
      headline = 'Hangisiydi?';
    } else if (game.lastCorrect) {
      headline = 'Doğru!  +${game.lastGain}';
      headlineColor = AppColors.good;
    } else {
      headline = 'Yanlış! Doğru kart işaretlendi';
      headlineColor = AppColors.bad;
    }

    return Column(
      children: [
        Hud(
          level: game.level,
          lives: game.lives,
          score: game.score,
          color: Colors.white,
          onClose: onClose,
        ),
        Padding(
          padding: const EdgeInsets.only(top: 12, bottom: 4),
          child: Text(
            headline,
            style: TextStyle(color: headlineColor, fontSize: 22, fontWeight: FontWeight.w800),
          ),
        ),
        Text(
          '${game.difficulty.cardCount} kart',
          style: const TextStyle(color: AppColors.textDim, fontSize: 13),
        ),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: LayoutBuilder(
              builder: (context, constraints) {
                final n = game.round.cards.length;
                final cols = n <= 6 ? 2 : 3;
                final rows = (n / cols).ceil();
                const gap = 14.0;
                final byW = (constraints.maxWidth - gap * (cols - 1)) / cols;
                final byH = (constraints.maxHeight - gap * (rows - 1)) / rows;
                final size = math.max(40.0, math.min(byW, byH));

                return Center(
                  child: Wrap(
                    alignment: WrapAlignment.center,
                    runAlignment: WrapAlignment.center,
                    spacing: gap,
                    runSpacing: gap,
                    children: [
                      for (var i = 0; i < n; i++)
                        _CardTile(
                          size: size,
                          color: game.round.cards[i],
                          state: _stateFor(i),
                          onTap: () => game.pick(i),
                        ),
                    ],
                  ),
                );
              },
            ),
          ),
        ),
      ],
    );
  }

  _TileState _stateFor(int i) {
    if (game.phase != GamePhase.reveal) return _TileState.idle;
    if (i == game.round.correctIndex) return _TileState.correct;
    if (i == game.selectedIndex) return _TileState.wrong;
    return _TileState.dimmed;
  }
}

enum _TileState { idle, correct, wrong, dimmed }

class _CardTile extends StatelessWidget {
  const _CardTile({
    required this.size,
    required this.color,
    required this.state,
    required this.onTap,
  });

  final double size;
  final Rgb color;
  final _TileState state;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final Color borderColor;
    final IconData? icon;
    switch (state) {
      case _TileState.correct:
        borderColor = AppColors.good;
        icon = Icons.check_rounded;
      case _TileState.wrong:
        borderColor = AppColors.bad;
        icon = Icons.close_rounded;
      case _TileState.idle:
      case _TileState.dimmed:
        borderColor = Colors.transparent;
        icon = null;
    }

    final iconColor = color.luminance > _lumaThreshold ? AppColors.bg : Colors.white;

    return GestureDetector(
      onTap: onTap,
      child: AnimatedOpacity(
        duration: const Duration(milliseconds: 200),
        opacity: state == _TileState.dimmed ? 0.3 : 1,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          width: size,
          height: size,
          decoration: BoxDecoration(
            color: color.toColor(),
            borderRadius: BorderRadius.circular(22),
            border: Border.all(color: borderColor, width: 5),
          ),
          child: icon == null ? null : Icon(icon, color: iconColor, size: size * 0.4),
        ),
      ),
    );
  }
}

// ───────────────────────── Oyun sonu ─────────────────────────

class _OverView extends StatelessWidget {
  const _OverView({required this.game, required this.onClose});

  final GameController game;
  final VoidCallback onClose;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Oyun bitti',
              style: TextStyle(fontSize: 32, fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 24),
            Text(
              '${game.score}',
              style: const TextStyle(
                fontSize: 72,
                fontWeight: FontWeight.w900,
                color: AppColors.accent,
              ),
            ),
            const Text('puan', style: TextStyle(color: AppColors.textDim, fontSize: 16)),
            const SizedBox(height: 16),
            Text(
              'Ulaşılan seviye: ${game.level}',
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 8),
            if (game.isNewBest)
              const Text(
                'Yeni rekor!',
                style: TextStyle(
                  color: AppColors.good,
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                ),
              )
            else
              Text(
                'En yüksek skor: ${game.bestScore}',
                style: const TextStyle(color: AppColors.textDim, fontSize: 16),
              ),
            const SizedBox(height: 40),
            SizedBox(
              width: 240,
              height: 56,
              child: FilledButton(
                style: FilledButton.styleFrom(
                  backgroundColor: AppColors.accent,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
                ),
                onPressed: game.start,
                child: const Text(
                  'Tekrar oyna',
                  style: TextStyle(fontSize: 19, fontWeight: FontWeight.w700),
                ),
              ),
            ),
            const SizedBox(height: 12),
            TextButton(
              onPressed: onClose,
              child: const Text('Ana menü', style: TextStyle(fontSize: 16)),
            ),
          ],
        ),
      ),
    );
  }
}
