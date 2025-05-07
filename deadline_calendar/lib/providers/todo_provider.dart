// lib/providers/todo_provider.dart
// 데드라인 투두

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';
import '../models/todo.dart';

class TodoProvider with ChangeNotifier {
  List<Todo> _todos = [];
  DateTime _selectedDate = DateTime.now();
  
  List<Todo> get todos => _todos;
  DateTime get selectedDate => _selectedDate;
  
  // Get todos for selected date
  List<Todo> get todosForSelectedDate {
    return _todos.where((todo) {
      if (todo.type == TodoType.regular) {
        return isSameDay(todo.createdAt, _selectedDate);
      } else {
        return todo.deadline != null && isSameDay(todo.deadline!, _selectedDate);
      }
    }).toList();
  }
  
  // Get deadline todos sorted by deadline
  List<Todo> get deadlineTodos {
    final deadlineTodos = _todos.where((todo) => 
      todo.type == TodoType.deadline && 
      todo.deadline != null
    ).toList();
    
    final now = DateTime.now();
    
    // 세 그룹으로 나누어 정렬: 만료됨(위), 임박함(중간), 먼 미래(아래)
    deadlineTodos.sort((a, b) {
      final aExpired = a.deadline!.isBefore(now);
      final bExpired = b.deadline!.isBefore(now);
      
      // 둘 다 만료되었거나 둘 다 만료되지 않은 경우
      if (aExpired == bExpired) {
        // 만료된 경우: 가장 최근에 만료된 것이 위로
        if (aExpired) {
          return b.deadline!.compareTo(a.deadline!);
        }
        // 만료되지 않은 경우: 가장 임박한 것이 위로
        else {
          return a.deadline!.compareTo(b.deadline!);
        }
      }
      // 하나만 만료된 경우: 만료된 것을 위로
      else {
        return aExpired ? -1 : 1;
      }
    });
    
    return deadlineTodos;
  }
  
  // Get upcoming deadline todos (not expired and not completed)
  List<Todo> get upcomingDeadlineTodos {
    final now = DateTime.now();
    final upcomingTodos = _todos.where((todo) => 
      todo.type == TodoType.deadline && 
      todo.deadline != null &&
      !todo.isCompleted &&
      todo.deadline!.isAfter(now)
    ).toList();
    
    upcomingTodos.sort((a, b) => a.deadline!.compareTo(b.deadline!));
    return upcomingTodos;
  }
  
  // Get regular todos
  List<Todo> get regularTodos {
    return _todos.where((todo) => todo.type == TodoType.regular).toList();
  }
  
  // Check if the day has any todos
  bool hasTasksForDay(DateTime day) {
    return _todos.any((todo) {
      if (todo.type == TodoType.regular) {
        return isSameDay(todo.createdAt, day);
      } else {
        return todo.deadline != null && isSameDay(todo.deadline!, day);
      }
    });
  }
  
  // Helper method to check if two dates are the same day
  bool isSameDay(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }
  
  // Set selected date
  void setSelectedDate(DateTime date) {
    _selectedDate = date;
    notifyListeners();
  }
  
  // Add a new todo
  Future<void> addTodo(String title, String description, TodoType type, DateTime? deadline) async {
    final newTodo = Todo(
      id: const Uuid().v4(),
      title: title,
      description: description,
      createdAt: DateTime.now(),
      type: type,
      deadline: deadline,
    );
    
    _todos.add(newTodo);
    await _saveTodos();
    notifyListeners();
  }
  
  // Add a new todo with specific created date
  Future<void> addTodoWithDate(String title, String description, TodoType type, DateTime? deadline, DateTime createdAt) async {
    final newTodo = Todo(
      id: const Uuid().v4(),
      title: title,
      description: description,
      createdAt: createdAt,
      type: type,
      deadline: deadline,
    );
    
    _todos.add(newTodo);
    await _saveTodos();
    notifyListeners();
  }
  
  // Toggle todo completion status
  Future<void> toggleTodoStatus(String id) async {
    final todoIndex = _todos.indexWhere((todo) => todo.id == id);
    if (todoIndex >= 0) {
      _todos[todoIndex] = _todos[todoIndex].copyWith(
        isCompleted: !_todos[todoIndex].isCompleted,
      );
      await _saveTodos();
      notifyListeners();
    }
  }
  
  // Update todo
  Future<void> updateTodo(String id, String title, String description, DateTime? deadline) async {
    final todoIndex = _todos.indexWhere((todo) => todo.id == id);
    if (todoIndex >= 0) {
      _todos[todoIndex] = _todos[todoIndex].copyWith(
        title: title,
        description: description,
        deadline: deadline,
      );
      await _saveTodos();
      notifyListeners();
    }
  }
  
  // Delete todo
  Future<void> deleteTodo(String id) async {
    _todos.removeWhere((todo) => todo.id == id);
    await _saveTodos();
    notifyListeners();
  }
  
  // Load todos from shared preferences
  Future<void> loadTodos() async {
    final prefs = await SharedPreferences.getInstance();
    final todoJsonList = prefs.getStringList('todos');
    
    if (todoJsonList != null) {
      _todos = todoJsonList
          .map((todoJson) => Todo.fromJson(json.decode(todoJson)))
          .toList();
      notifyListeners();
    }
  }
  
  // Save todos to shared preferences
  Future<void> _saveTodos() async {
    final prefs = await SharedPreferences.getInstance();
    final todoJsonList = _todos
        .map((todo) => json.encode(todo.toJson()))
        .toList();
    
    await prefs.setStringList('todos', todoJsonList);
  }
} 