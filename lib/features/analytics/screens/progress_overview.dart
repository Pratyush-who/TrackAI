// progress_overview_page.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:trackai/core/constants/appcolors.dart';
import 'package:trackai/core/provider/analytics_provider.dart';

class ProgressOverviewPage extends StatefulWidget {
  const ProgressOverviewPage({Key? key}) : super(key: key);

  @override
  State<ProgressOverviewPage> createState() => _ProgressOverviewPageState();
}

class _ProgressOverviewPageState extends State<ProgressOverviewPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AnalyticsProvider>().loadProgressData();
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
              _buildNutritionCard(isDark),
              const SizedBox(height: 20),
              _buildTimeframeSelector(provider, isDark),
              const SizedBox(height: 20),
              if (provider.selectedTrackers.isNotEmpty) ...[
                ...provider.selectedTrackers.map((tracker) {
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 20),
                    child: _buildTrackerProgressCard(tracker, provider, isDark),
                  );
                }).toList(),
              ] else ...[
                _buildEmptyState(isDark),
              ],
              const SizedBox(height: 100),
            ],
          ),
        );
      },
    );
  }

  Widget _buildNutritionCard(bool isDark) {
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
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.primary(isDark).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  Icons.restaurant,
                  color: AppColors.primary(isDark),
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Text(
                'Nutrition',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary(isDark),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            'Calorie intake for:',
            style: TextStyle(
              fontSize: 14,
              color: AppColors.textSecondary(isDark),
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              _buildTimeFrameChip('This Week', true, isDark),
              const SizedBox(width: 8),
              _buildTimeFrameChip('Last Week', false, isDark),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '0',
                      style: TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary(isDark),
                      ),
                    ),
                    Text(
                      'Total calories',
                      style: TextStyle(
                        fontSize: 12,
                        color: AppColors.textSecondary(isDark),
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '0',
                      style: TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary(isDark),
                      ),
                    ),
                    Text(
                      'Daily avg.',
                      style: TextStyle(
                        fontSize: 12,
                        color: AppColors.textSecondary(isDark),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          _buildWeeklyChart(isDark),
          const SizedBox(height: 20),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.surfaceColor(isDark),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: AppColors.warningColor.withOpacity(0.3),
                width: 1,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'No macro goals set.',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary(isDark),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Set your goals to see your daily targets here.',
                  style: TextStyle(
                    fontSize: 12,
                    color: AppColors.textSecondary(isDark),
                  ),
                ),
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: const Text('Goal setting feature coming soon!'),
                          backgroundColor: AppColors.primary(isDark),
                        ),
                      );
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
                      'Set Goals Now',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
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

  Widget _buildTimeFrameChip(String label, bool isSelected, bool isDark) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: isSelected 
            ? AppColors.primary(isDark)
            : AppColors.surfaceColor(isDark),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: isSelected 
              ? AppColors.primary(isDark)
              : AppColors.primary(isDark).withOpacity(0.3),
        ),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w500,
          color: isSelected 
              ? Colors.white
              : AppColors.textSecondary(isDark),
        ),
      ),
    );
  }

  Widget _buildWeeklyChart(bool isDark) {
    return Container(
      height: 60,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          _buildDayColumn('S', 0, isDark),
          _buildDayColumn('M', 0, isDark),
          _buildDayColumn('T', 0, isDark),
          _buildDayColumn('W', 0, isDark),
          _buildDayColumn('T', 0, isDark),
          _buildDayColumn('F', 0, isDark),
          _buildDayColumn('S', 0, isDark),
        ],
      ),
    );
  }

  Widget _buildDayColumn(String day, double value, bool isDark) {
    return Column(
      children: [
        Expanded(
          child: Container(
            width: 20,
            decoration: BoxDecoration(
              color: value > 0 
                  ? AppColors.primary(isDark)
                  : AppColors.surfaceColor(isDark),
              borderRadius: BorderRadius.circular(4),
            ),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          day,
          style: TextStyle(
            fontSize: 10,
            color: AppColors.textSecondary(isDark),
          ),
        ),
        Text(
          value.toInt().toString(),
          style: TextStyle(
            fontSize: 10,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary(isDark),
          ),
        ),
      ],
    );
  }

  Widget _buildTimeframeSelector(AnalyticsProvider provider, bool isDark) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.cardBackground(isDark),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppColors.primary(isDark).withOpacity(0.3),
          width: 1,
        ),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: provider.selectedTimeframe,
          isExpanded: true,
          icon: Icon(
            Icons.keyboard_arrow_down,
            color: AppColors.primary(isDark),
          ),
          style: TextStyle(
            color: AppColors.textPrimary(isDark),
            fontSize: 14,
            fontWeight: FontWeight.w500,
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
      ),
    );
  }

  Widget _buildTrackerProgressCard(String tracker, AnalyticsProvider provider, bool isDark) {
    final progressData = provider.progressData[tracker];
    final thisWeekData = progressData?['thisWeek'] ?? [];
    final lastWeekData = progressData?['lastWeek'] ?? [];
    final average = progressData?['average'] ?? 0.0;
    final total = progressData?['total'] ?? 0;

    return Container(
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
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.primary(isDark).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  _getTrackerIcon(tracker),
                  color: AppColors.primary(isDark),
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  tracker,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary(isDark),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _buildProgressStat(
                  'This Week',
                  thisWeekData.length.toString(),
                  'entries',
                  isDark,
                ),
              ),
              Expanded(
                child: _buildProgressStat(
                  'Last Week',
                  lastWeekData.length.toString(),
                  'entries',
                  isDark,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _buildProgressStat(
                  'Total',
                  total.toString(),
                  'entries',
                  isDark,
                ),
              ),
              Expanded(
                child: _buildProgressStat(
                  'Average',
                  average.toStringAsFixed(1),
                  _getTrackerUnit(tracker),
                  isDark,
                ),
              ),
            ],
          ),
          if (thisWeekData.isNotEmpty || lastWeekData.isNotEmpty) ...[
            const SizedBox(height: 16),
            _buildProgressChart(thisWeekData, lastWeekData, isDark),
          ],
        ],
      ),
    );
  }

  Widget _buildProgressStat(String label, String value, String unit, bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: AppColors.textSecondary(isDark),
          ),
        ),
        const SizedBox(height: 4),
        RichText(
          text: TextSpan(
            text: value,
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary(isDark),
            ),
            children: [
              TextSpan(
                text: ' $unit',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.normal,
                  color: AppColors.textSecondary(isDark),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildProgressChart(List<dynamic> thisWeekData, List<dynamic> lastWeekData, bool isDark) {
    return Container(
      height: 100,
      child: BarChart(
        BarChartData(
          alignment: BarChartAlignment.spaceAround,
          maxY: 10,
          barTouchData: BarTouchData(enabled: false),
          titlesData: FlTitlesData(show: false),
          borderData: FlBorderData(show: false),
          barGroups: [
            BarChartGroupData(
              x: 0,
              barRods: [
                BarChartRodData(
                  toY: lastWeekData.length.toDouble(),
                  color: AppColors.textSecondary(isDark).withOpacity(0.5),
                  width: 16,
                  borderRadius: BorderRadius.circular(4),
                ),
              ],
            ),
            BarChartGroupData(
              x: 1,
              barRods: [
                BarChartRodData(
                  toY: thisWeekData.length.toDouble(),
                  color: AppColors.primary(isDark),
                  width: 16,
                  borderRadius: BorderRadius.circular(4),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState(bool isDark) {
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
            Icons.trending_up,
            color: AppColors.primary(isDark),
            size: 64,
          ),
          const SizedBox(height: 16),
          Text(
            'No Progress Data',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary(isDark),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Configure your dashboard with trackers to see progress overview.',
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

  IconData _getTrackerIcon(String tracker) {
    switch (tracker) {
      case 'Sleep Tracker':
        return Icons.bedtime;
      case 'Mood Tracker':
        return Icons.mood;
      case 'Meditation Tracker':
        return Icons.self_improvement;
      case 'Expense Tracker':
        return Icons.money_off;
      case 'Savings Tracker':
        return Icons.savings;
      case 'Alcohol Tracker':
        return Icons.wine_bar;
      case 'Study Time Tracker':
        return Icons.school;
      case 'Mental Well-being Tracker':
        return Icons.psychology;
      case 'Workout Tracker':
        return Icons.fitness_center;
      case 'Weight Tracker':
        return Icons.monitor_weight;
      case 'Menstrual Cycle':
        return Icons.calendar_today;
      default:
        return Icons.track_changes;
    }
  }

  String _getTrackerUnit(String tracker) {
    switch (tracker) {
      case 'Sleep Tracker':
        return 'hours';
      case 'Mood Tracker':
        return '/10';
      case 'Weight Tracker':
        return 'kg';
      case 'Study Time Tracker':
        return 'hours';
      case 'Workout Tracker':
        return 'mins';
      default:
        return 'value';
    }
  }
}