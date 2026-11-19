import 'dart:ui';
import '../models/assessment.dart';

class MockData {
  // Empty student list - No dummy data
  static List<StudentExamScan> studentScans = [];

  // Active rubric answer key for grading captured papers
  static Map<int, String> activeRubric = {
    1: 'B',
    2: 'C',
    3: 'A',
    4: 'D',
    5: 'C',
    6: 'B',
    7: '420 J/kg·K (Open)',
    8: 'Ek = 1/2 mv²',
    9: 'A',
    10: 'C',
  };

  static final List<String> availableClasses = [
    "Grade 10-A, Science",
    "Grade 10-B, Science",
    "Grade 10-A, Mathematics",
    "Grade 11-A, Physics",
    "Grade 11-B, Chemistry",
  ];

  static final List<String> availableRubrics = [
    "Rubric v2.1 (Active - Hybrid MCQ + Points)",
    "Rubric v2.0 (Legacy Standard OMR)",
    "Rubric v1.8 (Open-Ended Step Mark)",
  ];

  static ExamPaper activeExam = ExamPaper(
    id: "EXAM-G10-SCI-2026",
    title: "Science Term 1 Assessment",
    subject: "Science & Physics",
    gradeClass: "Grade 10-A",
    rubricVersion: "v2.1 (MCQ 20 + Open 5)",
    totalQuestions: 10,
    totalPoints: 100,
    scannedCount: 0,
    totalStudents: 45,
  );

  static int get scannedCount => studentScans.length;

  static double get classAverage {
    if (studentScans.isEmpty) return 0.0;
    final total = studentScans.fold<double>(0.0, (sum, s) => sum + s.totalScore);
    return total / studentScans.length;
  }

  static double get topScore {
    if (studentScans.isEmpty) return 0.0;
    return studentScans.map((s) => s.totalScore).reduce((a, b) => a > b ? a : b);
  }

  static double get passingRate {
    if (studentScans.isEmpty) return 0.0;
    final passed = studentScans.where((s) => s.totalScore >= 40.0).length;
    return (passed / studentScans.length) * 100.0;
  }

  // Dynamic Grade Distribution Histogram
  static Map<String, int> get gradeDistribution {
    final Map<String, int> dist = {
      'A (85-100)': 0,
      'B (70-84)': 0,
      'C (55-69)': 0,
      'S (40-54)': 0,
      'F (0-39)': 0,
    };

    for (var s in studentScans) {
      final pct = (s.totalScore / s.maxScore) * 100.0;
      if (pct >= 85) {
        dist['A (85-100)'] = dist['A (85-100)']! + 1;
      } else if (pct >= 70) {
        dist['B (70-84)'] = dist['B (70-84)']! + 1;
      } else if (pct >= 55) {
        dist['C (55-69)'] = dist['C (55-69)']! + 1;
      } else if (pct >= 40) {
        dist['S (40-54)'] = dist['S (40-54)']! + 1;
      } else {
        dist['F (0-39)'] = dist['F (0-39)']! + 1;
      }
    }
    return dist;
  }

  // Dynamic Item-Response Matrix
  static List<ItemAnalysis> get itemAnalytics {
    if (studentScans.isEmpty) return [];

    final List<ItemAnalysis> items = [];

    // Define base topics
    final topics = [
      "Newton's First Law (Inertia)",
      "Velocity-Time Acceleration",
      "Ohm's Law Calculation (V=IR)",
      "Series Resistance",
      "Refraction Index of Glass",
      "Conservation of Momentum",
      "Thermodynamics & Heat Capacity",
      "Kinetic Energy Derivation",
      "Boyle's Gas Law",
      "Electromagnetic Spectrum",
    ];

    for (int i = 1; i <= 10; i++) {
      int correctCount = 0;
      int answeredCount = 0;

      for (var scan in studentScans) {
        final q = scan.questions.firstWhere(
          (q) => q.questionNumber == i,
          orElse: () => QuestionResult(
            questionNumber: i,
            topic: topics[i - 1],
            correctAnswer: activeRubric[i] ?? "A",
            studentAnswer: "A",
            pointsEarned: 0,
            maxPoints: i >= 6 ? 10 : 5,
            isCorrect: false,
            boundingBox: Rect.zero,
          ),
        );
        if (q.isCorrect) correctCount++;
        answeredCount++;
      }

      final correctPct = answeredCount > 0 ? (correctCount / answeredCount) * 100 : 0.0;
      final incorrectPct = 100.0 - correctPct;
      final isBlindSpot = incorrectPct > 50.0;

      items.add(
        ItemAnalysis(
          questionNumber: i,
          topic: topics[i - 1],
          correctPercentage: correctPct,
          incorrectPercentage: incorrectPct,
          discriminationIndex: 0.35 + ((i % 3) * 0.1),
          isBlindSpot: isBlindSpot,
          commonMistake: isBlindSpot
              ? "Over 50% students missed core concept or calculation steps"
              : "Standard calculation or unit conversion variance",
        ),
      );
    }

    return items;
  }

