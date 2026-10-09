/// Basit EN / TR metin tablosu. Varsayılan dil İngilizcedir.
class AppStrings {
  const AppStrings(this.isTr);

  final bool isTr;

  String _p(String en, String tr) => isTr ? tr : en;

  // Ana menü
  String get appName => 'Color Match';
  String get tagline => _p(
        'Memorize the color, then find the exact\nmatch among very similar cards.',
        'Rengi aklında tut, birbirine çok benzeyen\nkartlar arasından aynısını bul.',
      );
  String get play => _p('Play', 'Oyna');
  String bestLine(int score, int level) => _p(
        'Best score: $score  ·  Level $level',
        'En yüksek skor: $score  ·  Seviye $level',
      );
  String get howTo => _p(
        'You get 10 seconds to look, skip ahead when ready.\nYou have 3 lives, the game is endless.',
        '10 saniye bakabilirsin, hazırsan erken geç.\n3 canın var, oyun sonsuz.',
      );
  String get musicTooltip => _p('Music', 'Müzik');
  String get languageTooltip => _p('Language', 'Dil');

  // Oyun
  String get exit => _p('Exit', 'Çık');
  String level(int n) => _p('Level $n', 'Seviye $n');
  String get rememberColor => _p('Remember this color', 'Bu rengi aklında tut');
  String skipBonus(int n) => _p('Skip when ready: +$n bonus', 'Hazırsan geç: +$n bonus');
  String get ready => _p('Ready', 'Hazırım');
  String get whichOne => _p('Which one was it?', 'Hangisiydi?');
  String cards(int n) => _p('$n cards', '$n kart');
  String correct(int gain) => _p('Correct!  +$gain', 'Doğru!  +$gain');
  String get wrong => _p('Wrong! The right card is marked', 'Yanlış! Doğru kart işaretlendi');

  // Oyun sonu
  String get gameOver => _p('Game over', 'Oyun bitti');
  String get points => _p('points', 'puan');
  String levelReached(int n) => _p('Level reached: $n', 'Ulaşılan seviye: $n');
  String get newRecord => _p('New record!', 'Yeni rekor!');
  String bestScore(int n) => _p('Best score: $n', 'En yüksek skor: $n');
  String get playAgain => _p('Play again', 'Tekrar oyna');
  String get mainMenu => _p('Main menu', 'Ana menü');
}
