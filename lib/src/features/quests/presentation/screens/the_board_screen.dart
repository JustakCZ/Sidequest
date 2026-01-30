import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import '../../logic/quest_provider.dart';
import '../../data/quest_model.dart';
import 'package:sidequest/src/shared/widgets/glass_card.dart';

class TheBoardScreen extends ConsumerWidget {
  const TheBoardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final questState = ref.watch(questProvider);
    final availableQuests = questState.availableQuests;

    // Prepend a header item to the list logic
    final itemCount = availableQuests.isEmpty ? 1 : availableQuests.length + 1;

    return AnimationLimiter(
      child: ListView.separated(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        itemCount: itemCount,
        separatorBuilder: (_, __) => const SizedBox(height: 16),
        itemBuilder: (context, index) {
          if (index == 0) {
            return _BoardHeader(
              canShuffle: questState.canShuffle,
              onShuffle: () => ref.read(questProvider.notifier).shuffleQuests(),
            );
          }
          
          final questIndex = index - 1;
          if (availableQuests.isEmpty) {
             return const Center(
               child: Padding(
                 padding: EdgeInsets.only(top: 40),
                 child: Text("No quests available. Check back tomorrow!"),
               ),
             );
          }

          final quest = availableQuests[questIndex];
          return AnimationConfiguration.staggeredList(
            position: index,
            duration: const Duration(milliseconds: 500),
            child: SlideAnimation(
              verticalOffset: 50.0,
              child: FadeInAnimation(
                child: _QuestCard(quest: quest),
              ),
            ),
          );
        },
      ),
    );
  }
}

class _BoardHeader extends StatelessWidget {
  final bool canShuffle;
  final VoidCallback onShuffle;

  const _BoardHeader({required this.canShuffle, required this.onShuffle});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        const _CountdownTimer(),
        TextButton.icon(
          onPressed: canShuffle ? onShuffle : null,
          icon: Icon(
            Icons.shuffle_rounded, 
            size: 18,
            color: canShuffle ? Theme.of(context).colorScheme.primary : Colors.grey,
          ),
          label: Text(
            canShuffle ? "Shuffle Quests" : "Shuffled Today",
            style: TextStyle(
              color: canShuffle ? Theme.of(context).colorScheme.primary : Colors.grey,
              fontWeight: FontWeight.bold,
            ),
          ),
          style: TextButton.styleFrom(
            backgroundColor: canShuffle 
                ? Theme.of(context).colorScheme.surface.withValues(alpha: 0.5) 
                : Colors.transparent,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          ),
        ),
      ],
    );
  }
}

class _CountdownTimer extends StatefulWidget {
  const _CountdownTimer();

  @override
  State<_CountdownTimer> createState() => _CountdownTimerState();
}

class _CountdownTimerState extends State<_CountdownTimer> {
  late Timer _timer;
  Duration _timeLeft = Duration.zero;

  @override
  void initState() {
    super.initState();
    _calculateTimeLeft();
    _timer = Timer.periodic(const Duration(minutes: 1), (_) => _calculateTimeLeft());
  }

  void _calculateTimeLeft() {
    final now = DateTime.now();
    final tomorrow = DateTime(now.year, now.month, now.day + 1);
    final diff = tomorrow.difference(now);
    
    if (mounted) {
      setState(() {
        _timeLeft = diff;
      });
    }
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final hours = _timeLeft.inHours;
    final minutes = _timeLeft.inMinutes.remainder(60);
    
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.1),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.access_time_rounded, size: 14, color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.7)),
          const SizedBox(width: 6),
          Text(
            "${hours}h ${minutes}m left",
            style: TextStyle(
              fontSize: 12, 
              fontWeight: FontWeight.w600,
              color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.8),
            ),
          ),
        ],
      ),
    );
  }
}

class _QuestCard extends StatelessWidget {
  final QuestModel quest;

  const _QuestCard({required this.quest});

