import 'dart:ui';

/// Pixel-to-metre calibration produced before a set.
enum CalibrationMethod { plate, height, quick }

class Calibration {
  const Calibration({
    required this.method,
    required this.plateDiameterCm,
    required this.platePixelDiameter,
    required this.metersPerPixel,
    required this.tiltDegrees,
    required this.userHeightCm,
    required this.createdAt,
    this.confidence = 0.95,
  });

  final CalibrationMethod method;
  final double plateDiameterCm;
  final double platePixelDiameter;
  final double metersPerPixel;
  final double tiltDegrees;
  final double userHeightCm;
  final DateTime createdAt;
  final double confidence;

  static Calibration? fromPlate({
    required double plateDiameterCm,
    required double platePixelDiameter,
    double tiltDegrees = 0,
    double userHeightCm = 175,
    double confidence = 0.95,
    CalibrationMethod method = CalibrationMethod.plate,
  }) {
    if (platePixelDiameter <= 1 || plateDiameterCm <= 0) return null;
    return Calibration(
      method: method,
      plateDiameterCm: plateDiameterCm,
      platePixelDiameter: platePixelDiameter,
      metersPerPixel: (plateDiameterCm / 100) / platePixelDiameter,
      tiltDegrees: tiltDegrees,
      userHeightCm: userHeightCm,
      createdAt: DateTime.now(),
      confidence: confidence,
    );
  }

  static Calibration? fromHeight({
    required double userHeightCm,
    required double bodyPixelHeight,
    double tiltDegrees = 0,
  }) {
    if (bodyPixelHeight <= 1 || userHeightCm <= 0) return null;
    return Calibration(
      method: CalibrationMethod.height,
      plateDiameterCm: 45,
      platePixelDiameter: 0,
      metersPerPixel: (userHeightCm / 100) / bodyPixelHeight,
      tiltDegrees: tiltDegrees,
      userHeightCm: userHeightCm,
      createdAt: DateTime.now(),
      confidence: 0.86,
    );
  }

  double pixelsToMeters(double pixels) => pixels * metersPerPixel;
  double pixelsToCentimeters(double pixels) => pixels * metersPerPixel * 100;

  String get methodLabelKey => switch (method) {
    CalibrationMethod.plate => 'methodPlate',
    CalibrationMethod.height => 'methodHeight',
    CalibrationMethod.quick => 'quickCalibrate',
  };

  /// Supports both a level/landscape mount (≈0°) and an upright portrait mount
  /// (≈±90°). The phone is rarely exactly at 90°, so accept a tolerant band.
  bool get isLevel => tiltDegrees.abs() < 8 || tiltDegrees.abs() > 55;
}

class PlateDetection {
  const PlateDetection({required this.pixelDiameter, required this.confidence});

  final double pixelDiameter;
  final double confidence;

  bool get isValid => pixelDiameter > 20 && confidence > 0.5;
}

/// Frame used by the calibration stage. Kept separate from live workout data.
class CalibrationFrame {
  const CalibrationFrame({
    required this.plateDiameterPixels,
    required this.bodyPixelHeight,
    required this.plateCenter,
    required this.tiltDegrees,
    required this.skeleton,
  });

  final double plateDiameterPixels;
  final double bodyPixelHeight;
  final Offset plateCenter;
  final double tiltDegrees;
  final Map<String, Offset> skeleton;
}
