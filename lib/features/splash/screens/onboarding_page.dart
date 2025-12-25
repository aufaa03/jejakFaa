import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:liquid_swipe/liquid_swipe.dart';
import 'package:lottie/lottie.dart';
import 'package:shared_preferences/shared_preferences.dart';

// Key untuk menandai bahwa onboarding sudah selesai
const String kOnboardingCompleteKey = 'onboardingComplete';

// Warna sesuai palet Jejak Faa yang konsisten
class JejakFaaColors {
  static const Color primary = Color(0xFF1A535C); // Hijau Hutan Dalam
  static const Color backgroundColor = Color(0xFFF7F7F2); // Krem Pucat
  static const Color cardColor = Color(0xFFFFFFFF); // Putih bersih
  static const Color accentColor = Color(0xFFE07A5F); // Oranye Terakota
  static const Color textPrimary = Color(0xFF2D3748);
  static const Color textSecondary = Color(0xFF718096);
  static const Color textLight = Color(0xFFA0AEC0);
}

class OnboardingPage extends StatefulWidget {
  const OnboardingPage({super.key});

  @override
  State<OnboardingPage> createState() => _OnboardingPageState();
}

class _OnboardingPageState extends State<OnboardingPage> {
  late final LiquidController _liquidController;
  int _currentPage = 0;

  @override
  void initState() {
    super.initState();
    _liquidController = LiquidController();
  }
  
  // Fungsi untuk menandai onboarding selesai dan pindah halaman
  Future<void> _completeOnboarding() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(kOnboardingCompleteKey, true);
    
