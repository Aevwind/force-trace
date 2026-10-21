import 'dart:math' as math;
import 'dart:ui';

/// Angle in degrees at [vertex] formed by [a] and [c] (2D, screen space).
double jointAngle(Offset a, Offset vertex, Offset c) {
  final v1 = a - vertex;
  final v2 = c - vertex;
  final denominator = v1.distance * v2.distance;
  if (denominator < 1e-9) return 0;
  final cosine = ((v1.dx * v2.dx + v1.dy * v2.dy) / denominator).clamp(
    -1.0,
    1.0,
  );
  return math.acos(cosine) * 180 / math.pi;
}

/// Hip angle: shoulder → hip → knee.
double hipAngle(Offset shoulder, Offset hip, Offset knee) =>
    jointAngle(shoulder, hip, knee);

/// Knee angle: hip → knee → ankle.
double kneeAngle(Offset hip, Offset knee, Offset ankle) =>
    jointAngle(hip, knee, ankle);

/// Elbow angle: shoulder → elbow → wrist.
double elbowAngle(Offset shoulder, Offset elbow, Offset wrist) =>
    jointAngle(shoulder, elbow, wrist);

/// Signed angle of the vector from [from] to [to] in screen coordinates.
double vectorAngle(Offset from, Offset to) => math.atan2(to.dy, to.dx);

/// Formats an angle for the HUD (rounded whole degrees).
String formatAngle(double value) => '${value.round()}°';
