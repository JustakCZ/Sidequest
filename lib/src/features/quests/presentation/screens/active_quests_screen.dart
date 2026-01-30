import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import '../../logic/quest_provider.dart';
import '../../data/quest_model.dart';
import 'package:sidequest/src/shared/widgets/glass_card.dart';

class ActiveQuestsScreen extends ConsumerWidget {
  const ActiveQuestsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final questState = ref.watch(questProvider);
    final activeQuests = questState.activeQuests;

    if (activeQuests.isEmpty) {
      return const Center(child: Text("No active quests. Go to the board!"));
    }

    return AnimationLimiter(
      child: ListView.separated(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        itemCount: activeQuests.length,
        separatorBuilder: (_, __) => const SizedBox(height: 16),
        itemBuilder: (context, index) {
          final quest = activeQuests[index];
          return AnimationConfiguration.staggeredList(
            position: index,
            duration: const Duration(milliseconds: 500),
            child: SlideAnimation(
              verticalOffset: 50.0,
              child: FadeInAnimation(
                child: _ActiveQuestItem(quest: quest),
              ),
            ),
          );
        },
      ),
    );
  }
}

class _ActiveQuestItem extends ConsumerStatefulWidget {
  final QuestModel quest;

  const _ActiveQuestItem({required this.quest});

  @override
  ConsumerState<_ActiveQuestItem> createState() => _ActiveQuestItemState();
}

class _ActiveQuestItemState extends ConsumerState<_ActiveQuestItem> {
  late Timer _timer;
  Duration _timeLeft = Duration.zero;

  @override
  void initState() {
    super.initState();
    _calculateTimeLeft();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) => _calculateTimeLeft());
  }

  void _calculateTimeLeft() {
    final expiry = widget.quest.expiryTime;
    if (expiry == null) return;

    final now = DateTime.now();
    if (now.isAfter(expiry)) {
      _timer.cancel();
      setState(() {
        _timeLeft = Duration.zero;
      });
    } else {
      setState(() {
        _timeLeft = expiry.difference(now);
      });
    }
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, "0");
    String twoDigitMinutes = twoDigits(duration.inMinutes.remainder(60));
    String twoDigitSeconds = twoDigits(duration.inSeconds.remainder(60));
    return "${twoDigits(duration.inHours)}:$twoDigitMinutes:$twoDigitSeconds";
  }

  @override
  Widget build(BuildContext context) {
    final isCritical = _timeLeft.inHours < 1;

    return GlassCard(
      child: Column(
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: widget.quest.categoryColor.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: Hero(
                  tag: 'quest_icon_${widget.quest.id}',
                  child: Icon(
                    widget.quest.icon, 
                    size: 28, 
                    color: widget.quest.categoryColor
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.quest.title,
                      style: GoogleFonts.outfit(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                         Icon(
                          Icons.timer_outlined, 
                          size: 14, 
                          color: isCritical ? Colors.red : Colors.blue,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          _formatDuration(_timeLeft),
                          style: TextStyle(
                            fontFamily: 'monospace',
                            color: isCritical ? Colors.red : Colors.blue,
                            fontWeight: FontWeight.w700,
                            fontSize: 13,
                          ),
                        ),
                      ],
                    )
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Align(
            alignment: Alignment.centerLeft,
            child: Text(
              widget.quest.description,
              style: TextStyle(
                color: Theme.of(context).textTheme.bodyMedium?.color?.withValues(alpha: 0.8),
              ),
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () {
                ref.read(questProvider.notifier).completeQuest(widget.quest);
              },
              icon: const Icon(Icons.check_circle_outline_rounded),
              label: const Text("Complete Quest"),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                foregroundColor: Colors.white,
                elevation: 0,
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                textStyle: GoogleFonts.outfit(fontWeight: FontWeight.bold),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
