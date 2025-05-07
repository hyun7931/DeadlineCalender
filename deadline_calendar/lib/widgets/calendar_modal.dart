// lib/widgets/calendar_modal.dart
// 캘린더

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:intl/intl.dart';
import '../providers/todo_provider.dart';
import '../models/todo.dart';
import 'todo_item.dart';

class CalendarModal extends StatefulWidget {
  final Function() onClose;

  const CalendarModal({
    Key? key,
    required this.onClose,
  }) : super(key: key);

  @override
  State<CalendarModal> createState() => _CalendarModalState();
}

class _CalendarModalState extends State<CalendarModal> {
  CalendarFormat _calendarFormat = CalendarFormat.month;
  DateTime _focusedDay = DateTime.now();
  final kFirstDay = DateTime(DateTime.now().year - 1);
  final kLastDay = DateTime(DateTime.now().year + 1, 12, 31);
  final TextEditingController _todoController = TextEditingController();
  
  @override
  void dispose() {
    _todoController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final todoProvider = Provider.of<TodoProvider>(context);
    final todosForSelectedDate = todoProvider.todosForSelectedDate;
    
    return Container(
      color: Colors.white,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Header with month and year
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '${_focusedDay.year}년 ${_focusedDay.month}월',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
                const SizedBox(), // Spacer for alignment
              ],
            ),
          ),
          
          // Calendar
          _buildCalendar(todoProvider),
          
          // Divider
          const Divider(color: Colors.grey),
          
          // Today's date
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '${todoProvider.selectedDate.year}년 ${todoProvider.selectedDate.month}월 ${todoProvider.selectedDate.day}일',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
                InkWell(
                  onTap: () {
                    _showQuickAddTodo(context);
                  },
                  child: Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade200,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: const Icon(Icons.add, color: Colors.black),
                  ),
                ),
              ],
            ),
          ),
          
          // Todo list for selected date
          Expanded(
            child: todosForSelectedDate.isEmpty
                ? const Center(
                    child: Text(
                      '이 날짜에 할 일이 없습니다',
                      style: TextStyle(color: Colors.grey),
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    itemCount: todosForSelectedDate.length,
                    itemBuilder: (context, index) {
                      final todo = todosForSelectedDate[index];
                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 4.0),
                        child: Container(
                          key: ValueKey('todo_${todo.id}'),
                          decoration: BoxDecoration(
                            color: Colors.grey.shade100,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: ListTile(
                            leading: InkWell(
                              onTap: () => todoProvider.toggleTodoStatus(todo.id),
                              child: Container(
                                width: 24,
                                height: 24,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: todo.isCompleted ? Colors.green : Colors.transparent,
                                  border: Border.all(
                                    color: todo.isCompleted ? Colors.green : Colors.grey,
                                    width: 2,
                                  ),
                                ),
                                child: todo.isCompleted
                                    ? const Icon(Icons.check, size: 16, color: Colors.white)
                                    : null,
                              ),
                            ),
                            title: Text(
                              todo.title,
                              style: TextStyle(
                                decoration: todo.isCompleted ? TextDecoration.lineThrough : null,
                                color: todo.isCompleted ? Colors.grey : Colors.black,
                              ),
                            ),
                            trailing: IconButton(
                              icon: const Icon(Icons.delete_outline, color: Colors.grey),
                              onPressed: () => todoProvider.deleteTodo(todo.id),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildCalendar(TodoProvider todoProvider) {
    return TableCalendar(
      headerVisible: false,
      firstDay: kFirstDay,
      lastDay: kLastDay,
      focusedDay: _focusedDay,
      calendarFormat: _calendarFormat,
      rowHeight: 40,
      daysOfWeekHeight: 20,
      selectedDayPredicate: (day) {
        return isSameDay(todoProvider.selectedDate, day);
      },
      onDaySelected: (selectedDay, focusedDay) {
        setState(() {
          _focusedDay = focusedDay;
        });
        todoProvider.setSelectedDate(selectedDay);
      },
      onFormatChanged: (format) {
        setState(() {
          _calendarFormat = format;
        });
      },
      onPageChanged: (focusedDay) {
        setState(() {
          _focusedDay = focusedDay;
        });
      },
      calendarStyle: CalendarStyle(
        outsideDaysVisible: true,
        weekendTextStyle: const TextStyle(color: Colors.black),
        holidayTextStyle: const TextStyle(color: Colors.red),
        defaultTextStyle: const TextStyle(color: Colors.black),
      ),
      calendarBuilders: CalendarBuilders(
        defaultBuilder: (context, date, events) {
          final todos = todoProvider.todos;
          bool hasDeadline = todos.any((todo) => 
            todo.type == TodoType.deadline && 
            todo.deadline != null && 
            isSameDay(todo.deadline!, date)
          );
          
          return Container(
            margin: const EdgeInsets.all(4.0),
            alignment: Alignment.center,
            child: Text(
              date.day.toString(),
              style: TextStyle(
                color: hasDeadline ? Colors.red : Colors.black,
                fontWeight: hasDeadline ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          );
        },
        todayBuilder: (context, date, events) {
          final todos = todoProvider.todos;
          bool hasDeadline = todos.any((todo) => 
            todo.type == TodoType.deadline && 
            todo.deadline != null && 
            isSameDay(todo.deadline!, date)
          );
          
          return Container(
            margin: const EdgeInsets.all(4.0),
            alignment: Alignment.center,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: Colors.blue, width: 1),
            ),
            child: Text(
              date.day.toString(),
              style: TextStyle(
                color: hasDeadline ? Colors.red : Colors.black,
                fontWeight: FontWeight.bold,
              ),
            ),
          );
        },
        selectedBuilder: (context, date, events) {
          final todos = todoProvider.todos;
          bool hasDeadline = todos.any((todo) => 
            todo.type == TodoType.deadline && 
            todo.deadline != null && 
            isSameDay(todo.deadline!, date)
          );
          
          return Container(
            margin: const EdgeInsets.all(4.0),
            alignment: Alignment.center,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.blue.withOpacity(0.3),
            ),
            child: Text(
              date.day.toString(),
              style: TextStyle(
                color: hasDeadline ? Colors.red : Colors.black,
                fontWeight: FontWeight.bold,
              ),
            ),
          );
        },
      ),
    );
  }

  void _showQuickAddTodo(BuildContext context) {
    final todoProvider = Provider.of<TodoProvider>(context, listen: false);
    final selectedDate = todoProvider.selectedDate;
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.white,
        title: Text(
          '${selectedDate.year}년 ${selectedDate.month}월 ${selectedDate.day}일 할 일 추가', 
          style: const TextStyle(color: Colors.black, fontSize: 16),
        ),
        content: TextField(
          controller: _todoController,
          style: const TextStyle(color: Colors.black),
          decoration: const InputDecoration(
            hintText: '할 일을 입력하세요',
            hintStyle: TextStyle(color: Colors.grey),
            enabledBorder: UnderlineInputBorder(
              borderSide: BorderSide(color: Colors.grey),
            ),
            focusedBorder: UnderlineInputBorder(
              borderSide: BorderSide(color: Colors.blue),
            ),
          ),
          autofocus: true,
        ),
        actions: [
          TextButton(
            child: const Text('취소', style: TextStyle(color: Colors.grey)),
            onPressed: () {
              Navigator.of(context).pop();
              _todoController.clear();
            },
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue,
            ),
            child: const Text('추가'),
            onPressed: () {
              if (_todoController.text.trim().isNotEmpty) {
                final todoProvider = Provider.of<TodoProvider>(context, listen: false);
                
                // 선택한 날짜에 투두 추가하기 위한 날짜 설정
                final now = DateTime.now();
                final todoDate = DateTime(
                  selectedDate.year,
                  selectedDate.month,
                  selectedDate.day,
                  now.hour,
                  now.minute,
                  now.second,
                );
                
                // 생성 시간을 선택한 날짜로 설정
                todoProvider.addTodoWithDate(
                  _todoController.text.trim(), 
                  '', 
                  TodoType.regular, 
                  null,
                  todoDate
                );
                
                Navigator.of(context).pop();
                _todoController.clear();
              }
            },
          ),
        ],
      ),
    );
  }
} 