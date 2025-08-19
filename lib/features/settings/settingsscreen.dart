import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:provider/provider.dart';
import 'package:trackai/core/constants/appcolors.dart';
import 'package:trackai/core/themes/theme_provider.dart';
import 'package:trackai/features/onboarding/service/observices.dart';

class Settingsscreen extends StatefulWidget {
  const Settingsscreen({
    Key? key,
    this.onPatternBackgroundChanged,
    this.patternBackgroundEnabled = false,
  }) : super(key: key);

  final Function(bool)? onPatternBackgroundChanged;
  final bool patternBackgroundEnabled; 

  @override
  State<Settingsscreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<Settingsscreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  Map<String, dynamic>? _onboardingData;
  bool _isLoading = true;
  bool _burnedCaloriesEnabled = false;
  bool _patternBackgroundEnabled = false;

  @override
  void initState() {
    super.initState();
    _loadUserData();
    _patternBackgroundEnabled = widget.patternBackgroundEnabled;

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
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error signing out: $e')));
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
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Adjust Goals feature coming soon!')),
    );
  }

  void _navigateToHelpFeedback() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Help & Feedback feature coming soon!')),
    );
  }

  void _navigateToPrivacyPolicy() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Privacy Policy feature coming soon!')),
    );
  }

  void _navigateToTermsOfService() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Terms of Service feature coming soon!')),
    );
  }

  // Card decoration to match the design in the image
  BoxDecoration _getCardDecoration(bool isDarkTheme) {
    if (isDarkTheme) {
      return BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Color.fromRGBO(40, 50, 49, 1.0), // left/top green
            const Color.fromARGB(255, 14, 14, 14), // middle light shade
            Color.fromRGBO(33, 43, 42, 1.0), // right/bottom same green again
          ],
          begin: Alignment.topLeft, // tilt gradient
          end: Alignment.bottomRight,
          stops: const [0.0, 0.5, 1.0], // green -> dark -> green
        ),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppColors.darkPrimary.withOpacity(0.8), // subtle green border
          width: 0.5, // thin border like screenshot
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.darkPrimary.withOpacity(0.08),
            blurRadius: 8,
            spreadRadius: 1,
            offset: const Offset(0, 2),
          ),
        ],
      );
    } else {
      return BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.lightSecondary, // left/top green
            AppColors.lightSecondary, // middle light shade
            AppColors.lightSecondary, // right/bottom same green again
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          stops: const [0.0, 0.5, 1.0],
        ),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppColors.lightPrimary.withOpacity(0.6),
          width: 0.5,
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.lightPrimary.withOpacity(0.05),
            blurRadius: 6,
            spreadRadius: 1,
            offset: const Offset(0, 2),
          ),
        ],
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;
    final themeProvider = Provider.of<ThemeProvider>(context);
    final isDarkTheme = themeProvider.isDarkMode;

    return Scaffold(
      backgroundColor: AppColors.background(isDarkTheme),
      body: _isLoading
          ? Center(
              child: CircularProgressIndicator(
                color: AppColors.primary(isDarkTheme),
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
                  _buildProfileSummaryCard(isDarkTheme),
                  SizedBox(height: screenHeight * 0.02),
                  _buildCustomizationCard(isDarkTheme),
                  SizedBox(height: screenHeight * 0.02),
                  _buildPreferencesCard(isDarkTheme, themeProvider),
                  SizedBox(height: screenHeight * 0.02),
                  _buildSupportLegalCard(isDarkTheme),
                  SizedBox(height: screenHeight * 0.02),
                  _buildAccountCard(isDarkTheme),
                  SizedBox(height: screenHeight * 0.1),
                ],
              ),
            ),
    );
  }

  Widget _buildProfileSummaryCard(bool isDarkTheme) {
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
      decoration: _getCardDecoration(isDarkTheme),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Profile Summary',
            style: TextStyle(
              color: isDarkTheme ? Colors.white : Colors.black87,
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 16),
          _buildProfileRow('Age', age?.toString() ?? 'N/A', isDarkTheme),
          const SizedBox(height: 12),
          _buildProfileRow('Height', height, isDarkTheme),
          const SizedBox(height: 12),
          _buildProfileRowWithUnit(
            'Current Weight',
            weight,
            isMetric,
            isDarkTheme,
          ),
        ],
      ),
    );
  }

  Widget _buildProfileRow(String label, String value, bool isDarkTheme) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            color: isDarkTheme ? Colors.white70 : Colors.black54,
            fontSize: 16,
          ),
        ),
        Text(
          value,
          style: TextStyle(
            color: isDarkTheme ? Colors.white : Colors.black87,
            fontSize: 16,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Widget _buildProfileRowWithUnit(
    String label,
    String value,
    bool isMetric,
    bool isDarkTheme,
  ) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            color: isDarkTheme ? Colors.white70 : Colors.black54,
            fontSize: 16,
          ),
        ),
        Row(
          children: [
            Text(
              value.split(' ')[0],
              style: TextStyle(
                color: isDarkTheme ? Colors.white : Colors.black87,
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: const Color(0xFF4CAF50), // Green background for unit
                borderRadius: BorderRadius.circular(6),
              ),
              child: Text(
                value.split(' ')[1],
                style: const TextStyle(
                  color: Colors.white,
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

  Widget _buildCustomizationCard(bool isDarkTheme) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: _getCardDecoration(isDarkTheme),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Customization',
            style: TextStyle(
              color: isDarkTheme ? Colors.white : Colors.black87,
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 16),
          _buildSettingsItem(
            icon: Icons.person_outline,
            title: 'Personal details',
            onTap: _navigateToPersonalDetails,
            isDarkTheme: isDarkTheme,
          ),
          const SizedBox(height: 4),
          _buildSettingsItem(
            icon: Icons.track_changes_outlined,
            title: 'Adjust goals',
            subtitle: 'Calories, carbs, fats, and protein',
            onTap: _navigateToAdjustGoals,
            isDarkTheme: isDarkTheme,
          ),
        ],
      ),
    );
  }

  Widget _buildPreferencesCard(bool isDarkTheme, ThemeProvider themeProvider) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: _getCardDecoration(isDarkTheme),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Preferences',
            style: TextStyle(
              color: isDarkTheme ? Colors.white : Colors.black87,
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
            isDarkTheme: isDarkTheme,
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
              // Call the callback to update HomePage
              widget.onPatternBackgroundChanged?.call(value);
            },
            isDarkTheme: isDarkTheme,
          ),
          const SizedBox(height: 16),
          _buildThemeSelector(isDarkTheme, themeProvider),
        ],
      ),
    );
  }

  Widget _buildSupportLegalCard(bool isDarkTheme) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: _getCardDecoration(isDarkTheme),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Support & Legal',
            style: TextStyle(
              color: isDarkTheme ? Colors.white : Colors.black87,
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
            isDarkTheme: isDarkTheme,
          ),
          const SizedBox(height: 4),
          _buildSettingsItem(
            icon: Icons.privacy_tip_outlined,
            title: 'Privacy Policy',
            onTap: _navigateToPrivacyPolicy,
            isDarkTheme: isDarkTheme,
          ),
          const SizedBox(height: 4),
          _buildSettingsItem(
            icon: Icons.description_outlined,
            title: 'Terms of Service',
            onTap: _navigateToTermsOfService,
            isDarkTheme: isDarkTheme,
          ),
        ],
      ),
    );
  }

  Widget _buildAccountCard(bool isDarkTheme) {
    final user = _auth.currentUser;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: isDarkTheme
          ? BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  const Color.fromRGBO(40, 50, 49, 1.0), // left/top green
                  const Color.fromARGB(255, 14, 14, 14), // middle dark shade
                  const Color.fromRGBO(33, 43, 42, 1.0), // right/bottom green
                ],
                begin: Alignment.topLeft, // tilt gradient
                end: Alignment.bottomRight,
                stops: const [0.0, 0.5, 1.0],
              ),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: AppColors.darkPrimary.withOpacity(0.8),
                width: 0.5,
              ),
              boxShadow: [
                BoxShadow(
                  color: AppColors.darkPrimary.withOpacity(0.08),
                  blurRadius: 8,
                  spreadRadius: 1,
                  offset: const Offset(0, 2),
                ),
              ],
            )
          : BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  AppColors.lightSecondary,
                  AppColors.lightSecondary,
                  AppColors.lightSecondary,
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                stops: const [0.0, 0.5, 1.0],
              ),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: AppColors.lightPrimary.withOpacity(0.6),
                width: 0.5,
              ),
              boxShadow: [
                BoxShadow(
                  color: AppColors.lightPrimary.withOpacity(0.05),
                  blurRadius: 6,
                  spreadRadius: 1,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Account',
            style: TextStyle(
              color: isDarkTheme ? Colors.white : Colors.black87,
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'Signed in as',
            style: TextStyle(
              color: isDarkTheme ? Colors.white70 : Colors.black54,
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            user?.email ?? 'No email',
            style: TextStyle(
              color: isDarkTheme ? Colors.white : Colors.black87,
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
                border: Border.all(
                  color: isDarkTheme
                      ? Colors.red.withOpacity(.5)
                      : Colors.black54,
                  width: 1,
                ),
                borderRadius: BorderRadius.circular(8),
                color: isDarkTheme
                    ? Colors.white.withOpacity(0.1)
                    : Colors.black.withOpacity(0.05),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.logout,
                    color: isDarkTheme ? Colors.white : Colors.black54,
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Sign out',
                    style: TextStyle(
                      color: isDarkTheme ? Colors.white : Colors.black54,
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
    required bool isDarkTheme,
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
              color: isDarkTheme ? Colors.white : Colors.black54,
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
                      color: isDarkTheme ? Colors.white : Colors.black87,
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  if (subtitle != null) ...[
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      style: TextStyle(
                        color: isDarkTheme ? Colors.white70 : Colors.black54,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ],
              ),
            ),
            Icon(
              Icons.chevron_right,
              color: isDarkTheme ? Colors.white70 : Colors.black38,
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
    required bool isDarkTheme,
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
                  color: isDarkTheme ? Colors.white : Colors.black87,
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                subtitle,
                style: TextStyle(
                  color: isDarkTheme ? Colors.white70 : Colors.black54,
                  fontSize: 14,
                ),
              ),
            ],
          ),
        ),
        Switch(
          value: value,
          onChanged: onChanged,
          activeColor: const Color(0xFF4CAF50), // Green when active
          activeTrackColor: const Color(0xFF4CAF50).withOpacity(0.3),
          inactiveThumbColor: isDarkTheme ? Colors.white70 : Colors.black38,
          inactiveTrackColor: isDarkTheme
              ? Colors.white.withOpacity(0.2)
              : Colors.black.withOpacity(0.1),
        ),
      ],
    );
  }

  Widget _buildThemeSelector(bool isDarkTheme, ThemeProvider themeProvider) {
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Theme',
                style: TextStyle(
                  color: isDarkTheme ? Colors.white : Colors.black87,
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                'Select your preferred color scheme.',
                style: TextStyle(
                  color: isDarkTheme ? Colors.white70 : Colors.black54,
                  fontSize: 14,
                ),
              ),
            ],
          ),
        ),
        Row(
          children: [
            // Light theme button
            InkWell(
              onTap: () => themeProvider.setTheme(false),
              borderRadius: BorderRadius.circular(8),
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: !isDarkTheme
                      ? const Color(0xFF4CAF50).withOpacity(0.2)
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: !isDarkTheme
                        ? const Color(0xFF4CAF50)
                        : Colors.white.withOpacity(0.3),
                    width: 1,
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.light_mode,
                      color: !isDarkTheme
                          ? const Color(0xFF4CAF50)
                          : Colors.white70,
                      size: 16,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Light',
                      style: TextStyle(
                        color: !isDarkTheme
                            ? const Color(0xFF4CAF50)
                            : Colors.white70,
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(width: 8),
            // Dark theme button
            InkWell(
              onTap: () => themeProvider.setTheme(true),
              borderRadius: BorderRadius.circular(8),
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: isDarkTheme
                      ? const Color(0xFF4CAF50).withOpacity(0.2)
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: isDarkTheme
                        ? const Color(0xFF4CAF50)
                        : Colors.black.withOpacity(0.3),
                    width: 1,
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.dark_mode,
                      color: isDarkTheme
                          ? const Color(0xFF4CAF50)
                          : Colors.black54,
                      size: 16,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Dark',
                      style: TextStyle(
                        color: isDarkTheme
                            ? const Color(0xFF4CAF50)
                            : Colors.black54,
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
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
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error updating details: $e')));
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  // Card decoration for personal details to match main screen
  BoxDecoration _getCardDecoration(bool isDarkTheme) {
    if (isDarkTheme) {
      return BoxDecoration(
        color: const Color(
          0xFF1E1E1E,
        ).withOpacity(0.8), // Dark semi-transparent
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: const Color(0xFF404040), // Light grey border for dark theme
          width: 1,
        ),
      );
    } else {
      return BoxDecoration(
        color: Colors.white.withOpacity(0.7), // Light semi-transparent
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: const Color(0xFFE0E0E0), // Light grey border
          width: 1,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final isDarkTheme = themeProvider.isDarkMode;

    return Scaffold(
      backgroundColor: AppColors.background(isDarkTheme),
      appBar: AppBar(
        backgroundColor: AppColors.background(isDarkTheme),
        elevation: 0,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back,
            color: AppColors.textPrimary(isDarkTheme),
          ),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Personal Details',
          style: TextStyle(
            color: AppColors.textPrimary(isDarkTheme),
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
                      color: AppColors.primary(isDarkTheme),
                    ),
                  )
                : Text(
                    'Save',
                    style: TextStyle(
                      color: AppColors.primary(isDarkTheme),
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
            _buildGenderCard(isDarkTheme),
            const SizedBox(height: 16),
            _buildDateOfBirthCard(isDarkTheme),
            const SizedBox(height: 16),
            _buildUnitToggleCard(isDarkTheme),
            const SizedBox(height: 16),
            _buildHeightCard(isDarkTheme),
            const SizedBox(height: 16),
            _buildWeightCard(isDarkTheme),
            const SizedBox(height: 16),
            _buildGoalWeightCard(isDarkTheme),
          ],
        ),
      ),
    );
  }

  Widget _buildGenderCard(bool isDarkTheme) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: _getCardDecoration(isDarkTheme),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Gender',
            style: TextStyle(
              color: isDarkTheme ? Colors.white : Colors.black87,
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(child: _buildGenderOption('Male', isDarkTheme)),
              const SizedBox(width: 12),
              Expanded(child: _buildGenderOption('Female', isDarkTheme)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildGenderOption(String gender, bool isDarkTheme) {
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
              ? const Color(0xFF4CAF50).withOpacity(0.2)
              : (isDarkTheme
                    ? Colors.white.withOpacity(0.1)
                    : Colors.black.withOpacity(0.05)),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isSelected
                ? const Color(0xFF4CAF50)
                : (isDarkTheme
                      ? Colors.white.withOpacity(0.3)
                      : Colors.black.withOpacity(0.2)),
            width: 1,
          ),
        ),
        child: Center(
          child: Text(
            gender,
            style: TextStyle(
              color: isSelected
                  ? const Color(0xFF4CAF50)
                  : (isDarkTheme ? Colors.white70 : Colors.black54),
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDateOfBirthCard(bool isDarkTheme) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: _getCardDecoration(isDarkTheme),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Date of Birth',
            style: TextStyle(
              color: isDarkTheme ? Colors.white : Colors.black87,
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
                color: isDarkTheme
                    ? Colors.white.withOpacity(0.1)
                    : Colors.black.withOpacity(0.05),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: isDarkTheme
                      ? Colors.white.withOpacity(0.3)
                      : Colors.black.withOpacity(0.2),
                  width: 1,
                ),
              ),
              child: Text(
                _selectedDateOfBirth != null
                    ? '${_selectedDateOfBirth!.day}/${_selectedDateOfBirth!.month}/${_selectedDateOfBirth!.year}'
                    : 'Select Date of Birth',
                style: TextStyle(
                  color: _selectedDateOfBirth != null
                      ? (isDarkTheme ? Colors.white : Colors.black87)
                      : (isDarkTheme ? Colors.white70 : Colors.black54),
                  fontSize: 16,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildUnitToggleCard(bool isDarkTheme) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: _getCardDecoration(isDarkTheme),
      child: Row(
        children: [
          Expanded(
            child: Text(
              'Use Metric Units',
              style: TextStyle(
                color: isDarkTheme ? Colors.white : Colors.black87,
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
            activeColor: const Color(0xFF4CAF50),
            activeTrackColor: const Color(0xFF4CAF50).withOpacity(0.3),
            inactiveThumbColor: isDarkTheme ? Colors.white70 : Colors.black38,
            inactiveTrackColor: isDarkTheme
                ? Colors.white.withOpacity(0.2)
                : Colors.black.withOpacity(0.1),
          ),
        ],
      ),
    );
  }

  Widget _buildHeightCard(bool isDarkTheme) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: _getCardDecoration(isDarkTheme),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Height',
            style: TextStyle(
              color: isDarkTheme ? Colors.white : Colors.black87,
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
              isDarkTheme: isDarkTheme,
            ),
          ] else ...[
            Row(
              children: [
                Expanded(
                  child: _buildTextField(
                    controller: _heightFeetController,
                    label: 'Feet',
                    keyboardType: TextInputType.number,
                    isDarkTheme: isDarkTheme,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildTextField(
                    controller: _heightInchesController,
                    label: 'Inches',
                    keyboardType: TextInputType.number,
                    isDarkTheme: isDarkTheme,
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildWeightCard(bool isDarkTheme) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: _getCardDecoration(isDarkTheme),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Current Weight',
            style: TextStyle(
              color: isDarkTheme ? Colors.white : Colors.black87,
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 16),
          _buildTextField(
            controller: _isMetric ? _weightKgController : _weightLbsController,
            label: _isMetric ? 'Weight (kg)' : 'Weight (lbs)',
            keyboardType: TextInputType.numberWithOptions(decimal: true),
            isDarkTheme: isDarkTheme,
          ),
        ],
      ),
    );
  }

  Widget _buildGoalWeightCard(bool isDarkTheme) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: _getCardDecoration(isDarkTheme),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Goal Weight',
            style: TextStyle(
              color: isDarkTheme ? Colors.white : Colors.black87,
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 16),
          _buildTextField(
            controller: _goalWeightController,
            label: _isMetric ? 'Goal Weight (kg)' : 'Goal Weight (lbs)',
            keyboardType: TextInputType.numberWithOptions(decimal: true),
            isDarkTheme: isDarkTheme,
          ),
        ],
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    TextInputType? keyboardType,
    required bool isDarkTheme,
  }) {
    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      style: TextStyle(
        color: isDarkTheme ? Colors.white : Colors.black87,
        fontSize: 16,
      ),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(
          color: isDarkTheme ? Colors.white70 : Colors.black54,
          fontSize: 14,
        ),
        filled: true,
        fillColor: isDarkTheme
            ? Colors.white.withOpacity(0.1)
            : Colors.black.withOpacity(0.05),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(
            color: isDarkTheme
                ? Colors.white.withOpacity(0.3)
                : Colors.black.withOpacity(0.2),
            width: 1,
          ),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(
            color: isDarkTheme
                ? Colors.white.withOpacity(0.3)
                : Colors.black.withOpacity(0.2),
            width: 1,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: const Color(0xFF4CAF50), width: 2),
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
