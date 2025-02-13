import 'package:flutter/material.dart';

void showCustomSnackBar(
  BuildContext context, IconData icon, String title, String subtitle, Color color) {
  final snackBar = SnackBar(
  content: Row(
    children: [
    Icon(icon, color: Colors.white),
    const SizedBox(width: 8),
    Expanded(
      child: Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
        if (subtitle.isNotEmpty) Text(subtitle),
      ],
      ),
    ),
    ],
  ),
  backgroundColor: color,
  behavior: SnackBarBehavior.floating,
  margin: const EdgeInsets.all(20.0),
  duration: const Duration(milliseconds: 2000),
  dismissDirection: DismissDirection.horizontal,
  );

  ScaffoldMessenger.of(context).showSnackBar(snackBar);
}