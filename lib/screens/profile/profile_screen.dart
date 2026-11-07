// lib/screens/profile/profile_screen.dart
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../services/api_client.dart';
import '../auth/login_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  Map<String, dynamic>? _userProfile;
  Map<String, dynamic>? _stats;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadProfileAndStats();
  }

  Future<void> _loadProfileAndStats() async {
    setState(() => _isLoading = true);
    final userRes = await ApiClient.get('/auth/me');
    final statsRes = await ApiClient.get('/statistics/tasks');

    if (userRes.statusCode == 200) {
      _userProfile = jsonDecode(userRes.body);
    }
    if (statsRes.statusCode == 200) {
      _stats = jsonDecode(statsRes.body);
    }
    setState(() => _isLoading = false);
  }

  Future<void> _logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('jwt_token');
    if (mounted) {
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (_) => const LoginScreen()),
            (route) => false,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Cá nhân & Thống kê')),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            CircleAvatar(
              radius: 40,
              child: Text(_userProfile?['fullName']?[0]?.toUpperCase() ?? 'U', style: const TextStyle(fontSize: 32)),
            ),
            const SizedBox(height: 12),
            Text(_userProfile?['fullName'] ?? '', style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            Text(_userProfile?['email'] ?? '', style: const TextStyle(color: Colors.grey)),
            const Divider(height: 32),
            const Align(
              alignment: Alignment.centerLeft,
              child: Text('Thống kê công việc', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                _buildStatCard('Chưa làm', _stats?['todo']?.toString() ?? '0', Colors.grey),
                _buildStatCard('Đang làm', _stats?['in_progress']?.toString() ?? '0', Colors.orange),
                _buildStatCard('Hoàn thành', _stats?['completed']?.toString() ?? '0', Colors.green),
              ],
            ),
            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent),
                onPressed: _logout,
                icon: const Icon(Icons.logout, color: Colors.white),
                label: const Text('Đăng xuất', style: TextStyle(color: Colors.white)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatCard(String label, String value, Color color) {
    return Expanded(
      child: Card(
        color: color.withOpacity(0.1),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 16.0),
          child: Column(
            children: [
              Text(value, style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: color)),
              const SizedBox(height: 4),
              Text(label, style: TextStyle(fontSize: 12, color: color)),
            ],
          ),
        ),
      ),
    );
  }
}