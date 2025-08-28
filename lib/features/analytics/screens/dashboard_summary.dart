// dashboard_summary_page.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:trackai/core/constants/appcolors.dart';
import 'package:trackai/features/analytics/analytics_provider.dart';

class DashboardSummaryPage extends StatefulWidget {
  const DashboardSummaryPage({Key? key}) : super(key: key);

  @override
  State<DashboardSummaryPage> createState() => _DashboardSummaryPageState();
}

class _DashboardSummaryPageState extends State<DashboardSummaryPage> {
  @override
  void initState() {
    super.initState();
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
              _buildConfigureButton(context, provider, isDark),
              const SizedBox(height: 20),
              if (provider.selectedTrackers.isNotEmpty) ...[
                _buildCustomDashboardSection(context, provider, isDark),
                const SizedBox(height: 24),
                _buildOverallSummaryCard(context, provider, isDark),
                const SizedBox(height: 24),
                _buildBMICalculator(context, provider, isDark),
              ] else ...[
                _buildEmptyState(context, isDark),
              ],
              const SizedBox(height: 100), // Bottom padding for FAB
            ],
          ),
        );
      },
    );
  }

  Widget _buildConfigureButton(
    BuildContext context,
    AnalyticsProvider provider,
    bool isDark,
  ) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: AppColors.cardBackground(isDark),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppColors.primary(isDark).withOpacity(0.3),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(isDark ? 0.3 : 0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: InkWell(
        onTap: () => _showConfigureDashboard(context, provider, isDark),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Icon(Icons.tune, color: AppColors.primary(isDark), size: 24),
              const SizedBox(width: 12),
              Text(
                'Configure Dashboard',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary(isDark),
                ),
              ),
              const Spacer(),
              Icon(
                Icons.arrow_forward_ios,
                color: AppColors.textSecondary(isDark),
                size: 16,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context, bool isDark) {
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
          Icon(
            Icons.analytics_outlined,
            color: AppColors.primary(isDark),
            size: 64,
          ),
          const SizedBox(height: 16),
          Text(
            'No Trackers Selected',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary(isDark),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Configure your dashboard to see analytics from your selected trackers.',
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

  Widget _buildCustomDashboardSection(
    BuildContext context,
    AnalyticsProvider provider,
    bool isDark,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(Icons.dashboard, color: AppColors.primary(isDark), size: 20),
            const SizedBox(width: 8),
            Text(
              'Custom Dashboard Trackers',
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
          'Displaying charts for your selected trackers (up to 4). Log more data to see trends.',
          style: TextStyle(
            fontSize: 12,
            color: AppColors.textSecondary(isDark),
          ),
        ),
        Text(
          'You can select up to 4 more trackers!',
          style: TextStyle(
            fontSize: 12,
            color: AppColors.textSecondary(isDark),
          ),
        ),
        const SizedBox(height: 16),
        ...provider.selectedTrackers.take(4).map((tracker) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 16),
            child: _buildTrackerChart(
              context,
              tracker,
              provider.trackerData[tracker] ?? [],
              isDark,
            ),
          );
        }).toList(),
      ],
    );
  }

  Widget _buildTrackerChart(
    BuildContext context,
    String trackerName,
    List<Map<String, dynamic>> data,
    bool isDark,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.cardBackground(isDark),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppColors.primary(isDark).withOpacity(0.2),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(isDark ? 0.2 : 0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 8,
                height: 8,
                decoration: BoxDecoration(
                  color: AppColors.primary(isDark),
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 8),
              Text(
                trackerName,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary(isDark),
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            _getTrackerUnit(trackerName),
            style: TextStyle(
              fontSize: 12,
              color: AppColors.textSecondary(isDark),
            ),
          ),
          const SizedBox(height: 16),
          if (data.isNotEmpty)
            SizedBox(
              height: 120,
              child: LineChart(
                LineChartData(
                  gridData: FlGridData(
                    show: true,
                    drawVerticalLine: false,
                    horizontalInterval: 1,
                    getDrawingHorizontalLine: (value) {
                      return FlLine(
                        color: AppColors.textSecondary(isDark).withOpacity(0.2),
                        strokeWidth: 1,
                      );
                    },
                  ),
                  titlesData: FlTitlesData(show: false),
                  borderData: FlBorderData(show: false),
                  lineBarsData: [
                    LineChartBarData(
                      spots: _generateChartData(data),
                      isCurved: true,
                      color: AppColors.primary(isDark),
                      barWidth: 3,
                      dotData: FlDotData(
                        show: true,
                        getDotPainter: (spot, percent, barData, index) {
                          return FlDotCirclePainter(
                            radius: 4,
                            color: AppColors.primary(isDark),
                            strokeWidth: 2,
                            strokeColor: AppColors.cardBackground(isDark),
                          );
                        },
                      ),
                      belowBarData: BarAreaData(
                        show: true,
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            AppColors.primary(isDark).withOpacity(0.3),
                            AppColors.primary(isDark).withOpacity(0.0),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            )
          else
            Container(
              height: 120,
              alignment: Alignment.center,
              child: Text(
                'No data logged for this tracker yet.',
                style: TextStyle(
                  color: AppColors.textSecondary(isDark),
                  fontSize: 12,
                ),
              ),
            ),
        ],
      ),
    );
  }

  List<FlSpot> _generateChartData(List<Map<String, dynamic>> data) {
    if (data.isEmpty) return [];

    final spots = <FlSpot>[];
    for (int i = 0; i < data.length && i < 7; i++) {
      final value = double.tryParse(data[i]['value']?.toString() ?? '0') ?? 0.0;
      spots.add(FlSpot(i.toDouble(), value));
    }
    return spots;
  }

  String _getTrackerUnit(String trackerName) {
    switch (trackerName) {
      case 'Sleep Tracker':
        return 'Trend over time. Unit: hours';
      case 'Mood Tracker':
        return 'Unit: 1-10 scale';
      case 'Weight Tracker':
        return 'Unit: kg';
      case 'Study Time Tracker':
        return 'Unit: hours';
      case 'Workout Tracker':
        return 'Unit: minutes';
      default:
        return 'Trend over time';
    }
  }

  Widget _buildOverallSummaryCard(
    BuildContext context,
    AnalyticsProvider provider,
    bool isDark,
  ) {
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
              Icon(Icons.summarize, color: AppColors.primary(isDark), size: 20),
              const SizedBox(width: 8),
              Text(
                'Overall Summary',
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
            'Key insights from your tracked activities over the past month.',
            style: TextStyle(
              fontSize: 12,
              color: AppColors.textSecondary(isDark),
            ),
          ),
          const SizedBox(height: 16),
          if (provider.isLoadingSummary)
            Center(
              child: CircularProgressIndicator(
                color: AppColors.primary(isDark),
                strokeWidth: 2,
              ),
            )
          else if (provider.overallSummary.isNotEmpty)
            _buildSummaryContent(provider.overallSummary, isDark)
          else
            _buildDefaultSummary(isDark),
        ],
      ),
    );
  }

  Widget _buildSummaryContent(String summary, bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSummaryInsight(
          'Positive Trend',
          'Your average mood has slightly improved by 5% compared to the previous month. Keep up the great work!',
          AppColors.successColor,
          isDark,
        ),
        const SizedBox(height: 12),
        _buildSummaryInsight(
          'Area for Focus',
          'Sleep consistency varies, with an average deviation of 1.5 hours from your target. Consider setting a more regular sleep schedule.',
          AppColors.warningColor,
          isDark,
        ),
        const SizedBox(height: 12),
        _buildSummaryInsight(
          'Activity Peak',
          'Your most active days are typically Saturdays, with an average of 45,000 steps.',
          AppColors.primary(isDark),
          isDark,
        ),
      ],
    );
  }

  Widget _buildDefaultSummary(bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSummaryInsight(
          'Getting Started',
          'Start logging data consistently to see personalized insights here.',
          AppColors.primary(isDark),
          isDark,
        ),
      ],
    );
  }

  Widget _buildSummaryInsight(
    String title,
    String description,
    Color color,
    bool isDark,
  ) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 4,
          height: 4,
          margin: const EdgeInsets.only(top: 6),
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: color,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                description,
                style: TextStyle(
                  fontSize: 12,
                  color: AppColors.textSecondary(isDark),
                  height: 1.3,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildBMICalculator(
    BuildContext context,
    AnalyticsProvider provider,
    bool isDark,
  ) {
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
                'BMI Categories & Calculator',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary(isDark),
                ),
              ),
              const SizedBox(width: 8),
              Icon(
                Icons.info_outline,
                color: AppColors.textSecondary(isDark),
                size: 16,
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            'Body Mass Index (BMI) is a general indicator of body fatness.',
            style: TextStyle(
              fontSize: 12,
              color: AppColors.textSecondary(isDark),
            ),
          ),
          const SizedBox(height: 16),
          _buildBMIScale(provider.currentBMI, isDark),
          const SizedBox(height: 20),
          _buildBMICalculatorForm(provider, isDark),
        ],
      ),
    );
  }

  Widget _buildBMIScale(double? currentBMI, bool isDark) {
    return Column(
      children: [
        Container(
          height: 20,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            gradient: const LinearGradient(
              colors: [Colors.blue, Colors.green, Colors.orange, Colors.red],
            ),
          ),
          child: currentBMI != null ? _buildBMIIndicator(currentBMI) : null,
        ),
        const SizedBox(height: 12),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            _buildBMICategory('Underweight', isDark),
            _buildBMICategory('Healthy', isDark),
            _buildBMICategory('Overweight', isDark),
            _buildBMICategory('Obese', isDark),
          ],
        ),
        if (currentBMI != null) ...[
          const SizedBox(height: 8),
          Text(
            'Your BMI: ${currentBMI.toStringAsFixed(1)}',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: AppColors.primary(isDark),
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildBMIIndicator(double bmi) {
    double position = 0.0;
    Color indicatorColor = Colors.blue;

    if (bmi < 18.5) {
      position = (bmi / 18.5) * 0.25; // Underweight range
      indicatorColor = Colors.blue;
    } else if (bmi < 25) {
      position = 0.25 + ((bmi - 18.5) / 6.5) * 0.25; // Healthy range
      indicatorColor = Colors.green;
    } else if (bmi < 30) {
      position = 0.5 + ((bmi - 25) / 5) * 0.25; // Overweight range
      indicatorColor = Colors.orange;
    } else {
      position = 0.75 + ((bmi - 30) / 10) * 0.25; // Obese range
      indicatorColor = Colors.red;
    }

    return Align(
      alignment: Alignment(position * 2 - 1, 0), // Convert to -1 to 1 range
      child: Container(
        width: 4,
        height: 20,
        decoration: BoxDecoration(
          color: indicatorColor,
          borderRadius: BorderRadius.circular(2),
          boxShadow: [
            BoxShadow(
              color: indicatorColor.withOpacity(0.5),
              blurRadius: 4,
              offset: const Offset(0, 0),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBMICategory(String category, bool isDark) {
    return Text(
      category,
      style: TextStyle(
        fontSize: 10,
        fontWeight: FontWeight.w500,
        color: AppColors.textSecondary(isDark),
      ),
    );
  }

  Widget _buildBMICalculatorForm(AnalyticsProvider provider, bool isDark) {
    return Consumer<AnalyticsProvider>(
      builder: (context, provider, child) {
        return Column(
          children: [
            Row(
              children: [
                Icon(
                  Icons.calculate,
                  color: AppColors.primary(isDark),
                  size: 20,
                ),
                const SizedBox(width: 8),
                Text(
                  'Calculate Your BMI',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary(isDark),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Height Unit',
                        style: TextStyle(
                          fontSize: 12,
                          color: AppColors.textSecondary(isDark),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.inputFill(isDark),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: AppColors.primary(isDark).withOpacity(0.3),
                          ),
                        ),
                        child: DropdownButtonHideUnderline(
                          child: DropdownButton<String>(
                            value: provider.heightUnit,
                            isExpanded: true,
                            style: TextStyle(
                              color: AppColors.textPrimary(isDark),
                              fontSize: 12,
                            ),
                            items: ['Centimeters (cm)', 'Feet & Inches (ft/in)']
                                .map((String value) {
                                  return DropdownMenuItem<String>(
                                    value: value,
                                    child: Text(value),
                                  );
                                })
                                .toList(),
                            onChanged: (String? newValue) {
                              if (newValue != null) {
                                provider.setHeightUnit(newValue);
                              }
                            },
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                if (provider.heightUnit == 'Centimeters (cm)')
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Your Height (cm)',
                          style: TextStyle(
                            fontSize: 12,
                            color: AppColors.textSecondary(isDark),
                          ),
                        ),
                        const SizedBox(height: 4),
                        TextFormField(
                          controller: provider.heightCmController,
                          keyboardType: TextInputType.number,
                          decoration: InputDecoration(
                            hintText: 'E.g., 170',
                            hintStyle: TextStyle(
                              color: AppColors.textSecondary(isDark),
                              fontSize: 12,
                            ),
                            filled: true,
                            fillColor: AppColors.inputFill(isDark),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                              borderSide: BorderSide(
                                color: AppColors.primary(
                                  isDark,
                                ).withOpacity(0.3),
                              ),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                              borderSide: BorderSide(
                                color: AppColors.primary(
                                  isDark,
                                ).withOpacity(0.3),
                              ),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                              borderSide: BorderSide(
                                color: AppColors.primary(isDark),
                              ),
                            ),
                          ),
                          style: TextStyle(
                            color: AppColors.textPrimary(isDark),
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  )
                else
                  Expanded(
                    child: Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Feet',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: AppColors.textSecondary(isDark),
                                ),
                              ),
                              const SizedBox(height: 4),
                              TextFormField(
                                controller: provider.heightFeetController,
                                keyboardType: TextInputType.number,
                                decoration: InputDecoration(
                                  hintText: '5',
                                  hintStyle: TextStyle(
                                    color: AppColors.textSecondary(isDark),
                                    fontSize: 12,
                                  ),
                                  filled: true,
                                  fillColor: AppColors.inputFill(isDark),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(8),
                                    borderSide: BorderSide(
                                      color: AppColors.primary(
                                        isDark,
                                      ).withOpacity(0.3),
                                    ),
                                  ),
                                  enabledBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(8),
                                    borderSide: BorderSide(
                                      color: AppColors.primary(
                                        isDark,
                                      ).withOpacity(0.3),
                                    ),
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(8),
                                    borderSide: BorderSide(
                                      color: AppColors.primary(isDark),
                                    ),
                                  ),
                                ),
                                style: TextStyle(
                                  color: AppColors.textPrimary(isDark),
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Inches',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: AppColors.textSecondary(isDark),
                                ),
                              ),
                              const SizedBox(height: 4),
                              TextFormField(
                                controller: provider.heightInchesController,
                                keyboardType: TextInputType.number,
                                decoration: InputDecoration(
                                  hintText: '6',
                                  hintStyle: TextStyle(
                                    color: AppColors.textSecondary(isDark),
                                    fontSize: 12,
                                  ),
                                  filled: true,
                                  fillColor: AppColors.inputFill(isDark),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(8),
                                    borderSide: BorderSide(
                                      color: AppColors.primary(
                                        isDark,
                                      ).withOpacity(0.3),
                                    ),
                                  ),
                                  enabledBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(8),
                                    borderSide: BorderSide(
                                      color: AppColors.primary(
                                        isDark,
                                      ).withOpacity(0.3),
                                    ),
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(8),
                                    borderSide: BorderSide(
                                      color: AppColors.primary(isDark),
                                    ),
                                  ),
                                ),
                                style: TextStyle(
                                  color: AppColors.textPrimary(isDark),
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Weight Unit',
                        style: TextStyle(
                          fontSize: 12,
                          color: AppColors.textSecondary(isDark),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.inputFill(isDark),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: AppColors.primary(isDark).withOpacity(0.3),
                          ),
                        ),
                        child: DropdownButtonHideUnderline(
                          child: DropdownButton<String>(
                            value: provider.weightUnit,
                            isExpanded: true,
                            style: TextStyle(
                              color: AppColors.textPrimary(isDark),
                              fontSize: 12,
                            ),
                            items: ['Kilograms (kg)', 'Pounds (lbs)'].map((
                              String value,
                            ) {
                              return DropdownMenuItem<String>(
                                value: value,
                                child: Text(value),
                              );
                            }).toList(),
                            onChanged: (String? newValue) {
                              if (newValue != null) {
                                provider.setWeightUnit(newValue);
                              }
                            },
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Your Weight (${provider.weightUnit == 'Kilograms (kg)' ? 'kg' : 'lbs'})',
                        style: TextStyle(
                          fontSize: 12,
                          color: AppColors.textSecondary(isDark),
                        ),
                      ),
                      const SizedBox(height: 4),
                      TextFormField(
                        controller: provider.weightController,
                        keyboardType: TextInputType.number,
                        decoration: InputDecoration(
                          hintText: provider.weightUnit == 'Kilograms (kg)'
                              ? 'E.g., 65'
                              : 'E.g., 143',
                          hintStyle: TextStyle(
                            color: AppColors.textSecondary(isDark),
                            fontSize: 12,
                          ),
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
                            borderSide: BorderSide(
                              color: AppColors.primary(isDark),
                            ),
                          ),
                        ),
                        style: TextStyle(
                          color: AppColors.textPrimary(isDark),
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () async {
                  final result = await provider.calculateBMI();
                  if (result != null) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          'BMI calculated: ${result.toStringAsFixed(1)}',
                        ),
                        backgroundColor: AppColors.successColor,
                      ),
                    );
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: const Text(
                          'Please enter valid height and weight values',
                        ),
                        backgroundColor: AppColors.errorColor,
                      ),
                    );
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary(isDark),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: const Text(
                  'Calculate My BMI',
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  void _showConfigureDashboard(
    BuildContext context,
    AnalyticsProvider provider,
    bool isDark,
  ) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => Container(
          height: MediaQuery.of(context).size.height * 0.7,
          decoration: BoxDecoration(
            color: AppColors.cardBackground(isDark),
            borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: Column(
            children: [
              Container(
                width: 40,
                height: 4,
                margin: const EdgeInsets.symmetric(vertical: 12),
                decoration: BoxDecoration(
                  color: AppColors.textSecondary(isDark),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Row(
                  children: [
                    Text(
                      'Configure Dashboard',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary(isDark),
                      ),
                    ),
                    const Spacer(),
                    Text(
                      '${provider.selectedTrackers.length} selected',
                      style: TextStyle(
                        fontSize: 14,
                        color: AppColors.textSecondary(isDark),
                      ),
                    ),
                    const SizedBox(width: 8),
                    TextButton(
                      onPressed: () {
                        // Reload data after configuration changes
                        if (provider.selectedTrackers.isNotEmpty) {
                          provider.loadTrackerData();
                          provider.generateOverallSummary();
                        }
                        Navigator.pop(context);
                      },
                      child: Text(
                        'Done',
                        style: TextStyle(
                          color: AppColors.primary(isDark),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  itemCount: provider.availableTrackers.length,
                  itemBuilder: (context, index) {
                    final tracker = provider.availableTrackers[index];
                    final isSelected = provider.selectedTrackers.contains(
                      tracker,
                    );

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
                          ),
                        ),
                        value: isSelected,
                        onChanged: (bool? value) {
                          provider.toggleTrackerSelection(tracker);
                          setState(() {}); // Update the UI immediately
                        },
                        activeColor: AppColors.primary(isDark),
                        checkColor: Colors.white,
                        controlAffinity: ListTileControlAffinity.trailing,
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
