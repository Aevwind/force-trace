// Chooses the real ML Kit adapter on Android/iOS and a no-op adapter on web.
export 'vision_pose_source_stub.dart'
    if (dart.library.io) 'vision_pose_source_io.dart';
