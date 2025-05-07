// lib/widgets/todo_item.dart
// 할일 아이템 위젯젯

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/todo.dart';
import '../providers/todo_provider.dart';
import '../providers/settings_provider.dart';

class TodoItem extends StatelessWidget {
  final Todo todo;
  final bool showTimelineIndicator;
  
  const TodoItem({
    Key? key,
    required this.todo,
    this.showTimelineIndicator = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final todoProvider = Provider.of<TodoProvider>(context, listen: false);
    
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 6, horizontal: 0),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Checkmark circle
            Container(
              margin: const EdgeInsets.only(top: 2, right: 12),
              child: InkWell(
                onTap: () => todoProvider.toggleTodoStatus(todo.id),
                child: Container(
                  width: 28,
                  height: 28,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: todo.isCompleted ? Colors.green : Colors.transparent,
                    border: Border.all(
                      color: todo.isCompleted ? Colors.green : const Color(0xFF8C8C8C),
                      width: 2,
                    ),
                  ),
                  child: todo.isCompleted
                      ? const Icon(
                          Icons.check,
                          size: 16,
                          color: Colors.white,
                        )
                      : null,
                ),
              ),
            ),
            
            // Content column
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    todo.title,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      decoration: todo.isCompleted ? TextDecoration.lineThrough : null,
                      color: todo.isCompleted ? Colors.grey : Colors.white,
                    ),
                  ),
                  if (todo.description.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.only(top: 4.0),
                      child: Text(
                        todo.description,
                        style: TextStyle(
                          fontSize: 14,
                          color: todo.isCompleted ? Colors.grey : Colors.white70,
                          decoration: todo.isCompleted ? TextDecoration.lineThrough : null,
                        ),
                      ),
                    ),
                  if (todo.type == TodoType.deadline && todo.deadline != null)
                    Padding(
                      padding: const EdgeInsets.only(top: 8.0),
                      child: Row(
                        children: [
                          const Icon(
                            Icons.access_time,
                            size: 14,
                            color: Colors.orangeAccent,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            todo.remainingTime ?? '',
                            style: const TextStyle(
                              fontSize: 14,
                              color: Colors.orangeAccent,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                ],
              ),
            ),
            
            // Delete button
            IconButton(
              icon: const Icon(Icons.delete_outline, size: 20),
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(),
              onPressed: () => todoProvider.deleteTodo(todo.id),
            ),
          ],
        ),
      ),
    );
  }
}

class TodoTimelineItem extends StatelessWidget {
  final Todo todo;
  final bool isFirst;
  final bool isLast;
  final bool isUrgent;
  final bool isExpired;
  
