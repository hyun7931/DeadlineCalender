// lib/widgets/add_todo_form.dart
// 할일 추가 위젯젯

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../models/todo.dart';
import '../providers/todo_provider.dart';

class AddTodoForm extends StatefulWidget {
  final VoidCallback onClose;
  
  const AddTodoForm({
    Key? key,
    required this.onClose,
  }) : super(key: key);

  @override
  State<AddTodoForm> createState() => _AddTodoFormState();
}

class _AddTodoFormState extends State<AddTodoForm> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  TodoType _selectedType = TodoType.regular;
  DateTime? _deadline;
  TimeOfDay? _timeOfDay;
  
  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }
  
  Future<void> _selectDate(BuildContext context) async {
    final now = DateTime.now();
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _deadline ?? now,
      firstDate: now,
      lastDate: DateTime(now.year + 5),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: Theme.of(context).colorScheme.copyWith(
              primary: Theme.of(context).colorScheme.primary,
              onPrimary: Colors.white,
              surface: const Color(0xFF222222),
              onSurface: Colors.white,
            ),
            dialogBackgroundColor: const Color(0xFF1E1E1E),
          ),
          child: child!,
        );
      },
    );
    
    if (picked != null && picked != _deadline) {
      setState(() {
        _deadline = picked;
      });
      
      // If time not selected yet, show time picker
      if (_timeOfDay == null) {
        _selectTime(context);
      }
    }
  }
  
  Future<void> _selectTime(BuildContext context) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: _timeOfDay ?? TimeOfDay.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: Theme.of(context).colorScheme.copyWith(
              primary: Theme.of(context).colorScheme.primary,
              onPrimary: Colors.white,
              surface: const Color(0xFF222222),
              onSurface: Colors.white,
            ),
            dialogBackgroundColor: const Color(0xFF1E1E1E),
          ),
          child: child!,
        );
      },
    );
    
    if (picked != null) {
      setState(() {
        _timeOfDay = picked;
        
        if (_deadline != null) {
          // Combine date and time
          _deadline = DateTime(
            _deadline!.year,
            _deadline!.month,
            _deadline!.day,
            picked.hour,
            picked.minute,
          );
        }
      });
    }
  }
  
  void _submitForm() {
    if (!_formKey.currentState!.validate()) {
      return;
    }
    
    if (_selectedType == TodoType.deadline && _deadline == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('데드라인을 설정해주세요'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }
    
    final todoProvider = Provider.of<TodoProvider>(context, listen: false);
    
    todoProvider.addTodo(
      _titleController.text.trim(),
      _descriptionController.text.trim(),
      _selectedType,
      _deadline,
    );
    
    widget.onClose();
  }
  
  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                '할 일 추가',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 24),
              TextFormField(
                controller: _titleController,
                decoration: const InputDecoration(
                  labelText: '제목',
                  prefixIcon: Icon(Icons.title),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return '제목을 입력해주세요';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _descriptionController,
                decoration: const InputDecoration(
                  labelText: '설명 (선택사항)',
                  prefixIcon: Icon(Icons.description),
                ),
                maxLines: 3,
              ),
              const SizedBox(height: 24),
              Text(
                '유형 선택',
                style: Theme.of(context).textTheme.bodyLarge,
              ),
              Row(
                children: [
                  Expanded(
                    child: RadioListTile<TodoType>(
                      title: const Text('일반'),
                      value: TodoType.regular,
                      groupValue: _selectedType,
                      onChanged: (TodoType? value) {
                        setState(() {
                          _selectedType = value!;
                        });
                      },
                    ),
                  ),
                  Expanded(
                    child: RadioListTile<TodoType>(
                      title: const Text('데드라인'),
                      value: TodoType.deadline,
                      groupValue: _selectedType,
                      onChanged: (TodoType? value) {
                        setState(() {
                          _selectedType = value!;
                          
                          // Show date picker if deadline type is selected
                          if (value == TodoType.deadline) {
                            Future.delayed(Duration.zero, () {
                              _selectDate(context);
                            });
                          }
                        });
                      },
                    ),
                  ),
                ],
              ),
              if (_selectedType == TodoType.deadline) ...[
                const SizedBox(height: 16),
                Text(
                  '데드라인 설정',
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
                const SizedBox(height: 8),
                InkWell(
                  onTap: () => _selectDate(context),
                  child: InputDecorator(
                    decoration: const InputDecoration(
                      prefixIcon: Icon(Icons.calendar_today),
                      border: OutlineInputBorder(),
                    ),
                    child: Text(
                      _deadline == null
                          ? '날짜 선택'
                          : DateFormat('yyyy년 MM월 dd일 - HH:mm').format(_deadline!),
                    ),
                  ),
                ),
              ],
              const SizedBox(height: 32),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: widget.onClose,
                    child: const Text('취소'),
                  ),
                  const SizedBox(width: 16),
                  ElevatedButton(
                    onPressed: _submitForm,
                    child: const Text('저장'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
} 