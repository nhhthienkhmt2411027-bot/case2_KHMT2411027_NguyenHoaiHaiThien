// lib/widgets/user_selector.dart
import 'dart:convert';
import 'package:flutter/material.dart';
import '../models/user.dart';
import '../services/api_client.dart';

class UserSelector extends StatefulWidget {
  final Function(UserModel) onUserSelected;

  const UserSelector({super.key, required this.onUserSelected});

  @override
  State<UserSelector> createState() => _UserSelectorState();
}

class _UserSelectorState extends State<UserSelector> {
  final _searchController = TextEditingController();
  List<UserModel> _searchResults = [];
  bool _isSearching = false;

  Future<void> _searchUsers(String query) async {
    if (query.trim().isEmpty) {
      setState(() => _searchResults = []);
      return;
    }
    setState(() => _isSearching = true);
    final res = await ApiClient.get('/users/search?q=${Uri.encodeComponent(query)}');
    if (res.statusCode == 200) {
      final List data = jsonDecode(res.body);
      setState(() {
        _searchResults = data.map((item) => UserModel.fromJson(item)).toList();
      });
    }
    setState(() => _isSearching = false);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        TextField(
          controller: _searchController,
          decoration: InputDecoration(
            labelText: 'Tìm người dùng theo tên/email',
            suffixIcon: IconButton(
              icon: const Icon(Icons.search),
              onPressed: () => _searchUsers(_searchController.text),
            ),
            border: const OutlineInputBorder(),
          ),
          onSubmitted: _searchUsers,
        ),
        if (_isSearching) const Padding(padding: EdgeInsets.all(8.0), child: CircularProgressIndicator()),
        if (_searchResults.isNotEmpty)
          Container(
            height: 150,
            margin: const EdgeInsets.only(top: 8),
            decoration: BoxDecoration(border: Border.all(color: Colors.grey.shade300), borderRadius: BorderRadius.circular(8)),
            child: ListView.builder(
              itemCount: _searchResults.length,
              itemBuilder: (context, index) {
                final user = _searchResults[index];
                return ListTile(
                  leading: CircleAvatar(child: Text(user.fullName.isNotEmpty ? user.fullName[0].toUpperCase() : 'U')),
                  title: Text(user.fullName),
                  subtitle: Text(user.email),
                  onTap: () {
                    widget.onUserSelected(user);
                    setState(() {
                      _searchResults = [];
                      _searchController.clear();
                    });
                  },
                );
              },
            ),
          ),
      ],
    );
  }
}