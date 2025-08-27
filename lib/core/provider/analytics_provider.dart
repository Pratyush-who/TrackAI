// analytics_provider.dart
import 'package:flutter/foundation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class AnalyticsProvider extends ChangeNotifier {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  static final FirebaseAuth _auth = FirebaseAuth.instance;
  
  String? get _currentUserId => _auth.currentUser?.uid;
  
  List<String> _selectedTrackers = [];
  String _selectedTimeframe = 'This Week';
  String _selectedAnalyticsType = 'Dashboard & Summary';
  Map<String, dynamic> _dashboardConfig = {};
  String _overallSummary = '';
  bool _isLoadingSummary = false;
  Map<String, List<Map<String, dynamic>>> _trackerData = {};
  List<Map<String, dynamic>> _correlationResults = [];
  Map<String, dynamic> _progressData = {};
  Map<String, dynamic> _periodData = {};

  // Getters
  List<String> get selectedTrackers => _selectedTrackers;
  String get selectedTimeframe => _selectedTimeframe;
  String get selectedAnalyticsType => _selectedAnalyticsType;
  Map<String, dynamic> get dashboardConfig => _dashboardConfig;
  String get overallSummary => _overallSummary;
  bool get isLoadingSummary => _isLoadingSummary;
  Map<String, List<Map<String, dynamic>>> get trackerData => _trackerData;
  List<Map<String, dynamic>> get correlationResults => _correlationResults;
  Map<String, dynamic> get progressData => _progressData;
  Map<String, dynamic> get periodData => _periodData;

  final List<String> availableTrackers = [
    'Sleep Tracker',
    'Mood Tracker', 
    'Meditation Tracker',
    'Expense Tracker',
    'Savings Tracker',
    'Alcohol Tracker',
    'Study Time Tracker',
    'Mental Well-being Tracker',
    'Workout Tracker',
    'Weight Tracker',
    'Menstrual Cycle'
  ];

  final List<String> analyticsTypes = [
    'Dashboard & Summary',
    'Correlation Labs',
    'Progress Overview',
    'Period Cycle'
  ];

  final List<String> timeframes = [
    'This Week',
    'Last Week', 
    'This Month',
    'Last Month',
    'Last 3 Months',
    'Last 6 Months'
  ];

  void setSelectedAnalyticsType(String type) {
    _selectedAnalyticsType = type;
    notifyListeners();
  }

  void setSelectedTimeframe(String timeframe) {
    _selectedTimeframe = timeframe;
    notifyListeners();
    loadTrackerData();
  }

  void toggleTrackerSelection(String tracker) {
    if (_selectedTrackers.contains(tracker)) {
      _selectedTrackers.remove(tracker);
    } else {
      _selectedTrackers.add(tracker);
    }
    _saveDashboardConfig();
    notifyListeners();
  }

  Future<void> loadDashboardConfig() async {
    if (_currentUserId == null) return;
    
    try {
      final doc = await _firestore
          .collection('users')
          .doc(_currentUserId)
          .collection('analytics_data')
          .doc('dashboard_config')
          .get();
      
      if (doc.exists) {
        _dashboardConfig = doc.data() ?? {};
        _selectedTrackers = List<String>.from(_dashboardConfig['selectedTrackers'] ?? []);
      }
      notifyListeners();
    } catch (e) {
      debugPrint('Error loading dashboard config: $e');
    }
  }

  Future<void> _saveDashboardConfig() async {
    if (_currentUserId == null) return;
    
    try {
      await _firestore
          .collection('users')
          .doc(_currentUserId)
          .collection('analytics_data')
          .doc('dashboard_config')
          .set({
        'selectedTrackers': _selectedTrackers,
        'lastUpdated': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
    } catch (e) {
      debugPrint('Error saving dashboard config: $e');
    }
  }

  Future<void> loadTrackerData() async {
    if (_currentUserId == null || _selectedTrackers.isEmpty) return;

    try {
      final Map<String, List<Map<String, dynamic>>> data = {};
      
      for (String tracker in _selectedTrackers) {
        final trackerId = _getTrackerIdFromName(tracker);
        final entries = await _getTrackerEntries(trackerId);
        data[tracker] = entries;
      }
      
      _trackerData = data;
      notifyListeners();
    } catch (e) {
      debugPrint('Error loading tracker data: $e');
    }
  }

  Future<void> generateOverallSummary() async {
    if (_trackerData.isEmpty) return;
    
    _isLoadingSummary = true;
    notifyListeners();

    try {
      final geminiApiKey = dotenv.env['GEMINI_API_KEY'];
      if (geminiApiKey == null || geminiApiKey.isEmpty) {
        throw Exception('Gemini API key not found');
      }

      // Correct way to initialize Gemini model for free tier
      final model = GenerativeModel(
        model: 'gemini-pro', // Use gemini-pro for free tier
        apiKey: geminiApiKey,
      );

      final prompt = _buildSummaryPrompt();
      final response = await model.generateContent([Content.text(prompt)]);
      
      _overallSummary = response.text ?? 'Unable to generate summary';
    } catch (e) {
      _overallSummary = 'Error generating summary: ${e.toString()}';
      debugPrint('Error generating summary: $e');
    }

    _isLoadingSummary = false;
    notifyListeners();
  }

  String _buildSummaryPrompt() {
    final buffer = StringBuffer();
    buffer.writeln('Analyze the following tracking data and provide insights:');
    
    _trackerData.forEach((tracker, entries) {
      buffer.writeln('\n$tracker (${entries.length} entries):');
      for (int i = 0; i < entries.length && i < 5; i++) {
        final entry = entries[i];
        buffer.writeln('- ${entry['value'] ?? 'N/A'} on ${entry['timestamp']}');
      }
    });
    
    buffer.writeln('\nProvide a concise summary of trends, patterns, and actionable insights.');
    return buffer.toString();
  }

  Future<List<Map<String, dynamic>>> _getTrackerEntries(String trackerId) async {
    try {
      final querySnapshot = await _firestore
          .collection('users')
          .doc(_currentUserId)
          .collection('tracking')
          .doc(trackerId)
          .collection('entries')
          .orderBy('timestamp', descending: true)
          .limit(30)
          .get();

      return querySnapshot.docs.map((doc) {
        final data = doc.data();
        if (data['timestamp'] is Timestamp) {
          data['timestamp'] = (data['timestamp'] as Timestamp).toDate().toIso8601String();
        }
        data['id'] = doc.id;
        return data;
      }).toList();
    } catch (e) {
      debugPrint('Error getting tracker entries for $trackerId: $e');
      return [];
    }
  }

  String _getTrackerIdFromName(String trackerName) {
    final Map<String, String> trackerMap = {
      'Sleep Tracker': 'sleep',
      'Mood Tracker': 'mood',
      'Meditation Tracker': 'meditation',
      'Expense Tracker': 'expense',
      'Savings Tracker': 'savings',
      'Alcohol Tracker': 'alcohol',
      'Study Time Tracker': 'study',
      'Mental Well-being Tracker': 'mental_wellbeing',
      'Workout Tracker': 'workout',
      'Weight Tracker': 'weight',
      'Menstrual Cycle': 'menstrual'
    };
    return trackerMap[trackerName] ?? trackerName.toLowerCase().replaceAll(' ', '_');
  }

  Future<void> analyzeCorrelations() async {
    if (_selectedTrackers.length < 2) return;

    try {
      // Simple correlation analysis - you can expand this
      final List<Map<String, dynamic>> correlations = [];
      
      for (int i = 0; i < _selectedTrackers.length; i++) {
        for (int j = i + 1; j < _selectedTrackers.length; j++) {
          final tracker1 = _selectedTrackers[i];
          final tracker2 = _selectedTrackers[j];
          
          final data1 = _trackerData[tracker1] ?? [];
          final data2 = _trackerData[tracker2] ?? [];
          
          if (data1.isNotEmpty && data2.isNotEmpty) {
            final correlation = _calculateCorrelation(data1, data2);
            correlations.add({
              'tracker1': tracker1,
              'tracker2': tracker2,
              'correlation': correlation,
              'strength': _getCorrelationStrength(correlation),
            });
          }
        }
      }
      
      _correlationResults = correlations;
      notifyListeners();
    } catch (e) {
      debugPrint('Error analyzing correlations: $e');
    }
  }

  double _calculateCorrelation(List<Map<String, dynamic>> data1, List<Map<String, dynamic>> data2) {
    // Simplified correlation calculation
    // In a real implementation, you'd want more sophisticated analysis
    final values1 = data1.map((e) => double.tryParse(e['value']?.toString() ?? '0') ?? 0.0).toList();
    final values2 = data2.map((e) => double.tryParse(e['value']?.toString() ?? '0') ?? 0.0).toList();
    
    if (values1.isEmpty || values2.isEmpty) return 0.0;
    
    final minLength = values1.length < values2.length ? values1.length : values2.length;
    final trimmed1 = values1.take(minLength).toList();
    final trimmed2 = values2.take(minLength).toList();
    
    // Simple correlation coefficient calculation
    final mean1 = trimmed1.reduce((a, b) => a + b) / trimmed1.length;
    final mean2 = trimmed2.reduce((a, b) => a + b) / trimmed2.length;
    
    double numerator = 0.0;
    double sumSq1 = 0.0;
    double sumSq2 = 0.0;
    
    for (int i = 0; i < trimmed1.length; i++) {
      final diff1 = trimmed1[i] - mean1;
      final diff2 = trimmed2[i] - mean2;
      numerator += diff1 * diff2;
      sumSq1 += diff1 * diff1;
      sumSq2 += diff2 * diff2;
    }
    
    final denominator = (sumSq1 * sumSq2).abs();
    return denominator > 0 ? numerator / denominator : 0.0;
  }

  String _getCorrelationStrength(double correlation) {
    final abs = correlation.abs();
    if (abs >= 0.7) return 'Strong';
    if (abs >= 0.3) return 'Moderate';
    if (abs >= 0.1) return 'Weak';
    return 'None';
  }

  Future<void> loadProgressData() async {
    // Load progress overview data
    try {
      final Map<String, dynamic> progress = {};
      
      for (String tracker in _selectedTrackers) {
        final trackerId = _getTrackerIdFromName(tracker);
        final entries = await _getTrackerEntries(trackerId);
        
        if (entries.isNotEmpty) {
          final thisWeekData = _filterDataByTimeframe(entries, 'This Week');
          final lastWeekData = _filterDataByTimeframe(entries, 'Last Week');
          
          progress[tracker] = {
            'thisWeek': thisWeekData,
            'lastWeek': lastWeekData,
            'total': entries.length,
            'average': _calculateAverage(entries),
          };
        }
      }
      
      _progressData = progress;
      notifyListeners();
    } catch (e) {
      debugPrint('Error loading progress data: $e');
    }
  }

  List<Map<String, dynamic>> _filterDataByTimeframe(List<Map<String, dynamic>> entries, String timeframe) {
    final now = DateTime.now();
    DateTime startDate;
    
    switch (timeframe) {
      case 'This Week':
        startDate = now.subtract(Duration(days: now.weekday - 1));
        break;
      case 'Last Week':
        startDate = now.subtract(Duration(days: now.weekday + 6));
        break;
      default:
        return entries;
    }
    
    return entries.where((entry) {
      try {
        final entryDate = DateTime.parse(entry['timestamp']);
        return entryDate.isAfter(startDate) && entryDate.isBefore(now);
      } catch (e) {
        return false;
      }
    }).toList();
  }

  double _calculateAverage(List<Map<String, dynamic>> entries) {
    if (entries.isEmpty) return 0.0;
    
    final values = entries
        .map((e) => double.tryParse(e['value']?.toString() ?? '0') ?? 0.0)
        .where((v) => v > 0)
        .toList();
    
    return values.isEmpty ? 0.0 : values.reduce((a, b) => a + b) / values.length;
  }

  Future<void> loadPeriodData() async {
    if (!_selectedTrackers.contains('Menstrual Cycle')) return;
    
    try {
      final entries = await _getTrackerEntries('menstrual');
      final Map<String, dynamic> periodAnalysis = {};
      
      // Analyze period cycle data
      final cycles = _analyzeMenstrualCycles(entries);
      periodAnalysis['cycles'] = cycles;
      periodAnalysis['averageCycleLength'] = _calculateAverageCycleLength(cycles);
      periodAnalysis['nextPredictedPeriod'] = _predictNextPeriod(cycles);
      
      _periodData = periodAnalysis;
      notifyListeners();
    } catch (e) {
      debugPrint('Error loading period data: $e');
    }
  }

  List<Map<String, dynamic>> _analyzeMenstrualCycles(List<Map<String, dynamic>> entries) {
    // Simplified cycle analysis
    final cycles = <Map<String, dynamic>>[];
    
    for (var entry in entries) {
      if (entry['cycleDay'] != null) {
        cycles.add({
          'date': entry['timestamp'],
          'cycleDay': entry['cycleDay'],
          'phase': _getCyclePhase(entry['cycleDay']),
          'symptoms': entry['symptoms'] ?? [],
        });
      }
    }
    
    return cycles;
  }

  String _getCyclePhase(int cycleDay) {
    if (cycleDay >= 1 && cycleDay <= 7) return 'Menstrual';
    if (cycleDay >= 8 && cycleDay <= 13) return 'Follicular';
    if (cycleDay >= 14 && cycleDay <= 16) return 'Ovulation';
    if (cycleDay >= 17 && cycleDay <= 28) return 'Luteal';
    return 'Unknown';
  }

  double _calculateAverageCycleLength(List<Map<String, dynamic>> cycles) {
    if (cycles.length < 2) return 28.0; // Default cycle length
    
    final cycleLengths = <int>[];
    for (int i = 1; i < cycles.length; i++) {
      try {
        final current = DateTime.parse(cycles[i]['date']);
        final previous = DateTime.parse(cycles[i-1]['date']);
        final diff = current.difference(previous).inDays;
        if (diff > 0 && diff < 60) { // Reasonable cycle length
          cycleLengths.add(diff);
        }
      } catch (e) {
        continue;
      }
    }
    
    return cycleLengths.isEmpty 
        ? 28.0 
        : cycleLengths.reduce((a, b) => a + b) / cycleLengths.length;
  }

  DateTime? _predictNextPeriod(List<Map<String, dynamic>> cycles) {
    if (cycles.isEmpty) return null;
    
    try {
      final lastPeriod = DateTime.parse(cycles.first['date']);
      final averageLength = _calculateAverageCycleLength(cycles);
      return lastPeriod.add(Duration(days: averageLength.round()));
    } catch (e) {
      return null;
    }
  }
}