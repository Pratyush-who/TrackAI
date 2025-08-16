import 'package:flutter/material.dart';
import 'package:trackai/core/constants/appcolors.dart';
import 'package:trackai/core/services/auth_services.dart';
import 'package:trackai/features/home/homepage.dart';
import 'package:trackai/features/auth/views/login_page.dart';

class AuthWrapper extends StatefulWidget {
  const AuthWrapper({Key? key}) : super(key: key);

  @override
  State<AuthWrapper> createState() => _AuthWrapperState();
}

class _AuthWrapperState extends State<AuthWrapper> with WidgetsBindingObserver {
  // Static method to force rebuild of all AuthWrapper instances
  static void forceRebuild() {
    // This will be called from outside to force a rebuild
    print('AuthWrapper: Force rebuild requested');
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      // Temporarily disabled daily logout to debug auth issues
      // print('AuthWrapper: App resumed, checking for daily logout...');
      // FirebaseService.checkAndSignOutIfNewDay();
      print('AuthWrapper: App resumed, daily logout temporarily disabled');
    }
    super.didChangeAppLifecycleState(state);
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return StreamBuilder(
      stream: FirebaseService.authStateChanges,
      builder: (context, snapshot) {
        // Show loading screen while checking authentication state
        if (snapshot.connectionState == ConnectionState.waiting) {
          print('AuthWrapper: Waiting for auth state...');
          return LoadingScreen(isDark: isDark);
        }

        // Show appropriate screen based on authentication state
        if (snapshot.hasData && snapshot.data != null) {
          print('AuthWrapper: User is authenticated, showing HomePage');
          print('AuthWrapper: User email: ${snapshot.data?.email}');
          print('AuthWrapper: User UID: ${snapshot.data?.uid}');
          return const HomePage();
        } else {
          print('AuthWrapper: User is not authenticated, showing LoginPage');
          return const LoginPage();
        }
      },
    );
  }
}

class LoadingScreen extends StatefulWidget {
  final bool isDark;
  const LoadingScreen({Key? key, required this.isDark}) : super(key: key);

  @override
  State<LoadingScreen> createState() => _LoadingScreenState();
}

class _LoadingScreenState extends State<LoadingScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _pulseAnimation;
  late Animation<double> _rotationAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(seconds: 1),
      vsync: this,
    );

    _pulseAnimation = Tween<double>(begin: 0.8, end: 1.2).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );

    _rotationAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.linear),
    );

    _animationController.repeat(reverse: true);
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: AppColors.backgroundLinearGradient(widget.isDark),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              AnimatedBuilder(
                animation: _animationController,
                builder: (context, child) {
                  return Transform.scale(
                    scale: _pulseAnimation.value,
                    child: Transform.rotate(
                      angle: _rotationAnimation.value * 2 * 3.14159,
                      child: Container(
                        width: 100,
                        height: 100,
                        decoration: BoxDecoration(
                          gradient: AppColors.primaryLinearGradient(
                            widget.isDark,
                          ),
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.primary(
                                widget.isDark,
                              ).withOpacity(0.4),
                              blurRadius: 20,
                              offset: const Offset(0, 8),
                            ),
                          ],
                        ),
                        child: Icon(
                          Icons.track_changes_outlined,
                          size: 50,
                          color: AppColors.white,
                        ),
                      ),
                    ),
                  );
                },
              ),
              const SizedBox(height: 30),
              ShaderMask(
                shaderCallback: (bounds) =>
                    AppColors.appBarGradient.createShader(bounds),
                child: Text(
                  'TrackAI',
                  style: TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: AppColors.white,
                    letterSpacing: 1.2,
                  ),
                ),
              ),
              const SizedBox(height: 20),
              CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(
                  AppColors.accent(widget.isDark),
                ),
                strokeWidth: 3,
              ),
              const SizedBox(height: 16),
              Text(
                'Loading...',
                style: TextStyle(
                  color: AppColors.textSecondary(widget.isDark),
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
