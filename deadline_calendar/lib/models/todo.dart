// lib/models/todo.dart
// 할일

import 'package:flutter/foundation.dart';

enum TodoType {
  regular,
  deadline,
}

class Todo {
  final String id;
  String title;
  String description;
  bool isCompleted;
  DateTime createdAt;
  final TodoType type;
  
  // For deadline todos
  DateTime? deadline;
  
  // For timeline and sort
  bool isPriority;
  String? category;
  
  Todo({
    required this.id,
    required this.title,
    this.description = '',
    this.isCompleted = false,
    required this.createdAt,
    required this.type,
    this.deadline,
    this.isPriority = false,
    this.category,
  });
  
  Todo copyWith({
    String? title,
    String? description,
    bool? isCompleted,
    DateTime? deadline,
    bool? isPriority,
    String? category,
  }) {
    return Todo(
      id: this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      isCompleted: isCompleted ?? this.isCompleted,
      createdAt: this.createdAt,
      type: this.type,
      deadline: deadline ?? this.deadline,
      isPriority: isPriority ?? this.isPriority,
      category: category ?? this.category,
    );
  }
  
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'isCompleted': isCompleted,
      'createdAt': createdAt.toIso8601String(),
      'type': type.toString(),
      'deadline': deadline?.toIso8601String(),
      'isPriority': isPriority,
      'category': category,
    };
  }
  
  factory Todo.fromJson(Map<String, dynamic> json) {
    return Todo(
      id: json['id'],
      title: json['title'],
      description: json['description'],
      isCompleted: json['isCompleted'],
      createdAt: DateTime.parse(json['createdAt']),
      type: json['type'] == 'TodoType.deadline' ? TodoType.deadline : TodoType.regular,
      deadline: json['deadline'] != null ? DateTime.parse(json['deadline']) : null,
      isPriority: json['isPriority'] ?? false,
      category: json['category'],
    );
  }
  
  // Get remaining time for deadline todos
  String? get remainingTime {
    if (type != TodoType.deadline || deadline == null) {
      return null;
    }
    
    final now = DateTime.now();
    if (deadline!.isBefore(now)) {
      final difference = now.difference(deadline!);
      
      if (difference.inDays > 0) {
        return '${difference.inDays}일 ${difference.inHours % 24}시간 전 만료됨';
      } else if (difference.inHours > 0) {
        return '${difference.inHours}시간 ${difference.inMinutes % 60}분 전 만료됨';
      } else {
        return '${difference.inMinutes}분 전 만료됨';
      }
    }
    
    final difference = deadline!.difference(now);
    
    if (difference.inDays > 0) {
      return '${difference.inDays}일 ${difference.inHours % 24}시간 ${difference.inMinutes % 60}분 후 마감';
    } else if (difference.inHours > 0) {
      return '${difference.inHours}시간 ${difference.inMinutes % 60}분 후 마감';
    } else {
      return '${difference.inMinutes}분 후 마감';
    }
  }
} 