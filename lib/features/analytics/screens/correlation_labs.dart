import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:trackai/core/constants/appcolors.dart';
import 'package:trackai/features/analytics/analytics_provider.dart';

class CorrelationLabsPage extends StatefulWidget {
  const CorrelationLabsPage({Key? key}) : super(key: key);

  @override
  State<CorrelationLabsPage> createState() => _CorrelationLabsPageState();
}

class _CorrelationLabsPageState extends State<CorrelationLabsPage> {
  List<String> selectedTrackers = [];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final provider = context.read<AnalyticsProvider>();
      // Initialize with available trackers that have data
      setState(() {
        selectedTrackers = [];
      });
    });
  }

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
              _buildTimeframeSelector(provider, isDark),
              const SizedBox(height: 20),
              _buildTrackerSelectionCard(provider, isDark),
              const SizedBox(height: 20),
              if (selectedTrackers.length >= 2) ...[
                _buildAnalyzeButton(provider, isDark),
                const SizedBox(height: 20),
              ],
              if (provider.isLoadingCorrelations) ...[
                _buildLoadingCard(isDark),
                const SizedBox(height: 20),
              ],
              if (provider.correlationResults.isNotEmpty &&
                  !provider.isLoadingCorrelations) ...[
                _buildCorrelationResults(provider, isDark),
                const SizedBox(height: 20),
              ],
              if (selectedTrackers.length < 2) ...[
                _buildInstructionCard(isDark),
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
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.primary(isDark).withOpacity(0.1),
            AppColors.accent(isDark).withOpacity(0.1),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppColors.primary(isDark).withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.primary(isDark).withOpacity(0.2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  Icons.scatter_plot,
                  color: AppColors.primary(isDark),
                  size: 24,
                ),
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
          const SizedBox(height: 12),
          Text(
            'Discover hidden relationships between your tracked activities. Select at least 2 trackers to analyze patterns and get AI-powered insights about how different aspects of your life influence each other.',
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

  Widget _buildTimeframeSelector(AnalyticsProvider provider, bool isDark) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.cardBackground(isDark),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppColors.primary(isDark).withOpacity(0.2),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Analysis Timeframe',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary(isDark),
            ),
          ),
          const SizedBox(height: 8),
          DropdownButtonFormField<String>(
            value: provider.selectedTimeframe,
            decoration: InputDecoration(
              filled: true,
              fillColor: AppColors.inputFill(isDark),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(
                  color: AppColors.primary(isDark).withOpacity(0.3),
                ),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(
                  color: AppColors.primary(isDark).withOpacity(0.3),
                ),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(color: AppColors.primary(isDark)),
              ),
            ),
            style: TextStyle(
              color: AppColors.textPrimary(isDark),
              fontSize: 14,
            ),
            dropdownColor: AppColors.cardBackground(isDark),
            items: provider.timeframes.map((String timeframe) {
              return DropdownMenuItem<String>(
                value: timeframe,
                child: Text(timeframe),
              );
            }).toList(),
            onChanged: (String? newValue) {
              if (newValue != null) {
                provider.setSelectedTimeframe(newValue);
              }
            },
          ),
        ],
      ),
    );
  }

  Widget _buildInstructionCard(bool isDark) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.cardBackground(isDark),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppColors.warningColor.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Column(
        children: [
          Icon(Icons.info_outline, color: AppColors.warningColor, size: 48),
          const SizedBox(height: 16),
          Text(
            'Select at least 2 trackers',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary(isDark),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Choose multiple trackers above to discover meaningful correlations and patterns in your data.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 14,
              color: AppColors.textSecondary(isDark),
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
          Row(
            children: [
              Text(
                'Select Trackers to Compare',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary(isDark),
                ),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: selectedTrackers.length >= 2
                      ? AppColors.successColor.withOpacity(0.2)
                      : AppColors.warningColor.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  '${selectedTrackers.length} selected',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: selectedTrackers.length >= 2
                        ? AppColors.successColor
                        : AppColors.warningColor,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            'Minimum 2 trackers required for correlation analysis',
            style: TextStyle(
              fontSize: 12,
              color: AppColors.textSecondary(isDark),
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
      onPressed: provider.isLoadingCorrelations
          ? null
          : () async {
              // First clear any existing selections in the provider
              for (String tracker in List.from(provider.selectedTrackers)) {
                provider.toggleTrackerSelection(tracker);
              }
              
              // Then add the new selections from the UI
              for (String tracker in selectedTrackers) {
                provider.toggleTrackerSelection(tracker);
              }

              // Analyze correlations
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
      child: provider.isLoadingCorrelations
          ? Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  'Analyzing Correlations...',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                ),
              ],
            )
          : Row(
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

  Widget _buildLoadingCard(bool isDark) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: AppColors.cardBackground(isDark),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppColors.primary(isDark).withOpacity(0.2),
          width: 1,
        ),
      ),
      child: Column(
        children: [
          CircularProgressIndicator(
            color: AppColors.primary(isDark),
            strokeWidth: 3,
          ),
          const SizedBox(height: 16),
          Text(
            'Analyzing Your Data',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary(isDark),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Our AI is discovering patterns and correlations in your tracked data...',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 14,
              color: AppColors.textSecondary(isDark),
            ),
          ),
        ],
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
                'Correlation Analysis Results',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary(isDark),
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            'Based on your ${provider.selectedTimeframe.toLowerCase()} data',
            style: TextStyle(
              fontSize: 12,
              color: AppColors.textSecondary(isDark),
            ),
          ),
          const SizedBox(height: 16),
          if (provider.correlationResults.isNotEmpty) ...[
            ...provider.correlationResults.map((correlation) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: _buildCorrelationItem(correlation, isDark),
              );
            }).toList(),
          ] else ...[
            _buildNoCorrelationsFound(isDark),
          ],
        ],
      ),
    );
  }

  // Correlation Labs Page - Improved UI