  const TodoTimelineItem({
    Key? key,
    required this.todo,
    this.isFirst = false,
    this.isLast = false,
    this.isUrgent = false,
    this.isExpired = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final todoProvider = Provider.of<TodoProvider>(context, listen: false);
    final settingsProvider = Provider.of<SettingsProvider>(context, listen: false);
    final isDarkMode = settingsProvider.isDarkMode;
    
    // 타임라인 및 체크박스는 항상 회색 사용
    final Color timelineColor = Colors.grey.shade400;
    
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Timeline column
        SizedBox(
          width: 60,
          child: Column(
            children: [
              // Timeline circle - 항상 회색으로, 체크 시 초록색
              InkWell(
                onTap: () => todoProvider.toggleTodoStatus(todo.id),
                child: Container(
                  width: 28,
                  height: 28,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: todo.isCompleted ? Colors.green : Colors.transparent,
                    border: Border.all(
                      color: todo.isCompleted ? Colors.green : Colors.grey.shade400,
                      width: 2,
                    ),
                  ),
                  child: todo.isCompleted
                      ? const Icon(
                          Icons.check,
                          size: 16,
                          color: Colors.white,
                        )
                      : null,
                ),
              ),
              
              // Timeline line - 항상 회색으로
              if (!isLast)
                Container(
                  width: 2,
                  height: 50,
                  color: timelineColor,
                ),
            ],
          ),
        ),
        
        // Content column
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 제목 - 테마에 따라 색상 변경 (다크모드: 흰색, 라이트모드: 검정색)
              Text(
                todo.title,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  decoration: todo.isCompleted ? TextDecoration.lineThrough : null,
                  color: todo.isCompleted 
                      ? Colors.grey 
                      : isDarkMode 
                          ? Colors.white 
                          : Colors.black,
                ),
              ),
              if (todo.deadline != null)
                Padding(
                  padding: const EdgeInsets.only(top: 4.0),
                  child: Text(
                    todo.remainingTime ?? 'Expired',
                    style: TextStyle(
                      fontSize: 14,
                      // 시간만 긴급한 경우 빨간색으로 표시
                      color: todo.isCompleted 
                        ? Colors.grey 
                        : isUrgent 
                          ? Colors.red 
                          : isExpired 
                            ? Colors.red.withOpacity(0.7) 
                            : Colors.grey.shade400,
                    ),
                  ),
                ),
              const SizedBox(height: 16),
            ],
          ),
        ),
        
        // 수정 및 삭제 버튼
        Column(
          children: [
            // 수정 버튼
            IconButton(
              icon: const Icon(Icons.edit, size: 18),
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(),
              onPressed: () => _showEditDialog(context, todo),
            ),
            const SizedBox(height: 8),
            // 삭제 버튼
            IconButton(
              icon: const Icon(Icons.delete_outline, size: 18),
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(),
              onPressed: () {
                // 삭제 확인 다이얼로그
                showDialog(
                  context: context,
                  builder: (ctx) => AlertDialog(
                    title: const Text('데드라인 삭제'),
                    content: const Text('이 항목을 삭제하시겠습니까?'),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.of(ctx).pop(),
                        child: const Text('취소'),
                      ),
                      TextButton(
                        onPressed: () {
                          todoProvider.deleteTodo(todo.id);
                          Navigator.of(ctx).pop();
                        },
                        child: const Text('삭제'),
                      ),
                    ],
                  ),
                );
              },
            ),
          ],
        ),
      ],
    );
  }
  
  // 데드라인 수정 다이얼로그
  void _showEditDialog(BuildContext context, Todo todo) {
    final titleController = TextEditingController(text: todo.title);
    final descriptionController = TextEditingController(text: todo.description);
    DateTime? selectedDate = todo.deadline;
    TimeOfDay? selectedTime = todo.deadline != null 
        ? TimeOfDay(hour: todo.deadline!.hour, minute: todo.deadline!.minute) 
        : null;
    
    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setState) {
          return AlertDialog(
            title: const Text('데드라인 수정'),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  TextField(
                    controller: titleController,
                    decoration: const InputDecoration(
                      labelText: '제목',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: descriptionController,
                    decoration: const InputDecoration(
                      labelText: '설명',
                      border: OutlineInputBorder(),
                    ),
                    maxLines: 3,
                  ),
                  const SizedBox(height: 16),
                  const Text('마감일', style: TextStyle(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          selectedDate != null 
                              ? '${selectedDate?.year}년 ${selectedDate?.month}월 ${selectedDate?.day}일'
                              : '날짜 선택',
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.calendar_today),
                        onPressed: () async {
                          final date = await showDatePicker(
                            context: context,
                            initialDate: selectedDate ?? DateTime.now(),
                            firstDate: DateTime.now().subtract(const Duration(days: 365)),
                            lastDate: DateTime.now().add(const Duration(days: 365 * 5)),
                          );
                          if (date != null) {
                            setState(() {
                              selectedDate = date;
                            });
                          }
                        },
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          selectedTime != null 
                              ? '${selectedTime!.hour}시 ${selectedTime!.minute}분' 
                              : '시간 선택',
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.access_time),
                        onPressed: () async {
                          final time = await showTimePicker(
                            context: context,
                            initialTime: selectedTime ?? TimeOfDay.now(),
                          );
                          if (time != null) {
                            setState(() {
                              selectedTime = time;
                            });
                          }
                        },
                      ),
                    ],
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(ctx).pop(),
                child: const Text('취소'),
              ),
              TextButton(
                onPressed: () {
                  // 날짜와 시간 병합
                  DateTime? deadline;
                  if (selectedDate != null && selectedTime != null) {
                    deadline = DateTime(
                      selectedDate!.year,
                      selectedDate!.month,
                      selectedDate!.day,
                      selectedTime!.hour,
                      selectedTime!.minute,
                    );
                  }
                  
                  // 투두 업데이트
                  Provider.of<TodoProvider>(context, listen: false).updateTodo(
                    todo.id,
                    titleController.text,
                    descriptionController.text,
                    deadline,
                  );
                  
                  Navigator.of(ctx).pop();
                },
                child: const Text('저장'),
              ),
            ],
          );
        },
      ),
    );
  }
} 