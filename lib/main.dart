import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'src/features/quests/data/quest_model.dart';
import 'src/features/quests/logic/quest_provider.dart';
import 'src/features/settings/logic/settings_provider.dart';
import 'src/shared/widgets/nav_scaffold.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Hive Setup
  await Hive.initFlutter();
  if (!Hive.isAdapterRegistered(0)) {
     Hive.registerAdapter(QuestModelAdapter());
  }
  
  // Open Boxes
  final questBox = await Hive.openBox<QuestModel>('quests');
  await Hive.openBox('stats');
  await Hive.openBox('settings');

  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    statusBarColor: Colors.transparent,
  ));

  runApp(
    ProviderScope(
      overrides: [
        questBoxProvider.overrideWithValue(questBox),
      ],
      child: const SidequestApp(),
    ),
  );
}

class SidequestApp extends ConsumerWidget {
  const SidequestApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(themeProvider);

    return MaterialApp(
      title: 'Sidequest',
      debugShowCheckedModeBanner: false,
      themeMode: themeMode,
      theme: _buildTheme(Brightness.light),
      darkTheme: _buildTheme(Brightness.dark),
      home: const NavScaffold(),
    );
  }

  ThemeData _buildTheme(Brightness brightness) {
    final isDark = brightness == Brightness.dark;
    final base = isDark ? ThemeData.dark() : ThemeData.light();
    
    return base.copyWith(
      scaffoldBackgroundColor: isDark ? const Color(0xFF121212) : const Color(0xFFF5F5F7),
      colorScheme: ColorScheme.fromSeed(
        seedColor: Colors.deepPurple,
        brightness: brightness,
      ),
      textTheme: GoogleFonts.outfitTextTheme(base.textTheme),
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: isDark ? const Color(0xFF1E1E1E) : Colors.white,
        selectedItemColor: Colors.deepPurpleAccent,
        unselectedItemColor: Colors.grey,
        elevation: 0,
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: false,
        titleTextStyle: GoogleFonts.outfit(
          fontSize: 24,
          fontWeight: FontWeight.bold,
          color: isDark ? Colors.white : Colors.black,
        ),
      ),
    );
  }
}
