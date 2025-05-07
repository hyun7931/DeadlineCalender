// lib/screens/home_screen.dart
// 홈 화면

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/todo_provider.dart';
import '../widgets/calendar_modal.dart';
import 'deadline_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  bool _showWelcomePopup = true;
  final DraggableScrollableController _dragController = DraggableScrollableController();
  
  @override
  void initState() {
    super.initState();
    // Load todos when app starts
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<TodoProvider>(context, listen: false).loadTodos();
      
      // Show welcome popup
      if (_showWelcomePopup) {
        _showWelcomeDialog();
      }
    });
  }
  
  void _showWelcomeDialog() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: Colors.white,
        title: const Text(
          '데드라인 캘린더 앱에 오신 것을 환영합니다!',
          style: TextStyle(color: Colors.black),
        ),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('이 앱에서는 다음과 같은 기능을 사용할 수 있습니다:', style: TextStyle(color: Colors.black)),
            SizedBox(height: 12),
            Text('• 일반 투두와 데드라인 투두 관리', style: TextStyle(color: Colors.black)),
            Text('• 캘린더를 통한 일정 관리', style: TextStyle(color: Colors.black)),
            Text('• 마감이 가까운 순서대로 정렬된 데드라인 보기', style: TextStyle(color: Colors.black)),
            Text('• 남은 시간 카운트다운 표시', style: TextStyle(color: Colors.black)),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              setState(() {
                _showWelcomePopup = false;
              });
              Navigator.of(ctx).pop();
            },
            child: const Text('확인', style: TextStyle(color: Colors.blue)),
          ),
        ],
      ),
    );
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Main content - DeadlineScreen
          const DeadlineScreen(),
          
          // Bottom draggable calendar sheet
          DraggableScrollableSheet(
            initialChildSize: 0.1,
            minChildSize: 0.1,
            maxChildSize: 0.8,
            controller: _dragController,
            snap: true,
            snapSizes: const [0.1, 0.5, 0.8],
            builder: (context, scrollController) {
              return Container(
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.vertical(
                    top: Radius.circular(20),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black26,
                      blurRadius: 10,
                      spreadRadius: 0,
                    ),
                  ],
                ),
                child: SingleChildScrollView(
                  controller: scrollController,
                  child: Column(
                    children: [
                      // Handle bar
                      Container(
                        margin: const EdgeInsets.symmetric(vertical: 8),
                        width: 40,
                        height: 4,
                        decoration: BoxDecoration(
                          color: Colors.grey.shade300,
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                      
                      // Calendar contents
                      SizedBox(
                        height: MediaQuery.of(context).size.height * 0.8 - 20, // Subtract handle bar height
                        child: CalendarModal(
                          onClose: () {
                            _dragController.animateTo(
                              0.1,
                              duration: const Duration(milliseconds: 300),
                              curve: Curves.easeInOut,
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
} 