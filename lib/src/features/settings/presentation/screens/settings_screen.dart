import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:sidequest/src/shared/widgets/glass_card.dart';
import '../../logic/settings_provider.dart';
import 'package:sidequest/src/features/quests/logic/quest_provider.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(themeProvider);
    final settingsState = ref.watch(settingsProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: Text(
          'Settings',
          style: GoogleFonts.outfit(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: isDark
                ? [const Color(0xFF121212), const Color(0xFF2C2C2C)]
                : [const Color(0xFFF0F2F5), const Color(0xFFE1E5EA)],
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Appearance Section
                GlassCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Appearance',
                        style: GoogleFonts.outfit(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 16),
                      _ThemeOption(
                        title: 'System Default',
                        icon: Icons.brightness_auto,
                        isSelected: themeMode == ThemeMode.system,
                        onTap: () => ref.read(themeProvider.notifier).setTheme(ThemeMode.system),
                      ),
                      _ThemeOption(
                        title: 'Light Mode',
                        icon: Icons.light_mode,
                        isSelected: themeMode == ThemeMode.light,
                        onTap: () => ref.read(themeProvider.notifier).setTheme(ThemeMode.light),
                      ),
                      _ThemeOption(
                        title: 'Dark Mode',
                        icon: Icons.dark_mode,
                        isSelected: themeMode == ThemeMode.dark,
                        onTap: () => ref.read(themeProvider.notifier).setTheme(ThemeMode.dark),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),

                // Gameplay Section
                GlassCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Gameplay',
                        style: GoogleFonts.outfit(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 16),
                      SwitchListTile.adaptive(
                        title: const Text("Enable Notifications"),
                        subtitle: const Text("Daily summons at 9 AM & 9 PM"),
                        value: settingsState.notificationsEnabled,
                        onChanged: (val) => ref.read(settingsProvider.notifier).toggleNotifications(val),
                        contentPadding: EdgeInsets.zero,
                      ),
                      SwitchListTile.adaptive(
                        title: const Text("Tavern Rest (Vacation)"),
                        subtitle: const Text("Pause streaks while you rest"),
                        secondary: const Icon(Icons.hotel_rounded, color: Colors.indigo),
                        value: settingsState.vacationMode,
                        onChanged: (val) => ref.read(settingsProvider.notifier).toggleVacationMode(val),
                        contentPadding: EdgeInsets.zero,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),

                // Danger Zone
                GlassCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Danger Zone',
                        style: GoogleFonts.outfit(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          color: Colors.redAccent,
                        ),
                      ),
                      const SizedBox(height: 16),
                      SizedBox(
                        width: double.infinity,
                        child: TextButton.icon(
                          onPressed: () => _showWipeConfirmation(context, ref),
                          icon: const Icon(Icons.delete_forever_rounded, color: Colors.red),
                          label: const Text(
                            "WIPE ALL DATA",
                            style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
                          ),
                          style: TextButton.styleFrom(
                            backgroundColor: Colors.red.withValues(alpha: 0.1),
                            padding: const EdgeInsets.symmetric(vertical: 16),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 32),
                Center(
                  child: Text(
                    'Sidequest v1.0.0',
                    style: TextStyle(color: Colors.grey.withValues(alpha: 0.5)),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showWipeConfirmation(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Wipe All Data?"),
        content: const Text(
          "This action is irreversible. All your XP, streaks, and quest history will be permanently deleted.",
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancel"),
          ),
          TextButton(
            onPressed: () {
              ref.read(questProvider.notifier).wipeAllData();
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text("All data has been wiped.")),
              );
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text("Wipe Data"),
          ),
        ],
      ),
    );
  }
}

class _ThemeOption extends StatelessWidget {
  final String title;
  final IconData icon;
  final bool isSelected;
  final VoidCallback onTap;

  const _ThemeOption({
    required this.title,
    required this.icon,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    
    return ListTile(
      onTap: onTap,
      leading: Icon(
        icon,
        color: isSelected ? colorScheme.primary : colorScheme.onSurface.withValues(alpha: 0.6),
      ),
      title: Text(
        title,
        style: TextStyle(
          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          color: isSelected ? colorScheme.primary : colorScheme.onSurface,
        ),
      ),
      trailing: isSelected 
          ? Icon(Icons.check_circle, color: colorScheme.primary) 
          : null,
      contentPadding: EdgeInsets.zero,
    );
  }
}
