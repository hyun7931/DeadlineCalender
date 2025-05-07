// lib/screens/deadline_screen.dart
// 데드라인 투두 화면

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/todo_provider.dart';
import '../models/todo.dart';
import '../widgets/todo_item.dart';
import '../widgets/deadline_add_popup.dart';
import 'settings_screen.dart';

class DeadlineScreen extends StatefulWidget {
  const DeadlineScreen({Key? key}) : super(key: key);

  @override
  State<DeadlineScreen> createState() => _DeadlineScreenState();
}

class _DeadlineScreenState extends State<DeadlineScreen> {
  // 초기 스크롤 위치를 첫 번째 만료되지 않은 항목으로 설정하기 위한 컨트롤러
  final ScrollController _scrollController = ScrollController();
  int _initialScrollIndex = 0;
  
  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }
  
  @override
  Widget build(BuildContext context) {
    final todoProvider = Provider.of<TodoProvider>(context);
    final deadlineTodos = todoProvider.deadlineTodos;
    
    // 만료되지 않은 첫 번째 항목의 인덱스 찾기
    final now = DateTime.now();
    _initialScrollIndex = deadlineTodos.indexWhere(
      (todo) => todo.deadline != null && todo.deadline!.isAfter(now)
    );
    
    // 만료되지 않은 항목이 없으면 마지막 항목으로 설정
    if (_initialScrollIndex == -1 && deadlineTodos.isNotEmpty) {
      _initialScrollIndex = deadlineTodos.length - 1;
    }
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('데드라인 캘린더'),
        actions: [
          // 알림 버튼
          IconButton(
            icon: const Icon(Icons.notifications_none),
            onPressed: () {},
          ),
          // 설정 버튼
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const SettingsScreen()),
              );
            },
          ),
        ],
      ),
      body: deadlineTodos.isEmpty
          ? _buildEmptyState(context)
          : _buildTimelineView(context, deadlineTodos),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showDeadlineAddPopup(context),
        child: const Icon(Icons.add),
      ),
    );
  }
  
  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.check_circle_outline,
            size: 64,
            color: Colors.grey,
          ),
          const SizedBox(height: 16),
          Text(
            '데드라인 투두가 없습니다',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              color: Colors.grey,
            ),
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: () => _showDeadlineAddPopup(context),
            icon: const Icon(Icons.add),
            label: const Text('새 데드라인 추가'),
          ),
        ],
      ),
    );
  }
  
  Widget _buildTimelineView(BuildContext context, List<Todo> todos) {
    final now = DateTime.now();
    
    // 24시간 내에 해야 하는 과제 수 계산 (전체 개수)
    final totalUrgentDeadlines = todos.where((todo) => 
      todo.deadline != null && 
      !todo.deadline!.isBefore(now) &&
      todo.deadline!.difference(now).inHours <= 24
    ).length;
    
    // 24시간 내에 해야 하는 과제 중 남은 개수 (미완료 개수)
    final remainingUrgentDeadlines = todos.where((todo) => 
      !todo.isCompleted && 
      todo.deadline != null && 
      !todo.deadline!.isBefore(now) &&
      todo.deadline!.difference(now).inHours <= 24
    ).length;
    
    return Column(
      children: [
        // 상단 카운터 - 24시간 내 과제 남은개수/전체개수 표시
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Today $remainingUrgentDeadlines/$totalUrgentDeadlines',
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
              
              // 추가 버튼 (모바일에서 하단의 FAB가 가려질 수 있어 상단에도 추가)
              IconButton(
                onPressed: () => _showDeadlineAddPopup(context),
                icon: Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.primary,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.add,
                    color: Colors.white,
                    size: 16,
                  ),
                ),
              ),
            ],
          ),
        ),
        
        // 타임라인 목록
        Expanded(
          child: ListView.builder(
            controller: _scrollController,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: todos.length,
            itemBuilder: (context, index) {
              final todo = todos[index];
              final bool isUrgent = todo.deadline != null && 
                  !todo.deadline!.isBefore(now) &&
                  now.difference(todo.deadline!).inHours.abs() <= 24;
              
              // 만료된 항목인지 확인
              final bool isExpired = todo.deadline != null && 
                  todo.deadline!.isBefore(now);
              
              return TodoTimelineItem(
                todo: todo,
                isFirst: index == 0,
                isLast: index == todos.length - 1,
                isUrgent: isUrgent,
                isExpired: isExpired,
              );
            },
          ),
        ),
      ],
    );
  }
  
  @override
  void initState() {
    super.initState();
    // 화면이 로드된 후 적절한 위치로 스크롤
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients && _initialScrollIndex > 0) {
        _scrollController.jumpTo(_initialScrollIndex * 80.0); // 대략적인 아이템 높이로 계산
      }
    });
  }
  
  void _showDeadlineAddPopup(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => const DeadlineAddPopup(),
    );
  }
} 