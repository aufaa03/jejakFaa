import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:jejak_faa_new/features/hike_log/providers/hike_provider.dart';
import 'package:jejak_faa_new/features/hike_log/widgets/hike_card.dart';
import 'package:jejak_faa_new/data/local_db/database.dart';

// Provider untuk state search dan filter
final searchQueryProvider = StateProvider<String>((ref) => '');
final sortByProvider = StateProvider<SortOption>((ref) => SortOption.dateDesc);

enum SortOption {
  dateDesc,
  dateAsc,
  nameAsc,
  nameDesc,
  distanceDesc,
  distanceAsc,
}

class HikeListPage extends ConsumerStatefulWidget {
  const HikeListPage({super.key});

  @override
  ConsumerState<HikeListPage> createState() => _HikeListPageState();
}

class _HikeListPageState extends ConsumerState<HikeListPage> {
  final TextEditingController _searchController = TextEditingController();
  bool _isSearching = false;

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
    _searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchChanged() {
    ref.read(searchQueryProvider.notifier).state = _searchController.text;
  }

  void _toggleSearch() {
    setState(() {
      _isSearching = !_isSearching;
      if (!_isSearching) {
        _searchController.clear();
      }
    });
  }

  // Method untuk filter dan sort data
  List<Hike> _filterAndSortHikes(List<Hike> hikes, String searchQuery, SortOption sortBy) {
    // Filter berdasarkan search query
    List<Hike> filteredHikes = hikes.where((hike) {
      final query = searchQuery.toLowerCase();
      return hike.mountainName.toLowerCase().contains(query) ||
          (hike.notes?.toLowerCase().contains(query) ?? false) ||
          (hike.partners?.toLowerCase().contains(query) ?? false);
    }).toList();

    // Sort berdasarkan pilihan
    switch (sortBy) {
      case SortOption.dateDesc:
        filteredHikes.sort((a, b) => b.hikeDate.compareTo(a.hikeDate));
        break;
      case SortOption.dateAsc:
        filteredHikes.sort((a, b) => a.hikeDate.compareTo(b.hikeDate));
        break;
      case SortOption.nameAsc:
        filteredHikes.sort((a, b) => a.mountainName.compareTo(b.mountainName));
        break;
      case SortOption.nameDesc:
        filteredHikes.sort((a, b) => b.mountainName.compareTo(a.mountainName));
        break;
      case SortOption.distanceDesc:
        filteredHikes.sort((a, b) => (b.totalDistanceKm ?? 0).compareTo(a.totalDistanceKm ?? 0));
        break;
      case SortOption.distanceAsc:
        filteredHikes.sort((a, b) => (a.totalDistanceKm ?? 0).compareTo(b.totalDistanceKm ?? 0));
        break;
    }

    return filteredHikes;
  }

  void _showSortDialog() {
    final currentSort = ref.read(sortByProvider);

    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      backgroundColor: cardColor,
      builder: (context) {
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
                const SizedBox(height: 20),
                
                // Title
                Text(
                  'Urutkan Berdasarkan',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: textPrimary,
                  ),
                ),
                const SizedBox(height: 20),
                
                // Sort options
                ...SortOption.values.map((option) {
                  return _buildSortOption(
                    option: option,
                    isSelected: currentSort == option,
                    onTap: () {
                      ref.read(sortByProvider.notifier).state = option;
                      Navigator.pop(context);
                    },
                  );
                }).toList(),
                
                const SizedBox(height: 16),
                
                // Cancel button
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton(
                    onPressed: () => Navigator.pop(context),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: textSecondary,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      side: BorderSide(color: textLight.withOpacity(0.3)),
                    ),
                    child: const Text('Tutup'),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildSortOption({
    required SortOption option,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: isSelected ? primaryColor.withOpacity(0.1) : Colors.transparent,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(
          _getSortIcon(option),
          color: isSelected ? primaryColor : textSecondary,
          size: 20,
        ),
      ),
      title: Text(
        _getSortLabel(option),
        style: TextStyle(
          fontSize: 16,
          fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
          color: isSelected ? primaryColor : textPrimary,
        ),
      ),
      trailing: isSelected
          ? Icon(
              Icons.check_rounded,
              color: primaryColor,
              size: 20,
            )
          : null,
      contentPadding: const EdgeInsets.symmetric(horizontal: 8),
      onTap: onTap,
    );
  }

  IconData _getSortIcon(SortOption option) {
    switch (option) {
      case SortOption.dateDesc:
        return Icons.date_range_rounded;
      case SortOption.dateAsc:
        return Icons.date_range_outlined;
      case SortOption.nameAsc:
        return Icons.sort_by_alpha_rounded;
      case SortOption.nameDesc:
        return Icons.sort_by_alpha_outlined;
      case SortOption.distanceDesc:
        return Icons.arrow_downward_rounded;
      case SortOption.distanceAsc:
        return Icons.arrow_upward_rounded;
    }
  }

