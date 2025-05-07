// lib/screens/settings_screen.dart
// 환경설정 화면    

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/settings_provider.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('환경설정'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: ListView(
        children: [
          _buildThemeSection(context),
          const Divider(),
          _buildFontSizeSection(context),
          const Divider(),
          _buildAlarmSection(context),
        ],
      ),
    );
  }
  
  Widget _buildThemeSection(BuildContext context) {
    final settingsProvider = Provider.of<SettingsProvider>(context);
    
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '테마 설정',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          SwitchListTile(
            title: const Text('다크 모드'),
            value: settingsProvider.isDarkMode,
            onChanged: (value) => settingsProvider.setDarkMode(value),
            secondary: Icon(
              settingsProvider.isDarkMode 
                  ? Icons.dark_mode 
                  : Icons.light_mode,
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildFontSizeSection(BuildContext context) {
    final settingsProvider = Provider.of<SettingsProvider>(context);
    final double currentSize = settingsProvider.fontSize;
    
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '글씨 크기 설정',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              const Icon(Icons.text_decrease),
              Expanded(
                child: Slider(
                  value: currentSize,
                  min: 0.8,
                  max: 1.4,
                  divisions: 6,
                  label: _getFontSizeLabel(currentSize),
                  onChanged: (value) => settingsProvider.setFontSize(value),
                ),
              ),
              const Icon(Icons.text_increase),
            ],
          ),
          Center(
            child: Text(
              '샘플 텍스트',
              style: TextStyle(
                fontSize: 16 * currentSize,
              ),
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildAlarmSection(BuildContext context) {
    final settingsProvider = Provider.of<SettingsProvider>(context);
    
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '알림 설정',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          ListTile(
            title: const Text('마감 전 알림 시간'),
            subtitle: Text('${_formatAlarmTime(settingsProvider.alarmMinutes)} 전에 알림'),
            leading: const Icon(Icons.notifications_active),
            trailing: const Icon(Icons.navigate_next),
            onTap: () => _showAlarmTimePicker(context),
          ),
        ],
      ),
    );
  }
  
  String _getFontSizeLabel(double size) {
    if (size <= 0.8) return '아주 작게';
    if (size <= 0.9) return '작게';
    if (size <= 1.0) return '보통';
    if (size <= 1.1) return '조금 크게';
    if (size <= 1.2) return '크게';
    if (size <= 1.3) return '더 크게';
    return '아주 크게';
  }
  
  String _formatAlarmTime(int minutes) {
    if (minutes < 60) {
      return '$minutes분';
    } else {
      final hours = minutes ~/ 60;
      final remainingMinutes = minutes % 60;
      
      if (remainingMinutes == 0) {
        return '$hours시간';
      } else {
        return '$hours시간 $remainingMinutes분';
      }
    }
  }
  
  void _showAlarmTimePicker(BuildContext context) {
    final settingsProvider = Provider.of<SettingsProvider>(context, listen: false);
    int selectedMinutes = settingsProvider.alarmMinutes;
    
    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setState) {
          return AlertDialog(
            title: const Text('알림 시간 설정'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text('마감 전 얼마나 일찍 알림을 받으시겠습니까?'),
                const SizedBox(height: 16),
                DropdownButton<int>(
                  isExpanded: true,
                  value: selectedMinutes,
                  items: [
                    DropdownMenuItem(value: 5, child: Text(_formatAlarmTime(5))),
                    DropdownMenuItem(value: 15, child: Text(_formatAlarmTime(15))),
                    DropdownMenuItem(value: 30, child: Text(_formatAlarmTime(30))),
                    DropdownMenuItem(value: 60, child: Text(_formatAlarmTime(60))),
                    DropdownMenuItem(value: 120, child: Text(_formatAlarmTime(120))),
                    DropdownMenuItem(value: 180, child: Text(_formatAlarmTime(180))),
                    DropdownMenuItem(value: 360, child: Text(_formatAlarmTime(360))),
                    DropdownMenuItem(value: 720, child: Text(_formatAlarmTime(720))),
                    DropdownMenuItem(value: 1440, child: Text(_formatAlarmTime(1440))),
                  ],
                  onChanged: (value) {
                    if (value != null) {
                      setState(() {
                        selectedMinutes = value;
                      });
                    }
                  },
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(ctx).pop(),
                child: const Text('취소'),
              ),
              TextButton(
                onPressed: () {
                  settingsProvider.setAlarmMinutes(selectedMinutes);
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