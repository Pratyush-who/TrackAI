import 'package:flutter/material.dart';
import 'package:trackai/core/constants/appcolors.dart';

class DesiredWeightPage extends StatefulWidget {
  final VoidCallback onNext;
  final VoidCallback onBack;
  final Function(double) onDataUpdate;
  final bool isMetric;

  const DesiredWeightPage({
    Key? key,
    required this.onNext,
    required this.onBack,
    required this.onDataUpdate,
    required this.isMetric,
  }) : super(key: key);

  @override
  State<DesiredWeightPage> createState() => _DesiredWeightPageState();
}

class _DesiredWeightPageState extends State<DesiredWeightPage>
    with TickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  double desiredWeight = 110;
  double desiredWeightKg = 50;

  @override
  void initState() {
    super.initState();
    
    // Initialize based on metric/imperial preference
    if (widget.isMetric) {
      desiredWeightKg = 50;
      desiredWeight = desiredWeightKg / 0.453592;
    } else {
      desiredWeight = 110;
      desiredWeightKg = desiredWeight * 0.453592;
    }
    
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

  void _updateWeight(double value) {
    setState(() {
      if (widget.isMetric) {
        desiredWeightKg = value;
        desiredWeight = desiredWeightKg / 0.453592;
      } else {
        desiredWeight = value;
        desiredWeightKg = desiredWeight * 0.453592;
      }
    });
    widget.onDataUpdate(widget.isMetric ? desiredWeightKg : desiredWeight);
  }

  void _continue() {
    widget.onNext();
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
                  _buildWeightSlider(),
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
          'What\'s your target weight?',
          style: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.w700,
            color: Colors.white,
            letterSpacing: -0.5,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Set your desired weight to help us create a personalized plan',
          style: TextStyle(
            fontSize: 16,
            color: AppColors.textSecondary(true),
            fontWeight: FontWeight.w400,
          ),
        ),
      ],
    );
  }

  Widget _buildWeightSlider() {
    return Center(
      child: Column(
        children: [
          Container(
            width: 200,
            height: 200,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  AppColors.successColor.withOpacity(0.1),
                  AppColors.successColor.withOpacity(0.3),
                ],
              ),
              border: Border.all(
                color: AppColors.successColor,
                width: 3,
              ),
            ),
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    widget.isMetric 
                        ? '${desiredWeightKg.round()}'
                        : '${desiredWeight.round()}',
                    style: TextStyle(
                      fontSize: 48,
                      fontWeight: FontWeight.w700,
                      color: AppColors.successColor,
                    ),
                  ),
                  Text(
                    widget.isMetric ? 'kg' : 'lbs',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textSecondary(true),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 40),
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: AppColors.cardBackground(true).withOpacity(0.8),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.darkGrey, width: 1),
            ),
            child: Column(
              children: [
                                  Text(
                  'Adjust your target weight',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 20),
                SliderTheme(
                  data: SliderThemeData(
                    trackHeight: 8,
                    thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 16),
                    overlayShape: const RoundSliderOverlayShape(overlayRadius: 24),
                    activeTrackColor: AppColors.successColor,
                    inactiveTrackColor: AppColors.darkGrey,
                    thumbColor: AppColors.successColor,
                    overlayColor: AppColors.successColor.withOpacity(0.3),
                    valueIndicatorShape: const PaddleSliderValueIndicatorShape(),
                    valueIndicatorColor: AppColors.successColor,
                    valueIndicatorTextStyle: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                    ),
                    showValueIndicator: ShowValueIndicator.always,
                  ),
                  child: Slider(
                    value: widget.isMetric ? desiredWeightKg : desiredWeight,
                    min: widget.isMetric ? 30 : 66,
                    max: widget.isMetric ? 200 : 440,
                    divisions: widget.isMetric ? 170 : 374,
                    label: widget.isMetric 
                        ? '${desiredWeightKg.round()} kg'
                        : '${desiredWeight.round()} lbs',
                    onChanged: _updateWeight,
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      widget.isMetric ? '30 kg' : '66 lbs',
                      style: TextStyle(
                        fontSize: 12,
                        color: AppColors.textSecondary(true),
                      ),
                    ),
                    Text(
                      widget.isMetric ? '200 kg' : '440 lbs',
                      style: TextStyle(
                        fontSize: 12,
                        color: AppColors.textSecondary(true),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.successColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.successColor.withOpacity(0.3), width: 1),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.lightbulb_outline,
                  color: AppColors.successColor,
                  size: 20,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Tip: Aim for a healthy and realistic target weight for the best results',
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
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [AppColors.successColor, AppColors.successColor],
        ),
      ),
      child: ElevatedButton(
        onPressed: _continue,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          shadowColor: Colors.transparent,
          elevation: 0,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
        child: const Text(
          'Continue',
          style: TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}