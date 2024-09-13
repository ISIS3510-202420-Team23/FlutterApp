import 'package:flutter/material.dart';
import 'package:logging/logging.dart';
import '../models/entities/student_complex.dart';

class StudentComplexViewModel extends ChangeNotifier {
  /// List of student complexes, this can be fetched from a data source (e.g., API, Firebase, etc.)
  final List<StudentComplex> _studentComplexes = [];
  bool _isLoading = false;

  static final log = Logger('StudentComplexViewModel');

  /// Getter for student complexes
  List<StudentComplex> get studentComplexes => _studentComplexes;

  /// Getter for loading state
  bool get isLoading => _isLoading;

  /// Method to fetch student complexes from a data source
  Future<void> fetchStudentComplexes() async {
    _setLoading(true);

    try {
      // TODO: Add fetching logic here, possibly from an API or database

      // Notify listeners that data has changed
      notifyListeners();
    } catch (e) {
      // Handle error if something goes wrong
      log.shout('Error fetching student complexes: $e');
    } finally {
      _setLoading(false);
    }
  }

  /// Method to add a new student complex
  void addStudentComplex(StudentComplex studentComplex) {
    _studentComplexes.add(studentComplex);
    notifyListeners();
  }

  /// Method to remove a student complex
  void removeStudentComplex(int index) {
    _studentComplexes.removeAt(index);
    notifyListeners();
  }

  /// Method to update loading state and notify listeners
  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }
}
