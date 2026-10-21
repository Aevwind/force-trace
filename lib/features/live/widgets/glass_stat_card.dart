import 'package:flutter/material.dart';

import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/common.dart';

class GlassStatCard extends StatelessWidget {
  const GlassStatCard({
    super.key,
    required this.label,
    required this.value,
    required this.unit,
    required this.accent,
    this.sub,
    this.secondary,
    this.progress,
    this.progressMarker,
    this.compact = false,
  });

  final String label;
  final String value;
  final String unit;
  final Color accent;
  final String? sub;
  final String? secondary;
  final double? progress;
  final double? progressMarker;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    return GlassPanel(
      radius: 16,
      blur: 14,
      tint: const Color(0x5C0B1218),
      borderColor: Colors.white.withValues(alpha: 0.1),
      padding: EdgeInsets.fromLTRB(
        compact ? 10 : 12,
        compact ? 9 : 10,
        compact ? 10 : 12,
        compact ? 9 : 10,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              Container(
                width: 4,
                height: 4,
                decoration: BoxDecoration(
                  color: accent,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: accent.withValues(alpha: 0.7),
                      blurRadius: 5,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: compact ? 8 : 8.5,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 0.9,
                    color: Colors.white.withValues(alpha: 0.62),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 5),
          Row(
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Flexible(
                child: Text(
                  value,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: numericStyle(
                    size: compact ? 22 : 25,
                    color: accent,
                    letterSpacing: -0.8,
                  ),
                ),
              ),
              const SizedBox(width: 3),
              Text(
                unit,
                style: TextStyle(
                  fontSize: compact ? 7.5 : 8,
                  fontWeight: FontWeight.w600,
                  color: Colors.white.withValues(alpha: 0.45),
                ),
              ),
            ],
          ),
          if (secondary != null || sub != null) ...[
            const SizedBox(height: 2),
            Text(
              secondary ?? sub!,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: compact ? 7.5 : 8,
                color: Colors.white.withValues(alpha: 0.52),
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
          if (progress != null) ...[
            const SizedBox(height: 6),
            LayoutBuilder(
              builder: (context, constraints) {
                final width = constraints.maxWidth;
                final value = progress!.clamp(0.0, 1.0);
                return Stack(
                  children: [
                    Container(
                      height: 3,
                      width: width,
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.09),
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                    Container(
                      height: 3,
                      width: width * value,
                      decoration: BoxDecoration(
                        color: accent,
                        borderRadius: BorderRadius.circular(2),
                        boxShadow: [
                          BoxShadow(
                            color: accent.withValues(alpha: 0.4),
                            blurRadius: 5,
                          ),
                        ],
                      ),
                    ),
                    if (progressMarker != null)
                      Positioned(
                        left: (width * progressMarker!.clamp(0.0, 1.0)).clamp(
                          0.0,
                          width - 2,
                        ),
                        top: -2,
                        child: Container(
                          width: 2,
                          height: 7,
                          color: Colors.white.withValues(alpha: 0.55),
                        ),
                      ),
                  ],
                );
              },
            ),
          ],
        ],
      ),
    );
  }
}
