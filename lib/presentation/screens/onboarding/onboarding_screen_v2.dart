import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../core/constants/colors.dart';
import '../../../core/constants/text_styles.dart';
import '../../../core/constants/app_constants.dart';

class OnboardingScreenV2 extends StatefulWidget {
  const OnboardingScreenV2({super.key});

  @override
  State<OnboardingScreenV2> createState() => _OnboardingScreenV2State();
}

class _OnboardingScreenV2State extends State<OnboardingScreenV2>
    with TickerProviderStateMixin {
  final PageController _pageController = PageController();
  int _currentPage = 0;
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  final List<OnboardingPage> _pages = [
    OnboardingPage(
      title: 'Add Your Books',
      description: 'Import PDF and EPUB files from your device storage',
      icon: Icons.add_circle_outline,
      color: AppColors.primary,
      instructions: [
        'Tap the + button in Library tab',
        'Select PDF or EPUB files',
        'Books appear automatically',
      ],
      gesture: 'Tap to add books',
    ),
    OnboardingPage(
      title: 'Navigate Pages',
      description: 'Easy page turning with swipe gestures',
      icon: Icons.swipe,
      color: AppColors.secondary,
      instructions: [
        'Swipe left/right to turn pages',
        'Use page slider for quick jumps',
        'Double-tap to zoom in/out',
      ],
      gesture: 'Swipe ← → to navigate',
    ),
    OnboardingPage(
      title: 'Reading Controls',
      description: 'Access reading features with simple taps',
      icon: Icons.touch_app,
      color: AppColors.accent,
      instructions: [
        'Tap screen to show/hide controls',
        'Bookmark pages with bookmark icon',
        'Adjust brightness and themes',
      ],
      gesture: 'Tap screen for controls',
    ),
    OnboardingPage(
      title: 'Chapter Navigation',
      description: 'Jump between chapters and sections easily',
      icon: Icons.list_alt,
      color: AppColors.primary,
      instructions: [
        'Tap menu icon for chapter list',
        'Select any chapter to jump',
        'Track reading progress',
      ],
      gesture: 'Tap menu for chapters',
    ),
  ];

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
    _animationController.forward();
  }

  @override
  void dispose() {
    _pageController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surface,
      body: SafeArea(
        child: Column(
          children: [
            // Skip button
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'How to Use',
                    style: AppTextStyles.h5.copyWith(
                      color: AppColors.textPrimary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  TextButton(
                    onPressed: _completeOnboarding,
                    child: Text(
                      'Skip',
                      style: AppTextStyles.labelMedium.copyWith(
                        color: AppColors.primary,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: PageView.builder(
                controller: _pageController,
                onPageChanged: (index) {
                  setState(() {
                    _currentPage = index;
                  });
                  _animationController.reset();
                  _animationController.forward();
                  // Haptic feedback
                  HapticFeedback.lightImpact();
                },
                itemCount: _pages.length,
                itemBuilder: (context, index) {
                  return FadeTransition(
                    opacity: _fadeAnimation,
                    child: _buildPage(_pages[index]),
                  );
                },
              ),
            ),
            _buildBottomSection(),
          ],
        ),
      ),
    );
  }

  Widget _buildPage(OnboardingPage page) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Icon with animated background
          Container(
            width: 140,
            height: 140,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  page.color.withValues(alpha: 0.1),
                  page.color.withValues(alpha: 0.05),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: page.color.withValues(alpha: 0.2),
                  blurRadius: 20,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: Icon(page.icon, size: 70, color: page.color),
          ),
          const SizedBox(height: 40),

          // Title
          Text(
            page.title,
            style: AppTextStyles.h2.copyWith(
              color: AppColors.textPrimary,
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),

          // Description
          Text(
            page.description,
            style: AppTextStyles.bodyLarge.copyWith(
              color: AppColors.textSecondary,
              height: 1.5,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 32),

          // Instructions
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: AppColors.surfaceLight,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: page.color.withValues(alpha: 0.2),
                width: 1,
              ),
            ),
            child: Column(
              children: [
                ...page.instructions.map(
                  (instruction) => Padding(
                    padding: const EdgeInsets.symmetric(vertical: 4),
                    child: Row(
                      children: [
                        Icon(Icons.check_circle, color: page.color, size: 20),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            instruction,
                            style: AppTextStyles.bodyMedium.copyWith(
                              color: AppColors.textPrimary,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: page.color.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    page.gesture,
                    style: AppTextStyles.labelMedium.copyWith(
                      color: page.color,
                      fontWeight: FontWeight.w600,
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

  Widget _buildBottomSection() {
    return Container(
      padding: const EdgeInsets.all(24.0),
      decoration: BoxDecoration(
        color: AppColors.surface,
        boxShadow: [
          BoxShadow(
            color: AppColors.shadowLight,
            blurRadius: 10,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: Column(
        children: [
          // Page indicators
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(
              _pages.length,
              (index) => AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                margin: const EdgeInsets.symmetric(horizontal: 4),
                width: _currentPage == index ? 32 : 8,
                height: 8,
                decoration: BoxDecoration(
                  color: _currentPage == index
                      ? AppColors.primary
                      : AppColors.borderLight,
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
            ),
          ),
          const SizedBox(height: 24),

          // Navigation buttons
          Row(
            children: [
              if (_currentPage > 0)
                Expanded(
                  child: OutlinedButton(
                    onPressed: () {
                      _pageController.previousPage(
                        duration: const Duration(milliseconds: 300),
                        curve: Curves.easeInOut,
                      );
                    },
                    child: const Text('Previous'),
                  ),
                ),
              if (_currentPage > 0) const SizedBox(width: 16),
              Expanded(
                flex: _currentPage > 0 ? 1 : 2,
                child: ElevatedButton(
                  onPressed: () {
                    if (_currentPage < _pages.length - 1) {
                      _pageController.nextPage(
                        duration: const Duration(milliseconds: 300),
                        curve: Curves.easeInOut,
                      );
                    } else {
                      _completeOnboarding();
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  child: Text(
                    _currentPage < _pages.length - 1
                        ? 'Next'
                        : 'Start Reading!',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Future<void> _completeOnboarding() async {
    // Play completion sound
    HapticFeedback.mediumImpact();
    SystemSound.play(SystemSoundType.click);

    // Mark onboarding as completed
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(AppConstants.onboardingCompletedKey, true);

    // Navigate to home
    if (mounted) {
      Navigator.of(context).pushReplacementNamed('/home');
    }
  }
}

class OnboardingPage {
  final String title;
  final String description;
  final IconData icon;
  final Color color;
  final List<String> instructions;
  final String gesture;

  OnboardingPage({
    required this.title,
    required this.description,
    required this.icon,
    required this.color,
    required this.instructions,
    required this.gesture,
  });
}
