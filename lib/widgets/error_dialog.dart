import 'package:flutter/material.dart';

/// Shows a warning popup for a failed API response — lists every validation
/// message returned in `errors` (Laravel's standard {field: [messages]}
/// shape) rather than just the first one found, so the actual cause is
/// visible instead of a generic "failed" message.
Future<void> showApiErrorDialog(
  BuildContext context,
  Map<String, dynamic> response, {
  String fallbackMessage = 'Something went wrong. Please try again.',
}) {
  final messages = <String>[];

  final errors = response['errors'];
  if (errors is Map) {
    for (final value in errors.values) {
      if (value is List) {
        messages.addAll(value.map((e) => e.toString()));
      } else if (value != null) {
        messages.add(value.toString());
      }
    }
  }

  if (messages.isEmpty) {
    final message = response['message']?.toString();
    messages.add(
      message != null && message.isNotEmpty ? message : fallbackMessage,
    );
  }

  return showDialog(
    context: context,
    builder: (dialogContext) => AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      title: const Row(
        children: [
          Icon(Icons.warning_amber_rounded, color: Colors.orange),
          SizedBox(width: 8),
          Text(
            'Something went wrong',
            style: TextStyle(
              fontFamily: 'Montserrat',
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
        ],
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: messages
            .map(
              (m) => Padding(
                padding: const EdgeInsets.only(bottom: 6),
                child: Text(
                  m,
                  style: const TextStyle(
                    fontFamily: 'Montserrat',
                    fontSize: 14,
                  ),
                ),
              ),
            )
            .toList(),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(dialogContext),
          child: const Text('OK'),
        ),
      ],
    ),
  );
}
