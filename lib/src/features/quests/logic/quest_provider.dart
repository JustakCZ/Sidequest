import 'dart:math';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:uuid/uuid.dart';
import '../data/quest_model.dart';

// --- Hive Box Provider ---
final questBoxProvider = Provider<Box<QuestModel>>((ref) {
  throw UnimplementedError('questBoxProvider not initialized');
});

// --- State Definitions ---
class QuestState {
  final List<QuestModel> availableQuests;
  final List<QuestModel> activeQuests;
  final List<QuestModel> completedQuests;
  final int streak;
  final int totalXp;
  final DateTime? lastCompletedDate;
  final Map<DateTime, String> weeklyHistory;
  final bool canShuffle;

  QuestState({
    required this.availableQuests,
    required this.activeQuests,
    required this.completedQuests,
    this.streak = 0,
    this.totalXp = 0,
    this.lastCompletedDate,
    this.weeklyHistory = const {},
    this.canShuffle = true,
  });

  QuestState copyWith({
    List<QuestModel>? availableQuests,
    List<QuestModel>? activeQuests,
    List<QuestModel>? completedQuests,
    int? streak,
    int? totalXp,
    DateTime? lastCompletedDate,
    Map<DateTime, String>? weeklyHistory,
    bool? canShuffle,
  }) {
    return QuestState(
      availableQuests: availableQuests ?? this.availableQuests,
      activeQuests: activeQuests ?? this.activeQuests,
      completedQuests: completedQuests ?? this.completedQuests,
      streak: streak ?? this.streak,
      totalXp: totalXp ?? this.totalXp,
      lastCompletedDate: lastCompletedDate ?? this.lastCompletedDate,
      weeklyHistory: weeklyHistory ?? this.weeklyHistory,
      canShuffle: canShuffle ?? this.canShuffle,
    );
  }
}

// --- Notifier ---
class QuestNotifier extends StateNotifier<QuestState> {
  final Box<QuestModel> box;
  final Box<dynamic> statsBox;
  final Box<dynamic> settingsBox;

  QuestNotifier(this.box, this.statsBox, this.settingsBox)
      : super(QuestState(
          availableQuests: [],
          activeQuests: [],
          completedQuests: [],
          streak: statsBox.get('streak', defaultValue: 0),
          totalXp: statsBox.get('totalXp', defaultValue: 0),
          lastCompletedDate: statsBox.get('lastCompletedDate'),
          weeklyHistory: (statsBox.get('weeklyHistory') as Map?)?.cast<DateTime, String>() ?? {},
          canShuffle: true, // Init value, updated in load
        )) {
    _loadInitialData();
  }

  void _loadInitialData() {
    final allQuests = box.values.toList();
    
    // Purge bad data
    final badQuests = allQuests.where((q) => 
        (q.category == 'General' || q.category == '') && 
        q.acceptedAt == null 
    ).toList();
    for (var q in badQuests) {
      q.delete();
    }

    final cleanQuests = box.values.toList();
    final available = cleanQuests.where((q) => q.acceptedAt == null && !q.isCompleted && !q.isFailed).toList();
    final active = cleanQuests.where((q) => q.isActive).toList();
    final completed = cleanQuests.where((q) => q.isCompleted).toList();

    final lastRefresh = statsBox.get('lastRefresh', defaultValue: DateTime(2000));
    final lastShuffle = statsBox.get('lastShuffle', defaultValue: DateTime(2000));
    final now = DateTime.now();

    if (!_isSameDay(lastRefresh, now) || available.isEmpty) {
      _refreshDailyQuests(available);
      statsBox.put('lastRefresh', now);
      // Reset shuffle availability on new day
      state = state.copyWith(canShuffle: true);
    } else {
      state = state.copyWith(
        availableQuests: available,
        activeQuests: active,
        completedQuests: completed,
        canShuffle: !_isSameDay(lastShuffle, now),
      );
    }
    
    _checkExpiredQuests();
  }

