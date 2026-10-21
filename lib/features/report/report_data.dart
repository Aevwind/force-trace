import '../../data/models/models.dart';
import '../../domain/vbt/pose_models.dart';

class RepReport {
  const RepReport({
    required this.index,
    required this.meanVelocity,
    required this.peakVelocity,
    required this.romCm,
    required this.velocityLoss,
    required this.durationMs,
    required this.eccentricMs,
    required this.concentricMs,
    required this.isBestRep,
    required this.minKneeAngle,
    required this.minHipAngle,
  });

  final int index;
  final double meanVelocity;
  final double peakVelocity;
  final double romCm;
  final double velocityLoss;
  final int durationMs;
  final int eccentricMs;
  final int concentricMs;
  final bool isBestRep;
  final double minKneeAngle;
  final double minHipAngle;

  String get tempo =>
      '${(eccentricMs / 1000).toStringAsFixed(1)} : ${(concentricMs / 1000).toStringAsFixed(1)}';
}

class ReportData {
  const ReportData({
    required this.exerciseName,
    required this.tier,
    required this.startedAt,
    required this.finishedAt,
    required this.weightKg,
    required this.totalReps,
    required this.invalidReps,
    required this.reps,
    required this.avgMeanVelocity,
    required this.bestMeanVelocity,
    required this.peakVelocity,
    required this.bestRomCm,
    required this.velocityLoss,
    this.saved = false,
  });

  final String exerciseName;
  final int tier;
  final DateTime startedAt;
  final DateTime finishedAt;
  final double weightKg;
  final int totalReps;
  final int invalidReps;
  final List<RepReport> reps;
  final double avgMeanVelocity;
  final double bestMeanVelocity;
  final double peakVelocity;
  final double bestRomCm;
  final double velocityLoss;
  final bool saved;

  Duration get duration => finishedAt.difference(startedAt);

  RepReport? get bestRep {
    if (reps.isEmpty) return null;
    return reps.reduce((a, b) => a.meanVelocity >= b.meanVelocity ? a : b);
  }

  factory ReportData.fromSetResult(SetResult result, {bool saved = false}) {
    return ReportData(
      exerciseName: result.exerciseName,
      tier: result.tier,
      startedAt: result.startedAt,
      finishedAt: result.finishedAt,
      weightKg: result.weightKg,
      totalReps: result.totalReps,
      invalidReps: result.invalidReps,
      reps: result.reps
          .map(
            (rep) => RepReport(
              index: rep.index,
              meanVelocity: rep.meanVelocity,
              peakVelocity: rep.peakVelocity,
              romCm: rep.romCm,
              velocityLoss: rep.velocityLossPercent,
              durationMs: rep.durationMs,
              eccentricMs: rep.eccentricMs,
              concentricMs: rep.concentricMs,
              isBestRep: rep.isBestRep,
              minKneeAngle: rep.minKneeAngle,
              minHipAngle: rep.minHipAngle,
            ),
          )
          .toList(),
      avgMeanVelocity: result.avgMeanVelocity,
      bestMeanVelocity: result.bestMeanVelocity,
      peakVelocity: result.peakVelocity,
      bestRomCm: result.bestRomCm,
      velocityLoss: result.velocityLoss,
      saved: saved,
    );
  }

  factory ReportData.fromSessionDetail(SessionDetail detail) {
    final session = detail.session;
    return ReportData(
      exerciseName: session.exerciseName,
      tier: session.tier,
      startedAt: session.startedAt,
      finishedAt: session.finishedAt,
      weightKg: session.weightKg,
      totalReps: session.totalReps,
      invalidReps: session.invalidReps,
      reps: detail.reps
          .map(
            (rep) => RepReport(
              index: rep.repIndex,
              meanVelocity: rep.meanVelocity,
              peakVelocity: rep.peakVelocity,
              romCm: rep.romCm,
              velocityLoss: rep.velocityLossPercent,
              durationMs: rep.durationMs,
              eccentricMs: rep.eccentricMs,
              concentricMs: rep.concentricMs,
              isBestRep: rep.isBestRep,
              minKneeAngle: rep.minKneeAngle,
              minHipAngle: rep.minHipAngle,
            ),
          )
          .toList(),
      avgMeanVelocity: session.avgMeanVelocity,
      bestMeanVelocity: session.bestMeanVelocity,
      peakVelocity: session.peakVelocity,
      bestRomCm: session.bestRomCm,
      velocityLoss: session.velocityLoss,
      saved: true,
    );
  }
}
