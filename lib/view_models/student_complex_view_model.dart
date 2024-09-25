import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:logging/logging.dart';
import '../models/entities/student_complex.dart';

class StudentComplexViewModel extends ChangeNotifier {
  /// List of student complexes
  List<StudentComplex> _studentComplexes = [];
  bool _isLoading = false;

  static final log = Logger('StudentComplexViewModel');

  // Reference to Firestore 'student_complexes' collection
  final CollectionReference _studentComplexesRef =
      FirebaseFirestore.instance.collection('student_complexes');

  /// Getter for student complexes
  List<StudentComplex> get studentComplexes => _studentComplexes;

  /// Getter for loading state
  bool get isLoading => _isLoading;

  /// Method to fetch student complexes from Firestore
  Future<void> fetchStudentComplexes() async {
    _setLoading(true);

    try {
      QuerySnapshot snapshot = await _studentComplexesRef.get();

      _studentComplexes = snapshot.docs.map((doc) {
        final complexData = doc.data() as Map<String, dynamic>;

        return StudentComplex(
          id: doc.id, // Document ID will be used as the unique ID
          name: complexData['name'] ?? '',
          rating: complexData['rating']?.toDouble() ?? 0.0,
          address: complexData['address'] ?? '',
        );
      }).toList();

      notifyListeners();
    } catch (e) {
      log.shout('Error fetching student complexes: $e');
    } finally {
      _setLoading(false);
    }
  }

  /// Method to add a new student complex to Firestore
  Future<void> addStudentComplex(StudentComplex studentComplex) async {
    try {
      await _studentComplexesRef.add({
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

  /// Method to remove a student complex from Firestore by document ID
  Future<void> removeStudentComplex(String documentId) async {
    try {
      await _studentComplexesRef.doc(documentId).delete();

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