  void _refreshDailyQuests(List<QuestModel> currentAvailable) {
    for (var q in currentAvailable) {
      q.delete();
    }

    final newQuests = [
      _generateQuest(tier: 1),
      _generateQuest(tier: 1),
      _generateQuest(tier: 2),
      _generateQuest(tier: 2),
      _generateQuest(tier: 3),
      _generateQuest(tier: 3),
    ];
    
    box.addAll(newQuests);
    state = state.copyWith(availableQuests: newQuests);
  }

  void shuffleQuests() {
    if (!state.canShuffle) return;

    final now = DateTime.now();
    statsBox.put('lastShuffle', now);
    
    _refreshDailyQuests(state.availableQuests);
    
    state = state.copyWith(canShuffle: false);
  }

  QuestModel _generateQuest({required int tier}) {
    final List<Map<String, String>> pool;

    if (tier == 1) {
      pool = [
        {'title': 'Drink Water', 'desc': 'Drink one glass of water.', 'cat': 'Fitness'},
        {'title': 'Read 1 Page', 'desc': 'Read one page of a book.', 'cat': 'Knowledge'},
        {'title': 'Deep Breath', 'desc': 'Take 5 deep breaths.', 'cat': 'Mindfulness'},
        {'title': 'Make Bed', 'desc': 'Make your bed neatly.', 'cat': 'Chore'},
        {'title': 'Water Plants', 'desc': 'Check and water your plants.', 'cat': 'Chore'},
        {'title': 'Learn Word', 'desc': 'Learn one new word.', 'cat': 'Knowledge'},
        {'title': 'Text Friend', 'desc': 'Send a nice text to a friend.', 'cat': 'Social'},
        {'title': 'Stand Up', 'desc': 'Stand up and stretch for 1 min.', 'cat': 'Fitness'},
      ];
    } else if (tier == 2) {
      pool = [
        {'title': '20m Walk', 'desc': 'Go for a 20-minute walk.', 'cat': 'Fitness'},
        {'title': 'Organize Desk', 'desc': 'Clear and organize your workspace.', 'cat': 'Chore'},
        {'title': 'Call Parents', 'desc': 'Call a parent or relative.', 'cat': 'Social'},
        {'title': 'Meditate 10m', 'desc': 'Meditate for 10 minutes.', 'cat': 'Mindfulness'},
        {'title': 'Cook Meal', 'desc': 'Cook a simple meal.', 'cat': 'Creativity'},
        {'title': 'Write Journal', 'desc': 'Write half a page.', 'cat': 'Mindfulness'},
        {'title': 'Read Chapter', 'desc': 'Read one full chapter.', 'cat': 'Knowledge'},
        {'title': 'No Socials', 'desc': 'No social media for 2 hours.', 'cat': 'Mindfulness'},
      ];
    } else { // Tier 3
      pool = [
        {'title': 'Run 5km', 'desc': 'Run 5 kilometers.', 'cat': 'Fitness'},
        {'title': 'Cold Shower', 'desc': 'Take a 3-minute cold shower.', 'cat': 'Fitness'},
        {'title': 'Read 1 Hour', 'desc': 'Read for 60 minutes.', 'cat': 'Knowledge'},
        {'title': 'Volunteer', 'desc': 'Help someone for an hour.', 'cat': 'Social'},
        {'title': 'Deep Clean', 'desc': 'Deep clean one entire room.', 'cat': 'Chore'},
        {'title': 'Create Art', 'desc': 'Spend 1 hour on a hobby.', 'cat': 'Creativity'},
        {'title': 'Screen Fast', 'desc': 'No screens after 8 PM.', 'cat': 'Mindfulness'},
        {'title': 'Study Topic', 'desc': 'Study a new topic for 1 hour.', 'cat': 'Knowledge'},
      ];
    }

    final random = Random();
    final data = pool[random.nextInt(pool.length)];
    
    return QuestModel(
      id: const Uuid().v4(),
      title: data['title']!,
      description: data['desc']!,
      tier: tier,
      createdAt: DateTime.now(),
      category: data['cat']!,
    );
  }