  String _getSortLabel(SortOption option) {
    switch (option) {
      case SortOption.dateDesc:
        return 'Tanggal Terbaru';
      case SortOption.dateAsc:
        return 'Tanggal Terlama';
      case SortOption.nameAsc:
        return 'Nama A-Z';
      case SortOption.nameDesc:
        return 'Nama Z-A';
      case SortOption.distanceDesc:
        return 'Jarak Terjauh';
      case SortOption.distanceAsc:
        return 'Jarak Terdekat';
    }
  }

  @override
  Widget build(BuildContext context) {
    final hikeListAsync = ref.watch(hikeListStreamProvider);
    final searchQuery = ref.watch(searchQueryProvider);
    final sortBy = ref.watch(sortByProvider);

    return Scaffold(
      backgroundColor: backgroundColor,
      body: hikeListAsync.when(
        data: (hikes) {
          final filteredHikes = _filterAndSortHikes(hikes, searchQuery, sortBy);

          if (filteredHikes.isEmpty) {
            return _buildEmptyState(searchQuery.isNotEmpty);
          }

          return CustomScrollView(
            slivers: [
              // Header dengan search dan filter
              SliverAppBar(
                backgroundColor: backgroundColor,
                elevation: 0,
                pinned: true,
                title: _isSearching
                    ? TextField(
                        controller: _searchController,
                        autofocus: true,
                        decoration: InputDecoration(
                          hintText: 'Cari nama gunung, catatan, teman...',
                          hintStyle: TextStyle(
                            color: textLight,
                            fontSize: 16,
                          ),
                          border: InputBorder.none,
                          isDense: true,
                        ),
                        style: TextStyle(
                          fontSize: 16,
                          color: textPrimary,
                        ),
                      )
                    : Text(
                        'Semua Jejak',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.w700,
                          color: textPrimary,
                          letterSpacing: -0.5,
                        ),
                      ),
                actions: [
                  if (_isSearching)
                    IconButton(
                      icon: Icon(
                        Icons.close_rounded,
                        color: primaryColor,
                        size: 24,
                      ),
                      onPressed: _toggleSearch,
                    )
                  else
                    IconButton(
                      icon: Icon(
                        Icons.search_rounded,
                        color: primaryColor,
                        size: 24,
                      ),
                      onPressed: _toggleSearch,
                    ),
                  IconButton(
                    icon: Icon(
                      Icons.filter_list_rounded,
                      color: primaryColor,
                      size: 24,
                    ),
                    onPressed: _showSortDialog,
                  ),
                ],
              ),

              // Search info jika sedang mencari
              if (searchQuery.isNotEmpty)
                SliverToBoxAdapter(
                  child: Container(
                    margin: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: primaryColor.withOpacity(0.05),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: primaryColor.withOpacity(0.1),
                        width: 1,
                      ),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.search_rounded,
                          size: 16,
                          color: primaryColor,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            'Hasil untuk "$searchQuery"',
                            style: TextStyle(
                              fontSize: 14,
                              color: textPrimary,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: primaryColor,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            '${filteredHikes.length}',
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

              // Stats summary
              SliverToBoxAdapter(
                child: _buildStatsSummary(filteredHikes),
              ),

              // List of hikes
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(24, 8, 24, 24),
                sliver: SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      final hike = filteredHikes[index];
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 16),
                        child: HikeCard(hike: hike),
                      );
                    },
                    childCount: filteredHikes.length,
                  ),
                ),
              ),
            ],
          );
        },
        error: (error, stackTrace) {
          return _buildErrorState(error.toString(), ref);
        },
        loading: () {
          return _buildLoadingState();
        },
      ),
    );
  }

  Widget _buildStatsSummary(List<Hike> hikes) {
    final totalHikes = hikes.length;
    final totalDistance = hikes.fold(0.0, (sum, hike) => sum + (hike.totalDistanceKm ?? 0));
    final totalElevation = hikes.fold(0.0, (sum, hike) => sum + (hike.totalElevationGainMeters ?? 0));
    final totalDuration = hikes.fold(0, (sum, hike) => sum + (hike.durationSeconds ?? 0));
    final totalHours = (totalDuration / 3600).ceil();

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildStatItem(
            value: totalHikes.toString(),
            label: 'Jejak',
            icon: Icons.flag_outlined,
            color: primaryColor,
          ),
          _buildStatItem(
            value: totalDistance.toStringAsFixed(1),
            label: 'Km',
            icon: Icons.terrain_outlined,
            color: const Color(0xFF4ECDC4),
          ),
          _buildStatItem(
            value: totalElevation.toStringAsFixed(0),
            label: 'm DPL',
            icon: Icons.arrow_upward_outlined,
            color: const Color(0xFFFFC107),
          ),
          _buildStatItem(
            value: totalHours.toString(),
            label: 'Jam',
            icon: Icons.timer_outlined,
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
          width: 44,
          height: 44,
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
            fontSize: 16,
            fontWeight: FontWeight.w700,
            color: textPrimary,
          ),
        ),
        const SizedBox(height: 2),
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

  Widget _buildEmptyState(bool isSearching) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                color: primaryColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(60),
              ),
              child: Icon(
                isSearching ? Icons.search_off_rounded : Icons.terrain_outlined,
                size: 60,
                color: primaryColor,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              isSearching ? 'Tidak Ditemukan' : 'Belum Ada Jejak',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.w700,
                color: textPrimary,
              ),
            ),
            const SizedBox(height: 12),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 40),
              child: Text(
                isSearching 
                    ? 'Tidak ada jejak yang sesuai dengan pencarian Anda'
                    : 'Mulai petualangan pertama Anda dan catat setiap jejak perjalanan',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w400,
                  color: textSecondary,
                  height: 1.5,
                ),
                textAlign: TextAlign.center,
              ),
            ),
            if (!isSearching) ...[
              const SizedBox(height: 24),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                  color: primaryColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: primaryColor.withOpacity(0.2),
                    width: 1,
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.add_rounded,
                      size: 16,
                      color: primaryColor,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Tekan + di bawah untuk menambah jejak',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: primaryColor,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildErrorState(String error, WidgetRef ref) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
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
                Icons.error_outline_rounded,
                size: 40,
                color: accentColor,
              ),
            ),
            const SizedBox(height: 20),
            Text(
              'Gagal Memuat Data',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w600,
                color: textPrimary,
              ),
            ),
            const SizedBox(height: 12),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 40),
              child: Text(
                error.length > 100 ? '${error.substring(0, 100)}...' : error,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w400,
                  color: textSecondary,
                  height: 1.4,
                ),
                textAlign: TextAlign.center,
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () {
                ref.invalidate(hikeListStreamProvider);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: primaryColor,
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
      ),
    );
  }

  Widget _buildLoadingState() {
    return CustomScrollView(
      slivers: [
        SliverAppBar(
          backgroundColor: backgroundColor,
          elevation: 0,
          pinned: true,
          title: Container(
            width: 120,
            height: 24,
            decoration: BoxDecoration(
              color: const Color(0xFFE0E0E0),
              borderRadius: BorderRadius.circular(8),
            ),
          ),
          actions: [
            Container(
              width: 40,
              height: 40,
              margin: const EdgeInsets.only(right: 8),
              decoration: BoxDecoration(
                color: const Color(0xFFE0E0E0),
                borderRadius: BorderRadius.circular(20),
              ),
            ),
            Container(
              width: 40,
              height: 40,
              margin: const EdgeInsets.only(right: 16),
              decoration: BoxDecoration(
                color: const Color(0xFFE0E0E0),
                borderRadius: BorderRadius.circular(20),
              ),
            ),
          ],
        ),
        SliverToBoxAdapter(
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: cardColor,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: List.generate(4, (index) => _buildStatSkeleton()),
            ),
          ),
        ),
        SliverPadding(
          padding: const EdgeInsets.fromLTRB(24, 8, 24, 24),
          sliver: SliverList(
            delegate: SliverChildBuilderDelegate(
              (context, index) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: 16),
                  child: _buildHikeCardSkeleton(),
                );
              },
              childCount: 6,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildStatSkeleton() {
    return Column(
      children: [
        Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            color: const Color(0xFFF0F0F0),
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        const SizedBox(height: 8),
        Container(
          width: 30,
          height: 16,
          decoration: BoxDecoration(
            color: const Color(0xFFF0F0F0),
            borderRadius: BorderRadius.circular(4),
          ),
        ),
        const SizedBox(height: 4),
        Container(
          width: 40,
          height: 12,
          decoration: BoxDecoration(
            color: const Color(0xFFF0F0F0),
            borderRadius: BorderRadius.circular(4),
          ),
        ),
      ],
    );
  }

  Widget _buildHikeCardSkeleton() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: const Color(0xFFF0F0F0),
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 120,
                  height: 18,
                  decoration: BoxDecoration(
                    color: const Color(0xFFF0F0F0),
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
                const SizedBox(height: 8),
                Container(
                  width: 80,
                  height: 14,
                  decoration: BoxDecoration(
                    color: const Color(0xFFF0F0F0),
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
                const SizedBox(height: 8),
                Container(
                  width: 150,
                  height: 12,
                  decoration: BoxDecoration(
                    color: const Color(0xFFF0F0F0),
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}