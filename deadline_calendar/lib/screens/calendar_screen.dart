// lib/screens/calendar_screen.dart
// 캘린더 화면

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/todo_provider.dart';
import '../widgets/calendar_widget.dart';
import '../widgets/todo_item.dart';
import '../widgets/add_todo_form.dart';

class CalendarScreen extends StatelessWidget {
  const CalendarScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final todoProvider = Provider.of<TodoProvider>(context);
    final todosForSelectedDate = todoProvider.todosForSelectedDate;
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('캘린더'),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_none),
            onPressed: () {},
          ),
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () {},
          ),
        ],
      ),
      body: Column(
        children: [
          // Calendar widget
          Container(
            margin: const EdgeInsets.only(bottom: 8),
            child: const CalendarWidget(),
          ),
          
          // Selected date info
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '${todoProvider.selectedDate.year}년 ${todoProvider.selectedDate.month}월 ${todoProvider.selectedDate.day}일',
                  style: Theme.of(context).textTheme.titleLarge!.copyWith(
                    fontSize: 18,
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade800,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    '${todosForSelectedDate.length}개의 할 일',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ),
              ],
            ),
          ),
          
          // Divider
          const Divider(),
          
          // Todos for selected date
          Expanded(
            child: todosForSelectedDate.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(
                          Icons.event_available,
                          size: 64,
                          color: Colors.grey,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          '이 날짜에 할 일이 없습니다',
                          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            color: Colors.grey,
                          ),
                        ),
                        const SizedBox(height: 24),
                        ElevatedButton.icon(
                          onPressed: () => _showAddTodoForm(context),
                          icon: const Icon(Icons.add),
                          label: const Text('할 일 추가하기'),
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: todosForSelectedDate.length,
                    itemBuilder: (context, index) {
                      return TodoItem(todo: todosForSelectedDate[index]);
                    },
                  ),
          ),
        ],
      ),
      floatingActionButton: todosForSelectedDate.isNotEmpty
          ? FloatingActionButton(
              onPressed: () => _showAddTodoForm(context),
              child: const Icon(Icons.add),
            )
          : null, // Hide FAB when there are no todos to prevent duplication with the button in empty state
    );
  }
  
  void _showAddTodoForm(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Theme.of(context).bottomSheetTheme.backgroundColor,
      shape: Theme.of(context).bottomSheetTheme.shape,
      builder: (ctx) => Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(ctx).viewInsets.bottom,
        ),
        child: AddTodoForm(
          onClose: () => Navigator.of(ctx).pop(),
        ),
      ),
    );
  }
} 