import 'package:flutter/material.dart';

class SplashPage extends StatefulWidget {
  const SplashPage({super.key});

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    _scaleAnimation = Tween<double>(
      begin: 0.8,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOutBack,
    ));

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.3, 1.0, curve: Curves.easeIn),
    ));

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F7F2), // JejakFaaColors.background
      body: Center(
        child: ScaleTransition(
          scale: _scaleAnimation,
          child: FadeTransition(
            opacity: _fadeAnimation,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Logo Container dengan desain premium
                Container(
                  width: 120,
                  height: 120,
                  decoration: BoxDecoration(
                    color: const Color(0xFF1A535C), // JejakFaaColors.primary
                    borderRadius: BorderRadius.circular(24),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF1A535C).withOpacity(0.3),
                        blurRadius: 20,
                        offset: const Offset(0, 10),
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.terrain_rounded,
                    color: Colors.white,
                    size: 60,
                  ),
                ),
                
                const SizedBox(height: 32),
                
                // Nama Aplikasi dengan typography premium
                Column(
                  children: [
                    Text(
                      'Jejak Faa',
                      style: TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.w700,
                        color: const Color(0xFF1A535C), // Primary color
                        letterSpacing: -0.5,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Pelacak Pendakian',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                        color: const Color(0xFF666666), // Text secondary
                        letterSpacing: 0.5,
                      ),
                    ),
                  ],
                ),
                
                const SizedBox(height: 48),
                
                // Loading indicator custom
                Container(
                  width: 120,
                  height: 4,
                  decoration: BoxDecoration(
                    color: const Color(0xFFE0E0E0),
                    borderRadius: BorderRadius.circular(2),
                  ),
                  child: Stack(
                    children: [
                      // Animated progress bar
                      AnimatedBuilder(
                        animation: _controller,
                        builder: (context, child) {
                          return Container(
                            width: 120 * _controller.value,
                            height: 4,
                            decoration: BoxDecoration(
                              color: const Color(0xFF1A535C), // Primary color
                              borderRadius: BorderRadius.circular(2),
                              gradient: const LinearGradient(
                                colors: [
                                  Color(0xFF1A535C),
                                  Color(0xFF4ECDC4), // Primary light
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ),
                
                const SizedBox(height: 16),
                
                // Loading text dengan filosofi brand
                Text(
                  'Menyiapkan petualangan Anda...',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w400,
                    color: const Color(0xFF999999), // Text light
                  ),
                ),
                
                const SizedBox(height: 8),
                
                // Filosofi brand
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 40),
                  child: Text(
                    '"Jejak Anda, Data Anda"',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: const Color(0xFF666666), // Text secondary
                      fontStyle: FontStyle.italic,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),

      // Bottom info version
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Stats preview (opsional - menunjukkan kekuatan data)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 10,
                      offset: const Offset(0, 5),
                    ),
                  ],
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _buildStatPreview('12.5K', 'Jejak Tersimpan'),
                    _buildStatPreview('847', 'Gunung Terdaftar'),
                    _buildStatPreview('98%', 'Akurasi GPS'),
                  ],
                ),
              ),
              
              const SizedBox(height: 16),
              
              Text(
                'v1.0.0 • © 2024 Jejak Faa',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w400,
                  color: const Color(0xFF999999),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatPreview(String value, String label) {
    return Column(
      children: [
        Text(
          value,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w700,
            color: Color(0xFF1A535C),
          ),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: TextStyle(
            fontSize: 10,
            fontWeight: FontWeight.w400,
            color: const Color(0xFF666666),
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}