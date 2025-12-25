import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:jejak_faa_new/data/models/weather_model.dart';
import 'package:jejak_faa_new/features/map_view/providers/weather_provider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:go_router/go_router.dart';

class WeatherWidget extends ConsumerWidget {
  const WeatherWidget({super.key});

  // Warna sesuai palet Jejak Faa
  static const Color primaryColor = Color(0xFF1A535C);
  static const Color backgroundColor = Color(0xFFF7F7F2);
  static const Color cardColor = Color(0xFFFFFFFF);
  static const Color accentColor = Color(0xFFE07A5F);
  static const Color textPrimary = Color(0xFF2D3748);
  static const Color textSecondary = Color(0xFF718096);
  static const Color textLight = Color(0xFFA0AEC0);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final weatherState = ref.watch(weatherProvider);
    final weatherData = weatherState.data;

    Widget content;

    if (weatherState.lastFetched == null && weatherData == null) {
      content = const SizedBox.shrink();
    } else if (weatherData == null) {
      content = _buildErrorState();
    } else {
      content = _buildWeatherContent(context, weatherData, ref);
    }

    return Positioned(
      top: 60,
      right: 16,
      child: Material(
        color: cardColor,
        borderRadius: BorderRadius.circular(16),
        elevation: 8,
        shadowColor: Colors.black.withOpacity(0.2),
        child: InkWell(
          onTap: () {
            context.push('/home/weather');
          },
          borderRadius: BorderRadius.circular(16),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            constraints: const BoxConstraints(minWidth: 140),
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 300),
              child: content,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildWeatherContent(BuildContext context, WeatherData weatherData, WidgetRef ref) {
    final iconCode = weatherData.current.iconCode;
    final iconUrl = ref.read(weatherProvider.notifier).getIconUrl(iconCode);
    final condition = _getWeatherCondition(weatherData.current.conditionMain);
    final temperature = '${weatherData.current.temp.toStringAsFixed(0)}°C';

    return Row(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // Weather Icon
        if (iconUrl != null)
          Container(
            width: 36,
            height: 36,
            margin: const EdgeInsets.only(right: 8),
            child: CachedNetworkImage(
              imageUrl: iconUrl,
              width: 36,
              height: 36,
              placeholder: (context, url) => Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: backgroundColor,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Center(
                  child: SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(primaryColor),
                    ),
                  ),
                ),
              ),
              errorWidget: (context, url, error) => Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: backgroundColor,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  Icons.cloud_outlined,
                  color: primaryColor,
                  size: 20,
                ),
              ),
            ),
          ),
        
        // Weather Info
        Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              temperature,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: textPrimary,
              ),
            ),
            Text(
              condition,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: textSecondary,
              ),
            ),
          ],
        ),
        
        // Chevron Icon
        const SizedBox(width: 8),
        Icon(
          Icons.chevron_right_rounded,
          color: textLight,
          size: 16,
        ),
      ],
    );
  }

  Widget _buildErrorState() {
    return Row(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          width: 28,
          height: 28,
          decoration: BoxDecoration(
            color: accentColor.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            Icons.cloud_off_outlined,
            color: accentColor,
            size: 16,
          ),
        ),
        const SizedBox(width: 8),
        Text(
          'No Data',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: textSecondary,
          ),
        ),
      ],
    );
  }

  String _getWeatherCondition(String conditionMain) {
    switch (conditionMain) {
      case "Clear":
        return "Cerah";
      case "Clouds":
        return "Berawan";
      case "Rain":
        return "Hujan";
      case "Drizzle":
        return "Gerimis";
      case "Thunderstorm":
        return "Badai Petir";
      case "Mist":
      case "Fog":
        return "Berkabut";
      case "Snow":
        return "Salju";
      case "Atmosphere":
        return "Berkabut";
      default:
        return conditionMain;
    }
  }
}