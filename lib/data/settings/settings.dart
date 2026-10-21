import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AppSettings {
  const AppSettings({
    this.locale = 'zh',
    this.voiceEnabled = true,
    this.vlThreshold = 20,
    this.plateDiameterCm = 45,
    this.userHeightCm = 175,
    this.autoStopOnVl = true,
    this.showDemoBanner = true,
  });

  final String locale;
  final bool voiceEnabled;
  final double vlThreshold;
  final double plateDiameterCm;
  final double userHeightCm;
  final bool autoStopOnVl;
  final bool showDemoBanner;

  bool get isZh => locale == 'zh';

  AppSettings copyWith({
    String? locale,
    bool? voiceEnabled,
    double? vlThreshold,
    double? plateDiameterCm,
    double? userHeightCm,
    bool? autoStopOnVl,
    bool? showDemoBanner,
  }) {
    return AppSettings(
      locale: locale ?? this.locale,
      voiceEnabled: voiceEnabled ?? this.voiceEnabled,
      vlThreshold: vlThreshold ?? this.vlThreshold,
      plateDiameterCm: plateDiameterCm ?? this.plateDiameterCm,
      userHeightCm: userHeightCm ?? this.userHeightCm,
      autoStopOnVl: autoStopOnVl ?? this.autoStopOnVl,
      showDemoBanner: showDemoBanner ?? this.showDemoBanner,
    );
  }

  Map<String, dynamic> toJson() => {
    'locale': locale,
    'voiceEnabled': voiceEnabled,
    'vlThreshold': vlThreshold,
    'plateDiameterCm': plateDiameterCm,
    'userHeightCm': userHeightCm,
    'autoStopOnVl': autoStopOnVl,
    'showDemoBanner': showDemoBanner,
  };

  factory AppSettings.fromJson(Map<String, dynamic> json) {
    return AppSettings(
      locale: (json['locale'] as String?) ?? 'zh',
      voiceEnabled: (json['voiceEnabled'] as bool?) ?? true,
      vlThreshold: (json['vlThreshold'] as num?)?.toDouble() ?? 20,
      plateDiameterCm: (json['plateDiameterCm'] as num?)?.toDouble() ?? 45,
      userHeightCm: (json['userHeightCm'] as num?)?.toDouble() ?? 175,
      autoStopOnVl: (json['autoStopOnVl'] as bool?) ?? true,
      showDemoBanner: (json['showDemoBanner'] as bool?) ?? true,
    );
  }
}

class SettingsController extends ChangeNotifier {
  SettingsController(this._prefs) : _value = _load(_prefs);

  static const _key = 'force_trace_settings_v1';

  final SharedPreferences _prefs;
  AppSettings _value;

  AppSettings get value => _value;

  static AppSettings _load(SharedPreferences prefs) {
    final raw = prefs.getString(_key);
    if (raw == null) return const AppSettings();
    try {
      return AppSettings.fromJson(
        (jsonDecode(raw) as Map).cast<String, dynamic>(),
      );
    } catch (_) {
      return const AppSettings();
    }
  }

  Future<void> update(AppSettings next) async {
    _value = next;
    notifyListeners();
    await _prefs.setString(_key, jsonEncode(next.toJson()));
  }

  Future<void> setLocale(String locale) =>
      update(_value.copyWith(locale: locale));

  Future<void> toggleVoice() =>
      update(_value.copyWith(voiceEnabled: !_value.voiceEnabled));

  Future<void> setVlThreshold(double value) =>
      update(_value.copyWith(vlThreshold: value));

  Future<void> setPlateDiameter(double value) =>
      update(_value.copyWith(plateDiameterCm: value));

  Future<void> setUserHeight(double value) =>
      update(_value.copyWith(userHeightCm: value));

  Future<void> setAutoStop(bool value) =>
      update(_value.copyWith(autoStopOnVl: value));

  Future<void> reset() => update(const AppSettings());
}
