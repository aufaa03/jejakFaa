import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:jejak_faa_new/features/auth/providers/auth_provider.dart';

class LoginPage extends ConsumerStatefulWidget {
  const LoginPage({super.key});

  @override
  ConsumerState<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends ConsumerState<LoginPage> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  late Animation<double> _slideAnimation;

  @override
  void initState() {
    super.initState();
    
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.4, 1.0, curve: Curves.easeOut),
    ));

    _slideAnimation = Tween<double>(
      begin: 50.0,
      end: 0.0,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.6, 1.0, curve: Curves.easeOut),
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
    final authState = ref.watch(authStateProvider);
    final size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: const Color(0xFFF7F7F2),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 32),
          child: SizedBox(
            height: size.height - MediaQuery.of(context).padding.top,
            child: Column(
              children: [
                // Header section dengan animasi
                Expanded(
                  flex: 2,
                  child: AnimatedBuilder(
                    animation: _controller,
                    builder: (context, child) {
                      return Transform.translate(
                        offset: Offset(0, _slideAnimation.value),
                        child: Opacity(
                          opacity: _fadeAnimation.value,
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              // Logo container
                              Container(
                                width: 80,
                                height: 80,
                                decoration: BoxDecoration(
                                  color: const Color(0xFF1A535C),
                                  borderRadius: BorderRadius.circular(20),
                                  boxShadow: [
                                    BoxShadow(
                                      color: const Color(0xFF1A535C).withOpacity(0.3),
                                      blurRadius: 15,
                                      offset: const Offset(0, 8),
                                    ),
                                  ],
                                ),
                                child: const Icon(
                                  Icons.terrain_rounded,
                                  color: Colors.white,
                                  size: 40,
                                ),
                              ),
                              
                              const SizedBox(height: 32),
                              
                              // Welcome text
                              Text(
                                'Selamat Datang',
                                style: TextStyle(
                                  fontSize: 32,
                                  fontWeight: FontWeight.w700,
                                  color: const Color(0xFF1A1A1A),
                                  letterSpacing: -0.5,
                                ),
                              ),
                              
                              const SizedBox(height: 12),
                              
                              // Subtitle
                              Text(
                                'Lanjutkan petualangan Anda dengan Jejak Faa',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w400,
                                  color: const Color(0xFF666666),
                                  height: 1.5,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),

                // Login section
                Expanded(
                  flex: 1,
                  child: AnimatedBuilder(
                    animation: _controller,
                    builder: (context, child) {
                      return Opacity(
                        opacity: _fadeAnimation.value,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            // Google login button
                            Container(
                              width: double.infinity,
                              height: 56,
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(16),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.08),
                                    blurRadius: 20,
                                    offset: const Offset(0, 8),
                                  ),
                                ],
                                border: Border.all(
                                  color: const Color(0xFFE0E0E0),
                                  width: 1,
                                ),
                              ),
                              child: Material(
                                color: Colors.transparent,
                                child: InkWell(
                                  borderRadius: BorderRadius.circular(16),
                                  onTap: authState.isLoading 
                                      ? null 
                                      : () {
                                          ref.read(authControllerProvider).signInWithGoogle();
                                        },
                                  child: Padding(
                                    padding: const EdgeInsets.symmetric(horizontal: 20),
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        // Google logo
                                        Image.asset(
                                          'assets/images/google_logo.png',
                                          width: 24,
                                          height: 24,
                                          errorBuilder: (context, error, stackTrace) {
                                            return Container(
                                              width: 24,
                                              height: 24,
                                              decoration: BoxDecoration(
                                                color: const Color(0xFF4285F4),
                                                borderRadius: BorderRadius.circular(12),
                                              ),
                                              child: const Icon(
                                                Icons.account_circle,
                                                color: Colors.white,
                                                size: 16,
                                              ),
                                            );
                                          },
                                        ),
                                        const SizedBox(width: 12),
                                        Text(
                                          authState.isLoading ? 'Memproses...' : 'Lanjutkan dengan Google',
                                          style: TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.w600,
                                            color: authState.isLoading 
                                                ? const Color(0xFF999999) 
                                                : const Color(0xFF1A1A1A),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ),

                            const SizedBox(height: 24),

                            // Loading indicator
                            if (authState.isLoading)
                              Container(
                                width: 120,
                                height: 4,
                                decoration: BoxDecoration(
                                  color: const Color(0xFFE0E0E0),
                                  borderRadius: BorderRadius.circular(2),
                                ),
                                child: Stack(
                                  children: [
                                    LayoutBuilder(
                                      builder: (context, constraints) {
                                        return Container(
                                          width: constraints.maxWidth * 0.7,
                                          height: 4,
                                          decoration: BoxDecoration(
                                            color: const Color(0xFF1A535C),
                                            borderRadius: BorderRadius.circular(2),
                                            gradient: const LinearGradient(
                                              colors: [
                                                Color(0xFF1A535C),
                                                Color(0xFF4ECDC4),
                                              ],
                                            ),
                                          ),
                                        );
                                      },
                                    ),
                                  ],
                                ),
                              ),

                            const SizedBox(height: 32),

                            // Privacy text
                            Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 20),
                              child: Text(
                                'Dengan melanjutkan, Anda menyetujui Kebijakan Privasi dan Syarat Layanan kami',
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w400,
                                  color: const Color(0xFF999999),
                                  height: 1.4,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),

                // Footer dengan filosofi brand
                Padding(
                  padding: const EdgeInsets.only(bottom: 32),
                  child: AnimatedBuilder(
                    animation: _controller,
                    builder: (context, child) {
                      return Opacity(
                        opacity: _fadeAnimation.value,
                        child: Column(
                          children: [
                            Text(
                              '"Jejak Anda, Data Anda"',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                                color: const Color(0xFF666666),
                                fontStyle: FontStyle.italic,
                              ),
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'Aplikasi Pendakian Premium',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w400,
                                color: const Color(0xFF999999),
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
          ),
        ),
      ),
    );
  }
}