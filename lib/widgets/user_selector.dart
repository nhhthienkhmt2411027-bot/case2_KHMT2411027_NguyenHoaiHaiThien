import 'dart:async';
import 'package:flutter/material.dart';
import '../models/user.dart';
import '../services/user_service.dart';

/// Tìm người dùng theo tên/email và chọn nhiều người.
class UserSelector extends StatefulWidget {
  final List<User> initialSelected;
  final Set<String> excludeIds;
  final ValueChanged<List<User>> onChanged;

  const UserSelector({
    super.key,
    this.initialSelected = const [],
    this.excludeIds = const {},
    required this.onChanged,
  });

  @override
  State<UserSelector> createState() => _UserSelectorState();
}

class _UserSelectorState extends State<UserSelector> {
  final _service = UserService();
  final _controller = TextEditingController();
  late final List<User> _selected = [...widget.initialSelected];
  List<User> _results = [];
  bool _loading = false;
  String? _error;
  Timer? _debounce;

  @override
  void dispose() {
    _debounce?.cancel();
    _controller.dispose();
    super.dispose();
  }

  void _onQuery(String q) {
    _debounce?.cancel();
    if (q.trim().length < 2) {
      setState(() {
        _results = [];
        _error = null;
      });
      return;
    }
    _debounce = Timer(const Duration(milliseconds: 400), () async {
      setState(() {
        _loading = true;
        _error = null;
      });
      try {
        final r = await _service.search(q);
        if (!mounted) return;
        setState(() => _results = r.where((u) => !widget.excludeIds.contains(u.id)).toList());
      } catch (e) {
        if (mounted) setState(() => _error = e.toString());
      } finally {
        if (mounted) setState(() => _loading = false);
      }
    });
  }

  bool _isSelected(User u) => _selected.any((s) => s.id == u.id);

  void _toggle(User u) {
    setState(() {
      if (_isSelected(u)) {
        _selected.removeWhere((s) => s.id == u.id);
      } else {
        _selected.add(u);
      }
    });
    widget.onChanged(List.unmodifiable(_selected));
  }

  @override
  Widget build(BuildContext context) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      TextField(
        controller: _controller,
        onChanged: _onQuery,
        decoration: InputDecoration(
          labelText: 'Tìm theo tên hoặc email',
          prefixIcon: const Icon(Icons.search),
          border: const OutlineInputBorder(),
          suffixIcon: _loading
              ? const Padding(
                  padding: EdgeInsets.all(12),
                  child: SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2)))
              : null,
        ),
      ),
      if (_selected.isNotEmpty) ...[
        const SizedBox(height: 10),
        Wrap(spacing: 6, runSpacing: 6, children: [
          for (final u in _selected)
            InputChip(
              avatar: CircleAvatar(child: Text(u.initials)),
              label: Text(u.displayName),
              onDeleted: () => _toggle(u),
            ),
        ]),
      ],
      if (_error != null)
        Padding(
          padding: const EdgeInsets.only(top: 8),
          child: Text(_error!, style: TextStyle(color: Theme.of(context).colorScheme.error)),
        ),
      for (final u in _results)
        CheckboxListTile(
          value: _isSelected(u),
          onChanged: (_) => _toggle(u),
          secondary: CircleAvatar(child: Text(u.initials)),
          title: Text(u.displayName),
          subtitle: Text(u.email),
          contentPadding: EdgeInsets.zero,
        ),
    ]);
  }
}
