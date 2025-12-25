// Salin ke: lib/features/profile/widgets/badge_card.dart
import 'package:flutter/material.dart';

class BadgeCard extends StatelessWidget {
  final String title;
  final IconData icon;
  final bool isUnlocked;
  final String description;
  final Color? primaryColor;
  final Color? accentColor; // Opsional untuk Tooltip

  const BadgeCard({
    super.key,
    required this.title,
    required this.icon,
    required this.isUnlocked,
    this.description = '', // Default kosong
    this.primaryColor,
    this.accentColor
  });

  @override
  Widget build(BuildContext context) {
     final primary = primaryColor ?? const Color(0xFF1A535C);
    final accent = accentColor ?? const Color(0xFFE07A5F);
    // Tentukan warna berdasarkan status 'isUnlocked'
    final Color activeColor = Theme.of(context).colorScheme.primary;
    final Color inactiveColor = Colors.grey.shade500;
    final Color bgColor = isUnlocked 
        ? activeColor.withOpacity(0.1) 
        : Colors.grey.shade100;
    final Color iconColor = isUnlocked ? activeColor : inactiveColor;
    final Color textColor = isUnlocked ? Colors.black87 : inactiveColor;

    return Tooltip(
      message: description.isEmpty ? title : description,
      child: Container(
        width: 90, // Lebar kartu
        height: 100, // Tinggi kartu
        padding: const EdgeInsets.all(12.0),
        margin: const EdgeInsets.only(right: 10.0), // Jarak antar kartu
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(16.0),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 32,
              color: iconColor,
            ),
            const SizedBox(height: 8),
            Text(
              title,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: textColor,
                    fontWeight: isUnlocked ? FontWeight.bold : FontWeight.normal,
                  ),
              textAlign: TextAlign.center,
              maxLines: 2,
            ),
          ],
        ),
      ),
    );
  }
}