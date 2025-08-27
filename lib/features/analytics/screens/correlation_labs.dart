// correlation_labs_page.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:trackai/core/constants/appcolors.dart';
import 'package:trackai/core/provider/analytics_provider.dart';

class CorrelationLabsPage extends StatefulWidget {
  const CorrelationLabsPage({Key? key}) : super(key: key);

  @override
  State<CorrelationLabsPage> createState() => _CorrelationLabsPageState();
}

class _CorrelationLabsPageState extends State<CorrelationLabsPage> {
  List<String> selectedTrackers = [];

  @override
  Widget build(BuildContext context) {
    return Consumer<AnalyticsProvider>(
      builder: (context, provider, child) {
        final isDark = Theme.of(context).brightness == Brightness.dark;

        return SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeaderCard(isDark),
              const SizedBox(height: 20),
              _buildTrackerSelectionCard(provider, isDark),
              const SizedBox(height: 20),
              if (selectedTrackers.length >= 2) ...[
                _buildAnalyzeButton(provider, isDark),
                const SizedBox(height: 20),
              ],
              if (provider.correlationResults.isNotEmpty) ...[
                _buildCorrelationResults(provider, isDark),
                const SizedBox(height: 20),
              ],
              const SizedBox(height: 100),
            ],
          ),
        );
      },
    );
  }

  Widget _buildHeaderCard(bool isDark) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.cardBackground(isDark),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppColors.primary(isDark).withOpacity(0.2),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(isDark ? 0.2 : 0.05),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.scatter_plot,
                color: AppColors.primary(isDark),
                size: 24,
              ),
              const SizedBox(width: 12),
              Text(
                'Correlation Lab',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary(isDark),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            'Select multiple trackers to discover relationships and AI-driven insights.',
            style: TextStyle(
              fontSize: 14,
              color: AppColors.textSecondary(isDark),
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTrackerSelectionCard(AnalyticsProvider provider, bool isDark) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.cardBackground(isDark),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppColors.primary(isDark).withOpacity(0.2),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(isDark ? 0.2 : 0.05),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Select Trackers to Compare (at least 2)',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary(isDark),
            ),
          ),
          const SizedBox(height: 16),
          ...provider.availableTrackers.map((tracker) {
            final isSelected = selectedTrackers.contains(tracker);

            return Container(
              margin: const EdgeInsets.only(bottom: 8),
              decoration: BoxDecoration(
                color: isSelected
                    ? AppColors.primary(isDark).withOpacity(0.1)
                    : AppColors.surfaceColor(isDark),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: isSelected
                      ? AppColors.primary(isDark)
                      : AppColors.primary(isDark).withOpacity(0.2),
                  width: isSelected ? 2 : 1,
                ),
              ),
              child: CheckboxListTile(
                title: Text(
                  tracker,
                  style: TextStyle(
                    color: AppColors.textPrimary(isDark),
                    fontWeight: isSelected
                        ? FontWeight.w600
                        : FontWeight.normal,
                    fontSize: 14,
                  ),
                ),
                value: isSelected,
                onChanged: (bool? value) {
                  setState(() {
                    if (value == true) {
                      selectedTrackers.add(tracker);
                    } else {
                      selectedTrackers.remove(tracker);
                    }
                  });
                },
                activeColor: AppColors.primary(isDark),
                checkColor: Colors.white,
                controlAffinity: ListTileControlAffinity.trailing,
                dense: true,
              ),
            );
          }).toList(),
        ],
      ),
    );
  }

  Widget _buildAnalyzeButton(AnalyticsProvider provider, bool isDark) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: () async {
          // Set selected trackers in provider and analyze
          for (String tracker in selectedTrackers) {
            if (!provider.selectedTrackers.contains(tracker)) {
              provider.toggleTrackerSelection(tracker);
            }
          }
          await provider.loadTrackerData();
          await provider.analyzeCorrelations();
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary(isDark),
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          elevation: 4,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.analytics, color: Colors.white, size: 20),
            const SizedBox(width: 8),
            Text(
              'Analyze Correlations',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCorrelationResults(AnalyticsProvider provider, bool isDark) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.cardBackground(isDark),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppColors.primary(isDark).withOpacity(0.2),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(isDark ? 0.2 : 0.05),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.insights, color: AppColors.primary(isDark), size: 20),
              const SizedBox(width: 8),
              Text(
                'Correlation Results',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary(isDark),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ...provider.correlationResults.map((correlation) {
            return _buildCorrelationItem(correlation, isDark);
          }).toList(),
          if (provider.correlationResults.isEmpty)
            _buildNoCorrelationsFound(isDark),
        ],
      ),
    );
  }

  Widget _buildCorrelationItem(Map<String, dynamic> correlation, bool isDark) {
    final double correlationValue = correlation['correlation'] ?? 0.0;
    final String strength = correlation['strength'] ?? 'None';

    Color strengthColor;
    IconData strengthIcon;

    switch (strength) {
      case 'Strong':
        strengthColor = AppColors.successColor;
        strengthIcon = Icons.trending_up;
        break;
      case 'Moderate':
        strengthColor = AppColors.warningColor;
        strengthIcon = Icons.trending_flat;
        break;
      case 'Weak':
        strengthColor = AppColors.primary(isDark);
        strengthIcon = Icons.trending_down;
        break;
      default:
        strengthColor = AppColors.textSecondary(isDark);
        strengthIcon = Icons.remove;
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surfaceColor(isDark),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: strengthColor.withOpacity(0.3), width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  '${correlation['tracker1']} ↔ ${correlation['tracker2']}',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary(isDark),
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: strengthColor.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(strengthIcon, color: strengthColor, size: 14),
                    const SizedBox(width: 4),
                    Text(
                      strength,
                      style: TextStyle(
                        color: strengthColor,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            'Correlation coefficient: ${correlationValue.toStringAsFixed(3)}',
            style: TextStyle(
              fontSize: 12,
              color: AppColors.textSecondary(isDark),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            _getCorrelationInsight(
              correlation['tracker1'],
              correlation['tracker2'],
              strength,
            ),
            style: TextStyle(
              fontSize: 12,
              color: AppColors.textSecondary(isDark),
              height: 1.3,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNoCorrelationsFound(bool isDark) {
    return Container(
      padding: const EdgeInsets.all(24),
      alignment: Alignment.center,
      child: Column(
        children: [
          Icon(
            Icons.search_off,
            color: AppColors.textSecondary(isDark),
            size: 48,
          ),
          const SizedBox(height: 12),
          Text(
            'No Correlations Found',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary(isDark),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Try logging more data or selecting different trackers to discover meaningful relationships.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 12,
              color: AppColors.textSecondary(isDark),
              height: 1.3,
            ),
          ),
        ],
      ),
    );
  }

  String _getCorrelationInsight(
    String tracker1,
    String tracker2,
    String strength,
  ) {
    final Map<String, Map<String, String>> insights = {
      'Sleep Tracker': {
        'Mood Tracker':
            'Better sleep quality often correlates with improved mood stability.',
        'Workout Tracker':
            'Regular exercise may influence sleep patterns and quality.',
        'Study Time Tracker':
            'Sleep affects cognitive performance and study effectiveness.',
      },
      'Mood Tracker': {
        'Meditation Tracker':
            'Meditation practice can have a positive impact on emotional well-being.',
        'Exercise Tracker':
            'Physical activity is linked to improved mental health outcomes.',
        'Social Activity':
            'Social connections play a crucial role in mood regulation.',
      },
      'Workout Tracker': {
        'Weight Tracker':
            'Exercise frequency and weight changes often show clear relationships.',
        'Sleep Tracker':
            'Physical activity can improve sleep quality and duration.',
        'Energy Level':
            'Regular exercise typically correlates with higher energy levels.',
      },
    };

    final insight =
        insights[tracker1]?[tracker2] ??
        insights[tracker2]?[tracker1] ??
        'This correlation shows how these two activities may influence each other.';

    return '$strength correlation detected. $insight';
  }
}
