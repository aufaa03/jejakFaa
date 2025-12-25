// Salin ke: lib/features/hike_log/widgets/hike_stats_chart.dart
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';
import 'package:jejak_faa_new/data/local_db/database.dart';
import 'package:jejak_faa_new/features/hike_log/providers/route_points_provider.dart';

// Helper class untuk menampung data yang sudah diproses
class ProcessedChartData {
  final List<FlSpot> elevationSpots;
  final List<FlSpot> speedSpots;
  final double maxElevation;
  final double minElevation;
  final double maxSpeed;
  final double totalDistanceKm;
  final int totalPoints;

  ProcessedChartData({
    required this.elevationSpots,
    required this.speedSpots,
    required this.maxElevation,
    required this.minElevation,
    required this.maxSpeed,
    required this.totalDistanceKm,
    required this.totalPoints,
  });
}

// Provider untuk toggle chart
final _showElevationProvider = StateProvider<bool>((ref) => true);

class HikeStatsChart extends ConsumerWidget {
  final int hikeId;
  const HikeStatsChart({super.key, required this.hikeId});

  // Fungsi untuk memproses data route points menjadi data chart
  ProcessedChartData _processRoutePoints(List<RoutePoint> points) {
    if (points.isEmpty) {
      return ProcessedChartData(
        elevationSpots: [],
        speedSpots: [],
        maxElevation: 0,
        minElevation: 0,
        maxSpeed: 0,
        totalDistanceKm: 0,
        totalPoints: 0,
      );
    }

    final List<FlSpot> elevationSpots = [];
    final List<FlSpot> speedSpots = [];
    double cumulativeDistance = 0.0;
    double maxElevation = points.first.altitude ?? 0;
    double minElevation = points.first.altitude ?? 0;
    double maxSpeed = 0;
    RoutePoint? previousPoint;

    for (int i = 0; i < points.length; i++) {
      final point = points[i];
      
      // Hitung jarak dari titik sebelumnya (jika ada)
      if (previousPoint != null) {
        final distance = Geolocator.distanceBetween(
          previousPoint.latitude,
          previousPoint.longitude,
          point.latitude,
          point.longitude,
        );
        cumulativeDistance += distance;
      }
      
      final distanceKm = cumulativeDistance / 1000.0;
      
      // Process elevation data
      if (point.altitude != null) {
        final elevation = point.altitude!;
        elevationSpots.add(FlSpot(distanceKm, elevation));
        
        if (elevation > maxElevation) maxElevation = elevation;
        if (elevation < minElevation) minElevation = elevation;
      }
      
      // Process speed data
      if (point.speedKmh != null) {
        final speed = point.speedKmh!;
        speedSpots.add(FlSpot(distanceKm, speed));
        if (speed > maxSpeed) maxSpeed = speed;
      }
      
      previousPoint = point;
    }

    return ProcessedChartData(
      elevationSpots: elevationSpots,
      speedSpots: speedSpots,
      maxElevation: maxElevation,
      minElevation: minElevation,
      maxSpeed: maxSpeed,
      totalDistanceKm: cumulativeDistance / 1000.0,
      totalPoints: points.length,
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final routePointsAsync = ref.watch(routePointsProvider(hikeId));
    final showElevation = ref.watch(_showElevationProvider);
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return routePointsAsync.when(
      loading: () => _buildLoadingState(),
      error: (error, stack) => _buildErrorState(error.toString()),
      data: (points) {
        if (points.isEmpty) {
          return _buildEmptyState();
        }

        final chartData = _processRoutePoints(points);
        final currentSpots = showElevation ? chartData.elevationSpots : chartData.speedSpots;
        
        if (currentSpots.length < 2) {
          return _buildInsufficientDataState(showElevation);
        }

        return Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: colors.surface,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: colors.outline.withOpacity(0.2)),
          ),
          child: Column(
            children: [
              // Toggle buttons
              Row(
                children: [
                  Expanded(
                    child: Text(
                      'Statistik Rute',
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  Container(
                    decoration: BoxDecoration(
                      color: colors.surfaceVariant,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: ToggleButtons(
                      isSelected: [showElevation, !showElevation],
                      onPressed: (index) {
                        ref.read(_showElevationProvider.notifier).state = index == 0;
                      },
                      borderRadius: BorderRadius.circular(8),
                      constraints: const BoxConstraints(
                        minHeight: 36,
                        minWidth: 80,
                      ),
                      children: [
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 12),
                          child: Row(
                            children: [
                              Icon(Icons.terrain, size: 16),
                              SizedBox(width: 4),
                              Text('Elevasi'),
                            ],
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 12),
                          child: Row(
                            children: [
                              Icon(Icons.speed, size: 16),
                              SizedBox(width: 4),
                              Text('Kecepatan'),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Stats summary
              _buildStatsSummary(chartData, showElevation, theme),
              const SizedBox(height: 16),

              // Chart
              SizedBox(
                height: 200,
                child: LineChart(
                  LineChartData(
                    minX: 0,
                    maxX: chartData.totalDistanceKm,
                    minY: showElevation ? chartData.minElevation : 0,
                    maxY: showElevation ? chartData.maxElevation * 1.1 : chartData.maxSpeed * 1.1,
                    lineBarsData: [
                      LineChartBarData(
                        spots: currentSpots,
                        isCurved: true,
                        color: showElevation ? Colors.green : Colors.blue,
                        barWidth: 3,
                        isStrokeCapRound: true,
                        dotData: const FlDotData(show: false),
                        belowBarData: BarAreaData(
                          show: true,
                          color: showElevation 
                              ? Colors.green.withOpacity(0.1)
                              : Colors.blue.withOpacity(0.1),
                        ),
                      ),
                    ],
                    lineTouchData: LineTouchData(
                      enabled: true,
                      touchTooltipData: LineTouchTooltipData(
                        getTooltipColor: (touchSpot) => colors.surface,
                        // tooltipBgColor: colors.surface,
                        tooltipBorder: BorderSide(color: colors.outline),
                        getTooltipItems: (touchedSpots) {
                          return touchedSpots.map((touchedSpot) {
                            final yValue = showElevation
                                ? '${touchedSpot.y.toStringAsFixed(0)} m'
                                : '${touchedSpot.y.toStringAsFixed(1)} km/jam';
                            
                            return LineTooltipItem(
                              yValue,
                              TextStyle(
                                color: colors.onSurface,
                                fontWeight: FontWeight.bold,
                              ),
                              children: [
                                TextSpan(
                                  text: '\n${touchedSpot.x.toStringAsFixed(1)} km',
                                  style: TextStyle(
                                    color: colors.onSurface.withOpacity(0.7),
                                    fontSize: 12,
                                  ),
                                ),
                              ],
                            );
                          }).toList();
                        },
                      ),
                    ),
                    gridData: FlGridData(
                      show: true,
                      drawHorizontalLine: true,
                      drawVerticalLine: false,
                      getDrawingHorizontalLine: (value) {
                        return FlLine(
                          color: colors.outline.withOpacity(0.2),
                          strokeWidth: 1,
                        );
                      },
                    ),
                    borderData: FlBorderData(
                      show: true,
                      border: Border.all(
                        color: colors.outline.withOpacity(0.3),
                      ),
                    ),
                    titlesData: FlTitlesData(
                      show: true,
                      leftTitles: AxisTitles(
                        sideTitles: SideTitles(
                          showTitles: true,
                          reservedSize: 40,
                          getTitlesWidget: (value, meta) {
                            return Padding(
                              padding: const EdgeInsets.only(right: 8),
                              child: Text(
                                value.toInt().toString(),
                                style: theme.textTheme.bodySmall?.copyWith(
                                  color: colors.onSurface.withOpacity(0.6),
                                ),
                                textAlign: TextAlign.right,
                              ),
                            );
                          },
                        ),
                      ),
                      bottomTitles: AxisTitles(
                        sideTitles: SideTitles(
                          showTitles: true,
                          reservedSize: 24,
                          getTitlesWidget: (value, meta) {
                            // Format label berdasarkan total distance
                            String label;
                            if (chartData.totalDistanceKm < 1) {
                              label = value.toStringAsFixed(2);
                            } else if (chartData.totalDistanceKm < 10) {
                              label = value.toStringAsFixed(1);
                            } else {
                              label = value.toInt().toString();
                            }

                            if (value > chartData.totalDistanceKm) {
                              return const SizedBox.shrink();
                            }

                            return Text(
                              '$label km',
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: colors.onSurface.withOpacity(0.6),
                              ),
                            );
                          },
                        ),
                      ),
                      topTitles: const AxisTitles(
                        sideTitles: SideTitles(showTitles: false),
                      ),
                      rightTitles: const AxisTitles(
                        sideTitles: SideTitles(showTitles: false),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildStatsSummary(ProcessedChartData data, bool showElevation, ThemeData theme) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        _buildStatItem(
          'Jarak',
          '${data.totalDistanceKm.toStringAsFixed(1)} km',
          Icons.route,
          theme,
        ),
        _buildStatItem(
          'Titik Data',
          '${data.totalPoints}',
          Icons.location_on,
          theme,
        ),
        _buildStatItem(
          showElevation ? 'Max Elevasi' : 'Max Speed',
          showElevation 
              ? '${data.maxElevation.toStringAsFixed(0)} m'
              : '${data.maxSpeed.toStringAsFixed(1)} km/jam',
          showElevation ? Icons.height : Icons.speed,
          theme,
        ),
      ],
    );
  }

  Widget _buildStatItem(String title, String value, IconData icon, ThemeData theme) {
    return Column(
      children: [
        Icon(icon, size: 20, color: theme.colorScheme.primary),
        const SizedBox(height: 4),
        Text(
          value,
          style: theme.textTheme.bodyLarge?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        Text(
          title,
          style: theme.textTheme.bodySmall?.copyWith(
            color: theme.colorScheme.onSurface.withOpacity(0.6),
          ),
        ),
      ],
    );
  }

  Widget _buildLoadingState() {
    return Container(
      height: 300,
      padding: const EdgeInsets.all(16),
      child: const Center(
        child: CircularProgressIndicator(),
      ),
    );
  }

  Widget _buildErrorState(String error) {
    return Container(
      height: 200,
      padding: const EdgeInsets.all(16),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, color: Colors.red, size: 48),
            const SizedBox(height: 16),
            Text(
              'Gagal memuat data grafik',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
            ),
            const SizedBox(height: 8),
            Text(
              error.length > 100 ? '${error.substring(0, 100)}...' : error,
              style: TextStyle(color: Colors.grey[600]),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Container(
      height: 200,
      padding: const EdgeInsets.all(16),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.analytics_outlined, color: Colors.grey[400], size: 48),
            const SizedBox(height: 16),
            Text(
              'Tidak ada data tracking',
              style: TextStyle(fontSize: 16, color: Colors.grey[600]),
            ),
            const SizedBox(height: 8),
            Text(
              'Data grafik akan tersedia setelah melakukan tracking GPS',
              style: TextStyle(color: Colors.grey[500], fontSize: 12),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInsufficientDataState(bool showElevation) {
    return Container(
      height: 200,
      padding: const EdgeInsets.all(16),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.insights_outlined, color: Colors.grey[400], size: 48),
            const SizedBox(height: 16),
            Text(
              'Data ${showElevation ? 'elevasi' : 'kecepatan'} tidak cukup',
              style: TextStyle(fontSize: 16, color: Colors.grey[600]),
            ),
            const SizedBox(height: 8),
            Text(
              'Perlu minimal 2 titik data untuk menampilkan grafik',
              style: TextStyle(color: Colors.grey[500], fontSize: 12),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}