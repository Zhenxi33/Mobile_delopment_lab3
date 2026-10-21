import 'package:test/test.dart';

import '../service/lms_system.dart';

void main() {
  group('Student Tests', () {
    test('Create student', () {
      final lms = LmsSystem();

      lms.addStudent(studentId: 'S1', studentName: 'Ronan');

      expect(lms.students.first.name, 'Ronan');
    });

    test('Remove student', () {
      final lms = LmsSystem();
      lms.addStudent(studentId: 'S1', studentName: 'Ronan');

      lms.removeStudent(studentId: 'S1');

      expect(lms.students, isEmpty);
    });

    test('Removing a student clears enrollments in every course', () {
      final lms = LmsSystem();
      lms.addStudent(studentId: 'S1', studentName: 'Ronan');
      lms.addStudent(studentId: 'S2', studentName: 'Alex');
      lms.addCourse(courseId: 'C1', courseName: 'Mobile Development');
      lms.addCourse(courseId: 'C2', courseName: 'Programming');
      lms.enrollStudent(studentId: 'S1', courseId: 'C1');
      lms.enrollStudent(studentId: 'S1', courseId: 'C2');
      lms.enrollStudent(studentId: 'S2', courseId: 'C1');

      lms.removeStudent(studentId: 'S1');

      expect(lms.students.map((student) => student.id), ['S2']);
      expect(lms.courses[0].studentIds, ['S2']);
      expect(lms.courses[1].studentIds, isEmpty);
      expect(lms.courses, hasLength(2));
    });

    test('Removing a student also removes their results', () {
      final lms = LmsSystem();
      lms.addStudent(studentId: 'S1', studentName: 'Ronan');
      lms.addStudent(studentId: 'S2', studentName: 'Alex');
      lms.addCourse(courseId: 'C1', courseName: 'Mobile Development');
      lms.enrollStudent(studentId: 'S1', courseId: 'C1');
      lms.enrollStudent(studentId: 'S2', courseId: 'C1');
      lms.addResult(studentId: 'S1', courseId: 'C1', score: 85);
      lms.addResult(studentId: 'S2', courseId: 'C1', score: 90);

      lms.removeStudent(studentId: 'S1');

      expect(lms.results.map((result) => result.studentId), ['S2']);
    });
  });

  group('Course Tests', () {
    test('Add course', () {
      final lms = LmsSystem();

      lms.addCourse(courseId: 'C1', courseName: 'Dart Basics');

      expect(lms.courses.first.name, 'Dart Basics');
    });

    test('Rejects a duplicate course ID', () {
      final lms = LmsSystem();
      lms.addCourse(courseId: 'C1', courseName: 'Mobile Development');

      expect(
        () => lms.addCourse(courseId: 'C1', courseName: 'Another Course'),
        throwsA(isA<Exception>()),
      );
      expect(lms.courses, hasLength(1));
    });

    test('Remove course', () {
      final lms = LmsSystem();
      lms.addCourse(courseId: 'C1', courseName: 'Dart Basics');

      lms.removeCourse(courseId: 'C1');

      expect(lms.courses, isEmpty);
    });

    test('Rejects removing a nonexistent course', () {
      final lms = LmsSystem();

      expect(
        () => lms.removeCourse(courseId: 'missing'),
        throwsA(isA<Exception>()),
      );
    });

    test('Removing a course also removes its results', () {
      final lms = LmsSystem();
      lms.addStudent(studentId: 'S1', studentName: 'Ronan');
      lms.addCourse(courseId: 'C1', courseName: 'Mobile Development');
      lms.enrollStudent(studentId: 'S1', courseId: 'C1');
      lms.addResult(studentId: 'S1', courseId: 'C1', score: 85);

      lms.removeCourse(courseId: 'C1');

      expect(lms.results, isEmpty);
    });
  });

  group('Enrollment Tests', () {
    test('Enrolls an existing student in an existing course', () {
      final lms = LmsSystem();
      lms.addStudent(studentId: 'S1', studentName: 'Ronan');
      lms.addCourse(courseId: 'C1', courseName: 'Mobile Development');

      lms.enrollStudent(studentId: 'S1', courseId: 'C1');

      expect(lms.courses.first.studentIds, contains('S1'));
    });

    test('Rejects enrolling a nonexistent student', () {
      final lms = LmsSystem();
      lms.addCourse(courseId: 'C1', courseName: 'Mobile Development');

      expect(
        () => lms.enrollStudent(studentId: 'missing', courseId: 'C1'),
        throwsA(isA<Exception>()),
      );
      expect(lms.courses.first.studentIds, isEmpty);
    });

    test('Rejects enrolling a student in a nonexistent course', () {
      final lms = LmsSystem();
      lms.addStudent(studentId: 'S1', studentName: 'Ronan');

      expect(
        () => lms.enrollStudent(studentId: 'S1', courseId: 'missing'),
        throwsA(isA<Exception>()),
      );
    });

    test('Rejects duplicate enrollment', () {
      final lms = LmsSystem();
      lms.addStudent(studentId: 'S1', studentName: 'Ronan');
      lms.addCourse(courseId: 'C1', courseName: 'Mobile Development');
      lms.enrollStudent(studentId: 'S1', courseId: 'C1');

      expect(
        () => lms.enrollStudent(studentId: 'S1', courseId: 'C1'),
        throwsA(isA<Exception>()),
      );
      expect(lms.courses.first.studentIds, ['S1']);
    });

    test('Removes an enrollment without removing the student or course', () {
      final lms = LmsSystem();
      lms.addStudent(studentId: 'S1', studentName: 'Ronan');
      lms.addCourse(courseId: 'C1', courseName: 'Mobile Development');
      lms.enrollStudent(studentId: 'S1', courseId: 'C1');

      lms.discardStudentFromCourse(studentId: 'S1', courseId: 'C1');

      expect(lms.courses.first.studentIds, isEmpty);
      expect(lms.students, hasLength(1));
      expect(lms.courses, hasLength(1));
    });

    test('Rejects removing an enrollment that does not exist', () {
      final lms = LmsSystem();
      lms.addStudent(studentId: 'S1', studentName: 'Ronan');
      lms.addCourse(courseId: 'C1', courseName: 'Mobile Development');

      expect(
        () => lms.discardStudentFromCourse(studentId: 'S1', courseId: 'C1'),
        throwsA(isA<Exception>()),
      );
    });

    test('Rejects removing an enrollment for a nonexistent student', () {
      final lms = LmsSystem();
      lms.addCourse(courseId: 'C1', courseName: 'Mobile Development');

      expect(
        () => lms.discardStudentFromCourse(
          studentId: 'missing',
          courseId: 'C1',
        ),
        throwsA(isA<Exception>()),
      );
    });

    test('Rejects removing an enrollment from a nonexistent course', () {
      final lms = LmsSystem();
      lms.addStudent(studentId: 'S1', studentName: 'Ronan');

      expect(
        () => lms.discardStudentFromCourse(
          studentId: 'S1',
          courseId: 'missing',
        ),
        throwsA(isA<Exception>()),
      );
    });
  });

  group('Result Tests', () {
    test('Adds a result for an enrolled student', () {
      final lms = LmsSystem();
      lms.addStudent(studentId: 'S1', studentName: 'Ronan');
      lms.addCourse(courseId: 'C1', courseName: 'Mobile Development');
      lms.enrollStudent(studentId: 'S1', courseId: 'C1');

      final result = lms.addResult(
        studentId: 'S1',
        courseId: 'C1',
        score: 85,
      );

      expect(result.id, 'R1');
      expect(result.studentId, 'S1');
      expect(result.courseId, 'C1');
      expect(result.score, 85);
      expect(lms.results, [result]);
    });

    test('Accepts scores at the minimum and maximum', () {
      final lms = LmsSystem();
      lms.addStudent(studentId: 'S1', studentName: 'Ronan');
      lms.addStudent(studentId: 'S2', studentName: 'Alex');
      lms.addCourse(courseId: 'C1', courseName: 'Mobile Development');
      lms.enrollStudent(studentId: 'S1', courseId: 'C1');
      lms.enrollStudent(studentId: 'S2', courseId: 'C1');

      lms.addResult(studentId: 'S1', courseId: 'C1', score: 0);
      lms.addResult(studentId: 'S2', courseId: 'C1', score: 100);

      expect(lms.results.map((result) => result.score), [0, 100]);
    });

    test('Rejects adding a result for a nonexistent student', () {
      final lms = LmsSystem();
      lms.addCourse(courseId: 'C1', courseName: 'Mobile Development');

      expect(
        () => lms.addResult(
          studentId: 'missing',
          courseId: 'C1',
          score: 85,
        ),
        throwsA(isA<Exception>()),
      );
      expect(lms.results, isEmpty);
    });

    test('Rejects adding a result for a nonexistent course', () {
      final lms = LmsSystem();
      lms.addStudent(studentId: 'S1', studentName: 'Ronan');

      expect(
        () => lms.addResult(
          studentId: 'S1',
          courseId: 'missing',
          score: 85,
        ),
        throwsA(isA<Exception>()),
      );
      expect(lms.results, isEmpty);
    });

    test('Rejects adding a result when the student is not enrolled', () {
      final lms = LmsSystem();
      lms.addStudent(studentId: 'S1', studentName: 'Ronan');
      lms.addCourse(courseId: 'C1', courseName: 'Mobile Development');

      expect(
        () => lms.addResult(studentId: 'S1', courseId: 'C1', score: 85),
        throwsA(isA<Exception>()),
      );
      expect(lms.results, isEmpty);
    });

    test('Rejects scores outside the valid range', () {
      final lms = LmsSystem();
      lms.addStudent(studentId: 'S1', studentName: 'Ronan');
      lms.addCourse(courseId: 'C1', courseName: 'Mobile Development');
      lms.enrollStudent(studentId: 'S1', courseId: 'C1');

      expect(
        () => lms.addResult(studentId: 'S1', courseId: 'C1', score: -1),
        throwsA(isA<Exception>()),
      );
      expect(
        () => lms.addResult(studentId: 'S1', courseId: 'C1', score: 101),
        throwsA(isA<Exception>()),
      );
      expect(lms.results, isEmpty);
    });

    test('Rejects duplicate results for the same student and course', () {
      final lms = LmsSystem();
      lms.addStudent(studentId: 'S1', studentName: 'Ronan');
      lms.addCourse(courseId: 'C1', courseName: 'Mobile Development');
      lms.enrollStudent(studentId: 'S1', courseId: 'C1');
      lms.addResult(studentId: 'S1', courseId: 'C1', score: 85);

      expect(
        () => lms.addResult(studentId: 'S1', courseId: 'C1', score: 90),
        throwsA(isA<Exception>()),
      );
      expect(lms.results, hasLength(1));
    });

    test('Removing an enrollment preserves its historical result', () {
      final lms = LmsSystem();
      lms.addStudent(studentId: 'S1', studentName: 'Ronan');
      lms.addCourse(courseId: 'C1', courseName: 'Mobile Development');
      lms.enrollStudent(studentId: 'S1', courseId: 'C1');
      lms.addResult(studentId: 'S1', courseId: 'C1', score: 85);

      lms.discardStudentFromCourse(studentId: 'S1', courseId: 'C1');

      expect(lms.results, hasLength(1));
      expect(lms.results.first.score, 85);
    });

    test(
        'Removes a result without changing students, courses, or other results',
        () {
      final lms = LmsSystem();
      lms.addStudent(studentId: 'S1', studentName: 'Ronan');
      lms.addStudent(studentId: 'S2', studentName: 'Alex');
      lms.addCourse(courseId: 'C1', courseName: 'Mobile Development');
      lms.enrollStudent(studentId: 'S1', courseId: 'C1');
      lms.enrollStudent(studentId: 'S2', courseId: 'C1');
      final removed = lms.addResult(
        studentId: 'S1',
        courseId: 'C1',
        score: 85,
      );
      final preserved = lms.addResult(
        studentId: 'S2',
        courseId: 'C1',
        score: 90,
      );

      lms.removeResult(resultId: removed.id);

      expect(lms.results, [preserved]);
      expect(lms.students.map((student) => student.id), ['S1', 'S2']);
      expect(lms.courses, hasLength(1));
      expect(lms.courses.first.studentIds, ['S1', 'S2']);
    });

    test('Rejects removing a nonexistent result', () {
      final lms = LmsSystem();

      expect(
        () => lms.removeResult(resultId: 'missing'),
        throwsA(isA<Exception>()),
      );
      expect(lms.results, isEmpty);
    });
  });
}
