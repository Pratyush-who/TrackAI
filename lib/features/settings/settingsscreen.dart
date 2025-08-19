import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:trackai/core/constants/appcolors.dart';
import 'package:trackai/features/onboarding/service/observices.dart';

class Settingsscreen extends StatefulWidget {
  const Settingsscreen({Key? key}) : super(key: key);

  @override
  State<Settingsscreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<Settingsscreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  Map<String, dynamic>? _onboardingData;
  bool _isLoading = true;
  bool _burnedCaloriesEnabled = false;
  bool _patternBackgroundEnabled = false;
  bool _isDarkTheme = true;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    try {
      final data = await OnboardingService.getOnboardingData();
      setState(() {
        _onboardingData = data;
        _isLoading = false;
      });
    } catch (e) {
      print('Error loading user data: $e');
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _signOut() async {
    try {
      await _auth.signOut();
      // Navigate to login screen - you'll need to implement this navigation
      // Navigator.pushNamedAndRemoveUntil(context, '/login', (route) => false);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error signing out: $e')),
      );
    }
  }

  void _navigateToPersonalDetails() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => PersonalDetailsScreen(
          onboardingData: _onboardingData,
          onDataUpdated: _loadUserData,
        ),
      ),
    );
  }

  void _navigateToAdjustGoals() {
    // Implement navigation to goals adjustment screen
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Adjust Goals feature coming soon!')),
    );
  }

  void _navigateToHelpFeedback() {
    // Implement navigation to help & feedback screen
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Help & Feedback feature coming soon!')),
    );
  }

  void _navigateToPrivacyPolicy() {
    // Implement navigation to privacy policy screen
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Privacy Policy feature coming soon!')),
    );
  }

  void _navigateToTermsOfService() {
    // Implement navigation to terms of service screen
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Terms of Service feature coming soon!')),
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: AppColors.background(_isDarkTheme),
      body: _isLoading
          ? Center(
              child: CircularProgressIndicator(
                color: AppColors.primary(_isDarkTheme),
              ),
            )
          : SingleChildScrollView(
              padding: EdgeInsets.symmetric(
                horizontal: screenWidth * 0.04,
                vertical: screenHeight * 0.02,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(height: screenHeight * 0.05),
                  _buildProfileSummaryCard(),
                  SizedBox(height: screenHeight * 0.02),
                  _buildCustomizationCard(),
                  SizedBox(height: screenHeight * 0.02),
                  _buildPreferencesCard(),
                  SizedBox(height: screenHeight * 0.02),
                  _buildSupportLegalCard(),
                  SizedBox(height: screenHeight * 0.02),
                  _buildAccountCard(),
                  SizedBox(height: screenHeight * 0.1),
                ],
              ),
            ),
    );
  }

  Widget _buildProfileSummaryCard() {
    final age = _onboardingData?['dateOfBirth'] != null
        ? OnboardingService.calculateAge(_onboardingData!['dateOfBirth'])
        : null;
    
    final isMetric = _onboardingData?['isMetric'] ?? false;
    final height = isMetric
        ? '${_onboardingData?['heightCm'] ?? 0} cm'
        : '${_onboardingData?['heightFeet'] ?? 0} ft ${_onboardingData?['heightInches'] ?? 0} in';
    
    final weight = isMetric
        ? '${_onboardingData?['weightKg'] ?? 0} kg'
        : '${_onboardingData?['weightLbs'] ?? 0} lbs';

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.cardBackground(_isDarkTheme),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppColors.darkGrey.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Profile Summary',
            style: TextStyle(
              color: AppColors.textPrimary(_isDarkTheme),
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 16),
          _buildProfileRow('Age', age?.toString() ?? 'N/A'),
          const SizedBox(height: 12),
          _buildProfileRow('Height', height),
          const SizedBox(height: 12),
          _buildProfileRowWithUnit('Current Weight', weight, isMetric),
        ],
      ),
    );
  }

  Widget _buildProfileRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            color: AppColors.textSecondary(_isDarkTheme),
            fontSize: 16,
          ),
        ),
        Text(
          value,
          style: TextStyle(
            color: AppColors.textPrimary(_isDarkTheme),
            fontSize: 16,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Widget _buildProfileRowWithUnit(String label, String value, bool isMetric) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            color: AppColors.textSecondary(_isDarkTheme),
            fontSize: 16,
          ),
        ),
        Row(
          children: [
            Text(
              value.split(' ')[0],
              style: TextStyle(
                color: AppColors.textPrimary(_isDarkTheme),
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: AppColors.primary(_isDarkTheme).withOpacity(0.2),
                borderRadius: BorderRadius.circular(6),
                border: Border.all(
                  color: AppColors.primary(_isDarkTheme),
                  width: 1,
                ),
              ),
              child: Text(
                value.split(' ')[1],
                style: TextStyle(
                  color: AppColors.primary(_isDarkTheme),
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildCustomizationCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.cardBackground(_isDarkTheme),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppColors.darkGrey.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Customization',
            style: TextStyle(
              color: AppColors.textPrimary(_isDarkTheme),
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 16),
          _buildSettingsItem(
            icon: Icons.person_outline,
            title: 'Personal details',
            onTap: _navigateToPersonalDetails,
          ),
          const SizedBox(height: 4),
          _buildSettingsItem(
            icon: Icons.track_changes_outlined,
            title: 'Adjust goals',
            subtitle: 'Calories, carbs, fats, and protein',
            onTap: _navigateToAdjustGoals,
          ),
        ],
      ),
    );
  }

  Widget _buildPreferencesCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.cardBackground(_isDarkTheme),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppColors.darkGrey.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Preferences',
            style: TextStyle(
              color: AppColors.textPrimary(_isDarkTheme),
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 16),
          _buildToggleItem(
            title: 'Burned Calories',
            subtitle: 'Add burned calories to daily goal',
            value: _burnedCaloriesEnabled,
            onChanged: (value) {
              setState(() {
                _burnedCaloriesEnabled = value;
              });
            },
          ),
          const SizedBox(height: 16),
          _buildToggleItem(
            title: 'Pattern Background',
            subtitle: 'Toggle decorative background',
            value: _patternBackgroundEnabled,
            onChanged: (value) {
              setState(() {
                _patternBackgroundEnabled = value;
              });
            },
          ),
          const SizedBox(height: 16),
          _buildThemeSelector(),
        ],
      ),
    );
  }

  Widget _buildSupportLegalCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.cardBackground(_isDarkTheme),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppColors.darkGrey.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Support & Legal',
            style: TextStyle(
              color: AppColors.textPrimary(_isDarkTheme),
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 16),
          _buildSettingsItem(
            icon: Icons.help_outline,
            title: 'Help & Feedback',
            subtitle: 'Find answers and share your thoughts',
            onTap: _navigateToHelpFeedback,
          ),
          const SizedBox(height: 4),
          _buildSettingsItem(
            icon: Icons.privacy_tip_outlined,
            title: 'Privacy Policy',
            onTap: _navigateToPrivacyPolicy,
          ),
          const SizedBox(height: 4),
          _buildSettingsItem(
            icon: Icons.description_outlined,
            title: 'Terms of Service',
            onTap: _navigateToTermsOfService,
          ),
        ],
      ),
    );
  }

  Widget _buildAccountCard() {
    final user = _auth.currentUser;
    
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.cardBackground(_isDarkTheme),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Colors.red.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Account',
            style: TextStyle(
              color: Colors.red,
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'Signed in as',
            style: TextStyle(
              color: AppColors.textSecondary(_isDarkTheme),
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            user?.email ?? 'No email',
            style: TextStyle(
              color: AppColors.textPrimary(_isDarkTheme),
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 16),
          InkWell(
            onTap: _signOut,
            borderRadius: BorderRadius.circular(8),
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.red, width: 1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(
                    Icons.logout,
                    color: Colors.red,
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  const Text(
                    'Sign out',
                    style: TextStyle(
                      color: Colors.red,
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSettingsItem({
    required IconData icon,
    required String title,
    String? subtitle,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12),
        child: Row(
          children: [
            Icon(
              icon,
              color: AppColors.primary(_isDarkTheme),
              size: 24,
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      color: AppColors.textPrimary(_isDarkTheme),
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  if (subtitle != null) ...[
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      style: TextStyle(
                        color: AppColors.textSecondary(_isDarkTheme),
                        fontSize: 14,
                      ),
                    ),
                  ],
                ],
              ),
            ),
            Icon(
              Icons.chevron_right,
              color: AppColors.textSecondary(_isDarkTheme),
              size: 24,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildToggleItem({
    required String title,
    required String subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(
                  color: AppColors.textPrimary(_isDarkTheme),
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                subtitle,
                style: TextStyle(
                  color: AppColors.textSecondary(_isDarkTheme),
                  fontSize: 14,
                ),
              ),
            ],
          ),
        ),
        Switch(
          value: value,
          onChanged: onChanged,
          activeColor: AppColors.primary(_isDarkTheme),
          inactiveThumbColor: AppColors.textSecondary(_isDarkTheme),
          inactiveTrackColor: AppColors.darkGrey,
        ),
      ],
    );
  }

  Widget _buildThemeSelector() {
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Theme',
                style: TextStyle(
                  color: AppColors.textPrimary(_isDarkTheme),
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                'Select your preferred color scheme.',
                style: TextStyle(
                  color: AppColors.textSecondary(_isDarkTheme),
                  fontSize: 14,
                ),
              ),
            ],
          ),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: AppColors.surfaceColor(_isDarkTheme),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: AppColors.darkGrey.withOpacity(0.3),
              width: 1,
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.dark_mode,
                color: AppColors.textPrimary(_isDarkTheme),
                size: 16,
              ),
              const SizedBox(width: 8),
              Text(
                'Dark',
                style: TextStyle(
                  color: AppColors.textPrimary(_isDarkTheme),
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class PersonalDetailsScreen extends StatefulWidget {
  final Map<String, dynamic>? onboardingData;
  final VoidCallback onDataUpdated;

  const PersonalDetailsScreen({
    Key? key,
    required this.onboardingData,
    required this.onDataUpdated,
  }) : super(key: key);

  @override
  State<PersonalDetailsScreen> createState() => _PersonalDetailsScreenState();
}

class _PersonalDetailsScreenState extends State<PersonalDetailsScreen> {
  late TextEditingController _heightFeetController;
  late TextEditingController _heightInchesController;
  late TextEditingController _heightCmController;
  late TextEditingController _weightLbsController;
  late TextEditingController _weightKgController;
  late TextEditingController _goalWeightController;
  
  String _selectedGender = '';
  DateTime? _selectedDateOfBirth;
  bool _isMetric = false;
  bool _isLoading = false;
  bool _isDarkTheme = true;

  @override
  void initState() {
    super.initState();
    _initializeControllers();
    _loadCurrentData();
  }

  void _initializeControllers() {
    _heightFeetController = TextEditingController();
    _heightInchesController = TextEditingController();
    _heightCmController = TextEditingController();
    _weightLbsController = TextEditingController();
    _weightKgController = TextEditingController();
    _goalWeightController = TextEditingController();
  }

  void _loadCurrentData() {
    if (widget.onboardingData != null) {
      final data = widget.onboardingData!;
      
      _selectedGender = data['gender'] ?? '';
      _selectedDateOfBirth = data['dateOfBirth'];
      _isMetric = data['isMetric'] ?? false;
      
      _heightFeetController.text = (data['heightFeet'] ?? 0).toString();
      _heightInchesController.text = (data['heightInches'] ?? 0).toString();
      _heightCmController.text = (data['heightCm'] ?? 0).toString();
      _weightLbsController.text = (data['weightLbs'] ?? 0.0).toString();
      _weightKgController.text = (data['weightKg'] ?? 0.0).toString();
      _goalWeightController.text = (data['desiredWeight'] ?? 0.0).toString();
    }
  }

  Future<void> _saveChanges() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final updates = <String, dynamic>{
        'gender': _selectedGender,
        'dateOfBirth': _selectedDateOfBirth,
        'isMetric': _isMetric,
        'heightFeet': int.tryParse(_heightFeetController.text) ?? 0,
        'heightInches': int.tryParse(_heightInchesController.text) ?? 0,
        'heightCm': int.tryParse(_heightCmController.text) ?? 0,
        'weightLbs': double.tryParse(_weightLbsController.text) ?? 0.0,
        'weightKg': double.tryParse(_weightKgController.text) ?? 0.0,
        'desiredWeight': double.tryParse(_goalWeightController.text) ?? 0.0,
      };

      await OnboardingService.updateOnboardingData(updates);
      
      widget.onDataUpdated();
      
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Personal details updated successfully!')),
      );
      
      Navigator.pop(context);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error updating details: $e')),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background(_isDarkTheme),
      appBar: AppBar(
        backgroundColor: AppColors.background(_isDarkTheme),
        elevation: 0,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back,
            color: AppColors.textPrimary(_isDarkTheme),
          ),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Personal Details',
          style: TextStyle(
            color: AppColors.textPrimary(_isDarkTheme),
            fontSize: 20,
            fontWeight: FontWeight.w600,
          ),
        ),
        actions: [
          TextButton(
            onPressed: _isLoading ? null : _saveChanges,
            child: _isLoading
                ? SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: AppColors.primary(_isDarkTheme),
                    ),
                  )
                : Text(
                    'Save',
                    style: TextStyle(
                      color: AppColors.primary(_isDarkTheme),
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            _buildGenderCard(),
            const SizedBox(height: 16),
            _buildDateOfBirthCard(),
            const SizedBox(height: 16),
            _buildUnitToggleCard(),
            const SizedBox(height: 16),
            _buildHeightCard(),
            const SizedBox(height: 16),
            _buildWeightCard(),
            const SizedBox(height: 16),
            _buildGoalWeightCard(),
          ],
        ),
      ),
    );
  }

  Widget _buildGenderCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.cardBackground(_isDarkTheme),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppColors.darkGrey.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Gender',
            style: TextStyle(
              color: AppColors.textPrimary(_isDarkTheme),
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _buildGenderOption('Male'),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildGenderOption('Female'),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildGenderOption(String gender) {
    final isSelected = _selectedGender == gender;
    
    return InkWell(
      onTap: () {
        setState(() {
          _selectedGender = gender;
        });
      },
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.primary(_isDarkTheme).withOpacity(0.2)
              : AppColors.surfaceColor(_isDarkTheme),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isSelected
                ? AppColors.primary(_isDarkTheme)
                : AppColors.darkGrey.withOpacity(0.3),
            width: 1,
          ),
        ),
        child: Center(
          child: Text(
            gender,
            style: TextStyle(
              color: isSelected
                  ? AppColors.primary(_isDarkTheme)
                  : AppColors.textPrimary(_isDarkTheme),
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDateOfBirthCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.cardBackground(_isDarkTheme),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppColors.darkGrey.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Date of Birth',
            style: TextStyle(
              color: AppColors.textPrimary(_isDarkTheme),
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 16),
          InkWell(
            onTap: () async {
              final date = await showDatePicker(
                context: context,
                initialDate: _selectedDateOfBirth ?? DateTime(2000),
                firstDate: DateTime(1900),
                lastDate: DateTime.now(),
              );
              if (date != null) {
                setState(() {
                  _selectedDateOfBirth = date;
                });
              }
            },
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.surfaceColor(_isDarkTheme),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: AppColors.darkGrey.withOpacity(0.3),
                  width: 1,
                ),
              ),
              child: Text(
                _selectedDateOfBirth != null
                    ? '${_selectedDateOfBirth!.day}/${_selectedDateOfBirth!.month}/${_selectedDateOfBirth!.year}'
                    : 'Select Date of Birth',
                style: TextStyle(
                  color: _selectedDateOfBirth != null
                      ? AppColors.textPrimary(_isDarkTheme)
                      : AppColors.textSecondary(_isDarkTheme),
                  fontSize: 16,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildUnitToggleCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.cardBackground(_isDarkTheme),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppColors.darkGrey.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              'Use Metric Units',
              style: TextStyle(
                color: AppColors.textPrimary(_isDarkTheme),
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Switch(
            value: _isMetric,
            onChanged: (value) {
              setState(() {
                _isMetric = value;
              });
            },
            activeColor: AppColors.primary(_isDarkTheme),
            inactiveThumbColor: AppColors.textSecondary(_isDarkTheme),
            inactiveTrackColor: AppColors.darkGrey,
          ),
        ],
      ),
    );
  }

  Widget _buildHeightCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.cardBackground(_isDarkTheme),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppColors.darkGrey.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Height',
            style: TextStyle(
              color: AppColors.textPrimary(_isDarkTheme),
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 16),
          if (_isMetric) ...[
            _buildTextField(
              controller: _heightCmController,
              label: 'Height (cm)',
              keyboardType: TextInputType.number,
            ),
          ] else ...[
            Row(
              children: [
                Expanded(
                  child: _buildTextField(
                    controller: _heightFeetController,
                    label: 'Feet',
                    keyboardType: TextInputType.number,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildTextField(
                    controller: _heightInchesController,
                    label: 'Inches',
                    keyboardType: TextInputType.number,
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildWeightCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.cardBackground(_isDarkTheme),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppColors.darkGrey.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Current Weight',
            style: TextStyle(
              color: AppColors.textPrimary(_isDarkTheme),
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 16),
          _buildTextField(
            controller: _isMetric ? _weightKgController : _weightLbsController,
            label: _isMetric ? 'Weight (kg)' : 'Weight (lbs)',
            keyboardType: TextInputType.numberWithOptions(decimal: true),
          ),
        ],
      ),
    );
  }

  Widget _buildGoalWeightCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.cardBackground(_isDarkTheme),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppColors.darkGrey.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Goal Weight',
            style: TextStyle(
              color: AppColors.textPrimary(_isDarkTheme),
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 16),
          _buildTextField(
            controller: _goalWeightController,
            label: _isMetric ? 'Goal Weight (kg)' : 'Goal Weight (lbs)',
            keyboardType: TextInputType.numberWithOptions(decimal: true),
          ),
        ],
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    TextInputType? keyboardType,
  }) {
    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      style: TextStyle(
        color: AppColors.textPrimary(_isDarkTheme),
        fontSize: 16,
      ),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(
          color: AppColors.textSecondary(_isDarkTheme),
          fontSize: 14,
        ),
        filled: true,
        fillColor: AppColors.inputFill(_isDarkTheme),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(
            color: AppColors.darkGrey.withOpacity(0.3),
            width: 1,
          ),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(
            color: AppColors.darkGrey.withOpacity(0.3),
            width: 1,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(
            color: AppColors.inputFocusedBorder,
            width: 2,
          ),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 16,
        ),
      ),
    );
  }

  @override
  void dispose() {
    _heightFeetController.dispose();
    _heightInchesController.dispose();
    _heightCmController.dispose();
    _weightLbsController.dispose();
    _weightKgController.dispose();
    _goalWeightController.dispose();
    super.dispose();
  }
}