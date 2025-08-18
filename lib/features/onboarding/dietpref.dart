import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:trackai/core/constants/appcolors.dart';

class DietPreferencePage extends StatefulWidget {
  final VoidCallback onNext;
  final VoidCallback onBack;
  final Function(String) onDataUpdate;

  const DietPreferencePage({
    Key? key,
    required this.onNext,
    required this.onBack,
    required this.onDataUpdate,
  }) : super(key: key);

  @override
  State<DietPreferencePage> createState() => _DietPreferencePageState();
}

class _DietPreferencePageState extends State<DietPreferencePage>
    with TickerProviderStateMixin {
  String? selectedDiet;
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  final List<Map<String, dynamic>> dietOptions = [
    {
      'title': 'Classic',
      'subtitle': 'Balanced diet with all food groups',
      'icon': FontAwesomeIcons.utensils,
      'value': 'classic',
      'color': AppColors.successColor,
      'description': 'Includes all food groups for balanced nutrition',
    },
    {
      'title': 'Vegetarian',
      'subtitle': 'Plant-based with dairy and eggs',
      'icon': FontAwesomeIcons.leaf,
      'value': 'vegetarian',
      'color': const Color(0xFF27AE60),
      'description': 'No meat, but includes dairy products and eggs',
    },
    {
      'title': 'Vegan',
      'subtitle': 'Fully plant-based diet',
      'icon': FontAwesomeIcons.seedling,
      'value': 'vegan',
      'color': const Color(0xFF2ECC71),
      'description': 'Completely plant-based, no animal products',
    },
    {
      'title': 'Non-Vegetarian',
      'subtitle': 'Includes meat, fish, and poultry',
      'icon': FontAwesomeIcons.drumstickBite,
      'value': 'non_vegetarian',
      'color': const Color(0xFFE67E22),
      'description': 'All foods including meat and seafood',
    },
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

    _slideAnimation =
        Tween<Offset>(begin: const Offset(0, 0.3), end: Offset.zero).animate(
          CurvedAnimation(
            parent: _animationController,
            curve: Curves.elasticOut,
          ),
        );

    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _selectDiet(String diet) {
    setState(() {
      selectedDiet = diet;
    });
    widget.onDataUpdate(diet);
  }

  void _continue() {
    if (selectedDiet != null) {
      widget.onNext();
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isTablet = screenWidth > 600;

    return AnimatedBuilder(
      animation: _animationController,
      builder: (context, child) {
        return FadeTransition(
          opacity: _fadeAnimation,
          child: SlideTransition(
            position: _slideAnimation,
            child: SingleChildScrollView(
              padding: EdgeInsets.symmetric(
                horizontal: isTablet ? screenWidth * 0.2 : 24.0,
                vertical: 24.0,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildBackButton(),
                  const SizedBox(height: 20),
                  _buildHeader(),
                  const SizedBox(height: 40),
                  _buildDietOptions(),
                  const SizedBox(height: 40),
                  _buildContinueButton(),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildBackButton() {
    return GestureDetector(
      onTap: widget.onBack,
      child: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: AppColors.cardBackground(true).withOpacity(0.8),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.darkGrey, width: 1),
        ),
        child: const Icon(
          Icons.arrow_back_ios_new,
          color: Colors.white,
          size: 18,
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'What diet do you follow?',
          style: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.w700,
            color: Colors.white,
            letterSpacing: -0.5,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Tell us about your dietary preferences for personalized meal recommendations',
          style: TextStyle(
            fontSize: 16,
            color: AppColors.textSecondary(true),
            fontWeight: FontWeight.w400,
          ),
        ),
      ],
    );
  }

  Widget _buildDietOptions() {
    return Column(
      children: dietOptions.asMap().entries.map((entry) {
        final index = entry.key;
        final option = entry.value;
        bool isSelected = selectedDiet == option['value'];

        return TweenAnimationBuilder<double>(
          duration: Duration(milliseconds: 300 + (index * 100)),
          tween: Tween(begin: 0.0, end: 1.0),
          builder: (context, value, child) {
            return Transform.translate(
              offset: Offset(0, 30 * (1 - value)),
              child: Opacity(
                opacity: value,
                child: Padding(
                  padding: const EdgeInsets.only(bottom: 16),
                  child: _buildDietCard(
                    option['title'],
                    option['subtitle'],
                    option['icon'],
                    option['value'],
                    option['color'],
                    option['description'],
                    isSelected,
                  ),
                ),
              ),
            );
          },
        );
      }).toList(),
    );
  }

  Widget _buildDietCard(
    String title,
    String subtitle,
    IconData icon,
    String value,
    Color iconColor,
    String description,
    bool isSelected,
  ) {
    return GestureDetector(
      onTap: () => _selectDiet(value),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.successColor.withOpacity(0.1)
              : AppColors.cardBackground(true).withOpacity(0.8),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? AppColors.successColor : AppColors.darkGrey,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Column(
          children: [
            Row(
              children: [
                Container(
                  width: 64,
                  height: 64,
                  decoration: BoxDecoration(
                    color: isSelected
                        ? iconColor.withOpacity(0.2)
                        : AppColors.darkGrey.withOpacity(0.3),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    icon,
                    color: isSelected ? iconColor : Colors.white70,
                    size: 28,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w600,
                          color: isSelected
                              ? AppColors.successColor
                              : Colors.white,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        subtitle,
                        style: TextStyle(
                          fontSize: 14,
                          color: AppColors.textSecondary(true),
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                    ],
                  ),
                ),
                AnimatedScale(
                  scale: isSelected ? 1.0 : 0.0,
                  duration: const Duration(milliseconds: 200),
                  child: Icon(
                    Icons.check_circle,
                    color: AppColors.successColor,
                    size: 28,
                  ),
                ),
              ],
            ),
            if (isSelected) ...[
              const SizedBox(height: 12),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: iconColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: iconColor.withOpacity(0.3),
                    width: 1,
                  ),
                ),
                child: Text(
                  description,
                  style: TextStyle(
                    fontSize: 13,
                    color: AppColors.textSecondary(true),
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildContinueButton() {
    return Container(
      width: double.infinity,
      height: 48,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        gradient: selectedDiet != null
            ? LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [AppColors.successColor, AppColors.successColor],
              )
            : null,
        color: selectedDiet == null ? AppColors.darkGrey : null,
      ),
      child: ElevatedButton(
        onPressed: selectedDiet != null ? _continue : null,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          shadowColor: Colors.transparent,
          elevation: 0,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
        child: Text(
          'Continue',
          style: TextStyle(
            color: selectedDiet != null ? Colors.white : Colors.white54,
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}
