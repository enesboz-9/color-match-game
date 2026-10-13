# Color Match: Memory Game

Rengi aklında tut, çok benzeyen kartlar arasından aynısını bul. Çevrimdışı, hesapsız, reklamsız.

- Bir renk kısa süre gösterilir ("Bu rengi aklında tut"), hazır olunca kartlar gelir ve aynı rengi bulursun.
- 3 can, bölümler sonsuz; kartlar gittikçe birbirine daha çok benzer ve sayıları artar.
- Erken geçersen bonus puan. En yüksek skor cihazda saklanır.
- EN / TR dil seçeneği, müzik aç/kapa.

## Kurulum
```bash
flutter pub get
dart run flutter_launcher_icons   # assets/logo/icon.png'den ikon üretir
flutter analyze
flutter test
flutter run
```
`android/` ve `ios/` klasörleri hazır geliyor (Android paketi: `com.bnovative.mind_mix`, iOS bundle: `com.bnovative.mindMix`).
iOS `Info.plist` içinde `ITSAppUsesNonExemptEncryption=false` zaten ekli.

> Bundle ID'ler App Store Connect / Google Play'deki uygulama kaydıyla birebir aynı olmalı. Kayıt farklı bir ID ile açıldıysa
> `ios/Runner.xcodeproj/project.pbxproj`, `macos/...`, `codemagic.yaml` (`BUNDLE_ID`) ve `android/app/build.gradle.kts` içinde güncelle.

## Dosya yapısı
```
lib/main.dart                       uygulama girişi
lib/home/home_screen.dart           ana ekran (Color Match kartı + Oyna)
lib/core/theme.dart                 renkler ve tema
lib/core/l10n.dart                  EN / TR ortak metinler (t.p('en','tr'))
lib/core/app_settings.dart          dil + müzik ayarı (kayıtlı)
lib/core/audio_service.dart         müzik ve ses efektleri
lib/core/sfx.dart                   ses açıksa efekt çal
lib/core/score_store.dart           en yüksek skor
lib/core/mini_game.dart             oyun tanımı
lib/core/game_shell.dart            ortak HUD, düğme, oyun sonu paneli
lib/games/registry.dart             oyun listesi
lib/games/color_match/              oyunun kendisi (controller, zorluk, kart üretimi)
test/color_match_test.dart          zorluk ve kart üretimi testleri
```

## Not
- Müzik/efektler `tools/generate_audio.py` ile üretilmiş özgün seslerdir.
- App Store inceleme notları ve gönderim kontrol listesi: `APP_REVIEW_NOTES.md`.
