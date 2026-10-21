import '../model/student.dart';
import '../model/course.dart';
import '../model/course_result.dart';

class LmsSystem {
  final List<Student> students = [];
  final List<Course> courses = [];
  final List<CourseResult> results = [];
  int _nextResultId = 1;

  void addStudent({required String studentId, required String studentName}) {
    // ! Student shall not exist already
    Student? student = _findStudentOrNull(studentId);
    if (student != null) {
      throw Exception('Student $studentId already exists');
    }

    students.add(Student(id: studentId, name: studentName));
  }

  void removeStudent({required String studentId}) {
    if (_findStudentOrNull(studentId) == null) {
      throw Exception('Student $studentId not found');
    }

    for (final course in courses) {
      course.studentIds.remove(studentId);
    }
    results.removeWhere((result) => result.studentId == studentId);
    students.removeWhere((student) => student.id == studentId);
  }

  Student? _findStudentOrNull(String studentId) {
    for (Student s in students) {
      if (s.id == studentId) {
        return s;
      }
    }
    return null; // not found
  }

  void addCourse({required String courseId, required String courseName}) {
    // ! Course shall not exist already
    Course? course = _findCourseOrNull(courseId);
    if (course != null) {
      throw Exception('Course $courseId already exists');
    }

    courses.add(Course(id: courseId, name: courseName));
  }

  void removeCourse({required String courseId}) {
    Course? course = _findCourseOrNull(courseId);
    if (course == null) {
      throw Exception('Course $courseId not found');
    }
    // Remove the course from the LMS.
    courses.removeWhere((course) => course.id == courseId);
    results.removeWhere((result) => result.courseId == courseId);
  }

  void enrollStudent({required String studentId, required String courseId}) {
    if (_findStudentOrNull(studentId) == null) {
      throw Exception('Student $studentId not found');
    }

    Course? course = _findCourseOrNull(courseId);
    if (course == null) {
      throw Exception('Course $courseId not found');
    }

    if (course.studentIds.contains(studentId)) {
      throw Exception(
          'Student $studentId is already enrolled in course $courseId');
    }

    course.studentIds.add(studentId);
  }

  void discardStudentFromCourse({
    required String studentId,
    required String courseId,
  }) {
    if (_findStudentOrNull(studentId) == null) {
      throw Exception('Student $studentId not found');
    }

    Course? course = _findCourseOrNull(courseId);
    if (course == null) {
      throw Exception('Course $courseId not found');
    }

    if (!course.studentIds.contains(studentId)) {
      throw Exception('Student $studentId is not enrolled in course $courseId');
    }

    course.studentIds.remove(studentId);
  }

  CourseResult addResult({
    required String studentId,
    required String courseId,
    required double score,
  }) {
    if (_findStudentOrNull(studentId) == null) {
      throw Exception('Student $studentId not found');
    }

    Course? course = _findCourseOrNull(courseId);
    if (course == null) {
      throw Exception('Course $courseId not found');
    }

    if (!course.studentIds.contains(studentId)) {
      throw Exception('Student $studentId is not enrolled in course $courseId');
    }

    if (score < 0 || score > 100) {
      throw Exception('Score must be between 0 and 100');
    }

    if (results.any(
      (result) => result.studentId == studentId && result.courseId == courseId,
    )) {
      throw Exception(
        'A result already exists for student $studentId in course $courseId',
      );
    }

    final result = CourseResult(
      id: 'R${_nextResultId++}',
      studentId: studentId,
      courseId: courseId,
      score: score,
    );
    results.add(result);
    return result;
  }

  void removeResult({required String resultId}) {
    if (!results.any((result) => result.id == resultId)) {
      throw Exception('Result $resultId not found');
    }

    results.removeWhere((result) => result.id == resultId);
  }

  Course? _findCourseOrNull(String courseId) {
    for (Course c in courses) {
      if (c.id == courseId) {
        return c;
      }
    }
    return null; // not found
  }
}
