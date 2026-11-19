import 'dart:ui';

enum SyncStatus { synced, pending, retrying }

class QuestionResult {
  final int questionNumber;
  final String topic;
  final String correctAnswer;
  final String studentAnswer;
  double pointsEarned;
  final double maxPoints;
  bool isCorrect;
  bool requiresAudit;
  final Rect boundingBox; // Normalized 0..1 bounding box on answer sheet

  QuestionResult({
    required this.questionNumber,
    required this.topic,
    required this.correctAnswer,
    required this.studentAnswer,
    required this.pointsEarned,
    required this.maxPoints,
    required this.isCorrect,
    this.requiresAudit = false,
    required this.boundingBox,
  });

  void overridePoints(double newPoints) {
    pointsEarned = newPoints;
    isCorrect = pointsEarned >= maxPoints;
    requiresAudit = true;
  }
}

class StudentExamScan {
  final String id;
  final String rollNumber;
  final String name;
  final String gradeClass;
  final String subject;
  final String examPaperTitle;
  final DateTime timestamp;
  double totalScore;
  final double maxScore;
  String letterGrade;
  final double percentile;
  SyncStatus syncStatus;
  final String imagePath;
  final List<QuestionResult> questions;
  String? auditNotes;

  StudentExamScan({
    required this.id,
    required this.rollNumber,
    required this.name,
    required this.gradeClass,
    required this.subject,
    required this.examPaperTitle,
    required this.timestamp,
    required this.totalScore,
    required this.maxScore,
    required this.letterGrade,
    required this.percentile,
    required this.syncStatus,
    required this.imagePath,
    required this.questions,
    this.auditNotes,
  });

  void recalculateScore() {
    double sum = 0;
    for (var q in questions) {
      sum += q.pointsEarned;
    }
    totalScore = sum;
    letterGrade = calculateLetterGrade((totalScore / maxScore) * 100);
  }

  static String calculateLetterGrade(double percentage) {
    if (percentage >= 85) return 'A';
    if (percentage >= 70) return 'B';
    if (percentage >= 55) return 'C';
    if (percentage >= 40) return 'S';
    return 'F';
  }
}

class ExamPaper {
  final String id;
  final String title;
  final String subject;
  final String gradeClass;
  final String rubricVersion;
  final int totalQuestions;
  final double totalPoints;
  final int scannedCount;
  final int totalStudents;

  ExamPaper({
    required this.id,
    required this.title,
    required this.subject,
    required this.gradeClass,
    required this.rubricVersion,
    required this.totalQuestions,
    required this.totalPoints,
    required this.scannedCount,
    required this.totalStudents,
  });
}

class ItemAnalysis {
  final int questionNumber;
  final String topic;
  final double correctPercentage;
  final double incorrectPercentage;
  final double discriminationIndex; // -1.0 to +1.0 (>0.3 is good, <0.1 ambiguous)
  final bool isBlindSpot; // >50% incorrect
  final String commonMistake;

  ItemAnalysis({
    required this.questionNumber,
    required this.topic,
    required this.correctPercentage,
    required this.incorrectPercentage,
    required this.discriminationIndex,
    required this.isBlindSpot,
    required this.commonMistake,
  });
}
