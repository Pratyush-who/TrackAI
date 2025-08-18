import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:trackai/core/constants/appcolors.dart';

class GoalSelectionPage extends StatefulWidget {
  final VoidCallback onNext;
  final VoidCallback onBack;
  final Function(String) onDataUpdate;

  const GoalSelectionPage({
    Key? key,
    required this.onNext,
    required this.onBack,
    required this.onDataUpdate,
  }) : super(key: key);

  @override
  State<GoalSelectionPage> createState() => _GoalSelectionPageState();
}

class _GoalSelectionPageState extends State<GoalSelectionPage>
    with TickerProviderStateMixin {
  String? selectedGoal;
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  final List<Map<String, dynamic>> goalOptions = [
    {
      'title': 'Lose Weight',
      'subtitle': 'Burn fat and get leaner',
      'icon': FontAwesomeIcons.weightScale,
      'value': 'lose_weight',
      'color': const Color(0xFFFF6B6B),
    },
    {
      'title': 'Maintain Weight',
      'subtitle': 'Stay at your current weight',
      'icon': FontAwesomeIcons.balanceScale,
      'value': 'maintain_weight',
      'color': AppColors.successColor,
    },
    {
      'title': 'Gain Weight',
      'subtitle': 'Build muscle and bulk up',
      'icon': FontAwesomeIcons.dumbbell,
      'value': 'gain_weight',
      'color': const Color(0xFF4ECDC4),
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
      CurvedAnimation(parent: _animationController, curve: Curves.elasticOut),
    );

    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _selectGoal(String goal) {
    setState(() {
      selectedGoal = goal;
    });
    widget.onDataUpdate(goal);
  }

  void _continue() {
    if (selectedGoal != null) {
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
                  _buildGoalOptions(),
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
          'What\'s your goal?',
          style: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.w700,
            color: Colors.white,
            letterSpacing: -0.5,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Choose your primary fitness goal to get personalized recommendations',
          style: TextStyle(
            fontSize: 16,
            color: AppColors.textSecondary(true),
            fontWeight: FontWeight.w400,
          ),
        ),
      ],
    );
  }

  Widget _buildGoalOptions() {
    return Column(
      children: goalOptions.asMap().entries.map((entry) {
        final index = entry.key;
        final option = entry.value;
        bool isSelected = selectedGoal == option['value'];
        
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
                  child: _buildGoalCard(
                    option['title'],
                    option['subtitle'],
                    option['icon'],
                    option['value'],
                    option['color'],
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

  Widget _buildGoalCard(
    String title,
    String subtitle,
    IconData icon,
    String value,
    Color iconColor,
    bool isSelected,
  ) {
    return GestureDetector(
      onTap: () => _selectGoal(value),
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
        child: Row(
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
                      color: isSelected ? AppColors.successColor : Colors.white,
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
      ),
    );
  }

  Widget _buildContinueButton() {
    return Container(
      width: double.infinity,
      height: 48,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        gradient: selectedGoal != null
            ? LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [AppColors.successColor, AppColors.successColor],
              )
            : null,
        color: selectedGoal == null ? AppColors.darkGrey : null,
      ),
      child: ElevatedButton(
        onPressed: selectedGoal != null ? _continue : null,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          shadowColor: Colors.transparent,
          elevation: 0,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
        child: Text(
          'Continue',
          style: TextStyle(
            color: selectedGoal != null ? Colors.white : Colors.white54,
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}