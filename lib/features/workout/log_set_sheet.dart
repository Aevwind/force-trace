import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../core/i18n/app_strings.dart';
import '../../core/theme/app_theme.dart';
import '../../core/widgets/common.dart';
import '../../data/models/models.dart';

class LogSetDraft {
  const LogSetDraft({
    required this.weightKg,
    required this.reps,
    required this.rpe,
    required this.restSeconds,
    required this.notes,
  });

  final double weightKg;
  final int reps;
  final double rpe;
  final int restSeconds;
  final String notes;
}

Future<LogSetDraft?> showLogSetSheet(
  BuildContext context, {
  required Exercise exercise,
  double initialWeight = 0,
}) {
  return showModalBottomSheet<LogSetDraft>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (context) =>
        _LogSetSheet(exercise: exercise, initialWeight: initialWeight),
  );
}

class _LogSetSheet extends StatefulWidget {
  const _LogSetSheet({required this.exercise, required this.initialWeight});

  final Exercise exercise;
  final double initialWeight;

  @override
  State<_LogSetSheet> createState() => _LogSetSheetState();
}

class _LogSetSheetState extends State<_LogSetSheet> {
  late final TextEditingController _weight = TextEditingController(
    text: widget.initialWeight > 0 ? _trim(widget.initialWeight) : '',
  );
  late final TextEditingController _reps = TextEditingController(text: '8');
  late final TextEditingController _notes = TextEditingController();
  double _rpe = 8;
  int _rest = 90;

  static String _trim(double value) {
    return value == value.roundToDouble()
        ? value.toStringAsFixed(0)
        : value.toStringAsFixed(1);
  }

  @override
  void dispose() {
    _weight.dispose();
    _reps.dispose();
    _notes.dispose();
    super.dispose();
  }

