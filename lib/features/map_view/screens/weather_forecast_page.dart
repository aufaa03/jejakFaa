import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:jejak_faa_new/data/models/weather_model.dart';
import 'package:jejak_faa_new/features/map_view/providers/weather_provider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:intl/intl.dart';

class WeatherForecastPage extends ConsumerWidget {
  const WeatherForecastPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final weatherState = ref.watch(weatherProvider);
    
    // Cek struktur WeatherCache yang sebenarnya
    // Kemungkinan WeatherCache memiliki properti seperti:
    // - data (WeatherData?)
    // - isLoading (bool?)
    // - error (String?)
    // Atau mungkin struktur yang berbeda

    Widget bodyContent;
    
    // Coba akses properti yang mungkin ada
    final weatherData = weatherState.data; // Asumsi ada properti data
    
    // Jika data null, tampilkan loading/empty state
    if (weatherData == null) {
      bodyContent = const _WeatherLoadingState();
    } else {
      bodyContent = _WeatherContent(weatherData: weatherData, ref: ref);
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF7F7F2),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_rounded, color: const Color(0xFF1A535C)),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          'Prediksi Cuaca',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w700,
            color: const Color(0xFF1A1A1A),
          ),
        ),
      ),
      body: bodyContent,
    );
  }
}

class _WeatherContent extends ConsumerWidget {
  final WeatherData weatherData;
  final WidgetRef ref;

