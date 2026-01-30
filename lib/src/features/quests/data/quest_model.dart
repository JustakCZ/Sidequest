import 'package:flutter/material.dart';
import 'package:hive/hive.dart';

part 'quest_model.g.dart';

@HiveType(typeId: 0)
class QuestModel extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String title;

  @HiveField(2)
  final String description;

  @HiveField(3)
  final int tier; // 1, 2, or 3

  @HiveField(4)
  final DateTime createdAt;

  @HiveField(5)
  DateTime? acceptedAt;

  @HiveField(6)
  bool isCompleted;

  @HiveField(7)
  bool isFailed;

  // @HiveField(8) was emoji - deprecated
  
  @HiveField(9)
  final String category;

  QuestModel({
    required this.id,
    required this.title,
    required this.description,
    required this.tier,
    required this.createdAt,
    String? category, 
    this.acceptedAt,
    this.isCompleted = false,
    this.isFailed = false,
  }) : category = category ?? 'General'; 

  bool get isActive => acceptedAt != null && !isCompleted && !isFailed;

  int get xpReward {
    switch (tier) {
      case 1: return 10;
      case 2: return 25;
      case 3: return 50;
      default: return 10;
    }
  }

  IconData get icon {
    switch (category.toLowerCase()) {
      case 'fitness':
        return Icons.directions_run_rounded;
      case 'knowledge':
        return Icons.auto_stories_rounded;
      case 'social':
        return Icons.people_rounded;
      case 'chore':
      case 'chores':
        return Icons.cleaning_services_rounded;
      case 'mindfulness':
        return Icons.self_improvement_rounded;
      case 'creativity':
        return Icons.brush_rounded;
      default:
        // Fallback for any old data or unmapped categories
        return Icons.star_rounded;
    }
  }
  
  Color get categoryColor {
    switch (category.toLowerCase()) {
      case 'fitness':
        return Colors.redAccent;
      case 'knowledge':
        return Colors.blueAccent;
      case 'social':
        return Colors.purpleAccent;
      case 'chore':
      case 'chores':
        return Colors.orangeAccent;
      case 'mindfulness':
        return Colors.tealAccent;
      case 'creativity':
        return Colors.pinkAccent;
      default:
        return Colors.grey;
    }
  }

  DateTime? get expiryTime {
    if (acceptedAt == null) return null;
    return acceptedAt!.add(const Duration(hours: 24));
  }

  QuestModel copyWith({
    String? id,
    String? title,
    String? description,
    int? tier,
    DateTime? createdAt,
    DateTime? acceptedAt,
    bool? isCompleted,
    bool? isFailed,
    String? category,
  }) {
    return QuestModel(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      tier: tier ?? this.tier,
      createdAt: createdAt ?? this.createdAt,
      acceptedAt: acceptedAt ?? this.acceptedAt,
      isCompleted: isCompleted ?? this.isCompleted,
      isFailed: isFailed ?? this.isFailed,
      category: category ?? this.category,
    );
  }
}