  void _save() {
    final weight = double.tryParse(_weight.text.trim()) ?? 0;
    final reps = int.tryParse(_reps.text.trim()) ?? 0;
    if (reps <= 0) {
      showAppSnack(
        context,
        context.isZh ? '请输入有效次数' : 'Enter reps',
        error: true,
      );
      return;
    }
    Navigator.of(context).pop(
      LogSetDraft(
        weightKg: weight,
        reps: reps,
        rpe: _rpe,
        restSeconds: _rest,
        notes: _notes.text.trim(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.viewInsetsOf(context).bottom;
    return Padding(
      padding: EdgeInsets.only(bottom: bottomInset),
      child: Container(
        decoration: const BoxDecoration(
          color: AppColors.backgroundSoft,
          borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
        ),
        padding: const EdgeInsets.fromLTRB(22, 14, 22, 22),
        child: SafeArea(
          top: false,
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
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
                const SizedBox(height: 18),
                Row(
                  children: [
                    Container(
                      width: 42,
                      height: 42,
                      decoration: BoxDecoration(
                        color: AppColors.orange.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(13),
                      ),
                      child: const Icon(
                        Icons.edit_note_rounded,
                        color: AppColors.orange,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            context.t('logSetTitle'),
                            style: Theme.of(context).textTheme.titleLarge,
                          ),
                          Text(
                            widget.exercise.displayName(
                              Localizations.localeOf(context).languageCode,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: Theme.of(context).textTheme.bodyMedium,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 22),
                Row(
                  children: [
                    Expanded(
                      child: _NumberField(
                        controller: _weight,
                        label: context.t('logSetWeight'),
                        hint: context.t('weightPlaceholder'),
                        allowDecimal: true,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _NumberField(
                        controller: _reps,
                        label: context.t('logSetReps'),
                        hint: '8',
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                Row(
                  children: [
                    Text(
                      context.t('logSetRpe'),
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const Spacer(),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 11,
                        vertical: 5,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.orange.withValues(alpha: 0.13),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        'RPE ${_rpe.toStringAsFixed(1)}',
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w800,
                          color: AppColors.orange,
                        ),
                      ),
                    ),
                  ],
                ),
                Slider(
                  value: _rpe,
                  min: 5,
                  max: 10,
                  divisions: 10,
                  label: _rpe.toStringAsFixed(1),
                  onChanged: (value) => setState(() => _rpe = value),
                ),
                const SizedBox(height: 4),
                Text(
                  context.t('logSetRest'),
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 10),
                Wrap(
                  spacing: 8,
                  children: [
                    for (final seconds in [60, 90, 120, 180])
                      ChoiceChip(
                        label: Text('${seconds}s'),
                        selected: _rest == seconds,
                        onSelected: (_) => setState(() => _rest = seconds),
                      ),
                  ],
                ),
                const SizedBox(height: 18),
                TextField(
                  controller: _notes,
                  maxLines: 2,
                  textInputAction: TextInputAction.done,
                  decoration: InputDecoration(
                    hintText: context.isZh ? '备注（可选）' : 'Notes (optional)',
                  ),
                ),
                const SizedBox(height: 20),
                GradientButton(
                  label: context.t('commonSave'),
                  icon: Icons.check_rounded,
                  onPressed: _save,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _NumberField extends StatelessWidget {
  const _NumberField({
    required this.controller,
    required this.label,
    required this.hint,
    this.allowDecimal = false,
  });

  final TextEditingController controller;
  final String label;
  final String hint;
  final bool allowDecimal;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: Theme.of(context).textTheme.labelMedium),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          keyboardType: TextInputType.numberWithOptions(decimal: allowDecimal),
          inputFormatters: [
            FilteringTextInputFormatter.allow(
              allowDecimal ? RegExp(r'[0-9.]') : RegExp(r'[0-9]'),
            ),
          ],
          style: numericStyle(size: 24, letterSpacing: -0.4),
          decoration: InputDecoration(hintText: hint),
        ),
      ],
    );
  }
}

Future<void> showRestTimer(
  BuildContext context, {
  required int seconds,
  required String exerciseName,
  required int nextSet,
}) {
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    isDismissible: true,
    backgroundColor: Colors.transparent,
    builder: (context) => _RestTimerSheet(
      seconds: seconds,
      exerciseName: exerciseName,
      nextSet: nextSet,
    ),
  );
}

class _RestTimerSheet extends StatefulWidget {
  const _RestTimerSheet({
    required this.seconds,
    required this.exerciseName,
    required this.nextSet,
  });

  final int seconds;
  final String exerciseName;
  final int nextSet;

  @override
  State<_RestTimerSheet> createState() => _RestTimerSheetState();
}

class _RestTimerSheetState extends State<_RestTimerSheet> {
  late int _remaining = widget.seconds;
  Timer? _timer;
  bool _paused = false;

  @override
  void initState() {
    super.initState();
    _start();
  }

  void _start() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (!mounted) return;
      if (_remaining <= 1) {
        _timer?.cancel();
        setState(() => _remaining = 0);
        Future<void>.delayed(const Duration(milliseconds: 600), () {
          if (mounted) Navigator.of(context).maybePop();
        });
        return;
      }
      setState(() => _remaining--);
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final progress = widget.seconds == 0
        ? 0.0
        : 1 - (_remaining / widget.seconds);
    return Container(
      decoration: const BoxDecoration(
        color: AppColors.backgroundSoft,
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      padding: const EdgeInsets.fromLTRB(22, 14, 22, 26),
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 38,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.stroke,
                borderRadius: BorderRadius.circular(4),
              ),
            ),
            const SizedBox(height: 22),
            Text(
              context.t('restTimer'),
              style: Theme.of(context).textTheme.labelMedium,
            ),
            const SizedBox(height: 18),
            SizedBox(
              width: 172,
              height: 172,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  SizedBox(
                    width: 172,
                    height: 172,
                    child: CircularProgressIndicator(
                      value: progress,
                      strokeWidth: 6,
                      backgroundColor: AppColors.strokeSoft,
                      valueColor: const AlwaysStoppedAnimation(AppColors.green),
                      strokeCap: StrokeCap.round,
                    ),
                  ),
                  Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        _remaining == 0
                            ? 'GO'
                            : '${_remaining ~/ 60}:${(_remaining % 60).toString().padLeft(2, '0')}',
                        style: numericStyle(
                          size: 42,
                          color: _remaining == 0
                              ? AppColors.green
                              : AppColors.text,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        context.isZh
                            ? '第 ${widget.nextSet} 组准备'
                            : 'Set ${widget.nextSet} ready',
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            Text(
              widget.exerciseName,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 18),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () {
                      setState(() => _paused = !_paused);
                      if (_paused) {
                        _timer?.cancel();
                      } else {
                        _start();
                      }
                    },
                    icon: Icon(
                      _paused ? Icons.play_arrow_rounded : Icons.pause_rounded,
                      size: 18,
                    ),
                    label: Text(
                      _paused ? context.t('resume') : context.t('pause'),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: FilledButton(
                    onPressed: () => Navigator.of(context).maybePop(),
                    child: Text(context.t('restSkip')),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
