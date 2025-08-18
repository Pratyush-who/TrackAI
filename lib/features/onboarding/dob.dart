import 'package:flutter/material.dart';
import 'package:trackai/core/constants/appcolors.dart';

class DateOfBirthPage extends StatefulWidget {
  final VoidCallback onNext;
  final VoidCallback onBack;
  final Function(DateTime) onDataUpdate;

  const DateOfBirthPage({
    Key? key,
    required this.onNext,
    required this.onBack,
    required this.onDataUpdate,
  }) : super(key: key);

  @override
  State<DateOfBirthPage> createState() => _DateOfBirthPageState();
}

class _DateOfBirthPageState extends State<DateOfBirthPage>
    with TickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  DateTime? selectedDate;
  final DateTime minDate = DateTime(1920);
  final DateTime maxDate = DateTime.now().subtract(
    const Duration(days: 365 * 13),
  ); // Minimum 13 years old

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

  Future<void> _selectDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: selectedDate ?? DateTime(1995),
      firstDate: minDate,
      lastDate: maxDate,
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.dark(
              primary: AppColors.successColor,
              onPrimary: Colors.white,
              surface: AppColors.cardBackground(true),
              onSurface: Colors.white,
            ),
            dialogBackgroundColor: AppColors.cardBackground(true),
          ),
          child: child!,
        );
      },
    );

    if (picked != null && picked != selectedDate) {
      setState(() {
        selectedDate = picked;
      });
      widget.onDataUpdate(picked);
    }
  }

  void _continue() {
    if (selectedDate != null) {
      widget.onNext();
    }
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  int _calculateAge(DateTime birthDate) {
    final today = DateTime.now();
    int age = today.year - birthDate.year;
    if (today.month < birthDate.month ||
        (today.month == birthDate.month && today.day < birthDate.day)) {
      age--;
    }
    return age;
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
                  _buildDateSelector(),
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
          'When were you born?',
          style: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.w700,
            color: Colors.white,
            letterSpacing: -0.5,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'This helps us provide age-appropriate recommendations',
          style: TextStyle(
            fontSize: 16,
            color: AppColors.textSecondary(true),
            fontWeight: FontWeight.w400,
          ),
        ),
      ],
    );
  }

  Widget _buildDateSelector() {
    return Center(
      child: Column(
        children: [
          GestureDetector(
            onTap: _selectDate,
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: AppColors.cardBackground(true).withOpacity(0.8),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: selectedDate != null
                      ? AppColors.successColor
                      : AppColors.darkGrey,
                  width: selectedDate != null ? 2 : 1,
                ),
              ),
              child: Column(
                children: [
                  Icon(
                    Icons.calendar_today_outlined,
                    size: 48,
                    color: selectedDate != null
                        ? AppColors.successColor
                        : AppColors.textSecondary(true),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    selectedDate != null
                        ? _formatDate(selectedDate!)
                        : 'Select your date of birth',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w600,
                      color: selectedDate != null
                          ? AppColors.successColor
                          : Colors.white,
                    ),
                  ),
                  if (selectedDate != null) ...[
                    const SizedBox(height: 8),
                    Text(
                      '${_calculateAge(selectedDate!)} years old',
                      style: TextStyle(
                        fontSize: 16,
                        color: AppColors.textSecondary(true),
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  ],
                  if (selectedDate == null) ...[
                    const SizedBox(height: 8),
                    Text(
                      'Tap to open calendar',
                      style: TextStyle(
                        fontSize: 14,
                        color: AppColors.textSecondary(true),
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.successColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: AppColors.successColor.withOpacity(0.3),
                width: 1,
              ),
            ),
            child: Row(
              children: [
                Icon(Icons.security, color: AppColors.successColor, size: 20),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Your personal information is securely stored and never shared',
                    style: TextStyle(
                      fontSize: 14,
                      color: AppColors.textSecondary(true),
                      fontWeight: FontWeight.w400,
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

  Widget _buildContinueButton() {
    return Container(
      width: double.infinity,
      height: 48,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        gradient: selectedDate != null
            ? LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [AppColors.successColor, AppColors.successColor],
              )
            : null,
        color: selectedDate == null ? AppColors.darkGrey : null,
      ),
      child: ElevatedButton(
        onPressed: selectedDate != null ? _continue : null,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          shadowColor: Colors.transparent,
          elevation: 0,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
        child: Text(
          'Continue',
          style: TextStyle(
            color: selectedDate != null ? Colors.white : Colors.white54,
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}
