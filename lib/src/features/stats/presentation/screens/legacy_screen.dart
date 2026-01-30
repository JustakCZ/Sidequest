import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:sidequest/src/features/quests/logic/quest_provider.dart';
import 'package:sidequest/src/shared/widgets/glass_card.dart';
import 'package:intl/intl.dart';

class LegacyScreen extends ConsumerWidget {
  const LegacyScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final questState = ref.watch(questProvider);

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _buildHeroStats(context, questState.totalXp),
          const SizedBox(height: 20),
          _buildWeeklyProgress(context, questState.weeklyHistory),
          const SizedBox(height: 24),
          Text(
            "Quest History",
            style: GoogleFonts.outfit(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          _buildHistoryList(context, questState.completedQuests),
        ],
      ),
    );
  }

  Widget _buildHeroStats(BuildContext context, int totalXp) {
    return GlassCard(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          Text(
            "TOTAL XP",
            style: TextStyle(
              fontSize: 12, 
              fontWeight: FontWeight.w900,
              letterSpacing: 2.0,
              color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.8),
            ),
          ),
          const SizedBox(height: 12),
          Text(
            NumberFormat.decimalPattern().format(totalXp),
            style: GoogleFonts.outfit(
              fontSize: 56, 
              fontWeight: FontWeight.w800,
              height: 1,
            ),
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.amber.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: Colors.amber.withValues(alpha: 0.3)),
            ),
            child: const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.star_rounded, size: 16, color: Colors.amber),
                SizedBox(width: 6),
                Text(
                  "NOVICE ADVENTURER",
                  style: TextStyle(
                    fontSize: 11, 
                    color: Colors.amber, 
                    fontWeight: FontWeight.w800,
                    letterSpacing: 0.5,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWeeklyProgress(BuildContext context, Map<DateTime, String> history) {
    final now = DateTime.now();
    // Start from Monday of the current week
    final startOfWeek = now.subtract(Duration(days: now.weekday - 1));

    return GlassCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.date_range_rounded, size: 20),
              SizedBox(width: 8),
              Text(
                "Weekly Progress",
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: List.generate(7, (index) {
              final date = startOfWeek.add(Duration(days: index));
              final dayName = DateFormat('E').format(date)[0];
              final isToday = date.day == now.day && date.month == now.month;
              
              // Normalize to midnight for key lookup
              final key = DateTime(date.year, date.month, date.day);
              final status = history[key];
              
              return Column(
                children: [
                  Text(
                    dayName, 
                    style: TextStyle(
                      color: isToday 
                          ? Theme.of(context).colorScheme.primary 
                          : Theme.of(context).textTheme.bodySmall?.color?.withValues(alpha: 0.5),
                      fontWeight: isToday ? FontWeight.bold : FontWeight.normal,
                      fontSize: 12,
                    ),
                  ),
                  const SizedBox(height: 10),
                  _buildDayIndicator(status, isToday),
                ],
              );
            }),
          ),
        ],
      ),
    );
  }

  Widget _buildDayIndicator(String? status, bool isToday) {
    IconData icon;
    Color color;

    switch (status) {
      case 'completed':
        icon = Icons.check_circle_rounded;
        color = Colors.green;
        break;
      case 'failed':
        icon = Icons.cancel_rounded;
        color = Colors.red;
        break;
      case 'frozen':
        icon = Icons.ac_unit_rounded;
        color = Colors.blue;
        break;
      default:
        icon = Icons.circle_outlined;
        color = Colors.grey.withValues(alpha: 0.3);
    }

    if (isToday && status == null) {
      return Container(
        height: 28,
        width: 28,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(color: Colors.blueAccent, width: 2),
        ),
      );
    }

    return Icon(icon, color: color, size: 28);
  }

  Widget _buildHistoryList(BuildContext context, List quests) {
    if (quests.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32.0),
          child: Column(
            children: [
              Icon(Icons.history_edu_rounded, size: 48, color: Colors.grey.withValues(alpha: 0.3)),
              const SizedBox(height: 16),
              const Text(
                "Your legacy begins today.",
                style: TextStyle(color: Colors.grey),
              ),
            ],
          ),
        ),
      );
    }
    
    // Show only last 5 quests
    final displayQuests = quests.reversed.take(5).toList();
    
    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: displayQuests.length,
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        final quest = displayQuests[index];
        return GlassCard(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: quest.categoryColor.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  quest.icon, 
                  size: 20, 
                  color: quest.categoryColor
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      quest.title,
                      style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15),
                    ),
                    Text(
                      DateFormat('MMM d, h:mm a').format(quest.acceptedAt ?? DateTime.now()),
                      style: TextStyle(fontSize: 11, color: Colors.grey.withValues(alpha: 0.8)),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.green.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  "+${quest.xpReward} XP",
                  style: const TextStyle(
                    fontWeight: FontWeight.w800,
                    color: Colors.green,
                    fontSize: 11,
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
