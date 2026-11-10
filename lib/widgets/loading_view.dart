import 'package:flutter/material.dart';

class LoadingView extends StatelessWidget {
  const LoadingView({super.key});
  @override
  Widget build(BuildContext context) =>
      const Center(child: CircularProgressIndicator());
}

class ErrorView extends StatelessWidget {
  final String message;
  final VoidCallback? onRetry;
  const ErrorView({super.key, required this.message, this.onRetry});

  @override
  Widget build(BuildContext context) => Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.error_outline,
                  size: 48, color: Theme.of(context).colorScheme.error),
              const SizedBox(height: 12),
              Text(message, textAlign: TextAlign.center),
              if (onRetry != null) ...[
                const SizedBox(height: 12),
                FilledButton.tonal(onPressed: onRetry, child: const Text('Thử lại')),
              ],
            ],
          ),
        ),
      );
}

class EmptyView extends StatelessWidget {
  final String message;
  final IconData icon;
  const EmptyView({super.key, required this.message, this.icon = Icons.inbox_outlined});

  @override
  Widget build(BuildContext context) => Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 56, color: Theme.of(context).colorScheme.outline),
            const SizedBox(height: 8),
            Text(message, style: TextStyle(color: Theme.of(context).colorScheme.outline)),
          ],
        ),
      );
}

void showSnack(BuildContext context, String msg, {bool error = false}) {
  final cs = Theme.of(context).colorScheme;
  ScaffoldMessenger.of(context)
    ..hideCurrentSnackBar()
    ..showSnackBar(SnackBar(
      content: Text(msg),
      backgroundColor: error ? cs.error : null,
    ));
}

Future<bool> confirmDialog(BuildContext context, String title, String content,
    {String confirmLabel = 'Xác nhận'}) async {
  final r = await showDialog<bool>(
    context: context,
    builder: (ctx) => AlertDialog(
      title: Text(title),
      content: Text(content),
      actions: [
        TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Hủy')),
        FilledButton(onPressed: () => Navigator.pop(ctx, true), child: Text(confirmLabel)),
      ],
    ),
  );
  return r ?? false;
}