  void acceptQuest(QuestModel quest) {
    quest.acceptedAt = DateTime.now();
    quest.save();

    state = state.copyWith(
      availableQuests: state.availableQuests.where((q) => q.id != quest.id).toList(),
      activeQuests: [...state.activeQuests, quest],
    );
  }

  void completeQuest(QuestModel quest) {
    quest.isCompleted = true;
    quest.save();

    final newXp = state.totalXp + quest.xpReward;
    statsBox.put('totalXp', newXp);

    _updateStreak();
    _updateWeeklyHistory(DateTime.now(), 'completed');

    state = state.copyWith(
      activeQuests: state.activeQuests.where((q) => q.id != quest.id).toList(),
      completedQuests: [...state.completedQuests, quest],
      totalXp: newXp,
    );
  }
  
  void failQuest(QuestModel quest) {
    quest.isFailed = true;
    quest.save();
    
    _updateWeeklyHistory(DateTime.now(), 'failed');
    
    state = state.copyWith(
       activeQuests: state.activeQuests.where((q) => q.id != quest.id).toList(),
    );
  }

  void _updateStreak() {
    final now = DateTime.now();
    final lastDate = state.lastCompletedDate;
    final isVacation = settingsBox.get('vacationMode', defaultValue: false);
    
    int newStreak = state.streak;

    if (lastDate == null) {
      newStreak = 1;
    } else if (_isSameDay(lastDate, now)) {
      // Already completed a quest today
    } else if (_isYesterday(lastDate, now)) {
      newStreak += 1;
    } else {
      // Missed a day
      if (!isVacation) {
        newStreak = 1; // Reset streak if not on vacation
      }
      // If on vacation, we preserve the streak (do nothing to it)
    }
    
    statsBox.put('streak', newStreak);
    statsBox.put('lastCompletedDate', now);
    
    state = state.copyWith(
      streak: newStreak,
      lastCompletedDate: now,
    );
  }

  void _updateWeeklyHistory(DateTime date, String status) {
    final key = DateTime(date.year, date.month, date.day);
    final newHistory = Map<DateTime, String>.from(state.weeklyHistory);
    
    if (!newHistory.containsKey(key) || newHistory[key] == 'frozen') {
       newHistory[key] = status;
       statsBox.put('weeklyHistory', newHistory);
       state = state.copyWith(weeklyHistory: newHistory);
    }
  }

  void _checkExpiredQuests() {
    final now = DateTime.now();
    for (var quest in state.activeQuests) {
      if (quest.expiryTime != null && now.isAfter(quest.expiryTime!)) {
        failQuest(quest);
      }
    }
  }
  
  // Danger Zone
  Future<void> wipeAllData() async {
    await box.clear();
    await statsBox.clear();
    // Re-init with defaults
    state = QuestState(
      availableQuests: [],
      activeQuests: [],
      completedQuests: [],
      streak: 0,
      totalXp: 0,
    );
    _loadInitialData(); // Reload to generate fresh quests
  }

  bool _isSameDay(DateTime d1, DateTime d2) {
    return d1.year == d2.year && d1.month == d2.month && d1.day == d2.day;
  }
  
  bool _isYesterday(DateTime d1, DateTime d2) {
    final yesterday = d2.subtract(const Duration(days: 1));
    return _isSameDay(d1, yesterday);
  }
}

// --- Provider Definition ---
final questProvider = StateNotifierProvider<QuestNotifier, QuestState>((ref) {
  final box = ref.watch(questBoxProvider);
  final statsBox = Hive.box('stats');
  final settingsBox = Hive.box('settings');
  return QuestNotifier(box, statsBox, settingsBox);
});
