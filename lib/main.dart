import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'audio/audio_service.dart';
import 'screens/home_screen.dart';
import 'settings/app_settings.dart';
import 'theme.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setPreferredOrientations(const [DeviceOrientation.portraitUp]);
  await AppSettings.instance.load();
  runApp(const ColorMatchApp());
}

class ColorMatchApp extends StatefulWidget {
  const ColorMatchApp({super.key});

  @override
  State<ColorMatchApp> createState() => _ColorMatchAppState();
}

class _ColorMatchAppState extends State<ColorMatchApp> with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  /// Uygulama arka plana gidince müziği duraklat, dönünce devam ettir.
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    final audio = AudioService.instance;
    if (state == AppLifecycleState.resumed) {
      if (AppSettings.instance.musicOn && audio.hasStarted) audio.playMusic();
    } else {
      audio.pauseMusic();
    }
  }

  @override
  Widget build(BuildContext context) {
    return SettingsScope(
      settings: AppSettings.instance,
      child: Builder(
        builder: (context) {
          final t = SettingsScope.of(context).t;
          return MaterialApp(
            title: t.appName,
            debugShowCheckedModeBanner: false,
            theme: buildTheme(),
            home: const HomeScreen(),
          );
        },
      ),
    );
  }
}
