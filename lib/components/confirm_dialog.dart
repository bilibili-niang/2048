import 'package:flutter/material.dart';

class ConfirmDialog extends StatefulWidget {
  final String title;
  final String message;
  final String confirmLabel;
  final Future<void> Function() onConfirm;

  const ConfirmDialog({
    super.key,
    required this.title,
    required this.message,
    required this.confirmLabel,
    required this.onConfirm,
  });

  @override
  State<ConfirmDialog> createState() => _ConfirmDialogState();
}

class _ConfirmDialogState extends State<ConfirmDialog> {
  bool _submitting = false;

  @override
  Widget build(BuildContext context) {
    final navigator = Navigator.of(context);
    final messenger = ScaffoldMessenger.maybeOf(context);
    return AlertDialog(
      title: Text(widget.title),
      content: Text(widget.message),
      actions: [
        TextButton(
          onPressed: _submitting ? null : () => Navigator.pop(context, false),
          child: const Text('取消'),
        ),
        FilledButton(
          onPressed: _submitting
              ? null
              : () async {
                  setState(() {
                    _submitting = true;
                  });
                  try {
                    await widget.onConfirm();
                    if (!mounted) {
                      return;
                    }
                    navigator.pop(true);
                  } catch (_) {
                    if (!mounted) {
                      return;
                    }
                    messenger?.showSnackBar(
                      const SnackBar(content: Text('操作失败，请重试。')),
                    );
                  } finally {
                    if (mounted) {
                      setState(() {
                        _submitting = false;
                      });
                    }
                  }
                },
          child: Text(widget.confirmLabel),
        ),
      ],
    );
  }
}
