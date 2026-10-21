import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_body_atlas/flutter_body_atlas.dart';
import 'package:force_trace/features/library/widgets/muscle_map.dart';

void main() {
  group('muscle atlas mapping', () {
    test('pectorals map to the chest group', () {
      final muscles = muscleInfosForTarget('pectorals');
      expect(muscles, isNotEmpty);
      expect(muscles.every((m) => m.group == MuscleGroup.chest), isTrue);
    });

    test('quads map to rectus femoris and vastus heads', () {
      final ids = muscleInfosForTarget('quads').map((m) => m.id).toSet();
      expect(ids, contains('rectus_femoris_l'));
      expect(ids, contains('vastus_lateralis_r'));
    });

    test('biceps and triceps use the specific arm heads', () {
      final biceps = muscleInfosForTarget('biceps').map((m) => m.id);
      final triceps = muscleInfosForTarget('triceps').map((m) => m.id);
      expect(biceps.every((id) => id.startsWith('biceps_brachii')), isTrue);
      expect(triceps.every((id) => id.startsWith('triceps_brachii')), isTrue);
    });

    test('upper back spans traps, lats and infraspinatus', () {
      final ids = muscleInfosForTarget('upper back').map((m) => m.id).toSet();
      expect(ids.any((id) => id.startsWith('trapezius')), isTrue);
      expect(ids.any((id) => id.startsWith('latissimus')), isTrue);
      expect(ids.any((id) => id.startsWith('infraspinatus')), isTrue);
    });

    test('targets without an atlas layer are intentionally empty', () {
      expect(muscleInfosForTarget('cardiovascular system'), isEmpty);
      expect(muscleInfosForTarget('lower back'), isEmpty);
      expect(muscleInfosForTarget('hip flexors'), isEmpty);
    });
  });
}
