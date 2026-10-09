import 'package:flutter/material.dart';

import '../game/game_controller.dart';

/// Üst bar: kapat, seviye, canlar ve skor.
class Hud extends StatelessWidget {
  const Hud({
    super.key,
    required this.level,
    required this.lives,
    required this.score,
    required this.color,
    required this.onClose,
  });

  final int level;
  final int lives;
  final int score;
  final Color color;
  final VoidCallback onClose;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(4, 4, 16, 0),
      child: Row(
        children: [
          IconButton(
            onPressed: onClose,
            icon: Icon(Icons.close_rounded, color: color),
            tooltip: 'Çık',
          ),
          Text(
            'Seviye $level',
            style: TextStyle(color: color, fontWeight: FontWeight.w700, fontSize: 16),
          ),
          const Spacer(),
          for (var i = 0; i < GameController.startLives; i++)
            Padding(
              padding: const EdgeInsets.only(right: 2),
              child: Icon(
                i < lives ? Icons.favorite_rounded : Icons.favorite_border_rounded,
                color: color,
                size: 22,
              ),
            ),
          const SizedBox(width: 12),
          Text(
            '$score',
            style: TextStyle(color: color, fontWeight: FontWeight.w800, fontSize: 18),
          ),
        ],
      ),
    );
  }
}