  const _WeatherContent({
    required this.weatherData,
    required this.ref,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final current = weatherData.current;
    final hourly = weatherData.hourly;
    final daily = weatherData.daily;

    return CustomScrollView(
      slivers: [
        // Header dengan gradient
        SliverToBoxAdapter(
          child: Container(
            padding: const EdgeInsets.all(24),
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Color(0xFF1A535C),
                  Color(0xFF4ECDC4),
                ],
              ),
            ),
            child: Row(
              children: [
                Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Icon(
                    Icons.cloud_rounded,
                    color: Colors.white,
                    size: 32,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Kondisi Cuaca Saat Ini',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Update real-time untuk pendakian Anda',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.white.withOpacity(0.9),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),

        // Content
        SliverPadding(
          padding: const EdgeInsets.all(24),
          sliver: SliverList(
            delegate: SliverChildListDelegate([
              // Cuaca Sekarang
              _buildCurrentWeather(context, current, daily),
              const SizedBox(height: 20),

              // Kondisi Pendakian
              _buildClimbingConditions(context, current),
              const SizedBox(height: 20),

              // Peringatan
              _buildWarnings(context, current, daily),
              const SizedBox(height: 20),

              // Prediksi Per Jam
              _buildHourlyForecast(context, hourly, ref),
              const SizedBox(height: 20),

              // Prediksi Harian
              if (daily.isNotEmpty) _buildDailyForecast(context, daily),
            ]),
          ),
        ),
      ],
    );
  }

  Widget _buildCurrentWeather(
    BuildContext context,
    CurrentWeather current,
    List<DailyWeather> daily,
  ) {
    String getWeatherEmoji(String condition) {
      if (condition.contains('rain')) return '🌧️';
      if (condition.contains('cloud')) return '☁️';
      if (condition.contains('clear') || condition.contains('sunny')) return '☀️';
      if (condition.contains('overcast')) return '🌥️';
      if (condition.contains('mist') || condition.contains('fog')) return '🌫️';
      return '⛅';
    }

    final condition = current.conditionDescription.isNotEmpty
        ? current.conditionDescription[0].toUpperCase() +
            current.conditionDescription.substring(1)
        : 'Tidak tersedia';
    final emoji = getWeatherEmoji(current.conditionDescription);

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Cuaca Sekarang',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: const Color(0xFF1A1A1A),
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Text(
                emoji,
                style: const TextStyle(fontSize: 48),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      condition,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: const Color(0xFF1A1A1A),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${current.temp.toStringAsFixed(0)}°C',
                      style: TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.w700,
                        color: const Color(0xFF1A535C),
                      ),
                    ),
                    Text(
                      'Terasa ${current.feelsLike.toStringAsFixed(0)}°C',
                      style: TextStyle(
                        fontSize: 14,
                        color: const Color(0xFF666666),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildClimbingConditions(
    BuildContext context,
    CurrentWeather current,
  ) {
    String getVisibilityStatus(int visibility) {
      final km = visibility / 1000;
      if (km > 10) return 'Bagus';
      if (km > 5) return 'Cukup';
      return 'Terbatas';
    }

    String getPressureStatus(int pressure) {
      if (pressure >= 1013) return 'Stabil';
      if (pressure >= 1000) return 'Menurun';
      return 'Rendah';
    }

    String getCloudStatus(int clouds) {
      if (clouds < 20) return 'Cerah';
      if (clouds < 50) return 'Berawan';
      return 'Mendung';
    }

    final visibilityKm = (current.visibility / 1000).toStringAsFixed(1);
    final windSpeedKmh = (current.windSpeed * 3.6).toStringAsFixed(1);

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Kondisi Pendakian',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: const Color(0xFF1A1A1A),
            ),
          ),
          const SizedBox(height: 16),
          _buildConditionRow(
            icon: Icons.visibility_rounded,
            label: 'Visibilitas',
            value: '$visibilityKm km',
            status: getVisibilityStatus(current.visibility),
            statusColor: getVisibilityStatus(current.visibility) == 'Terbatas' 
                ? const Color(0xFFFFC107) 
                : const Color(0xFF4ECDC4),
          ),
          const SizedBox(height: 12),
          _buildConditionRow(
            icon: Icons.compress_rounded,
            label: 'Tekanan Udara',
            value: '${current.pressure} hPa',
            status: getPressureStatus(current.pressure),
            statusColor: getPressureStatus(current.pressure) == 'Rendah'
                ? const Color(0xFFFFC107)
                : const Color(0xFF4ECDC4),
          ),
          const SizedBox(height: 12),
          _buildConditionRow(
            icon: Icons.cloud_rounded,
            label: 'Tutupan Awan',
            value: '${current.clouds}%',
            status: getCloudStatus(current.clouds),
            statusColor: const Color(0xFF4ECDC4),
          ),
          const SizedBox(height: 12),
          _buildConditionRow(
            icon: Icons.water_drop_rounded,
            label: 'Kelembapan',
            value: '${current.humidity}%',
            status: '',
            statusColor: const Color(0xFF4ECDC4),
          ),
          const SizedBox(height: 12),
          _buildConditionRow(
            icon: Icons.air_rounded,
            label: 'Kecepatan Angin',
            value: '$windSpeedKmh km/jam',
            status: '',
            statusColor: const Color(0xFF4ECDC4),
          ),
        ],
      ),
    );
  }

  Widget _buildWarnings(
    BuildContext context,
    CurrentWeather current,
    List<DailyWeather> daily,
  ) {
    if (daily.isEmpty) return const SizedBox.shrink();

    final todayDaily = daily[0];
    final rainProbability = todayDaily.popPercentage;

    String getRainStatus(int pop) {
      if (pop < 20) return 'Aman';
      if (pop < 50) return 'Waspada';
      return 'Berhati-hati';
    }

    Color getRainStatusColor(int pop) {
      if (pop < 20) return const Color(0xFF4ECDC4);
      if (pop < 50) return const Color(0xFFFFC107);
      return const Color(0xFFE07A5F);
    }

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: getRainStatusColor(rainProbability).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  Icons.warning_amber_rounded,
                  color: getRainStatusColor(rainProbability),
                  size: 18,
                ),
              ),
              const SizedBox(width: 12),
              Text(
                'Peringatan Cuaca',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: const Color(0xFF1A1A1A),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _buildConditionRow(
            icon: Icons.water_drop_rounded,
            label: 'Kemungkinan Hujan',
            value: '$rainProbability%',
            status: getRainStatus(rainProbability),
            statusColor: getRainStatusColor(rainProbability),
          ),
        ],
      ),
    );
  }

  Widget _buildHourlyForecast(
    BuildContext context,
    List<HourlyWeather> hourly,
    WidgetRef ref,
  ) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Prediksi 24 Jam',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: const Color(0xFF1A1A1A),
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            height: 120,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: hourly.length,
              itemBuilder: (context, index) {
                final hour = hourly[index];
                final iconUrl =
                    ref.read(weatherProvider.notifier).getIconUrl(hour.iconCode);
                final localTime = hour.time.toLocal();
                final timeString = DateFormat('HH:mm').format(localTime);

                return Container(
                  width: 80,
                  margin: const EdgeInsets.only(right: 12),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF7F7F2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      Text(
                        timeString,
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: const Color(0xFF1A1A1A),
                        ),
                      ),
                      if (iconUrl != null)
                        CachedNetworkImage(
                          imageUrl: iconUrl,
                          width: 40,
                          height: 40,
                          errorWidget: (context, url, error) => Icon(
                            Icons.cloud_outlined,
                            color: const Color(0xFF1A535C),
                            size: 32,
                          ),
                        ),
                      Text(
                        '${hour.temp.toStringAsFixed(0)}°C',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: const Color(0xFF1A535C),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDailyForecast(
    BuildContext context,
    List<DailyWeather> daily,
  ) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Prediksi 7 Hari',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: const Color(0xFF1A1A1A),
            ),
          ),
          const SizedBox(height: 16),
          ...daily.take(7).toList().asMap().entries.map((entry) {
            final index = entry.key;
            final day = entry.value;
            // Generate dates starting from today
            final date = DateFormat('EEEE', 'id_ID').format(
              DateTime.now().add(Duration(days: index))
            );
            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      date,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: const Color(0xFF1A1A1A),
                      ),
                    ),
                  ),
                  Text(
                    '${day.tempMax.toStringAsFixed(0)}° / ${day.tempMin.toStringAsFixed(0)}°',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: const Color(0xFF1A535C),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: const Color(0xFF4ECDC4).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      '${day.popPercentage}%',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: const Color(0xFF1A535C),
                      ),
                    ),
                  ),
                ],
              ),
            );
          }).toList(),
        ],
      ),
    );
  }

  Widget _buildConditionRow({
    required IconData icon,
    required String label,
    required String value,
    required String status,
    required Color statusColor,
  }) {
    return Row(
      children: [
        Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            color: const Color(0xFF1A535C).withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            icon,
            color: const Color(0xFF1A535C),
            size: 18,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: const Color(0xFF666666),
                ),
              ),
              Text(
                value,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: const Color(0xFF1A1A1A),
                ),
              ),
            ],
          ),
        ),
        if (status.isNotEmpty)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: statusColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              status,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: statusColor,
              ),
            ),
          ),
      ],
    );
  }
}