Widget _buildCorrelationItem(Map<String, dynamic> correlation, bool isDark) {
  final double correlationValue = correlation['correlation'] ?? 0.0;
  final String strength = correlation['strength'] ?? 'Very Weak';
  final String insight =
      correlation['insight'] ?? 'No specific insight available.';
  final int dataPoints = correlation['dataPoints'] ?? 0;

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

  final bool isPositive = correlationValue > 0;
  final String directionText = isPositive ? 'Positive' : 'Negative';

  return Container(
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
                  fontSize: 16,
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
        Row(
          children: [
            Text(
              'Correlation: ${correlationValue.toStringAsFixed(3)}',
              style: TextStyle(
                fontSize: 12,
                color: AppColors.textSecondary(isDark),
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(width: 12),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: isPositive
                    ? Colors.green.withOpacity(0.2)
                    : Colors.red.withOpacity(0.2),
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(
                directionText,
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w600,
                  color: isPositive ? Colors.green : Colors.red,
                ),
              ),
            ),
            const Spacer(),
            Text(
              '$dataPoints data points',
              style: TextStyle(
                fontSize: 10,
                color: AppColors.textSecondary(isDark),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: AppColors.primary(isDark).withOpacity(0.05),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: AppColors.primary(isDark).withOpacity(0.1),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(
                    Icons.analytics,
                    color: AppColors.primary(isDark),
                    size: 16,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      insight,
                      style: TextStyle(
                        fontSize: 13,
                        color: AppColors.textSecondary(isDark),
                        height: 1.4,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              if (correlation['trend'] != null)
                Text(
                  'Trend: ${correlation['trend']}',
                  style: TextStyle(
                    fontSize: 11,
                    fontStyle: FontStyle.italic,
                    color: AppColors.textSecondary(isDark),
                  ),
                ),
            ],
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
            'No Significant Correlations Found',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary(isDark),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'This could mean:\n• Your data points are independent\n• You need more data for meaningful analysis\n• Try selecting different trackers or a longer timeframe',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 12,
              color: AppColors.textSecondary(isDark),
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }
}
