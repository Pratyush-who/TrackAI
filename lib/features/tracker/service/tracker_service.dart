import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class TrackerService {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  static final FirebaseAuth _auth = FirebaseAuth.instance;

  // Get current user ID
  static String? get _currentUserId => _auth.currentUser?.uid;

  // Base path for tracker data
  static CollectionReference _getTrackerCollection(String trackerId) {
    return _firestore
        .collection('users')
        .doc(_currentUserId)
        .collection('tracking')
        .doc(trackerId)
        .collection('entries');
  }

  // Save tracker entry
  static Future<void> saveTrackerEntry(String trackerId, Map<String, dynamic> data) async {
    if (_currentUserId == null) throw Exception('User not authenticated');

    data['timestamp'] = FieldValue.serverTimestamp();
    data['userId'] = _currentUserId;

    await _getTrackerCollection(trackerId).add(data);
  }

  // Get tracker entries
  static Stream<List<Map<String, dynamic>>> getTrackerEntries(String trackerId) {
    if (_currentUserId == null) return Stream.empty();

    return _getTrackerCollection(trackerId)
        .orderBy('timestamp', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;
        data['id'] = doc.id;
        return data;
      }).toList();
    });
  }

  // Delete tracker entry
  static Future<void> deleteTrackerEntry(String trackerId, String entryId) async {
    if (_currentUserId == null) throw Exception('User not authenticated');

    await _getTrackerCollection(trackerId).doc(entryId).delete();
  }

  // Update tracker entry
  static Future<void> updateTrackerEntry(
      String trackerId, String entryId, Map<String, dynamic> data) async {
    if (_currentUserId == null) throw Exception('User not authenticated');

    data['updatedAt'] = FieldValue.serverTimestamp();
    await _getTrackerCollection(trackerId).doc(entryId).update(data);
  }

  // Get specific tracker entry
  static Future<Map<String, dynamic>?> getTrackerEntry(String trackerId, String entryId) async {
    if (_currentUserId == null) return null;

    final doc = await _getTrackerCollection(trackerId).doc(entryId).get();
    if (doc.exists) {
      final data = doc.data() as Map<String, dynamic>;
      data['id'] = doc.id;
      return data;
    }
    return null;
  }

  // Get tracker statistics
  static Future<Map<String, dynamic>> getTrackerStats(String trackerId) async {
    if (_currentUserId == null) return {};

    final snapshot = await _getTrackerCollection(trackerId).get();
    final entries = snapshot.docs.length;
    
    // Calculate average, min, max if applicable
    final data = snapshot.docs.map((doc) => doc.data() as Map<String, dynamic>).toList();
    
    return {
      'totalEntries': entries,
      'data': data,
    };
  }
}