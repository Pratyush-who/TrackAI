import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:trackai/core/constants/appcolors.dart';

class GenderSelectionPage extends StatefulWidget {
  final VoidCallback onNext;
  final Function(String) onDataUpdate;

  const GenderSelectionPage({
    Key? key,
    required this.onNext,
    required this.onDataUpdate,
  }) : super(key: key);

  @override
  State<GenderSelectionPage> createState() => _GenderSelectionPageState();
}

class _GenderSelectionPageState extends State<GenderSelectionPage>
    with TickerProviderStateMixin {
  String? selectedGender;
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

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

  void _selectGender(String gender) {
    setState(() {
      selectedGender = gender;
    });
    widget.onDataUpdate(gender);
  }

  void _continue() {
    if (selectedGender != null) {
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
                  _buildHeader(),
                  const SizedBox(height: 40),
                  _buildGenderOptions(),
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

  Widget _buildHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Tell us about yourself',
          style: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.w700,
            color: Colors.white,
            letterSpacing: -0.5,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Choose your gender to help us personalize your experience',
          style: TextStyle(
            fontSize: 16,
            color: AppColors.textSecondary(true),
            fontWeight: FontWeight.w400,
          ),
        ),
      ],
    );
  }

  Widget _buildGenderOptions() {
    return Column(
      children: [
        _buildGenderCard(
          'Male',
          FontAwesomeIcons.mars,
          selectedGender == 'Male',
        ),
        const SizedBox(height: 16),
        _buildGenderCard(
          'Female',
          FontAwesomeIcons.venus,
          selectedGender == 'Female',
        ),
        const SizedBox(height: 16),
        _buildGenderCard(
          'Other',
          FontAwesomeIcons.genderless,
          selectedGender == 'Other',
        ),
      ],
    );
  }

  Widget _buildGenderCard(String gender, IconData icon, bool isSelected) {
    return GestureDetector(
      onTap: () => _selectGender(gender),
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
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                color: isSelected
                    ? AppColors.successColor.withOpacity(0.2)
                    : AppColors.darkGrey.withOpacity(0.3),
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                color: isSelected ? AppColors.successColor : Colors.white70,
                size: 24,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                gender,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: isSelected ? AppColors.successColor : Colors.white,
                ),
              ),
            ),
            if (isSelected)
              Icon(Icons.check_circle, color: AppColors.successColor, size: 24),
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
        gradient: selectedGender != null
            ? LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [AppColors.successColor, AppColors.successColor],
              )
            : null,
        color: selectedGender == null ? AppColors.darkGrey : null,
      ),
      child: ElevatedButton(
        onPressed: selectedGender != null ? _continue : null,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          shadowColor: Colors.transparent,
          elevation: 0,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
        child: Text(
          'Continue',
          style: TextStyle(
            color: selectedGender != null ? Colors.white : Colors.white54,
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}
