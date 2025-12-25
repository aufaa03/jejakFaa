import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:jejak_faa_new/core/services/gps_service.dart' as gps;
import 'package:jejak_faa_new/data/local_db/database.dart';
import 'package:jejak_faa_new/data/models/sync_status.dart';
import 'package:jejak_faa_new/features/map_view/providers/map_provider.dart';
import 'package:jejak_faa_new/features/map_view/providers/weather_provider.dart';
import 'package:jejak_faa_new/main.dart';
import 'package:latlong2/latlong.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:jejak_faa_new/data/local_db/database_providers.dart';
import 'package:jejak_faa_new/features/auth/providers/auth_provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:drift/drift.dart' as d;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:jejak_faa_new/data/models/location_models.dart';
import 'package:flutter_compass/flutter_compass.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'dart:math';
import 'package:jejak_faa_new/features/map_view/widgets/weather_widget.dart';
import 'package:flutter_map_cache/flutter_map_cache.dart';
import 'package:jejak_faa_new/features/hike_log/providers/route_points_provider.dart';
import 'package:geolocator/geolocator.dart' as geo;
import 'package:intl/intl.dart';

part 'map_page.g.dart';

@riverpod
Stream<double?> compassHeading(CompassHeadingRef ref) {
  return FlutterCompass.events?.map((event) => event.heading) ??
      Stream.value(null);
}

class MapPage extends ConsumerStatefulWidget {
  const MapPage({super.key});

  @override
  ConsumerState<MapPage> createState() => _MapPageState();
}