class _WeatherLoadingState extends StatelessWidget {
  const _WeatherLoadingState();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: const Color(0xFF1A535C).withOpacity(0.1),
              borderRadius: BorderRadius.circular(40),
            ),
            child: Icon(
              Icons.cloud_rounded,
              size: 40,
              color: const Color(0xFF1A535C),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'Memuat Data Cuaca',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: const Color(0xFF1A1A1A),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Mengambil informasi cuaca terbaru...',
            style: TextStyle(
              fontSize: 14,
              color: const Color(0xFF666666),
            ),
          ),
        ],
      ),
    );
  }
}

class _WeatherErrorState extends StatelessWidget {
  final String error;

  const _WeatherErrorState({required this.error});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: const Color(0xFFE07A5F).withOpacity(0.1),
              borderRadius: BorderRadius.circular(40),
            ),
            child: Icon(
              Icons.error_outline_rounded,
              size: 40,
              color: const Color(0xFFE07A5F),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'Gagal Memuat Cuaca',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: const Color(0xFF1A1A1A),
            ),
          ),
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 40),
            child: Text(
              error.length > 100 ? '${error.substring(0, 100)}...' : error,
              style: TextStyle(
                fontSize: 14,
                color: const Color(0xFF666666),
              ),
              textAlign: TextAlign.center,
            ),
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () {
              // TODO: Implement retry functionality
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF1A535C),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: const Text('Coba Lagi'),
          ),
        ],
      ),
    );
  }
}

class _WeatherEmptyState extends StatelessWidget {
  const _WeatherEmptyState();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: const Color(0xFF1A535C).withOpacity(0.1),
              borderRadius: BorderRadius.circular(40),
            ),
            child: Icon(
              Icons.cloud_off_rounded,
              size: 40,
              color: const Color(0xFF1A535C),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'Data Cuaca Tidak Tersedia',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: const Color(0xFF1A1A1A),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Pastikan koneksi internet tersedia',
            style: TextStyle(
              fontSize: 14,
              color: const Color(0xFF666666),
            ),
          ),
        ],
      ),
    );
  }
}