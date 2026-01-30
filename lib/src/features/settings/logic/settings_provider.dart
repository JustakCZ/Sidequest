import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../../../core/services/notification_service.dart';

final settingsBoxProvider = Provider<Box>((ref) {
  return Hive.box('settings');
});

// --- Theme ---

class ThemeNotifier extends StateNotifier<ThemeMode> {
  final Box box;

  ThemeNotifier(this.box) : super(_loadTheme(box));

  static ThemeMode _loadTheme(Box box) {
    final saved = box.get('themeMode', defaultValue: 'system');
    switch (saved) {
      case 'light':
        return ThemeMode.light;
      case 'dark':
        return ThemeMode.dark;
      default:
        return ThemeMode.system;
    }
  }

  void setTheme(ThemeMode mode) {
    state = mode;
    String value;
    switch (mode) {
      case ThemeMode.light:
        value = 'light';
        break;
      case ThemeMode.dark:
        value = 'dark';
        break;
      default:
        value = 'system';
    }
    box.put('themeMode', value);
  }
}

final themeProvider = StateNotifierProvider<ThemeNotifier, ThemeMode>((ref) {
  final box = ref.watch(settingsBoxProvider);
  return ThemeNotifier(box);
});

// --- General Settings (Notifications, Vacation Mode) ---

class SettingsState {
  final bool notificationsEnabled;
  final bool vacationMode;

  SettingsState({
    required this.notificationsEnabled,
    required this.vacationMode,
  });

  SettingsState copyWith({
    bool? notificationsEnabled,
    bool? vacationMode,
  }) {
    return SettingsState(
      notificationsEnabled: notificationsEnabled ?? this.notificationsEnabled,
      vacationMode: vacationMode ?? this.vacationMode,
    );
  }
}

class SettingsNotifier extends StateNotifier<SettingsState> {
  final Box box;

  SettingsNotifier(this.box)
      : super(SettingsState(
          notificationsEnabled: box.get('notificationsEnabled', defaultValue: false),
          vacationMode: box.get('vacationMode', defaultValue: false),
        ));

  Future<void> toggleNotifications(bool enabled) async {
    state = state.copyWith(notificationsEnabled: enabled);
    await box.put('notificationsEnabled', enabled);

    if (enabled) {
      await NotificationService().requestPermissions();
      await NotificationService().scheduleDailyNotifications();
    } else {
      await NotificationService().cancelAllNotifications();
    }
  }

  void toggleVacationMode(bool enabled) {
    state = state.copyWith(vacationMode: enabled);
    box.put('vacationMode', enabled);
  }
}

final settingsProvider = StateNotifierProvider<SettingsNotifier, SettingsState>((ref) {
  final box = ref.watch(settingsBoxProvider);
  return SettingsNotifier(box);
});