  @override
  Widget build(BuildContext context) {
    // Optimization: const constructor for GlassCard used where possible, 
    // but GlassCard itself depends on children.
    return GlassCard(
      child: Column(
        children: [
          // Icon & Tier Badge
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _QuestIcon(quest: quest),
              _TierBadge(tier: quest.tier),
            ],
          ),
          const SizedBox(height: 16),
          
          // Title & Description
          SizedBox(
            width: double.infinity,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  quest.title,
                  style: GoogleFonts.outfit(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    letterSpacing: -0.5,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  quest.description,
                  style: TextStyle(
                    fontSize: 15,
                    color: Theme.of(context).textTheme.bodyMedium?.color?.withValues(alpha: 0.7),
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // Footer: Category & Accept Button
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: quest.categoryColor.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: quest.categoryColor.withValues(alpha: 0.3)),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.label_outline_rounded,
                      size: 14,
                      color: quest.categoryColor,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      quest.category.toUpperCase(),
                      style: GoogleFonts.outfit(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: quest.categoryColor,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ],
                ),
              ),
              // Use Consumer here locally if needed, but since we are in a ConsumerWidget tree (TheBoardScreen),
              // we can pass the ref or callback.
              // To keep _QuestCard efficient and pure, we should pass the callback,
              // but for simplicity in refactor, using Consumer is fine or accessing ref from parent.
              // Since _QuestCard is Stateless, we need to wrap the button in Consumer or pass callback.
              // Let's use Consumer just for the button interaction.
              Consumer(
                builder: (context, ref, _) {
                  return OutlinedButton(
                    onPressed: () {
                      ref.read(questProvider.notifier).acceptQuest(quest);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: const Text('Quest Accepted!'),
                          behavior: SnackBarBehavior.floating,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                          margin: const EdgeInsets.all(16),
                        ),
                      );
                    },
                    style: OutlinedButton.styleFrom(
                      backgroundColor: Theme.of(context).brightness == Brightness.dark 
                          ? Colors.white.withValues(alpha: 0.05)
                          : Colors.black.withValues(alpha: 0.05),
                      side: BorderSide(
                        color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.2),
                        width: 1,
                      ),
                      foregroundColor: Theme.of(context).colorScheme.onSurface,
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    ),
                    child: Text(
                      'ACCEPT', 
                      style: GoogleFonts.outfit(
                        fontWeight: FontWeight.bold,
                        letterSpacing: 2.0,
                        fontSize: 12,
                      ),
                    ),
                  );
                }
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _QuestIcon extends StatelessWidget {
  final QuestModel quest;

  const _QuestIcon({required this.quest});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 60,
      width: 60,
      decoration: BoxDecoration(
        color: quest.categoryColor.withValues(alpha: 0.1),
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: quest.categoryColor.withValues(alpha: 0.2),
            blurRadius: 20,
            spreadRadius: 5,
          ),
        ],
      ),
      child: Center(
        child: Hero(
          tag: 'quest_icon_${quest.id}',
          child: Icon(
            quest.icon,
            size: 32,
            color: quest.categoryColor,
          ),
        ),
      ),
    );
  }
}

class _TierBadge extends StatelessWidget {
  final int tier;

  const _TierBadge({required this.tier});

  @override
  Widget build(BuildContext context) {
    Color color;
    String text;
    int xp;

    switch (tier) {
      case 1:
        color = Colors.green;
        text = 'TIER I';
        xp = 10;
        break;
      case 2:
        color = Colors.orange;
        text = 'TIER II';
        xp = 25;
        break;
      case 3:
        color = Colors.red;
        text = 'TIER III';
        xp = 50;
        break;
      default:
        color = Colors.grey;
        text = 'TIER I';
        xp = 10;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.2)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.bolt_rounded, size: 14, color: color),
          const SizedBox(width: 4),
          Text(
            text,
            style: TextStyle(
              color: color,
              fontSize: 10,
              fontWeight: FontWeight.w900,
              letterSpacing: 0.5,
            ),
          ),
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 6),
            height: 10,
            width: 1,
            color: color.withValues(alpha: 0.3),
          ),
          Text(
            '+${xp}XP',
            style: TextStyle(
              color: color,
              fontSize: 10,
              fontWeight: FontWeight.w900,
            ),
          ),
        ],
      ),
    );
  }
}
