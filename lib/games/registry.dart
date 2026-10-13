import 'package:flutter/material.dart';

import '../core/mini_game.dart';
import 'color_match/color_match_screen.dart';

/// Ana menüde görünen oyun(lar).
final List<MiniGame> allGames = [
  MiniGame(
    id: 'color_match',
    nameEn: 'Color Match',
    nameTr: 'Renk Eşle',
    descEn: 'Memorize a color, find its exact twin.',
    descTr: 'Rengi aklında tut, aynısını bul.',
    icon: Icons.palette_rounded,
    color: const Color(0xFFFF5E7E),
    builder: () => const ColorMatchScreen(),
  ),
];
