import 'dart:math';
import 'dart:typed_data';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/clock.dart';
import '../core/id_generator.dart';
import '../data/app_repository.dart';
import '../data/image_store.dart';
import '../services/sound_service.dart';

/// Opened before the first frame and supplied by `main()`.
final appRepositoryProvider = Provider<AppRepository>(
  (ref) => throw StateError('appRepositoryProvider must be overridden'),
);

final imageStoreProvider = Provider<ImageStore>((ref) => createImageStore());

final soundServiceProvider = Provider<SoundService>(
  (ref) => AssetSoundService(),
);

final clockProvider = Provider<Clock>((ref) => DateTime.now);

final randomProvider = Provider<Random>((ref) => Random());

final idGeneratorProvider = Provider<IdGenerator>((ref) => IdGenerator());

/// Photo bytes of a parent-made card, cached per image id.
final cardImageProvider = FutureProvider.family<Uint8List?, String>(
  (ref, imageId) => ref.watch(imageStoreProvider).load(imageId),
);
