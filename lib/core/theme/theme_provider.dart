import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'app_theme.dart';

final isDarkProvider = StateProvider<bool>((ref) => false);

final themeProvider = Provider<ThemeData>((ref) {
  final isDark = ref.watch(isDarkProvider);
  return isDark ? AppTheme.dark : AppTheme.light;
});