class _MapPageState extends ConsumerState<MapPage>
    with TickerProviderStateMixin {
  static final _mapController = MapController();
  late AnimationController _animationController;

  // Warna sesuai palet Jejak Faa
  static const Color primaryColor = Color(0xFF1A535C);
  static const Color backgroundColor = Color(0xFFF7F7F2);
  static const Color cardColor = Color(0xFFFFFFFF);
  static const Color accentColor = Color(0xFFE07A5F);
  static const Color textPrimary = Color(0xFF2D3748);
  static const Color textSecondary = Color(0xFF718096);
  static const Color textLight = Color(0xFFA0AEC0);

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkSessionStatus();
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _animatedMapMove(LatLng destLocation) {
    final startLatLng = _mapController.camera.center;
    final startZoom = _mapController.camera.zoom;
    final latTween = Tween<double>(
      begin: startLatLng.latitude,
      end: destLocation.latitude,
    );
    final lngTween = Tween<double>(
      begin: startLatLng.longitude,
      end: destLocation.longitude,
    );
    final zoomTween = Tween<double>(begin: startZoom, end: startZoom);
    final Animation<double> animation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    );
    animation.addListener(() {
      _mapController.move(
        LatLng(latTween.evaluate(animation), lngTween.evaluate(animation)),
        zoomTween.evaluate(animation),
      );
    });
    animation.addStatusListener((status) {
      if (status == AnimationStatus.completed ||
          status == AnimationStatus.dismissed) {}
    });
    _animationController.forward(from: 0.0);
  }

  Future<void> _checkSessionStatus() async {
    if (!mounted) return;
    final notifier = ref.read(mapNotifierProvider.notifier);
    final int? ongoingId = await notifier.pausedHikeId;
    if (ongoingId != null) {
      _showResumeDialog(ref);
      return;
    }
  }

  void _showResumeDialog(WidgetRef ref) {
    if (!mounted) return;
    final notifier = ref.read(mapNotifierProvider.notifier);
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        backgroundColor: cardColor,
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  color: const Color(0xFFFFC107).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(30),
                ),
                child: Icon(
                  Icons.pause_circle_outline_rounded,
                  size: 32,
                  color: const Color(0xFFFFC107),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'Sesi Ditemukan',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  color: textPrimary,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Anda memiliki sesi pendakian yang belum selesai',
                style: TextStyle(
                  fontSize: 14,
                  color: textSecondary,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () async {
                        Navigator.of(ctx).pop();
                        await notifier.discardPausedSession();
                      },
                      style: OutlinedButton.styleFrom(
                        foregroundColor: accentColor,
                        side: BorderSide(color: accentColor),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text('Buang Sesi'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () async {
                        Navigator.of(ctx).pop();
                        final prefs = await SharedPreferences.getInstance();
                        final bool isPaused =
                            prefs.getBool('ongoing_hike_paused') ?? false;
                        if (isPaused) {
                          await notifier.resumeTracking();
                        } else {
                          await notifier.startTracking();
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: primaryColor,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text('Lanjutkan'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(mapNotifierProvider);
    final notifier = ref.read(mapNotifierProvider.notifier);
    final heading = ref.watch(compassHeadingProvider).value ?? 0.0;

    final initialGpsAsync = ref.watch(gps.currentGpsLocationProvider);
    ref.listen<AsyncValue<PositionData?>>(gps.currentGpsLocationProvider, (
      previous,
      next,
    ) {
      final position = next.valueOrNull;
      if (position != null) {
        final weatherState = ref.read(weatherProvider);
        if (!weatherState.isValid) {
          ref
              .read(weatherProvider.notifier)
              .fetchWeather(position.latitude, position.longitude);
        }
      }
    });

    ref.listen<PositionData?>(
      mapNotifierProvider.select((s) => s.lastPosition),
      (PositionData? prev, PositionData? next) {
        if (next != null) {
          final newLocation = LatLng(next.latitude, next.longitude);
          _animatedMapMove(newLocation);
        }
      },
    );

    ref.watch(routePointsProvider(state.currentHikeId ?? 0));

    return Scaffold(
      backgroundColor: backgroundColor,
      body: Stack(
        children: [
          // Map Layer
          initialGpsAsync.when(
            loading: () => Scaffold(
              backgroundColor: backgroundColor,
              body: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      width: 80,
                      height: 80,
                      decoration: BoxDecoration(
                        color: primaryColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(40),
                      ),
                      child: Icon(
                        Icons.gps_fixed_rounded,
                        size: 40,
                        color: primaryColor,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Mencari Sinyal GPS',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: textPrimary,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Menunggu koneksi GPS stabil...',
                      style: TextStyle(
                        fontSize: 14,
                        color: textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            error: (err, stack) => Scaffold(
              backgroundColor: backgroundColor,
              body: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      width: 80,
                      height: 80,
                      decoration: BoxDecoration(
                        color: accentColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(40),
                      ),
                      child: Icon(
                        Icons.location_off_rounded,
                        size: 40,
                        color: accentColor,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'GPS Tidak Tersedia',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: textPrimary,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 40),
                      child: Text(
                        err.toString(),
                        style: TextStyle(
                          fontSize: 14,
                          color: textSecondary,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            data: (initialPosition) {
              if (initialPosition == null) {
                return Center(
                  child: Text(
                    'Gagal mendapatkan lokasi awal GPS.',
                    style: TextStyle(color: textSecondary),
                  ),
                );
              }

              final blueDotCenter = state.lastPosition != null
                  ? LatLng(
                      state.lastPosition!.latitude,
                      state.lastPosition!.longitude,
                    )
                  : LatLng(initialPosition.latitude, initialPosition.longitude);

              return FlutterMap(
                mapController: _mapController,
                options: MapOptions(
                  initialCenter: blueDotCenter,
                  initialZoom: 17.0,
                  onPositionChanged: (position, hasGesture) {},
                ),
                children: [
                  TileLayer(
                    urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                    userAgentPackageName: 'com.example.jejak_faa_new',
                    tileProvider: CachedTileProvider(
                      store: globalCacheStore,
                      maxStale: const Duration(days: 30),
                    ),
                  ),
                  if (state.livePoints.isNotEmpty)
                    PolylineLayer(
                      polylines: [
                        Polyline(
                          points: state.livePoints,
                          color: primaryColor,
                          strokeWidth: 6,
                        ),
                      ],
                    ),
                  Builder(
                    builder: (context) {
                      final List<Marker> allMarkers = [];

                      allMarkers.addAll(
                        state.liveWaypoints.map((waypoint) {
                          return Marker(
                            width: 48,
                            height: 48,
                            point: LatLng(
                              waypoint.latitude,
                              waypoint.longitude,
                            ),
                            child: Tooltip(
                              message: waypoint.name,
                              child: Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: cardColor,
                                  borderRadius: BorderRadius.circular(24),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.2),
                                      blurRadius: 8,
                                      offset: const Offset(0, 4),
                                    ),
                                  ],
                                ),
                                child: Icon(
                                  _getIconForCategory(waypoint.category),
                                  color: primaryColor,
                                  size: 24,
                                ),
                              ),
                            ),
                          );
                        }).toList(),
                      );

                      if (state.livePoints.isNotEmpty) {
                        allMarkers.add(
                          Marker(
                            width: 48,
                            height: 48,
                            point: state.livePoints.first,
                            alignment: Alignment.bottomCenter,
                            child: Tooltip(
                              message: 'Titik Mulai',
                              child: Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: const Color(0xFF4ECDC4),
                                  shape: BoxShape.circle,
                                  boxShadow: [
                                    BoxShadow(
                                      color: const Color(0xFF4ECDC4).withOpacity(0.5),
                                      blurRadius: 8,
                                      spreadRadius: 2,
                                    ),
                                  ],
                                ),
                                child: const Icon(
                                  Icons.flag_rounded,
                                  color: Colors.white,
                                  size: 24,
                                ),
                              ),
                            ),
                          ),
                        );
                      }

                      if (allMarkers.isEmpty) {
                        return const SizedBox.shrink();
                      }
                      return MarkerLayer(markers: allMarkers);
                    },
                  ),
                  MarkerLayer(
                    markers: [
                      Marker(
                        width: 48,
                        height: 48,
                        point: blueDotCenter,
                        child: Container(
                          decoration: BoxDecoration(
                            color: cardColor,
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.2),
                                blurRadius: 8,
                                spreadRadius: 2,
                              ),
                            ],
                          ),
                          child: Transform.rotate(
                            angle: (heading * (pi / 180)),
                            child: Icon(
                              Icons.navigation_rounded,
                              color: primaryColor,
                              size: 24,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              );
            },
          ),

          // UI Layers
          if (state.isPickingWaypoint)
            Center(
              child: IgnorePointer(
                child: Padding(
                  padding: const EdgeInsets.only(bottom: 50.0),
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: cardColor,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.2),
                          blurRadius: 12,
                          spreadRadius: 4,
                        ),
                      ],
                    ),
                    child: Icon(
                      Icons.location_pin,
                      size: 36,
                      color: accentColor,
                    ),
                  ),
                ),
              ),
            ),

          if (state.isPickingWaypoint)
            _buildPickingUI(context, ref, notifier)
          else
            _buildTrackingUI(context, ref, state, notifier),

          if (!state.isPickingWaypoint) const WeatherWidget(),
        ],
      ),
    );
  }

  Widget _buildPickingUI(
    BuildContext context,
    WidgetRef ref,
    MapNotifier notifier,
  ) {
    return Positioned.fill(
      child: Stack(
        children: [
          Positioned(
            top: 60,
            left: 16,
            child: Container(
              decoration: BoxDecoration(
                color: cardColor,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: IconButton(
                icon: Icon(Icons.close_rounded, color: primaryColor),
                onPressed: () {
                  notifier.exitWaypointPickMode();
                },
              ),
            ),
          ),
          Positioned(
            bottom: 30,
            left: 16,
            right: 16,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: cardColor,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 12,
                        offset: const Offset(0, 6),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.info_outline_rounded,
                        color: primaryColor,
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Geser peta untuk memposisikan pin',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                            color: textPrimary,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: () {
                      final LatLng pickedLocation = _mapController.camera.center;
                      _showAddWaypointDialog(
                        context,
                        ref,
                        notifier,
                        tappedLatLng: pickedLocation,
                      );
                      notifier.exitWaypointPickMode();
                    },
                    icon: const Icon(Icons.check_rounded, size: 20),
                    label: const Text('Tandai di Sini'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: primaryColor,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTrackingUI(
    BuildContext context,
    WidgetRef ref,
    MapTrackingState state,
    MapNotifier notifier,
  ) {
    return Positioned.fill(
      child: Stack(
        children: [
          // Stats Dashboard
          if (state.isTracking)
            Positioned(
              top: 60,
              left: 16,
              right: 16,
              child: _buildLiveStatsDashboard(context, state),
            ),

          // Control Buttons
          Positioned(
            bottom: 30,
            left: 16,
            right: 16,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (state.isTracking)
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      _buildControlButton(
                        icon: Icons.location_pin,
                        label: 'POI',
                        color: primaryColor,
                        onPressed: state.isPaused
                            ? null
                            : () {
                                _showWaypointSourceDialog(
                                  context,
                                  ref,
                                  notifier,
                                );
                              },
                        isDisabled: state.isPaused,
                      ),
                      _buildControlButton(
                        icon: state.isPaused ? Icons.play_arrow : Icons.pause,
                        label: state.isPaused ? 'Lanjut' : 'Jeda',
                        color: state.isPaused
                            ? const Color(0xFF4ECDC4)
                            : const Color(0xFFFFC107),
                        onPressed: () {
                          if (state.isPaused) {
                            notifier.resumeTracking();
                          } else {
                            notifier.pauseTracking();
                          }
                        },
                      ),
                      _buildControlButton(
                        icon: Icons.stop,
                        label: 'Selesai',
                        color: accentColor,
                        onPressed: () async {
                          try {
                            final Hike? finishedHike = await notifier
                                .stopTrackingAndGetHike();
                            if (finishedHike != null && context.mounted) {
                              context.go(
                                '/home/edit_hike',
                                extra: finishedHike,
                              );
                            }
                          } catch (e) {
                            if (context.mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text('Error: $e'),
                                  backgroundColor: accentColor,
                                  behavior: SnackBarBehavior.floating,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12)),
                                ),
                              );
                            }
                          }
                        },
                      ),
                    ],
                  )
                else if (!state.isTracking && !state.isPickingWaypoint)
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: () async {
                        try {
                          await notifier.startTracking();
                        } catch (e, st) {
                          if (context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text('Error: $e'),
                                backgroundColor: accentColor,
                                behavior: SnackBarBehavior.floating,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12)),
                              ),
                            );
                          }
                        }
                      },
                      icon: const Icon(Icons.play_arrow_rounded, size: 20),
                      label: const Text('Mulai Tracking'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: primaryColor,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 18),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildControlButton({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback? onPressed,
    bool isDisabled = false,
  }) {
    return Column(
      children: [
        Container(
          width: 56,
          height: 56,
          decoration: BoxDecoration(
            color: isDisabled ? textLight : color,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 8,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: IconButton(
            icon: Icon(icon, color: Colors.white),
            onPressed: isDisabled ? null : onPressed,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w500,
            color: textSecondary,
          ),
        ),
      ],
    );
  }

  Widget _buildLiveStatsDashboard(
    BuildContext context,
    MapTrackingState state,
  ) {
    final duration = state.liveDuration;
    final hours = duration.inHours.toString().padLeft(2, '0');
    final minutes = (duration.inMinutes % 60).toString().padLeft(2, '0');
    final seconds = (duration.inSeconds % 60).toString().padLeft(2, '0');

    final String altitude =
        state.lastPosition?.altitude.toStringAsFixed(0) ?? '--';
    final double distanceKm = state.liveDistanceMeters / 1000.0;
    final double pace = state.livePaceMinPerKm;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildStatItem(
            value: distanceKm.toStringAsFixed(2),
            label: 'KM',
            icon: Icons.terrain_rounded,
            color: primaryColor,
          ),
          _buildStatItem(
            value: '$hours:$minutes:$seconds',
            label: 'WAKTU',
            icon: Icons.timer_rounded,
            color: const Color(0xFF4ECDC4),
          ),
          _buildStatItem(
            value: _formatPace(pace),
            label: 'PACE',
            icon: Icons.speed_rounded,
            color: const Color(0xFFFFC107),
          ),
          _buildStatItem(
            value: altitude,
            label: 'MDPL',
            icon: Icons.height_rounded,
            color: accentColor,
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem({
    required String value,
    required String label,
    required IconData icon,
    required Color color,
  }) {
    return Column(
      children: [
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, color: color, size: 20),
        ),
        const SizedBox(height: 8),
        Text(
          value,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w700,
            color: textPrimary,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: TextStyle(
            fontSize: 10,
            fontWeight: FontWeight.w500,
            color: textSecondary,
          ),
        ),
      ],
    );
  }

  String _formatPace(double decimalPace) {
    if (decimalPace <= 0.0) return '--:--';
    final int minutes = decimalPace.floor();
    final double fractionalPart = decimalPace - minutes;
    final int seconds = (fractionalPart * 60).round();
    return '$minutes:${seconds.toString().padLeft(2, '0')}';
  }

  void _showWaypointSourceDialog(
    BuildContext context,
    WidgetRef ref,
    MapNotifier notifier,
  ) {
    showModalBottomSheet(
      context: context,
      backgroundColor: cardColor,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Handle bar
                Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: textLight.withOpacity(0.3),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const SizedBox(height: 16),
                
                Text(
                  'Tambah Waypoint',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: textPrimary,
                  ),
                ),
                const SizedBox(height: 20),
                
                _buildWaypointOption(
                  icon: Icons.my_location,
                  title: 'Lokasi Saat Ini',
                  subtitle: 'Tandai posisi Anda sekarang',
                  onTap: () {
                    Navigator.of(ctx).pop();
                    _showAddWaypointDialog(
                      context,
                      ref,
                      notifier,
                      tappedLatLng: null,
                    );
                  },
                ),
                
                _buildWaypointOption(
                  icon: Icons.push_pin,
                  title: 'Pilih dari Peta',
                  subtitle: 'Tandai titik di peta secara manual',
                  onTap: () {
                    Navigator.of(ctx).pop();
                    notifier.enterWaypointPickMode();
                  },
                ),
                
                const SizedBox(height: 8),
                
                // Cancel button
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton(
                    onPressed: () => Navigator.of(ctx).pop(),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: textSecondary,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      side: BorderSide(color: textLight.withOpacity(0.3)),
                    ),
                    child: const Text('Batal'),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildWaypointOption({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: Container(
        width: 48,
        height: 48,
        decoration: BoxDecoration(
          color: primaryColor.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Icon(icon, color: primaryColor, size: 24),
      ),
      title: Text(
        title,
        style: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w600,
          color: textPrimary,
        ),
      ),
      subtitle: Text(
        subtitle,
        style: TextStyle(
          fontSize: 14,
          color: textSecondary,
        ),
      ),
      trailing: Icon(
        Icons.chevron_right_rounded,
        color: textLight,
        size: 20,
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 8),
      onTap: onTap,
    );
  }

  void _showAddWaypointDialog(
    BuildContext context,
    WidgetRef ref,
    MapNotifier notifier, {
    required LatLng? tappedLatLng,
  }) {
    final nameController = TextEditingController();
    final descController = TextEditingController();
    String? selectedCategory;
    final categories = {
      'POS': 'Pos Pendakian',
      'SUMBER_AIR': 'Sumber Air',
      'PUNCAK': 'Puncak',
      'CAMP': 'Area Camp',
      'LAINNYA': 'Lainnya',
    };
    XFile? _tempImageFile;
    bool _isUploading = false;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (dialogContext, setDialogState) {
            Future<void> _pickImage() async {
              final imagePicker = ImagePicker();
              final ImageSource? source = await showModalBottomSheet<ImageSource>(
                context: context,
                backgroundColor: cardColor,
                shape: const RoundedRectangleBorder(
                  borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
                ),
                builder: (bottomSheetCtx) {
                  return SafeArea(
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          // Handle bar
                          Container(
                            width: 40,
                            height: 4,
                            decoration: BoxDecoration(
                              color: textLight.withOpacity(0.3),
                              borderRadius: BorderRadius.circular(2),
                            ),
                          ),
                          const SizedBox(height: 16),
                          
                          Text(
                            'Pilih Sumber Foto',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w700,
                              color: textPrimary,
                            ),
                          ),
                          const SizedBox(height: 20),
                          
                          _buildImageSourceOption(
                            icon: Icons.camera_alt_rounded,
                            title: 'Ambil Foto',
                            subtitle: 'Gunakan kamera',
                            onTap: () => Navigator.of(bottomSheetCtx).pop(ImageSource.camera),
                          ),
                          
                          _buildImageSourceOption(
                            icon: Icons.photo_library_rounded,
                            title: 'Pilih dari Galeri',
                            subtitle: 'Pilih foto yang sudah ada',
                            onTap: () => Navigator.of(bottomSheetCtx).pop(ImageSource.gallery),
                          ),
                          
                          const SizedBox(height: 8),
                          
                          // Cancel button
                          SizedBox(
                            width: double.infinity,
                            child: OutlinedButton(
                              onPressed: () => Navigator.of(bottomSheetCtx).pop(),
                              style: OutlinedButton.styleFrom(
                                foregroundColor: textSecondary,
                                padding: const EdgeInsets.symmetric(vertical: 14),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                side: BorderSide(color: textLight.withOpacity(0.3)),
                              ),
                              child: const Text('Batal'),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              );
              if (source == null) return;
              try {
                final XFile? imageFile = await imagePicker.pickImage(
                  source: source,
                  imageQuality: 85,
                );
                if (imageFile == null) return;
                setDialogState(() {
                  _tempImageFile = imageFile;
                });
              } catch (e) {
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Gagal mengambil gambar: $e'),
                      backgroundColor: accentColor,
                      behavior: SnackBarBehavior.floating,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                  );
                }
              }
            }

            Future<String> _uploadToStorage(
              XFile imageFile,
              String userId,
              int localHikeId,
            ) async {
              final supabase = Supabase.instance.client;
              final file = File(imageFile.path);
              final fileExtension = imageFile.path.split('.').last.toLowerCase();
              final fileName = '${DateTime.now().millisecondsSinceEpoch}.$fileExtension';
              final path = '$userId/$localHikeId/$fileName';
              await supabase.storage.from('hike_photos').upload(path, file);
              final publicUrl = supabase.storage
                  .from('hike_photos')
                  .getPublicUrl(path);
              return publicUrl;
            }

            return Dialog(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
              backgroundColor: cardColor,
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      tappedLatLng == null ? 'Tandai Lokasi' : 'Tandai Peta',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                        color: textPrimary,
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: nameController,
                      autofocus: true,
                      decoration: InputDecoration(
                        hintText: 'Contoh: Pos 1, Sumber Air',
                        labelText: 'Nama Lokasi',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      readOnly: _isUploading,
                    ),
                    const SizedBox(height: 16),
                    DropdownButtonFormField<String>(
                      value: selectedCategory,
                      isExpanded: true,
                      decoration: InputDecoration(
                        labelText: 'Kategori',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      hint: const Text('Pilih Kategori'),
                      items: categories.entries.map((entry) {
                        return DropdownMenuItem(
                          value: entry.key,
                          child: Text(entry.value),
                        );
                      }).toList(),
                      onChanged: _isUploading
                          ? null
                          : (value) {
                              setDialogState(() {
                                selectedCategory = value;
                              });
                            },
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: descController,
                      maxLines: 2,
                      decoration: InputDecoration(
                        hintText: 'Opsional',
                        labelText: 'Deskripsi',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      readOnly: _isUploading,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Foto (Opsional)',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: textSecondary,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      width: double.infinity,
                      height: 120,
                      decoration: BoxDecoration(
                        border: Border.all(color: textLight.withOpacity(0.3)),
                        borderRadius: BorderRadius.circular(12),
                        color: _isUploading
                            ? backgroundColor
                            : cardColor,
                      ),
                      child: _tempImageFile == null
                          ? InkWell(
                              onTap: _isUploading ? null : _pickImage,
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.add_photo_alternate_outlined,
                                    color: textLight,
                                    size: 32,
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    'Tambah Foto',
                                    style: TextStyle(color: textLight),
                                  ),
                                ],
                              ),
                            )
                          : Stack(
                              fit: StackFit.expand,
                              children: [
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(12),
                                  child: Image.file(
                                    File(_tempImageFile!.path),
                                    fit: BoxFit.cover,
                                  ),
                                ),
                                Positioned(
                                  top: 8,
                                  right: 8,
                                  child: InkWell(
                                    onTap: _isUploading
                                        ? null
                                        : () => setDialogState(() => _tempImageFile = null),
                                    child: Container(
                                      padding: const EdgeInsets.all(4),
                                      decoration: BoxDecoration(
                                        color: Colors.black.withOpacity(0.6),
                                        shape: BoxShape.circle,
                                      ),
                                      child: const Icon(
                                        Icons.close_rounded,
                                        color: Colors.white,
                                        size: 16,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                    ),
                    const SizedBox(height: 24),
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton(
                            onPressed: _isUploading
                                ? null
                                : () {
                                    Navigator.of(ctx).pop();
                                  },
                            style: OutlinedButton.styleFrom(
                              foregroundColor: primaryColor,
                              side: BorderSide(color: primaryColor),
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            child: const Text('Batal'),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: ElevatedButton(
                            onPressed: _isUploading
                                ? null
                                : () async {
                                    if (nameController.text.trim().isEmpty) {
                                      ScaffoldMessenger.of(dialogContext).showSnackBar(
                                        SnackBar(
                                          content: const Text('Nama Lokasi wajib diisi'),
                                          backgroundColor: const Color(0xFFFFC107),
                                          behavior: SnackBarBehavior.floating,
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(12)),
                                        ),
                                      );
                                      return;
                                    }
                                    setDialogState(() => _isUploading = true);
                                    try {
                                      final hikeId = ref
                                          .read(mapNotifierProvider)
                                          .currentHikeId;
                                      if (hikeId == null)
                                        throw Exception("Hike ID tidak ditemukan");

                                      final HikeWaypoint? newWaypoint = await notifier
                                          .addWaypoint(
                                            nameController.text.trim(),
                                            descController.text.trim().isEmpty
                                                ? null
                                                : descController.text.trim(),
                                            selectedCategory,
                                            tappedLatLng,
                                          );
                                      if (newWaypoint == null)
                                        throw Exception("Gagal menyimpan waypoint");

                                      if (_tempImageFile != null) {
                                        final userId = ref
                                            .read(authStateProvider)
                                            .value!
                                            .id;
                                        final photoDao = ref.read(hikePhotoDaoProvider);
                                        final photoUrl = await _uploadToStorage(
                                          _tempImageFile!,
                                          userId,
                                          hikeId,
                                        );
                                        final photoEntry = HikePhotosCompanion(
                                          hikeId: d.Value(hikeId),
                                          waypointId: d.Value(newWaypoint.id),
                                          photoUrl: d.Value(photoUrl),
                                          syncStatus: const d.Value(SyncStatus.pending),
                                        );
                                        await photoDao.insertHikePhoto(photoEntry);
                                      }
                                      if (ctx.mounted) {
                                        Navigator.of(ctx).pop();
                                        if (context.mounted) {
                                          ScaffoldMessenger.of(context).showSnackBar(
                                            SnackBar(
                                              content: Text(
                                                'POI "${nameController.text}" disimpan',
                                              ),
                                              backgroundColor: primaryColor,
                                              behavior: SnackBarBehavior.floating,
                                              shape: RoundedRectangleBorder(
                                                borderRadius: BorderRadius.circular(12)),
                                            ),
                                          );
                                        }
                                      }
                                    } catch (e) {
                                      setDialogState(() => _isUploading = false);
                                      if (dialogContext.mounted) {
                                        ScaffoldMessenger.of(dialogContext).showSnackBar(
                                          SnackBar(
                                            content: Text('Error: $e'),
                                            backgroundColor: accentColor,
                                            behavior: SnackBarBehavior.floating,
                                            shape: RoundedRectangleBorder(
                                              borderRadius: BorderRadius.circular(12)),
                                          ),
                                        );
                                      }
                                    }
                                  },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: primaryColor,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            child: _isUploading
                                ? SizedBox(
                                    width: 20,
                                    height: 20,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      color: Colors.white,
                                    ),
                                  )
                                : const Text('Simpan'),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildImageSourceOption({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: Container(
        width: 48,
        height: 48,
        decoration: BoxDecoration(
          color: primaryColor.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Icon(icon, color: primaryColor, size: 24),
      ),
      title: Text(
        title,
        style: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w600,
          color: textPrimary,
        ),
      ),
      subtitle: Text(
        subtitle,
        style: TextStyle(
          fontSize: 14,
          color: textSecondary,
        ),
      ),
      trailing: Icon(
        Icons.chevron_right_rounded,
        color: textLight,
        size: 20,
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 8),
      onTap: onTap,
    );
  }

  static IconData _getIconForCategory(String? category) {
    switch (category) {
      case 'POS':
        return Icons.signpost_outlined;
      case 'SUMBER_AIR':
        return Icons.water_drop_outlined;
      case 'PUNCAK':
        return Icons.flag_outlined;
      case 'CAMP':
        return Icons.local_fire_department_outlined;
      default:
        return Icons.location_pin;
    }
  }
}