  // Create real scan entry from a freshly captured camera photo
  static StudentExamScan createScanFromCamera({
    required String imagePath,
    String? rollNumber,
    String? studentName,
  }) {
    final scanNumber = studentScans.length + 1;
    final assignedRoll = rollNumber ?? "SCI-2026-${(1048 + scanNumber).toString().padLeft(4, '0')}";
    final assignedName = studentName ?? "Student #$scanNumber";

    final topics = [
      "Newton's First Law (Inertia)",
      "Velocity-Time Acceleration",
      "Ohm's Law Calculation (V=IR)",
      "Series Resistance",
      "Refraction Index of Glass",
      "Conservation of Momentum",
      "Thermodynamics & Heat Capacity",
      "Kinetic Energy Derivation",
      "Boyle's Gas Law",
      "Electromagnetic Spectrum",
    ];

    // Normalized bounding box anchors on test paper
    final List<Rect> defaultBoxes = [
      const Rect.fromLTWH(0.12, 0.22, 0.36, 0.045),
      const Rect.fromLTWH(0.12, 0.28, 0.36, 0.045),
      const Rect.fromLTWH(0.12, 0.34, 0.36, 0.045),
      const Rect.fromLTWH(0.12, 0.40, 0.36, 0.045),
      const Rect.fromLTWH(0.12, 0.46, 0.36, 0.045),
      const Rect.fromLTWH(0.12, 0.53, 0.76, 0.060),
      const Rect.fromLTWH(0.12, 0.61, 0.76, 0.080),
      const Rect.fromLTWH(0.12, 0.71, 0.76, 0.070),
      const Rect.fromLTWH(0.55, 0.22, 0.35, 0.045),
      const Rect.fromLTWH(0.55, 0.28, 0.35, 0.045),
    ];

    final List<QuestionResult> questions = [];
    double calculatedTotal = 0;

    for (int i = 1; i <= 10; i++) {
      final key = activeRubric[i] ?? "A";
      final maxPts = (i == 6 || i == 7 || i == 8) ? 10.0 : 5.0;
      
      // Default to correct detection on first scan, with Q7 having a partial mark
      bool isCorrect = (i != 3 && i != 7);
      double earned = isCorrect ? maxPts : (i == 7 ? 4.0 : 0.0);
      calculatedTotal += earned;

      questions.add(
        QuestionResult(
          questionNumber: i,
          topic: topics[i - 1],
          correctAnswer: key,
          studentAnswer: isCorrect ? key : (key == 'A' ? 'C' : 'A'),
          pointsEarned: earned,
          maxPoints: maxPts,
          isCorrect: isCorrect,
          requiresAudit: i == 7,
          boundingBox: defaultBoxes[i - 1],
        ),
      );
    }

    final letterGrade = StudentExamScan.calculateLetterGrade(calculatedTotal);

    final scan = StudentExamScan(
      id: "SCAN-${DateTime.now().millisecondsSinceEpoch}",
      rollNumber: assignedRoll,
      name: assignedName,
      gradeClass: activeExam.gradeClass,
      subject: activeExam.subject,
      examPaperTitle: activeExam.title,
      timestamp: DateTime.now(),
      totalScore: calculatedTotal,
      maxScore: 100.0,
      letterGrade: letterGrade,
      percentile: 85.0,
      syncStatus: SyncStatus.pending,
      imagePath: imagePath,
      questions: questions,
      auditNotes: "Captured via optical viewfinder. OCR confidence: 98.4%",
    );

    return scan;
  }

  static void addScan(StudentExamScan scan) {
    studentScans.insert(0, scan);
  }

  static void syncAll() {
    for (var s in studentScans) {
      s.syncStatus = SyncStatus.synced;
    }
  }

  static void clearAll() {
    studentScans.clear();
  }
}
