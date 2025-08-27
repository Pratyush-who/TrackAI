// period_cycle_page.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:trackai/core/constants/appcolors.dart';
import 'package:trackai/core/provider/analytics_provider.dart';

class PeriodCyclePage extends StatefulWidget {
  const PeriodCyclePage({Key? key}) : super(key: key);

  @override
  State<PeriodCyclePage> createState() => _PeriodCyclePageState();
}

class _PeriodCyclePageState extends State<PeriodCyclePage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final provider = context.read<AnalyticsProvider>();
      provider.toggleTrackerSelection('Menstrual Cycle');
      provider.loadPeriodData();
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
              _buildLogYourCycleCard(isDark),
              const SizedBox(height: 20),
              _buildHormoneCycleOverview(provider, isDark),
              const SizedBox(height: 20),
              _buildUnderstandingHormones(isDark),
              const SizedBox(height: 20),
              _buildCyclePhases(isDark),
              const SizedBox(height: 100),
            ],
          ),
        );
      },
    );
  }

  Widget _buildLogYourCycleCard(bool isDark) {
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
              Icon(
                Icons.calendar_today,
                color: AppColors.primary(isDark),
                size: 24,
              ),
              const SizedBox(width: 12),
              Text(
                'Log Your Cycle',
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
            'Track your menstrual cycle to predict dates, identify patterns, and understand your body better. Log your period start date and symptoms to get personalized insights.',
            style: TextStyle(
              fontSize: 14,
              color: AppColors.textSecondary(isDark),
              height: 1.4,
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: const Text('Period logging feature coming soon!'),
                    backgroundColor: AppColors.primary(isDark),
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary(isDark),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text(
                'Log Your Cycle',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHormoneCycleOverview(AnalyticsProvider provider, bool isDark) {
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
                Icons.show_chart,
                color: AppColors.primary(isDark),
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                'Hormone Cycle Overview',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary(isDark),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _buildHormoneChart(isDark),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildHormoneLegend('FSH', const Color(0xFF4CAF50), isDark),
              _buildHormoneLegend('LH', const Color(0xFF2196F3), isDark),
              _buildHormoneLegend('Estrogen', const Color(0xFFFF9800), isDark),
              _buildHormoneLegend('Progesterone', const Color(0xFF9C27B0), isDark),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildHormoneChart(bool isDark) {
    return Container(
      height: 200,
      child: LineChart(
        LineChartData(
          gridData: FlGridData(
            show: true,
            drawVerticalLine: true,
            horizontalInterval: 1,
            verticalInterval: 7,
            getDrawingHorizontalLine: (value) {
              return FlLine(
                color: AppColors.textSecondary(isDark).withOpacity(0.2),
                strokeWidth: 1,
              );
            },
            getDrawingVerticalLine: (value) {
              return FlLine(
                color: AppColors.textSecondary(isDark).withOpacity(0.2),
                strokeWidth: 1,
              );
            },
          ),
          titlesData: FlTitlesData(
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                getTitlesWidget: (value, meta) {
                  const days = ['1', '7', '14', '21', '28'];
                  if (value.toInt() < days.length) {
                    return Text(
                      days[value.toInt()],
                      style: TextStyle(
                        color: AppColors.textSecondary(isDark),
                        fontSize: 12,
                      ),
                    );
                  }
                  return const Text('');
                },
                interval: 7,
              ),
            ),
            leftTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
            topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
            rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
          ),
          borderData: FlBorderData(show: false),
          lineBarsData: [
            // FSH
            LineChartBarData(
              spots: [
                FlSpot(0, 4),
                FlSpot(7, 2),
                FlSpot(14, 6),
                FlSpot(21, 3),
                FlSpot(28, 4),
              ],
              isCurved: true,
              color: const Color(0xFF4CAF50),
              barWidth: 2,
              dotData: FlDotData(show: false),
            ),
            // LH
            LineChartBarData(
              spots: [
                FlSpot(0, 2),
                FlSpot(7, 1.5),
                FlSpot(14, 8),
                FlSpot(21, 2),
                FlSpot(28, 2),
              ],
              isCurved: true,
              color: const Color(0xFF2196F3),
              barWidth: 2,
              dotData: FlDotData(show: false),
            ),
            // Estrogen
            LineChartBarData(
              spots: [
                FlSpot(0, 1),
                FlSpot(7, 3),
                FlSpot(14, 7),
                FlSpot(21, 4),
                FlSpot(28, 1.5),
              ],
              isCurved: true,
              color: const Color(0xFFFF9800),
              barWidth: 2,
              dotData: FlDotData(show: false),
            ),
            // Progesterone
            LineChartBarData(
              spots: [
                FlSpot(0, 1),
                FlSpot(7, 1),
                FlSpot(14, 2),
                FlSpot(21, 6),
                FlSpot(28, 1.5),
              ],
              isCurved: true,
              color: const Color(0xFF9C27B0),
              barWidth: 2,
              dotData: FlDotData(show: false),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHormoneLegend(String name, Color color, bool isDark) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 12,
          height: 2,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(1),
          ),
        ),
        const SizedBox(width: 4),
        Text(
          name,
          style: TextStyle(
            fontSize: 10,
            color: AppColors.textSecondary(isDark),
          ),
        ),
      ],
    );
  }

  Widget _buildUnderstandingHormones(bool isDark) {
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
                Icons.psychology,
                color: AppColors.primary(isDark),
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                'Understanding Your Hormones',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary(isDark),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _buildHormoneInfo('FSH', 'Follicle Stimulating Hormone', 
              'Stimulates follicle development in ovaries', const Color(0xFF4CAF50), isDark),
          const SizedBox(height: 12),
          _buildHormoneInfo('LH', 'Luteinizing Hormone', 
              'Triggers ovulation around day 14', const Color(0xFF2196F3), isDark),
          const SizedBox(height: 12),
          _buildHormoneInfo('Estrogen', 'Primary Female Sex Hormone', 
              'Peaks before ovulation, affects mood and energy', const Color(0xFFFF9800), isDark),
          const SizedBox(height: 12),
          _buildHormoneInfo('Progesterone', 'Pregnancy Hormone', 
              'Rises after ovulation, prepares uterus for pregnancy', const Color(0xFF9C27B0), isDark),
        ],
      ),
    );
  }

  Widget _buildHormoneInfo(String shortName, String fullName, String description, Color color, bool isDark) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 4,
          height: 4,
          margin: const EdgeInsets.only(top: 6),
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              RichText(
                text: TextSpan(
                  text: '$shortName ',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: color,
                  ),
                  children: [
                    TextSpan(
                      text: '($fullName)',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.normal,
                        color: AppColors.textSecondary(isDark),
                      ),
                    ),
                  ],
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

  Widget _buildCyclePhases(bool isDark) {
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
                Icons.calendar_view_month,
                color: AppColors.primary(isDark),
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                'Phases of Your Cycle',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary(isDark),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _buildPhaseCard(
            'Menstrual',
            'Days 1-7',
            'Period starts, hormone levels drop. You may feel tired and need more rest.',
            Colors.red.shade400,
            isDark,
          ),
          const SizedBox(height: 12),
          _buildPhaseCard(
            'Follicular Phase',
            'Days 1-13',
            'Estrogen rises, energy increases. Great time for new projects and exercise.',
            Colors.green.shade400,
            isDark,
          ),
          const SizedBox(height: 12),
          _buildPhaseCard(
            'Ovulation',
            'Days 14-16',
            'Peak fertility window. Highest energy and confidence levels.',
            Colors.orange.shade400,
            isDark,
          ),
          const SizedBox(height: 12),
          _buildPhaseCard(
            'Luteal Phase',
            'Days 17-28',
            'Progesterone rises then falls. May experience PMS symptoms before next period.',
            Colors.purple.shade400,
            isDark,
          ),
        ],
      ),
    );
  }

  Widget _buildPhaseCard(String phase, String days, String description, Color color, bool isDark) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surfaceColor(isDark),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: color.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: color.withOpacity(0.2),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Center(
              child: Text(
                phase[0],
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      phase,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary(isDark),
                      ),
                    ),
                    const Spacer(),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: color.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        days,
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                          color: color,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
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
      ),
    );
  }
}