    if (mounted) {
      context.go('/home');
    }
  }

  @override
  Widget build(BuildContext context) {
    final Size size = MediaQuery.of(context).size;
    
    // Definisikan 3 halaman onboarding
    final pages = [
      // --- Halaman 1: Filosofi ---
      _buildOnboardingPage(
        lottieAsset: 'assets/lottie/tracking_people.json', // Ganti dengan Lottie hiking
        title: 'Jejak Anda, Data Anda',
        description: 'Setiap pendakian adalah cerita unik. Simpan dan analisis setiap langkah perjalanan Anda dengan detail yang kaya.',
        subtitle: 'Filosofi Kami',
        icon: Icons.flag_outlined,
        pageNumber: 1,
        totalPages: 3,
      ),
      
      // --- Halaman 2: Fitur Tracking ---
      _buildOnboardingPage(
        lottieAsset: 'assets/lottie/tracking.json', // Ganti dengan Lottie GPS
        title: 'Pelacakan Real-time Presisi',
        description: 'Rekam elevasi, kecepatan, dan rute dengan akurasi tinggi. Bekerja optimal bahkan di area terpencil.',
        subtitle: 'Teknologi Canggih',
        icon: Icons.travel_explore_outlined,
        pageNumber: 2,
        totalPages: 3,
      ),

      // --- Halaman 3: Visualisasi Data ---
      _buildOnboardingPage(
        lottieAsset: 'assets/lottie/chart.json', // Ganti dengan Lottie data
        title: 'Visualisasi Data Mendalam',
        description: 'Lihat grafik elevasi, statistik detail, dan peta interaktif. Pahami setiap aspek petualangan Anda.',
        subtitle: 'Analisis Komprehensif',
        icon: Icons.analytics_outlined,
        pageNumber: 3,
        totalPages: 3,
        isLastPage: true,
        onDone: _completeOnboarding,
      ),
    ];

    return Scaffold(
      backgroundColor: JejakFaaColors.backgroundColor,
      body: Stack(
        children: [
          LiquidSwipe(
            pages: pages,
            liquidController: _liquidController,
            waveType: WaveType.circularReveal,
            fullTransitionValue: 400,
            enableSideReveal: true,
            enableLoop: false,
            positionSlideIcon: 0.85,
            slideIconWidget: Icon(
              Icons.arrow_back_ios,
              color: JejakFaaColors.textSecondary,
              size: 20,
            ),
            onPageChangeCallback: (pageIndex) {
              setState(() {
                _currentPage = pageIndex;
              });
            },
          ),
          
          // Progress indicator di bagian atas
          Positioned(
            top: MediaQuery.of(context).padding.top + 20,
            left: 0,
            right: 0,
            child: _buildProgressIndicator(),
          ),
          
          // Skip button
          if (_currentPage < 2)
            Positioned(
              top: MediaQuery.of(context).padding.top + 16,
              right: 24,
              child: _buildSkipButton(),
            ),
        ],
      ),
    );
  }

  // Widget helper untuk membuat 1 halaman onboarding
  Widget _buildOnboardingPage({
    required String lottieAsset,
    required String title,
    required String description,
    required String subtitle,
    required IconData icon,
    required int pageNumber,
    required int totalPages,
    bool isLastPage = false,
    VoidCallback? onDone,
  }) {
    return Container(
      color: JejakFaaColors.backgroundColor,
      padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 80),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Spacer untuk progress indicator
          const SizedBox(height: 60),
          
          // Konten utama
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Icon dan subtitle
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: JejakFaaColors.primary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        icon,
                        size: 16,
                        color: JejakFaaColors.primary,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        subtitle,
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: JejakFaaColors.primary,
                        ),
                      ),
                    ],
                  ),
                ),
                
                const SizedBox(height: 40),
                
                // Animasi Lottie dengan container yang konsisten
                Container(
                  height: 240,
                  width: 240,
                  decoration: BoxDecoration(
                    color: JejakFaaColors.cardColor,
                    borderRadius: BorderRadius.circular(24),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.08),
                        blurRadius: 20,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(24),
                    child: Lottie.asset(
                      lottieAsset,
                      fit: BoxFit.cover,
                      repeat: true,
                      animate: true,
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          color: JejakFaaColors.cardColor,
                          child: Center(
                            child: Icon(
                              icon,
                              size: 80,
                              color: JejakFaaColors.primary.withOpacity(0.3),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ),
                
                const SizedBox(height: 48),
                
                // Judul
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.w700,
                    color: JejakFaaColors.textPrimary,
                    height: 1.3,
                  ),
                  textAlign: TextAlign.center,
                ),
                
                const SizedBox(height: 20),
                
                // Deskripsi
                Text(
                  description,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w400,
                    color: JejakFaaColors.textSecondary,
                    height: 1.6,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
          
          // Tombol atau indikator swipe
          if (isLastPage)
            _buildGetStartedButton(onDone!)
          else
            _buildSwipeIndicator(),
        ],
      ),
    );
  }

  Widget _buildProgressIndicator() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: List.generate(3, (index) {
          return AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            width: _currentPage == index ? 32 : 12,
            height: 8,
            margin: const EdgeInsets.symmetric(horizontal: 4),
            decoration: BoxDecoration(
              color: _currentPage == index 
                  ? JejakFaaColors.primary 
                  : JejakFaaColors.textLight.withOpacity(0.3),
              borderRadius: BorderRadius.circular(4),
            ),
          );
        }),
      ),
    );
  }

  Widget _buildSkipButton() {
    return Container(
      decoration: BoxDecoration(
        color: JejakFaaColors.cardColor,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: TextButton(
        onPressed: _completeOnboarding,
        style: TextButton.styleFrom(
          foregroundColor: JejakFaaColors.textSecondary,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        child: Text(
          'Lewati',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: JejakFaaColors.textSecondary,
          ),
        ),
      ),
    );
  }

  Widget _buildGetStartedButton(VoidCallback onDone) {
    return Column(
      children: [
        // Tombol utama
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: onDone,
            style: ElevatedButton.styleFrom(
              backgroundColor: JejakFaaColors.primary,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 18),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              elevation: 2,
              shadowColor: JejakFaaColors.primary.withOpacity(0.3),
            ),
            child: const Text(
              'Mulai Petualangan',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
        
        const SizedBox(height: 20),
        
        // Teks filosofi
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: JejakFaaColors.accentColor.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: JejakFaaColors.accentColor.withOpacity(0.2),
              width: 1,
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.eco_outlined,
                size: 16,
                color: JejakFaaColors.accentColor,
              ),
              const SizedBox(width: 8),
              Text(
                'Jejak Anda, Data Anda',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: JejakFaaColors.accentColor,
                  fontStyle: FontStyle.italic,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSwipeIndicator() {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          decoration: BoxDecoration(
            color: JejakFaaColors.cardColor,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
            border: Border.all(
              color: JejakFaaColors.primary.withOpacity(0.1),
              width: 1,
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Geser untuk lanjut',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: JejakFaaColors.textSecondary,
                ),
              ),
              const SizedBox(width: 8),
              Icon(
                Icons.arrow_forward_ios_rounded,
                size: 16,
                color: JejakFaaColors.textSecondary,
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),
      ],
    );
  }
}