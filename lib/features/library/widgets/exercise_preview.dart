import 'package:flutter/material.dart';

import '../../../core/i18n/app_strings.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/common.dart';
import '../../../data/models/models.dart';

/// Loads the dataset's matching thumbnail first. GIF decoding only starts when
/// requested and stops when switching back to the still image.
class ExercisePreview extends StatefulWidget {
  const ExercisePreview({super.key, required this.exercise});

  final Exercise exercise;

  @override
  State<ExercisePreview> createState() => _ExercisePreviewState();
}

class _ExercisePreviewState extends State<ExercisePreview> {
  static final _mediaBase = Uri.parse(
    'https://raw.githubusercontent.com/hasaneyldrm/exercises-dataset/main/',
  );

  bool _animated = false;
  int _retry = 0;

  @override
  void didUpdateWidget(covariant ExercisePreview oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.exercise.id != widget.exercise.id ||
        oldWidget.exercise.mediaId != widget.exercise.mediaId) {
      _animated = false;
      _retry = 0;
    }
  }

  @override
  Widget build(BuildContext context) {
    final exercise = widget.exercise;
    final hasMedia = exercise.id.isNotEmpty && exercise.mediaId.isNotEmpty;
    final filename = '${exercise.id}-${exercise.mediaId}';
    final url = _mediaBase
        .resolveUri(
          Uri(
            pathSegments: [
              _animated ? 'videos' : 'images',
              '$filename.${_animated ? 'gif' : 'jpg'}',
            ],
          ),
        )
        .toString();
    final locale = Localizations.localeOf(context).languageCode;

    return SurfaceCard(
      padding: EdgeInsets.zero,
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 10, 10, 10),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    context.t('exercisePreview'),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                SegmentedButton<bool>(
                  showSelectedIcon: false,
                  style: SegmentedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 10),
                    minimumSize: const Size(0, 36),
                    textStyle: const TextStyle(fontSize: 11),
                    visualDensity: VisualDensity.compact,
                  ),
                  segments: [
                    ButtonSegment(
                      value: false,
                      icon: const Icon(Icons.image_outlined, size: 15),
                      label: Text(context.t('previewImage')),
                    ),
                    ButtonSegment(
                      value: true,
                      icon: const Icon(
                        Icons.play_circle_outline_rounded,
                        size: 15,
                      ),
                      label: Text(context.t('previewAnimation')),
                    ),
                  ],
                  selected: {_animated},
                  onSelectionChanged: hasMedia
                      ? (selection) =>
                            setState(() => _animated = selection.single)
                      : null,
                ),
              ],
            ),
          ),
          AspectRatio(
            aspectRatio: 4 / 3,
            child: ColoredBox(
              color: hasMedia ? Colors.white : AppColors.surfaceHigh,
              child: hasMedia
                  ? Image.network(
                      url,
                      key: ValueKey('$url:$_retry'),
                      fit: BoxFit.contain,
                      gaplessPlayback: false,
                      semanticLabel:
                          '${exercise.displayName(locale)} · '
                          '${context.t(_animated ? 'previewAnimation' : 'previewImage')}',
                      loadingBuilder: (context, child, progress) {
                        if (progress == null) return child;
                        return const Center(
                          child: SizedBox(
                            width: 24,
                            height: 24,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          ),
                        );
                      },
                      errorBuilder: (context, error, stack) =>
                          _PreviewUnavailable(
                            label: context.t('previewLoadFailed'),
                            onRetry: () => setState(() => _retry++),
                          ),
                    )
                  : _PreviewUnavailable(label: context.t('previewUnavailable')),
            ),
          ),
          if (hasMedia)
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              child: Text(
                '© Gym visual — https://gymvisual.com/',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 9, color: AppColors.dim),
              ),
            ),
        ],
      ),
    );
  }
}

class _PreviewUnavailable extends StatelessWidget {
  const _PreviewUnavailable({required this.label, this.onRetry});

  final String label;
  final VoidCallback? onRetry;

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: AppColors.surfaceHigh,
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.image_not_supported_outlined,
              color: AppColors.dim,
              size: 32,
            ),
            const SizedBox(height: 10),
            Text(
              label,
              style: const TextStyle(fontSize: 12, color: AppColors.muted),
            ),
            if (onRetry != null) ...[
              const SizedBox(height: 6),
              TextButton.icon(
                onPressed: onRetry,
                icon: const Icon(Icons.refresh_rounded, size: 16),
                label: Text(context.t('previewRetry')),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
