import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:logging/logging.dart';
import '../models/entities/student_complex.dart';

class StudentComplexViewModel extends ChangeNotifier {
  /// List of student complexes
  List<StudentComplex> _studentComplexes = [];
  bool _isLoading = false;

  static final log = Logger('StudentComplexViewModel');
  final DatabaseReference _studentComplexesRef =
      FirebaseDatabase.instance.ref().child('student_complexes');

  /// Getter for student complexes
  List<StudentComplex> get studentComplexes => _studentComplexes;

  /// Getter for loading state
  bool get isLoading => _isLoading;

  /// Method to fetch student complexes from Firebase Realtime Database
  Future<void> fetchStudentComplexes() async {
    _setLoading(true);

    try {
      final DataSnapshot snapshot = await _studentComplexesRef.get();

      if (snapshot.exists) {
        final data = snapshot.value as Map<dynamic, dynamic>;

        _studentComplexes = data.entries.map((entry) {
          final complexData = entry.value as Map<dynamic, dynamic>;

          return StudentComplex(
            id: entry.key,
            name: complexData['name'] ?? '',
            rating: complexData['rating']?.toDouble() ?? 0.0,
            address: complexData['address'] ?? '',
          );
        }).toList();

        notifyListeners();
      }
    } catch (e) {
      log.shout('Error fetching student complexes: $e');
    } finally {
      _setLoading(false);
    }
  }

  /// Method to add a new student complex to Firebase
  Future<void> addStudentComplex(StudentComplex studentComplex) async {
    try {
      final newComplexRef = _studentComplexesRef.push();
      await newComplexRef.set({
        'name': studentComplex.name,
        'rating': studentComplex.rating,
        'address': studentComplex.address,
      });

      // Fetch the updated student complexes list
      await fetchStudentComplexes();
    } catch (e) {
      log.shout('Error adding student complex: $e');
    }
  }

  /// Method to remove a student complex from Firebase by key
  Future<void> removeStudentComplex(String complexKey) async {
    try {
      await _studentComplexesRef.child(complexKey).remove();

      // Fetch the updated student complexes list
      await fetchStudentComplexes();
    } catch (e) {
      log.shout('Error removing student complex: $e');
    }
  }

  /// Method to update loading state and notify listeners
  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }
}
