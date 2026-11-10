import 'package:flutter/material.dart';
import '../models/task.dart';
import '../utils/constants.dart';
import '../utils/date_formatter.dart';
import '../utils/validators.dart';
import 'loading_view.dart';

/// Form dùng chung cho màn hình thêm và chỉnh sửa công việc.
class TaskForm extends StatefulWidget {
  final Task? initial;
  final String submitLabel;
  final Future<void> Function(Map<String, dynamic> data) onSubmit;

  const TaskForm({
    super.key,
    this.initial,
    required this.submitLabel,
    required this.onSubmit,
  });

  @override
  State<TaskForm> createState() => _TaskFormState();
}

class _TaskFormState extends State<TaskForm> {
  final _formKey = GlobalKey<FormState>();
  late final _title = TextEditingController(text: widget.initial?.title);
  late final _desc = TextEditingController(text: widget.initial?.description);
  late DateTime? _start = widget.initial?.startDate ?? DateTime.now();
  late DateTime? _due = widget.initial?.dueDate;
  late String _priority = widget.initial?.priority ?? 'medium';
  late String _status = widget.initial?.status ?? 'todo';
  bool _saving = false;

  @override
  void dispose() {
    _title.dispose();
    _desc.dispose();
    super.dispose();
  }

  Future<void> _pick(bool isStart) async {
    final now = DateTime.now();
    final initial = (isStart ? _start : _due) ?? now;
    final d = await showDatePicker(
      context: context,
      initialDate: initial,
      firstDate: DateTime(now.year - 1),
      lastDate: DateTime(now.year + 5),
    );
    if (d != null) setState(() => isStart ? _start = d : _due = d);
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    if (_start != null && _due != null && _due!.isBefore(_start!)) {
      showSnack(context, 'Hạn hoàn thành phải sau ngày bắt đầu', error: true);
      return;
    }
    setState(() => _saving = true);
    try {
      await widget.onSubmit({
        'title': _title.text.trim(),
        'description': _desc.text.trim(),
        'startDate': _start?.toUtc().toIso8601String(),
        'dueDate': _due?.toUtc().toIso8601String(),
        'priority': _priority,
        'status': _status,
      });
    } catch (e) {
      if (mounted) showSnack(context, e.toString(), error: true);
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: ListView(padding: const EdgeInsets.all(16), children: [
        TextFormField(
          controller: _title,
          decoration: const InputDecoration(labelText: 'Tên công việc *', border: OutlineInputBorder()),
          validator: (v) => Validators.required(v, 'Tên công việc'),
        ),
        const SizedBox(height: 14),
        TextFormField(
          controller: _desc,
          maxLines: 4,
          decoration: const InputDecoration(labelText: 'Mô tả', alignLabelWithHint: true, border: OutlineInputBorder()),
        ),
        const SizedBox(height: 14),
        Row(children: [
          Expanded(child: _DateField(label: 'Ngày bắt đầu', value: _start, onTap: () => _pick(true))),
          const SizedBox(width: 12),
          Expanded(child: _DateField(label: 'Hạn hoàn thành', value: _due, onTap: () => _pick(false))),
        ]),
        const SizedBox(height: 14),
        DropdownButtonFormField<String>(
          initialValue: _priority,
          decoration: const InputDecoration(labelText: 'Mức độ ưu tiên', border: OutlineInputBorder()),
          items: [
            for (final e in AppConstants.priorities.entries)
              DropdownMenuItem(value: e.key, child: Text(e.value)),
          ],
          onChanged: (v) => setState(() => _priority = v!),
        ),
        const SizedBox(height: 14),
        DropdownButtonFormField<String>(
          initialValue: _status,
          decoration: const InputDecoration(labelText: 'Trạng thái', border: OutlineInputBorder()),
          items: [
            for (final e in AppConstants.statuses.entries)
              DropdownMenuItem(value: e.key, child: Text(e.value)),
          ],
          onChanged: (v) => setState(() => _status = v!),
        ),
        const SizedBox(height: 24),
        FilledButton(
          onPressed: _saving ? null : _submit,
          child: _saving
              ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2))
              : Text(widget.submitLabel),
        ),
      ]),
    );
  }
}

class _DateField extends StatelessWidget {
  final String label;
  final DateTime? value;
  final VoidCallback onTap;
  const _DateField({required this.label, required this.value, required this.onTap});

  @override
  Widget build(BuildContext context) => InkWell(
        onTap: onTap,
        child: InputDecorator(
          decoration: InputDecoration(
            labelText: label,
            border: const OutlineInputBorder(),
            suffixIcon: const Icon(Icons.calendar_today, size: 18),
          ),
          child: Text(DateFormatter.date(value)),
        ),
      );
}
