import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/providers.dart';
import '../../core/i18n/app_strings.dart';
import '../../core/theme/app_theme.dart';
import '../../core/widgets/common.dart';
import '../shell/home_shell.dart';

class SettingsPage extends ConsumerWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final controller = ref.watch(settingsProvider);
    final settings = controller.value;

    return SafeArea(
      bottom: false,
      child: PageWidth(
        maxWidth: 1040,
        child: ListView(
          padding: const EdgeInsets.only(bottom: 118),
          children: [
            PageHeader(
              title: context.t('settingsTitle'),
              subtitle: context.isZh ? '训练偏好与数据' : 'Preferences & data',
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(22),
                  gradient: const LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [Color(0xFF17261D), AppColors.surface],
                  ),
                  border: Border.all(
                    color: AppColors.green.withValues(alpha: 0.18),
                  ),
                ),
                child: Row(
                  children: [
                    const AppLogoMark(size: 48),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            context.isZh ? '力迹运动员' : 'ForceTrace Athlete',
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                          const SizedBox(height: 3),
                          Text(
                            'VBT · ${context.t('settingsVersion')}',
                            style: const TextStyle(
                              fontSize: 9.5,
                              color: AppColors.dim,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              const PulseDot(size: 6),
                              const SizedBox(width: 6),
                              Text(
                                context.t('demoBadge'),
                                style: const TextStyle(
                                  fontSize: 9,
                                  fontWeight: FontWeight.w700,
                                  letterSpacing: 0.8,
                                  color: AppColors.green,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const TierBadge(tierValue: 1),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
            _SectionLabel(label: context.t('settingsLanguage')),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: _SettingsCard(
                children: [
                  _LanguageRow(
                    selected: settings.locale,
                    onChanged: controller.setLocale,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            _SectionLabel(label: context.t('settingsVoice')),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: _SettingsCard(
                children: [
                  _SwitchRow(
                    icon: Icons.record_voice_over_rounded,
                    title: context.t('settingsVoice'),
                    subtitle: context.t('settingsVoiceDesc'),
                    value: settings.voiceEnabled,
                    onChanged: (_) => controller.toggleVoice(),
                  ),
                  const _Divider(),
                  _SwitchRow(
                    icon: Icons.stop_circle_outlined,
                    title: context.t('settingsAutoStop'),
                    subtitle: context.t('settingsAutoStopDesc'),
                    value: settings.autoStopOnVl,
                    onChanged: controller.setAutoStop,
                  ),
                  const _Divider(),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(14, 14, 14, 10),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            const Icon(
                              Icons.speed_rounded,
                              size: 18,
                              color: AppColors.muted,
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Text(
                                context.t('settingsVl'),
                                style: const TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                            Text(
                              '${settings.vlThreshold.round()}%',
                              style: numericStyle(
                                size: 17,
                                color: AppColors.orange,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 6),
                        Text(
                          context.t('settingsVlDesc'),
                          style: const TextStyle(
                            fontSize: 10.5,
                            color: AppColors.dim,
                          ),
                        ),
                        Slider(
                          value: settings.vlThreshold,
                          min: 5,
                          max: 40,
                          divisions: 35,
                          onChanged: (value) =>
                              controller.setVlThreshold(value),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            _SectionLabel(label: context.t('settingsPlate')),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: _SettingsCard(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(14),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            const Icon(
                              Icons.circle_outlined,
                              size: 18,
                              color: AppColors.muted,
                            ),
                            const SizedBox(width: 10),
                            Text(
                              context.t('settingsPlate'),
                              style: const TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const Spacer(),
                            Text(
                              '${settings.plateDiameterCm.round()} cm',
                              style: numericStyle(
                                size: 15,
                                color: AppColors.green,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 5),
                        Text(
                          context.t('settingsPlateDesc'),
                          style: const TextStyle(
                            fontSize: 10.5,
                            color: AppColors.dim,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            for (final diameter in [35.0, 45.0, 50.0]) ...[
                              Expanded(
                                child: GestureDetector(
                                  onTap: () =>
                                      controller.setPlateDiameter(diameter),
                                  child: AnimatedContainer(
                                    duration: const Duration(milliseconds: 160),
                                    height: 38,
                                    margin: const EdgeInsets.only(right: 8),
                                    decoration: BoxDecoration(
                                      color:
                                          settings.plateDiameterCm == diameter
                                          ? AppColors.green.withValues(
                                              alpha: 0.13,
                                            )
                                          : AppColors.surfaceHigh,
                                      borderRadius: BorderRadius.circular(10),
                                      border: Border.all(
                                        color:
                                            settings.plateDiameterCm == diameter
                                            ? AppColors.green.withValues(
                                                alpha: 0.4,
                                              )
                                            : AppColors.strokeSoft,
                                      ),
                                    ),
                                    alignment: Alignment.center,
                                    child: Text(
                                      '${diameter.round()}',
                                      style: TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.w700,
                                        color:
                                            settings.plateDiameterCm == diameter
                                            ? AppColors.green
                                            : AppColors.muted,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ],
                        ),
                      ],
                    ),
                  ),
                  const _Divider(),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(14, 14, 14, 8),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            const Icon(
                              Icons.accessibility_new_rounded,
                              size: 18,
                              color: AppColors.muted,
                            ),
                            const SizedBox(width: 10),
                            Text(
                              context.t('settingsHeight'),
                              style: const TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const Spacer(),
                            Text(
                              '${settings.userHeightCm.round()} cm',
                              style: numericStyle(
                                size: 15,
                                color: AppColors.green,
                              ),
                            ),
                          ],
                        ),
                        Slider(
                          value: settings.userHeightCm,
                          min: 140,
                          max: 210,
                          divisions: 70,
                          onChanged: (value) => controller.setUserHeight(value),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            _SectionLabel(label: context.t('settingsAbout')),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: _SettingsCard(
                children: [
                  _SwitchRow(
                    icon: Icons.science_outlined,
                    title: context.t('settingsDemoBanner'),
                    subtitle: context.t('demoBadge'),
                    value: settings.showDemoBanner,
                    onChanged: (value) => controller.update(
                      settings.copyWith(showDemoBanner: value),
                    ),
                  ),
                  const _Divider(),
                  ListTile(
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 2,
                    ),
                    leading: const Icon(
                      Icons.info_outline_rounded,
                      size: 19,
                      color: AppColors.muted,
                    ),
                    title: Text(
                      context.t('settingsAbout'),
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    subtitle: Text(
                      context.t('settingsVersion'),
                      style: const TextStyle(
                        fontSize: 10,
                        color: AppColors.dim,
                      ),
                    ),
                    trailing: const Icon(
                      Icons.chevron_right_rounded,
                      color: AppColors.dim,
                      size: 19,
                    ),
                    onTap: () => _showAbout(context),
                  ),
                  const _Divider(),
                  ListTile(
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 2,
                    ),
                    leading: const Icon(
                      Icons.delete_outline_rounded,
                      size: 19,
                      color: AppColors.orange,
                    ),
                    title: Text(
                      context.t('settingsReset'),
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: AppColors.orange,
                      ),
                    ),
                    subtitle: Text(
                      context.t('settingsResetDesc'),
                      style: const TextStyle(
                        fontSize: 10,
                        color: AppColors.dim,
                      ),
                    ),
                    onTap: () => _confirmReset(context, ref),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            Center(
              child: Text(
                'ForceTrace · made with Flutter',
                style: TextStyle(
                  fontSize: 9,
                  color: AppColors.dim.withValues(alpha: 0.7),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showAbout(BuildContext context) {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: const BoxDecoration(
          color: AppColors.backgroundSoft,
          borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
        ),
        padding: const EdgeInsets.fromLTRB(24, 14, 24, 26),
        child: SafeArea(
          top: false,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 38,
                  height: 4,
                  decoration: BoxDecoration(
                    color: AppColors.stroke,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  const AppLogoMark(size: 40),
                  const SizedBox(width: 12),
                  Text(
                    context.t('settingsAbout'),
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Text(
                context.t('settingsAboutBody'),
                style: const TextStyle(
                  fontSize: 13,
                  height: 1.7,
                  color: AppColors.muted,
                ),
              ),
              const SizedBox(height: 16),
              _AboutLine(
                icon: Icons.dataset_outlined,
                text: context.t('settingsDataset'),
              ),
              const SizedBox(height: 9),
              _AboutLine(
                icon: Icons.copyright_rounded,
                text: context.t('settingsAttribution'),
              ),
              const SizedBox(height: 9),
              _AboutLine(
                icon: Icons.accessibility_new_rounded,
                text: context.t('bodyAtlasAttribution'),
              ),
              const SizedBox(height: 9),
              _AboutLine(
                icon: Icons.memory_rounded,
                text: context.isZh
                    ? '端侧架构：Drift / SQLite · One-Euro · 动作状态机 · CustomPainter HUD'
                    : 'On-device: Drift / SQLite · One-Euro · rep state machine · CustomPainter HUD',
              ),
              const SizedBox(height: 9),
              _AboutLine(
                icon: Icons.science_outlined,
                text: context.t('demoNoticeBody'),
              ),
              const SizedBox(height: 22),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: Text(context.t('commonClose')),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _confirmReset(BuildContext context, WidgetRef ref) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(context.t('settingsReset')),
        content: Text(
          context.isZh ? '将清空所有 VBT 组、容量记录与今日计划，并重新生成示例计划。此操作不可撤销。' : 'This clears all VBT sets, volume logs and today\'s plan, then recreates the starter plan. It cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(context.t('commonCancel')),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: Text(
              context.isZh ? '清空' : 'Reset',
              style: const TextStyle(color: AppColors.red),
            ),
          ),
        ],
      ),
    );
    if (confirmed != true) return;
    await ref.read(workoutRepositoryProvider).resetAll();
    await ref.read(seedServiceProvider).ensureSeeded();
    ref.invalidate(sessionsProvider);
    ref.invalidate(setLogsProvider);
    ref.invalidate(todayPlanProvider);
    if (context.mounted) {
      showAppSnack(context, context.t('settingsResetDone'));
    }
  }
}

class _SectionLabel extends StatelessWidget {
  const _SectionLabel({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 0, 24, 9),
      child: Text(
        label.toUpperCase(),
        style: const TextStyle(
          fontSize: 9.5,
          fontWeight: FontWeight.w800,
          letterSpacing: 1.4,
          color: AppColors.dim,
        ),
      ),
    );
  }
}

class _SettingsCard extends StatelessWidget {
  const _SettingsCard({required this.children});

  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.strokeSoft),
      ),
      // ListTile needs a Material ancestor for ink splashes; the decorated
      // Container alone is not enough and triggers a debug assertion.
      child: Material(
        type: MaterialType.transparency,
        child: Column(children: children),
      ),
    );
  }
}

class _Divider extends StatelessWidget {
  const _Divider();

  @override
  Widget build(BuildContext context) {
    return const Divider(height: 1, indent: 42, endIndent: 14);
  }
}

class _SwitchRow extends StatelessWidget {
  const _SwitchRow({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.value,
    required this.onChanged,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final bool value;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(14, 10, 10, 10),
      child: Row(
        children: [
          Icon(icon, size: 18, color: AppColors.muted),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: const TextStyle(fontSize: 10, color: AppColors.dim),
                ),
              ],
            ),
          ),
          Switch(value: value, onChanged: onChanged),
        ],
      ),
    );
  }
}

class _LanguageRow extends StatelessWidget {
  const _LanguageRow({required this.selected, required this.onChanged});

  final String selected;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8),
      child: Row(
        children: [
          Expanded(
            child: _LanguageButton(
              label: context.t('settingsChinese'),
              selected: selected == 'zh',
              onTap: () => onChanged('zh'),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: _LanguageButton(
              label: context.t('settingsEnglish'),
              selected: selected == 'en',
              onTap: () => onChanged('en'),
            ),
          ),
        ],
      ),
    );
  }
}

class _LanguageButton extends StatelessWidget {
  const _LanguageButton({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 160),
        height: 42,
        decoration: BoxDecoration(
          color: selected
              ? AppColors.green.withValues(alpha: 0.12)
              : AppColors.surfaceHigh,
          borderRadius: BorderRadius.circular(11),
          border: Border.all(
            color: selected
                ? AppColors.green.withValues(alpha: 0.35)
                : AppColors.strokeSoft,
          ),
        ),
        alignment: Alignment.center,
        child: Text(
          label,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w700,
            color: selected ? AppColors.green : AppColors.muted,
          ),
        ),
      ),
    );
  }
}

class _AboutLine extends StatelessWidget {
  const _AboutLine({required this.icon, required this.text});

  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 14, color: AppColors.dim),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            text,
            style: const TextStyle(
              fontSize: 10,
              height: 1.55,
              color: AppColors.dim,
            ),
          ),
        ),
      ],
    );
  }
}
