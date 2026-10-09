# Color Match

Rengi aklında tut, birbirine çok benzeyen kartlar arasından aynısını bul. Sonsuz modlu Flutter oyunu.

## Nasıl oynanır
1. Ekranda bir renk görünür. En fazla **10 saniye** bakabilirsin, hazırsan **Hazırım** ile erken geçebilirsin (kalan saniye başına +5 bonus).
2. Renk kaybolur, birbirine çok yakın kartlar çıkar. Hedef rengin aynısını seç.
3. Doğru bilirsen seviye atlarsın, yanlışta 1 can gider. 3 can biter, oyun biter. Oyun sonsuzdur.

## Zorluk
Seviye geçtikçe sırayla biri artar:
- Kart sayısı: 4 → 9 (en fazla 9)
- Renkler yakınlaşır: kartlar arası ΔE (CIELAB) 30 → 3

9 karta ulaşıldıktan sonra her seviyede renkler biraz daha yakınlaşır.

## Puan
`100 + (seviye-1)*10 + kalan saniye*5 + (ardışık doğru-1)*10`

## Kurulum
```bash
flutter create --project-name color_match_game --org com.bnovative .
flutter pub get
dart run flutter_launcher_icons   # logoyu uygulama ikonu yapar
flutter run
```
`flutter create .` mevcut `lib/` ve `pubspec.yaml` dosyalarına dokunmaz, yalnızca `android/`, `ios/` gibi platform klasörlerini ekler.

## Dil ve müzik
- Oyun **İngilizce** açılır. Ana menüde sağ üstten EN / TR seçilir, tercih saklanır.
- Müzik ve ses efektleri `tools/generate_audio.py` ile sıfırdan sentezlenmiş özgün seslerdir, telif / lisans sorunu yoktur. Yeniden üretmek için: `python tools/generate_audio.py` (numpy + scipy).
- Müzik "Play" tuşuyla başlar (tarayıcılar ses için dokunuş ister). Müzik tuşu hem müziği hem efektleri kapatır.

## Testler
```bash
flutter test
```

## Dosya yapısı
```
lib/main.dart                     uygulama girişi
lib/theme.dart                    renkler ve tema
lib/l10n/app_strings.dart         EN / TR metinler
lib/settings/app_settings.dart    dil + müzik ayarı (kayıtlı)
lib/audio/audio_service.dart      müzik ve ses efektleri
lib/game/color_utils.dart         sRGB <-> CIELAB, ΔE
lib/game/difficulty.dart          seviye -> kart sayısı + ΔE
lib/game/choice_builder.dart      hedef renk ve yakın tuzak kartlar
lib/game/game_controller.dart     oyun akışı, can, skor, en yüksek skor
lib/screens/home_screen.dart      ana menü
lib/screens/game_screen.dart      gösterim / seçim / oyun sonu ekranları
lib/widgets/hud.dart              üst bar
assets/logo/                      logo (SVG + PNG) ve uygulama ikonu
assets/audio/                     müzik ve ses efektleri (WAV)
tools/generate_audio.py           sesleri üreten betik
push.bat                          GitHub'a gönderir
```
