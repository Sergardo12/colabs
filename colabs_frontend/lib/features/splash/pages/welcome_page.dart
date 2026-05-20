import 'package:flutter/material.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_sizes.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/routes/app_router.dart';
import 'dart:async';

class WelcomePage extends StatefulWidget {
  const WelcomePage({super.key});

  @override
  State<WelcomePage> createState() => _WelcomePageState();
}

class _WelcomePageState extends State<WelcomePage> {
  final PageController _pageController = PageController();
  late Timer _autoScrollTimer;
  int _currentPage = 0;

  final List<Map<String, String>> _slides = [
    {
      'image':       'assets/images/slide_1.png',
      'title':       AppStrings.slide1Title,
      'description': AppStrings.slide1Description,
    },
    {
      'image':       'assets/images/slide_2.png',
      'title':       AppStrings.slide2Title,
      'description': AppStrings.slide2Description,
    },
    {
      'image':       'assets/images/slide_3.png',
      'title':       AppStrings.slide3Title,
      'description': AppStrings.slide3Description,
    },
  ];

  @override
  void initState() {
    super.initState();
    _startAutoScroll();
  }

  void _startAutoScroll() {
    _autoScrollTimer = Timer.periodic(const Duration(seconds: 4), (_) {
      if (!mounted) return;
      final nextPage = (_currentPage + 1) % _slides.length;
      _pageController.animateToPage(
        nextPage,
        duration: const Duration(milliseconds: 500),
        curve:    Curves.easeInOut,
      );
    });
  }

  @override
  void dispose() {
    _autoScrollTimer.cancel();
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Carrusel de imágenes full screen
          PageView.builder(
            controller: _pageController,
            itemCount:  _slides.length,
            onPageChanged: (index) => setState(() => _currentPage = index),
            itemBuilder: (context, index) {
              return Image.asset(
                _slides[index]['image']!,
                fit:    BoxFit.cover,
                width:  double.infinity,
                height: double.infinity,
              );
            },
          ),

          // Gradiente oscuro de abajo hacia arriba
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin:  Alignment.topCenter,
                end:    Alignment.bottomCenter,
                colors: [
                  Colors.transparent,
                  Colors.transparent,
                  Color(0xAA000000),
                  Color(0xEE000000),
                ],
                stops: [0.0, 0.45, 0.65, 1.0],
              ),
            ),
          ),

          // Contenido sobre el gradiente
          SafeArea(
            child: Column(
              children: [
                const Spacer(),
                // Título y descripción
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSizes.paddingXXL,
                  ),
                  child: Column(
                    children: [
                      Text(
                        _slides[_currentPage]['title']!,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          color:      AppColors.white,
                          fontSize:   AppSizes.fontXXL,
                          fontWeight: FontWeight.bold,
                          height:     1.2,
                        ),
                      ),
                      const SizedBox(height: AppSizes.paddingS),
                      Text(
                        _slides[_currentPage]['description']!,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color:    AppColors.white.withOpacity(0.85),
                          fontSize: AppSizes.fontM,
                          height:   1.5,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: AppSizes.paddingL),

                // Puntitos
                SmoothPageIndicator(
                  controller: _pageController,
                  count:      _slides.length,
                  effect: ExpandingDotsEffect(
                    activeDotColor: AppColors.white,
                    dotColor:       AppColors.white.withOpacity(0.4),
                    dotHeight:      8,
                    dotWidth:       8,
                    expansionFactor: 3,
                  ),
                ),
                const SizedBox(height: AppSizes.paddingXL),

                // Botones
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSizes.paddingL,
                  ),
                  child: Column(
                    children: [
                      ElevatedButton(
                        onPressed: () => Navigator.pushNamed(
                          context,
                          AppRouter.register,
                        ),
                        child: const Text(AppStrings.welcomeRegister),
                      ),
                      const SizedBox(height: AppSizes.paddingM),
                      TextButton(
                        onPressed: () => Navigator.pushNamed(
                          context,
                          AppRouter.login,
                        ),
                        child: Text(
                          AppStrings.welcomeLogin,
                          style: TextStyle(
                            color:      AppColors.white.withOpacity(0.9),
                            fontSize:   AppSizes.fontL,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: AppSizes.paddingXL),
              ],
            ),
          ),
        ],
      ),
    );
  }
}