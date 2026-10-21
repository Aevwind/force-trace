import 'dart:math' as math;

String formatVelocity(double value, {int decimals = 2}) {
  if (!value.isFinite) return '0.00';
  return value.toStringAsFixed(decimals);
}

String formatNumber(double value, {int decimals = 1}) {
  if (!value.isFinite) return '0';
  if (value == value.roundToDouble()) return value.toStringAsFixed(0);
  return value.toStringAsFixed(decimals);
}

String formatDate(DateTime time) {
  final local = time.toLocal();
  return '${local.year}/${local.month.toString().padLeft(2, '0')}/${local.day.toString().padLeft(2, '0')}';
}

String formatTime(DateTime time) {
  final local = time.toLocal();
  return '${local.hour.toString().padLeft(2, '0')}:${local.minute.toString().padLeft(2, '0')}';
}

String formatDateShort(DateTime time, {bool zh = true}) {
  final local = time.toLocal();
  if (zh) return '${local.month}月${local.day}日';
  return '${local.month}/${local.day}';
}

String formatDuration(int milliseconds) {
  final seconds = milliseconds / 1000;
  if (seconds < 60) return '${seconds.toStringAsFixed(1)}s';
  final minutes = seconds ~/ 60;
  final rest = (seconds % 60).round();
  return '${minutes}m${rest.toString().padLeft(2, '0')}s';
}

String formatElapsed(Duration duration) {
  final minutes = duration.inMinutes;
  final seconds = duration.inSeconds % 60;
  return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
}

String formatVolume(double kg) {
  if (kg >= 1000) return '${(kg / 1000).toStringAsFixed(1)}t';
  return '${kg.round()}';
}

double clampDouble(double value, double min, double max) =>
    math.min(math.max(value, min), max);

String weekdayLabel(DateTime time, bool zh) {
  if (zh) {
    const labels = ['一', '二', '三', '四', '五', '六', '日'];
    return '周${labels[time.weekday - 1]}';
  }
  const labels = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
  return labels[time.weekday - 1];
}
